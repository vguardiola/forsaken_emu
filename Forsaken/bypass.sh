#!/usr/bin/env bash

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

debug() {
 echo "$1" >> "${logFile}"
}

findGameUrl() {
    url=$(head -n 1 < "${gamePath}");
    url=${url% }
    if [ -z "$url" ]; then
        zenity --error --text="Rom not found on list, it's a programmer problem"
        exit 1
    fi
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
    if [[ $url == *"www.mediafire.com"* ]]; then
        mediafire-dl -o "${romFile}" "${url}" | zenity --progress --title="Downloading ${gameName}" --auto-close --percentage=0
    else
        wget -q --show-progress -O "${romFile}" "${url}" 2>&1 | awk '{print $7}' | zenity --progress --title="Downloading ${gameName}" --auto-close --percentage=0
    fi

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

readConfigForPlatformFileExtension() {
    if [ -f "$configFile" ]; then
        echo "$(jq -r --arg system "$platformName" '.emulators[] | select(.system == $system) | .fileExtension | if type=="array" then .[0] else . end' "$configFile")"
    fi
}

runEmulator() {
    local rom=$1
    local romPath=$(dirname "${rom}")
    local romName=$(basename "${rom}")
    local romExtension=${rom##*.}

    local emuCmd=$(readConfigForPlatformCommand)
    local fullCommand="${bypassDir}/${emuCmd}"

    local acceptZipFiles=$(readConfigForPlatformAcceptZipFiles)
    if [ "$acceptZipFiles" = false ]; then
        if [ "$romExtension" = "zip" ] || [ "$romExtension" = "7z" ]; then
            7z x -bsp2 -y "${rom}" -o"${romPath}" | \
            zenity --progress --title="Extracting ${gameName}" --auto-close --no-cancel --percentage=0
            rom=$(7z l -ba "${rom}" | grep -vF 'D....' | grep -oP '(?<=^.{53}).*')
            rom="${romPath}/${rom}"
        fi
        if [ "$romExtension" = "rar" ]; then
            zenity --info --text="Rar decompresion is underdevlopemnt"
            exit 1
        fi
    fi

    case "$platformName" in
        pinballfx3)
            rom=$(echo "-table_${romName%.*}" | tr " " "_")
            fullCommand="${emuCmd}"
        ;;
        *)
        ;;
    esac

    if [ -n "$emuCmd" ]; then
        local safeRom=$(printf %q "${rom}")

        debug "emuCmd: ${fullCommand} ${safeRom}"
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

cleanTempDir() {
    rm -rf "${downloadTempDir}/*"
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
        cleanTempDir
        findGameUrl
        downloadRom
        runEmulator "${downloadTempDir}${gameName}"
        askSaveRom
        ;;
esac
