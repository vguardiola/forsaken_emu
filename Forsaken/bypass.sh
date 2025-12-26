#!/usr/bin/bash

logFile="${3}/bypasss.log"
gamePath=$1 #"~/ES-DE/roms/3do/3D Atlas (Europe).zip"
romsDir=$2 #"~/ES-DE/roms"
bypassDir=$3 #"~/ES-DE/Emulators/Forsaken"
gameName=$(basename "${gamePath}" | xargs printf '%b\n')
platformName=$(dirname "${gamePath}" | sed "s|${romsDir}/||g" | awk -F / '{print $1}' )
downloadTempDir="${romsDir}/_temp/${platformName}/"
downloadForeverDir="${romsDir}/_forever/${platformName}/"
configFile="${bypassDir}/config.json"
url=""
size=0

debug() {
 echo "$1" >> ${logFile}
}

findGameUrl() {
    data=$(grep "${gameName}" "${bypassDir}/lists/${platformName}.txt");
    url=$(echo ${data} | awk -F'*' '{print $1}' | awk -F'=' '{print $2}');
    url=${url% }
    size=$(echo ${data} | awk -F'*' '{print $2}' | awk -F'=' '{print $2}' | awk '{print $1}');
}

existRom() {
    if [ -f "${downloadForeverDir}${gameName}" ]; then
    return 1;
    fi
    if [ -f "${downloadTempDir}${gameName}" ]; then
    return 2;
    fi
    return 0;
}

downloadRom() {
    local romFile="${downloadTempDir}${gameName}";
    mkdir -p "${downloadTempDir}";
    wget -q --show-progress -O "${romFile}" "${url}" 2>&1 | awk '{print $7}' | zenity --progress --title="Downloading ${gameName}" --auto-close --percentage=0
    if [ $? -ne 0 ]; then
        rm -f "${romFile}"
        exit 1
    fi
}

readConfigForPlatformAcceptZipFiles() {
    if [ -f "$configFile" ]; then
        echo "$(jq -r --arg system "$platformName" '.emulators[] | select(.system == $system) | .acceptZipFiles | if type=="array" then .[0] else . end' "$configFile")"
    fi
}

readConfigForPlatformfileExtension() {
    if [ -f "$configFile" ]; then
        echo "$(jq -r --arg system "$platformName" '.emulators[] | select(.system == $system) | .fileExtension | if type=="array" then .[0] else . end' "$configFile")"
    fi
}

runEmulator() {
    local rom=$1
    local romPath=$(dirname "${rom}")
    local romName=$(basename "${rom}")

    local emuCmd=$(readConfigForPlatformCommand)
    local fullCommand="${bypassDir}/${emuCmd}"

    local acceptZipFiles=$(readConfigForPlatformAcceptZipFiles)
    if [ "$acceptZipFiles" = false ]; then
        7z x -bsp2 -y "${rom}" -o"${romPath}" | \
        zenity --progress --title="Extracting ${gameName}" --auto-close --no-cancel --percentage=0
    fi

    case "$platformName" in
        pinballfx3) #don't work at this moment
            rom=$(echo "-table_${romName%.*}" | tr " " "_")
            full_command="${emuCmd}"
        ;;
        *)
        ;;
    esac

    if [ -n "$emuCmd" ]; then
        local safeRom=$(printf %q "${rom}")

        debug "emu_cmd: ${fullCommand} ${safeRom}"
        eval "${fullCommand} ${safeRom}"
    else
        zenity --error --text="No emulator configuration found for platform: ${platformName}"
    fi
}

askSaveRom() {
    zenity --question --title="Save Rom" --text="Do you want to save this rom?" --ok-label="Save" --cancel-label="Discard" --default-cancel
    if [ $? -eq 0 ]; then
        mkdir -p "${downloadForeverDir}"
        mv "${downloadTempDir}${gameName}" "${downloadForeverDir}${gameName}"
    fi
}

readConfigForPlatformCommand() {
    if [ -f "$configFile" ]; then
        echo "$(jq -r --arg system "$platformName" '.emulators[] | select(.system == $system) | .command | if type=="array" then .[0] else . end' "$configFile")"
    fi
}

existRom
exist=$?
case $exist in
    1)
        runEmulator "${downloadForeverDir}${gameName}"
        ;;
    2)
        runEmulator "${downloadTempDir}${gameName}"
        askSaveRom
        ;;
    *)
        findGameUrl
        downloadRom
        runEmulator "${downloadTempDir}${gameName}"
        askSaveRom
        ;;
esac
