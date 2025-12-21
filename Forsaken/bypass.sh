#!/usr/bin/bash

logFile="${3}/bypasss.log"
romsDir=$2 #/mnt/data1/ES-DE/roms
bypassDir=$3 #/home/victor/ES-DE/Emulators/Forsaken
gamePath=$1 #/mnt/data1/ES-DE/roms/3do/3D Atlas (Europe).zip
gameName=$(basename "${gamePath}" | xargs printf '%b\n')
platformName=$(dirname "${gamePath}" | sed "s|${romsDir}/||g" | awk -F / '{print $1}' )
downloadTempDir="${romsDir}/TEMP/${platformName}/"
downloadForeverDir="${romsDir}/FOREVER/${platformName}/"

url=""
size=0


debug() {
 echo "$1" >> ${logFile}
}

debug $1 $2 $3
findGameUrl() {
    data=$(grep "${gameName}" "${bypassDir}/lists/${platformName}.txt");
    url=$(echo ${data} | awk -F'*' '{print $1}' | awk -F'=' '{print $2}');
    url=${url% }
    size=$(echo ${data} | awk -F'*' '{print $2}' | awk -F'=' '{print $2}' | awk '{print $1}');
    debug $url
}

existRom() {
debug "${downloadForeverDir}${gameName}"
    if [ -f "${downloadForeverDir}${gameName}" ]; then
    return 1;
    fi
debug "${downloadTempDir}${gameName}"
    if [ -f "${downloadTempDir}${gameName}" ]; then
    return 2;
    fi
    return 0;
}

downloadRom() {
    local romFile="${downloadTempDir}${gameName}";
    mkdir -p "${downloadTempDir}";
    wget -q --show-progress -O "${romFile}" "${url}";
}


runEmulator() {
    local rom=$1
    local romPath=$(dirname "${rom}")
    debug "7z x \"${rom}\" -o\"${romPath}\""
    7z x "${rom}" -o"${romPath}"
    debug $?
#     debug "${bypassDir}/../RetroArch.AppImage -L fuse_libretro.so \"${rom%zip}cue\""
    ${bypassDir}/../RetroArch.AppImage -L puae2021_libretro.so "${rom}"
}

existRom
exist=$?
case $exist in
    1)
        # runEmulator "${downloadForeverDir}${gameName}"
        debug "exist on FOREVER"
        runEmulator "${downloadForeverDir}${gameName}"
        ;;
    2)
        # runEmulator "${downloadTempDir}${gameName}"
        debug "exist on TEMP"
        runEmulator "${downloadTempDir}${gameName}"
        ;;
    *)
        debug "No exist"
        findGameUrl
        downloadRom
        runEmulator "${downloadTempDir}${gameName}"
        ;;
esac

downloadRom
