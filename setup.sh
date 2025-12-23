#!/bin/bash

#set -e

downloadList() {
    if [ ! -d "./lists" ]; then
        git clone https://github.com/Arley4d/Arley4dBypass.git ./lists
    fi
    cd ./lists
    git pull
    cd ../
}

generateFakeRoms() {
    for fileName in ./lists/*.txt; do
        platformName=$(echo "${fileName%.txt}")
        subfolder=""
        if [[ "$platformName" == *" "* ]]; then
            subfolder=$(echo "${platformName#* *}" | tr -d '()[]')
            platformName=$(echo "$platformName" | awk -F ' ' '{print $1}')
            path="./roms/${platformName}/${subfolder}"  
        else
            path="./roms/${platformName}"
        fi
        mkdir -p "${path}"
        echo "=== ${platformName} : ${subfolder} ==="
        readarray -t lines < "${fileName}"
        for game in "${lines[@]}"; do
            game=$(echo "${game}" | awk -F '=' '{print $1}')
            touch "${path}/${game}"
        done
    done
}

downloadEmulators() {
    wget -q --show-progress https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage -O ./DuckStation.AppImage
    wget -q --show-progress https://github.com/EKA2L1/EKA2L1/releases/download/continous/EKA2L1-Linux-x86_64.AppImage -O ./EKA2L1.AppImage
    wget -q --show-progress https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1524979887/VLC_media_player-3.0.11.1-x86_64.AppImage -O ./VLC.AppImage 
    wget -q --show-progress https://github.com/DCurrent/openbor/releases/download/v7533/OpenBOR-Linux-x86-v4.0.Build.7533.AppImage -O ./OpenBOR.AppImage  
    wget -q --show-progress https://github.com/PCSX2/pcsx2/releases/download/v2.4.0/pcsx2-v2.4.0-linux-appimage-x64-Qt.AppImage -O ./pcsx2-qt.AppImage  
    wget -q --show-progress https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-f81a5a5cb1cd30678061bff31b2156090abe2a57/rpcs3-v0.0.38-18544-f81a5a5c_linux64.AppImage -O ./rpcs3.AppImage 
    wget -q --show-progress https://github.com/m59peacemaker/mupdf-appimage/releases/download/1.18.0/MuPDF-1.18.0-x86_64.AppImage -O ./mupdf.AppImage
    wget -q --show-progress https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/1.3.3/ryujinx-1.3.3-x64.AppImage -O ./ryujinx.AppImage
    wget -q --show-progress https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/download/4cbcae5%402025-12-15_1765783676/Xenia_Canary-4cbcae5-anylinux-x86_64.AppImage -O ./xenia.AppImage
    wget -q --show-progress https://github.com/xemu-project/xemu/releases/download/v0.8.121/xemu-v0.8.121-x86_64.AppImage -O ./xemu.AppImage
    wget -q --show-progress https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-5.1.3.10/qBittorrent-Enhanced-Edition-x86_64.AppImage -O ./qbittorrent.AppImage

    chmod a+x ./*.AppImage
    wget -q --show-progress https://buildbot.libretro.com/stable/1.22.2/linux/x86_64/RetroArch_cores.7z -O RetroArch_cores.7z
    7z x ./RetroArch_cores.7z
    mkdir -p ~/.config/retroarch/cores
    cp -r ./RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/cores/* ~/.config/retroarch/cores
    rm -rf ./RetroArch-Linux-x86_64
    rm ./RetroArch_cores.7z
}

checkSystemApps() {
    #has /z installed
    if ! command -v 7z &> /dev/null; then
        echo "7z could not be found, please install it to continue"
        exit 1
    fi
    #has wget installed
    if ! command -v wget &> /dev/null; then
        echo "wget could not be found, please install it to continue"
        exit 1
    fi
    #has git installed
    if ! command -v git &> /dev/null; then
        echo "git could not be found, please install it to continue"
        exit 1
    fi
    #has retroarch installed
    if ! command -v retroarch &> /dev/null; then
        echo "RetroArch could not be found, please install it to continue"
        exit 1
    fi
    #has zenity installed
    if ! command -v zenity &> /dev/null; then
        echo "zenity could not be found, please install it to continue"
        exit 1
    fi
     #has jq installed
    if ! command -v jq &> /dev/null; then
        echo "jq could not be found, please install it to continue"
        exit 1
    fi
}

checkSystemApps
read -p "Do you want download Emulators? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Downloading Emulators..."
    downloadEmulators
fi
echo
cd ./Forsaken
downloadList
mkdir -p ./roms/_temp
mkdir -p ./roms/_forever
read -p "Do you want generate Fake Roms? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Generating Fake Roms..."
    generateFakeRoms
fi
cp ./es_systems.xml ~/ES-DE/custom_systems/es_systems.xml
sed -i 's|ROMDirectory=""|ROMDirectory="~/ES-DE/Emulators/Forsaken/roms"|' ~/ES-DE/settings/es_settings.xml
echo "Done"
cd ..