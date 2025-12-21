#!/bin/bash

set -e

downloadList() {
    if [ ! -d "./Forsaken/lists" ]; then
        git clone https://github.com/Arley4d/Arley4dBypass.git ./Forsaken/lists
    fi
    cd ./Forsaken/lists
    git pull
    cd ../../
}

generateFakeRoms() {
    mkdir -p ./Forsaken/roms
    cd ./Forsaken/lists
    for platform in *.txt; do
        mkdir -p ../roms/"${platform%.txt}"
        echo "${platform%.txt}"
        readarray -t lines < "${platform}"
        for game in "${lines[@]}"; do
            game=$(echo "${game}" | awk -F '=' '{print $1}')
            touch ../roms/"${platform%.txt}"/"${game}"
        done
    done
    cd ../../
}

downloadEmulators() {
    wget -q --show-progress https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage -O ./DuckStation.AppImage
    wget -q --show-progress https://github.com/EKA2L1/EKA2L1/releases/download/continous/EKA2L1-Linux-x86_64.AppImage -O ./EKA2L1.AppImage
    wget -q --show-progress https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1524979887/VLC_media_player-3.0.11.1-x86_64.AppImage -O ./VLC.AppImage 
    wget -q --show-progress https://github.com/DCurrent/openbor/releases/download/v7533/OpenBOR-Linux-x86-v4.0.Build.7533.AppImage -O ./OpenBOR.AppImage  
    wget -q --show-progress "https://release-assets.githubusercontent.com/github-production-release-asset/15379620/8e622946-386b-47d3-bc3b-fd7a0c658be6?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T21%3A23%3A23Z&rscd=attachment%3B+filename%3Dpcsx2-v2.4.0-linux-appimage-x64-Qt.AppImage&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T20%3A22%3A46Z&ske=2025-12-21T21%3A23%3A23Z&sks=b&skv=2018-11-09&sig=08GYCEBDGbZiwfggQb1nNdZ%2BnQusYujv5UNXKc9%2Fa4M%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjM1MzY2NywibmJmIjoxNzY2MzUwMDY3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.82opFXhlm1JPKD6_aAUsY0xawVYCLTdygN2AnhBMom0&response-content-disposition=attachment%3B%20filename%3Dpcsx2-v2.4.0-linux-appimage-x64-Qt.AppImage&response-content-type=application%2Foctet-stream" -O ./pcsx2-qt.AppImage  
    wget -q --show-progress "https://release-assets.githubusercontent.com/github-production-release-asset/162045852/7b4d2192-a435-4766-9930-93c9ce837618?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T21%3A30%3A16Z&rscd=attachment%3B+filename%3Drpcs3-v0.0.38-18543-2fb69732_linux64.AppImage&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2225-12-21T20%3A29%3A26Z&ske=2025-12-21T21%3A30%3A16Z&sks=b&skv=2018-11-09&sig=eHyhqdZLNDGMB%2FULlsF22sVlJAX5AxvIn7mvlVgJapw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjM1MTk2MCwibmJmIjoxNzY2MzUwMTYwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.hBp4ERp-aS7W_Dv1GKoIlyPyTUt9Mdyd7l8xq5Go35M&response-content-disposition=attachment%3B%20filename%3Drpcs3-v0.0.38-18543-2fb69732_linux64.AppImage&response-content-type=application%2Foctet-stream" -O ./rpcs3.AppImage 
    wget -q --show-progress https://github.com/m59peacemaker/mupdf-appimage/releases/download/1.18.0/MuPDF-1.18.0-x86_64.AppImage -O ./mupdf.AppImage
    wget -q --show-progress https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/1.3.3/ryujinx-1.3.3-x64.AppImage -O ./ryujinx.AppImage
    wget -q --show-progress https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/download/4cbcae5%402025-12-15_1765783676/Xenia_Canary-4cbcae5-anylinux-x86_64.AppImage -O ./xenia.AppImage
    wget -q --show-progress https://github.com/xemu-project/xemu/releases/download/v0.8.121/xemu-v0.8.121-x86_64.AppImage -O ./xemu.AppImage

    chmod a+x ./

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
}

checkSystemApps
downloadList

read -p "Do you want download Emulators? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Downloading Emulators..."
    downloadEmulators
fi
echo
read -p "Do you want generate Fake Roms? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Generating Fake Roms..."
    generateFakeRoms
fi
mkdir -p ./Forsaken/roms/TEMP
mkdir -p ./Forsaken/roms/FOREVER
cp ./Forsaken/es_systems.xml ~/ES-DE/custom_systems/es_systems.xml
sed -i 's|ROMDirectory=""|ROMDirectory="~/ES-DE/Emulators/Forsaken/roms"|' ~/ES-DE/settings/es_settings.xml