#!/bin/bash 

installPackages=("craft" "rednet" "brainfuck" "audm")

bash fullbuild.sh
rm -rf ~/.local/share/craftos-pc/computer/120/
mkdir ~/.local/share/craftos-pc/computer/120
cp build/* ~/.local/share/craftos-pc/computer/120/ -r
echo "o shell.lua" > ~/.local/share/craftos-pc/computer/120/services/enabled/login
mkdir ~/.local/share/craftos-pc/computer/120/config/arc
touch ~/.local/share/craftos-pc/computer/120/config/arc/devenv.lock
echo '{"theme": {"fg": "white","bg": "black"},"skipPrompt": true,"defargs": "--printLog","autoUpdate": false}' > ~/.local/share/craftos-pc/computer/120/config/aboot
for i in "${installPackages[@]}"
do
    echo RSyncing package: $i
    rsync -rI repo/$i/out/ ~/.local/share/craftos-pc/computer/120/
done
touch lockfile
( craftos --gui -i 120; rm lockfile )