bash build.sh;
rm -rf ~/.local/share/craftos-pc/computer/62;
mkdir ~/.local/share/craftos-pc/computer/62;
cp out/krnl.lua ~/.local/share/craftos-pc/computer/62/startup.lua
mkdir ~/.local/share/craftos-pc/computer/62/bin/
cp init.lua ~/.local/share/craftos-pc/computer/62/bin/init.lua
craftos -i 62