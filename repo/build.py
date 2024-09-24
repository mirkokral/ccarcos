import os, os.path
import arclib
import sys
files = os.listdir('.')
# print(files)
class InvalidPackageError(Exception):...
for erm in files:
    if os.path.isdir(erm):
        if os.path.exists(erm + "/build.sh") and os.path.isfile(erm + "/build.sh"):
            os.system(f'bash -c "cd {erm}; bash build.sh; cd .."');
            if not os.path.exists(erm + "/out") or not os.path.isdir(erm + "/out"):
                raise InvalidPackageError("Package's build script does not have an out directory.")
            with open(f"../archivedpkgs/{erm}.arc", "wb") as f:
                dirs = []
                files = []
                for p2, dirnames, filenames in os.walk(f"{erm}/build/"):
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
                f.write(arclib.archive(built))
        else:
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
