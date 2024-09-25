#!/bin/bash 

installPackages=("craft" "rednet")

bash fullbuild.sh
rm -rf ~/.local/share/craftos-pc/computer/120/
mkdir ~/.local/share/craftos-pc/computer/120
cp build/* ~/.local/share/craftos-pc/computer/120/ -r
echo "o shell.lua" > ~/.local/share/craftos-pc/computer/120/services/enabled/login
echo '{"theme": {"fg": "white","bg": "black"},"skipPrompt": false,"defargs": "--fileLog","autoUpdate": false}' > ~/.local/share/craftos-pc/computer/120/config/aboot
for i in "${installPackages[@]}"
do
    echo RSyncing package: $i
    rsync -rI repo/$i/ ~/.local/share/craftos-pc/computer/120/
done
touch lockfile
( craftos --gui -i 120; rm lockfile )
# while [ -f lockfile ];
# do
#     clear
#     cat ~/.local/share/craftos-pc/computer/120/system/log.txt
#     sleep 0.1
# done
