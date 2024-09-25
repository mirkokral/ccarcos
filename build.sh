# Build arcos
python build.py clean
python build.py whole

# Add cellui to build
cd cellui
haxe cellui.hxml
cp out/cellui.lua ../build/system/apis/cellui.lua
cd ..

# Put build into the package
python archivebuild.py
