if [ ! -e archivedpkgs ]; then
    mkdir archivedpkgs
fi
rm archivedpkgs/*
cd repo
python build.py
cd ..