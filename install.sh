#!/usr/bin/env bash

mkdir -p ~/ES-DE/
wget -q --show-progress https://github.com/vguardiola/forsaken_emu/archive/refs/heads/main.zip -O /tmp/forsaken_emu.zip
7z x -bsp2 -y -o/tmp/ /tmp/forsaken_emu.zip
rm -f /tmp/forsaken_emu.zip
mv /tmp/forsaken_emu-main ~/ES-DE/emulators/
cd ~/ES-DE/emulators/ || exit
./setup.sh
