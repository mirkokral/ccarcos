haxe bios.hxml
haxe kernel.hxml
cd out
bash ../ensed.sh krnl.lua
bash ../ensed.sh bios.lua
mv krnlb.lua krnl.lua
mv biosb.lua bios.lua
