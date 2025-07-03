#!/bin/bash 

installPackages=("base")

wget https://github.com/MCJack123/craftos2/releases/latest/download/CraftOS-PC.x86_64.AppImage -O craftospc.AppImage
chmod +x craftospc.AppImage

bash fullbuild.sh
rm -rf ~/.local/share/craftos-pc/computer/120/
mkdir -p ~/.local/share/craftos-pc/computer/120
for i in "${installPackages[@]}"
do
    echo RSyncing package: $i
    rsync -rI repo/$i/out/ ~/.local/share/craftos-pc/computer/120/
done
touch lockfile
( ./craftospc.AppImage --gui -i 120; rm lockfile )