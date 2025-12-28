#!/usr/bin/env bash

wget https://github.com/vguardiola/forsaken_emu/archive/refs/heads/main.zip -O forsaken_emu.zip

7z x -bsp2 -y -o./ ./forsaken_emu.zip
rm -f ./forsaken_emu.zip

mkdir -p ~/ES-DE/
mv ./forsaken_emu-main ./ES-DE/emulators/
cd ./ES-DE/emulators/ || exit
./setup.sh
