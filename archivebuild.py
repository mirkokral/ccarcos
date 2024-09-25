import os, repo.arclib

with open("archivedpkgs/base.arc", "wb") as f:
    dirs = []
    files = []
    for p2, dirnames, filenames in os.walk("build/"):
        dirpath = p2[6:]
        for name in dirnames:
            if dirpath + "/" + name not in dirs:
                dirs.append(dirpath + "/" + name)

        for name in filenames:
            if dirpath + "/" + name not in files:
                if dirpath == "" and name == "objList.txt": continue
                with open(p2 + "/" + name, "rb") as f2:
                    # print(name)
                    files.append([dirpath + "/" + name, f2.read()])

    built = []
    for i in dirs: built.append([i, None])
    for i in files: built.append([i[0], i[1]])
    f.write(repo.arclib.archive(built))
