# Build arcos
python build.py clean
python build.py whole

# Add cellui to build
cd src/cellui
haxe cellui.hxml
cp out/cellui.lua ../../build/system/apis/cellui.lua
cd ../..

# Add kernel to build
cd src/kernelcandidates/syne
bash build.sh
cp out/krnl.lua ../../../build/system/krnl.lua
cd ../../..

# Put build into the package
python archivebuild.py
