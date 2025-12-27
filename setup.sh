#!/bin/bash

downloadList() {
    rm -rf ./lists
    wgetAndProgressDialog https://github.com/vguardiola/romlists/archive/refs/heads/main.zip ./lists.zip
    7z x -bsp2 -y -o./ ./lists.zip
    rm -f ./lists.zip
    mv ./romlists-main ./lists
}

generateFakeRoms() {
    local count=0
    local total=0
    total=$(ls ./lists/*.txt | wc -l)
    cd lists
    for fileName in ./*.txt; do
        platformName=$(echo "${fileName%.txt}")
        path="../roms/$(echo "${platformName}" | tr "_" "/")"
        mkdir -p "${path}"
        echo "# ${platformName}"
        readarray -t lines < "${fileName}"
        for game in "${lines[@]}"; do
            game=$(echo "${game}" | awk -F '=' '{print $1}')
            touch "${path}/${game}"
        done
        count=$((count + 1))
        echo $((count * 100 / total))
    done
}

wgetAndProgressDialog() {
    local url="$1"
    local output="$2"
    wget -q --show-progress "${url}" -O "${output}" 2>&1 | awk '{print $7}' | zenity --progress --title="Downloading ${output#./}" --auto-close --percentage=0 --no-cancel --width=640 --height=220 2>/dev/null
}

downloadEmulators() {
    wgetAndProgressDialog https://github.com/stenzek/duckstation/releases/download/latest/DuckStation-x64.AppImage ./duckstation.AppImage
    wgetAndProgressDialog https://github.com/EKA2L1/EKA2L1/releases/download/continous/EKA2L1-Linux-x86_64.AppImage ./eka2l1.AppImage
    wgetAndProgressDialog https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1524979887/VLC_media_player-3.0.11.1-x86_64.AppImage ./vlc.AppImage
    wgetAndProgressDialog https://github.com/DCurrent/openbor/releases/download/v7533/OpenBOR-Linux-x86-v4.0.Build.7533.AppImage ./openbor.AppImage
    wgetAndProgressDialog https://github.com/PCSX2/pcsx2/releases/download/v2.4.0/pcsx2-v2.4.0-linux-appimage-x64-Qt.AppImage ./pcsx2.AppImage
    wgetAndProgressDialog https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-f81a5a5cb1cd30678061bff31b2156090abe2a57/rpcs3-v0.0.38-18544-f81a5a5c_linux64.AppImage ./rpcs3.AppImage
    wgetAndProgressDialog https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/1.3.3/ryujinx-1.3.3-x64.AppImage ./ryujinx.AppImage
    wgetAndProgressDialog https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/download/4cbcae5%402025-12-15_1765783676/Xenia_Canary-4cbcae5-anylinux-x86_64.AppImage ./xenia.AppImage
    wgetAndProgressDialog https://github.com/xemu-project/xemu/releases/download/v0.8.121/xemu-v0.8.121-x86_64.AppImage ./xemu.AppImage
    wgetAndProgressDialog https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-5.1.3.10/qBittorrent-Enhanced-Edition-x86_64.AppImage ./qbittorrent.AppImage
    wgetAndProgressDialog https://github.com/koreader/koreader/releases/download/v2025.10/koreader-appimage-x86_64-v2025.10.AppImage ./pdf.AppImage
    wgetAndProgressDialog https://github.com/Vita3K/Vita3K/releases/download/continuous/Vita3K-x86_64.AppImage ./vita3k.AppImage
    wgetAndProgressDialog https://github.com/shadps4-emu/shadPS4/releases/download/v.0.13.0/shadps4-linux-sdl-0.13.0.zip ./shadps4.zip
    wgetAndProgressDialog https://github.com/cemu-project/Cemu/releases/download/v2.6/Cemu-2.6-x86_64.AppImage ./cemu.AppImage
    wgetAndProgressDialog https://github.com/pkgforge-dev/Dolphin-emu-AppImage/releases/download/2509%402025-12-15_1765785200/Dolphin_Emulator-2509-anylinux.squashfs-x86_64.AppImage ./dolphin.AppImage
    wgetAndProgressDialog https://github.com/Portable-Linux-Apps/ruffle-AppImage/releases/download/nightly-2025-12-22%402025-12-22_1766420590/Ruffle-nightly-2025-12-22-x86_64.AppImage ./ruffle.AppImage
    wgetAndProgressDialog https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch.7z ./RetroArch.7z
    wgetAndProgressDialog https://buildbot.libretro.com/stable/1.22.2/linux/x86_64/RetroArch_cores.7z ./RetroArch_cores.7z
    wgetAndProgressDialog https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download ./es-de.AppImage
    wgetAndProgressDialog https://git.citron-emu.org/Citron/Emulator/releases/download/0.11.0/Citron_stable_0.11.0_linux.AppImage ./citron.AppImage

    7z x ./shadps4.zip -o./ && rm ./shadps4.zip && mv Shadps4*.AppImage ./shadps4.AppImage
    7z x ./RetroArch.7z -o./ && rm ./RetroArch.7z
    7z x ./RetroArch_cores.7z -o./ && rm ./RetroArch_cores.7z
    cp -r ./RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* ~/.config/retroarch/
    mv ./RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage ./retroarch.AppImage
    rm -rf ./RetroArch-Linux-x86_64
    chmod a+x ./*.AppImage
}

installCommandPerDistribution() {
    case $(cat /etc/*-release | grep -E '^ID_LIKE=' | cut -d'=' -f2) in
        debian|ubuntu)
            sudo apt update && sudo apt install -y "$@"
            ;;
        fedora)
            sudo dnf install -y "$@"
            ;;
        arch)
            sudo pacman -S --noconfirm "$@"
            ;;
        gentoo)
            sudo emerge "$@"
            ;;
        *)
            echo "Unsupported distribution"
            exit 1
            ;;
    esac
}

checkSystemApps() {
    #pipx install git+https://github.com/Juvenal-Yescas/mediafire-dl
    local neededApps=("7z" "wget" "unrar" "zenity" "jq" "mediafire-dl")
    local neededAppsNotFound=()
    for app in "${neededApps[@]}"; do
        if ! command -v "$app" &> /dev/null; then
            neededAppsNotFound+=("$app ")
        fi
    done
    if [ "${#neededAppsNotFound[@]}" -gt 0 ]; then
        zenity --question --text="The following applications are needed but not installed: ${neededAppsNotFound[*]}\nDo you want to install them?" --width=640 --height=480
        if [ $? -eq 0 ]; then
           ( installCommandPerDistribution "${neededAppsNotFound[*]}" )
        else
            exit 1
        fi
    fi
}

startDialog() {
    choice=$(zenity --info --text="Welcome to Forsaken Emulator Setup" \
        --icon="./Forsaken/icon.png" --width=640 --height=480 \
        --extra-button="Generate Roms" \
        --extra-button="Download Emulators" 2>/dev/null
        )
    case $choice in
        "Generate Roms")
            downloadList
            generateFakeRoms | zenity --progress --title="Generating Roms" --auto-close --percentage=0 --no-cancel --width=640 --height=220 2>/dev/null
            startDialog
            ;;
        "Download Emulators")
            downloadEmulators
            startDialog
            ;;
        *)
            return
            ;;
    esac
}

checkSystemApps
mkdir -p ./roms/_temp
mkdir -p ./roms/_forever
mkdir -p ~/.config/retroarch/
cp ./Forsaken/es_systems.xml ~/ES-DE/custom_systems/es_systems.xml
sed -i 's|<string name="ROMDirectory" value=""|<string name="ROMDirectory" value="~/ES-DE/emulators/roms"|' ~/ES-DE/settings/es_settings.xml
startDialog
