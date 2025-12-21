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
    echo "${game}"
    touch ./roms/"${platform%.txt}"/"${game}"
  done
 done
}

downloadList
generateFakeRoms