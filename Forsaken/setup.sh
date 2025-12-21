#!/bin/bash

downloadList() {
    if [ ! -d "./lists" ]; then
        git clone https://github.com/Arley4d/Arley4dBypass.git ./lists
    fi
    cd ./lists
    git pull
    cd ../
}

generateFakeRoms() {
 mkdir -p ./roms

 for platform in `ls ./lists`; do
  mkdir -p ./roms/"${platform%.txt}"
  readarray -t lines < ./lists/${platform}
  echo "${platform%.txt}"
  for game in "${lines[@]}"; do
    game=$(echo "${game}" | awk -F '=' '{print $1}')
    touch ./roms/"${platform%.txt}"/"${game}"
  done
 done
}

downloadEmulators() {
    wget -q --show-progress https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage -O ../DuckStation.AppImage
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
downloadEmulators
#generateFakeRoms