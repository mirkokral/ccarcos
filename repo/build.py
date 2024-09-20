import os, os.path
import arclib
import sys
files = os.listdir('.')
# print(files)
for erm in files:
    if os.path.isdir(erm):
        with open(erm + "/index", "w") as f:
            
            outfile = ""
            for root, dirs, files in os.walk(erm):
                # print(root, files)
                root = '/'.join(root.split("/")[1:])
                if root != "":
                    outfile = outfile + "d>" + root + "\n"
                    for wha in files:
                        outfile = outfile + "f>" + root + "/" + wha + "\n"
            f.write(outfile)
        print(erm)
        with open(f"../archivedpkgs/{erm}.arc", "wb") as f:
            dirs = []
            files = []
            for p2, dirnames, filenames in os.walk(f"{erm}/"):
                a = len(erm)+1
                dirpath = p2[a:]
                for name in dirnames:
                    if dirpath + "/" + name not in dirs:
                        dirs.append(dirpath + "/" + name)

                for name in filenames:
                    if dirpath + "/" + name not in files:
                        with open(p2 + "/" + name, "rb") as f2:
                            # print(name)
                            files.append([dirpath + "/" + name, f2.read()])

            built = []
            for aaa in dirs: built.append([aaa, None])
            for aaa in files: built.append([aaa[0], aaa[1]])
            f.write(arclib.archive(built))
