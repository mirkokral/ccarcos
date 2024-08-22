import os, arclib

with open("archived.arc", "wb") as f:
    dirs = []
    files = []
    for dirpath, dirnames, filenames in os.walk("."):
        for name in dirnames:
            if dirpath + "/" + name not in dirs:
                dirs.append(dirpath + "/" + name)

        for name in filenames:
            if dirpath + "/" + name not in files:
                with open(dirpath + "/" + name, "rb") as f2:
                    print(name)
                    files.append([dirpath + "/" + name, f2.read()])

    print(dirs, files)
    built = []
    for i in dirs: built.append([i, None])
    for i in files: built.append([i[0], i[1]])
    f.write(arclib.archive(built))
