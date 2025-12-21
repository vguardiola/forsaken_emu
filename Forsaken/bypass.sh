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
    wget --progress=bar:force:noscroll -O "${romFile}" "${url}" 2>&1 | \
    tr '\r' '\n' | \
    grep --line-buffered "%" | \
    sed -u -r 's/.* ([0-9]+)%.* ([0-9.,]+ [KMG]B\/s).*/\1\n# Downloading at \2/' | \
    zenity --progress --title="Downloading ${gameName}" --auto-close --percentage=0
    
    if [ $? -ne 0 ]; then
        rm -f "${romFile}"
        exit 1
    fi
}


runEmulator() {
    local rom=$1
    local romPath=$(dirname "${rom}")
    7z x -bsp1 -y "${rom}" -o"${romPath}" | \
    tr '\r' '\n' | \
    sed -u -n 's/.*\ \([0-9]\+\)%.*/\1/p' | \
    zenity --progress --title="Extracting ${gameName}" --auto-close --no-cancel --percentage=0
    ${bypassDir}/../RetroArch.AppImage -L puae2021_libretro.so "${rom}"
}

askSaveRom() {
    zenity --question --title="Save Rom" --text="Do you want to save this rom?"
    if [ $? -eq 0 ]; then
        mv "${downloadTempDir}${gameName}" "${downloadForeverDir}${gameName}"
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
