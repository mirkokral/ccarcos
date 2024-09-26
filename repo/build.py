import os, os.path
import shutil
import arclib
import sys
import json
files = os.listdir('.')
index = {}
# print(files)
class InvalidPackageError(Exception):...
for erm in files:
    if os.path.isdir(erm) and not erm.startswith("__"):
        cpi = {}
        if os.path.exists(erm + "/build.sh") and os.path.isfile(erm + "/build.sh"):
            os.system(f'bash -c "cd {erm}; bash build.sh; cd .."');
            if not os.path.exists(erm + "/out") or not os.path.isdir(erm + "/out"):
                raise InvalidPackageError("Package's build script does not have an out directory.")
            with open(f"../archivedpkgs/{erm}.arc", "wb") as f:
                dirs = []
                files = []
                for p2, dirnames, filenames in os.walk(f"{erm}/out/"):
                    a = len(erm)+7
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
                if not os.path.exists(f"{erm}/out/meta"):
                    f.write(arclib.archive(built))
        else:
            with open(f"../archivedpkgs/{erm}.arc", "wb") as f:
                if(os.path.exists(f"{erm}/out")):
                    shutil.rmtree(f"{erm}/out")
                os.mkdir(f"{erm}/out")
                dirs = []
                files = []
                for p2, dirnames, filenames in os.walk(f"{erm}/"):
                    a = len(erm)+1
                    dirpath = p2[a:]
                    for name in dirnames:
                        if dirpath.split("/")[0] == "out": continue
                        if dirpath + "/" + name == "/out": continue
                        if dirpath + "/" + name not in dirs:
                            dirs.append(dirpath + "/" + name)
                            os.mkdir(f"{erm}/out/{dirpath}/{name}")

                    for name in filenames:
                        if dirpath.split("/")[0] == "out": continue
                        # print(dirpath + "/" + name)
                        with open(p2 + "/" + name, "rb") as f2:
                            l = f2.read()
                            if dirpath + "/" + name == "/entry":
                                cpi = json.loads(l.decode())
                            elif dirpath + "/" + name not in files:
                                # print(name)
                                files.append([dirpath + "/" + name, l])
                                with open(f"{erm}/out/{dirpath}/{name}", "wb") as f3:
                                    f3.write(l)
                                

                built = []
                for aaa in dirs: built.append([aaa, None])
                for aaa in files: built.append([aaa[0], aaa[1]])
                if not os.path.exists(f"{erm}/out/meta"):
                    f.write(arclib.archive(built))
        index[erm] = cpi

with open("index.json", "w") as f:
    json.dump(index, f, indent=2)
