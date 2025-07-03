haxe syne.hxml
if [ -e out ]; then
    rm -rf out;
fi

mkdir -p out/system
mkdir -p out/config
cp passwd out/config
cp krnl.lua out/system