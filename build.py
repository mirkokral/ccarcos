from io import TextIOWrapper
import pathlib
import sys
import yaml
import os
with open('config.yml') as f:
    config = yaml.safe_load(f)
if not "options" in config:
    print("Missing config: options")

cf = []
cd = []
for root, dirs, files in os.walk("src/lua/"):
    for name in files:
        if not os.path.join(root[8:], name) in cf:
            cf.append(os.path.join(root[8:], name))
    for name in dirs:
        if not os.path.join(root[8:], name) in cd:
            cd.append(os.path.join(root[8:], name))
config["compileFiles"] = cf
config["mkDirs"] = cd
if not "build" in os.listdir("."):
    os.mkdir("build")

def recursiveMkdir(dir: str):
    for i,v in enumerate(str(dir).split("/")):
        try:
            os.mkdir("/".join(str(dir).split("/")[:i]))
        except:
            pass
    try:
        os.mkdir(dir)
    except:
        pass
def compileFile(filepathstr: str):
    recursiveMkdir(str(pathlib.Path(str(pathlib.Path("build/").absolute()) + "/" + filepathstr).absolute().parent))
    with open(str(pathlib.Path("src/lua/").absolute()) + "/" + filepathstr, "r") as file:
        outlines = []
        currentlyExcluding = 0
        inComment = False
        for l, i in enumerate(file.readlines()):
            if i.strip().startswith("-- C:"):
                cmd = i.strip()[5:]
                match cmd:
                    case "Exc":
                        currentlyExcluding += 1
                    case "End":
                        currentlyExcluding -= 1
                    case "Ifc":
                        currentlyExcluding += 1 if (i.strip()[8:] in config["options"]) else 0
                    case "Inv":
                        currentlyExcluding = not currentlyExcluding
            elif i.strip().startswith("--[["):
                currentlyExcluding += 1
                inComment = True    
            elif i.strip().startswith("--") or i.strip() == "":
                pass
            elif i.strip().endswith("]]") and inComment:
                currentlyExcluding -= 1
            else:
                if currentlyExcluding < 1:
                    i = i.replace("__CPOSINFOFILE__", f'{filepathstr}')
                    i = i.replace("__CPOSINFOLINE__", f'{l}')
                    i = i.replace("__CCOMPILECOUNT__", f'{config["buildCount"]}')
                    outlines.append(i)
        with open(pathlib.Path("build/" + filepathstr), "w") as writeFile:
            writeFile.writelines(outlines)
        
    
match sys.argv[1]:
    case "single":
        try:
            compileFile(sys.argv[2] or "FileNameThatSurelyDoesNotExistAsWhyWouldSomeoneMakeSuchAStupidDecisionToMakeThisFileNameJustToHaveADefaultFile.ImpracticalFileExtension")
        except Exception as e:
            print("An error happened while parsing said file.")
            print(e)
        pass
    case "whole":
        objectListLines = []
        packageListLines = []
        for i in config["mkDirs"]:
            objectListLines.append("d>" + i)
            packageListLines.append("d>" + i)
            try:
                recursiveMkdir("build/"+i)
            except:
                pass
        for ind, i in enumerate(config["compileFiles"]):
            try:
                compileFile(i or "FileNameThatSurelyDoesNotExistAsWhyWouldSomeoneMakeSuchAStupidDecisionToMakeThisFileNameJustToHaveADefaultFile.ImpracticalFileExtension")
                print(f'{ind+1}/{len(config["nrFiles"]) + len(config["compileFiles"])+1} | {i}')
            except Exception as e:
                print("An error happened while parsing file: " + i)
                print(e)
            objectListLines.append("f>" + i)
            packageListLines.append("f>" + i)
        for ind, i in enumerate(config["nrFiles"]):
            # try:
            compileFile(i or "FileNameThatSurelyDoesNotExistAsWhyWouldSomeoneMakeSuchAStupidDecisionToMakeThisFileNameJustToHaveADefaultFile.ImpracticalFileExtension")
            print(f'{len(config["compileFiles"]) +ind+1}/{len(config["nrFiles"])+len(config["compileFiles"])+1} | {i}')
            
            objectListLines.append("r>" + i)
            packageListLines.append("f>" + i)
        print(f'{len(config["nrFiles"])+len(config["compileFiles"])+1}/{len(config["nrFiles"]) + len(config["compileFiles"])+1} | objList.txt')

        with open("build/objList.txt", "w") as f:
            f.write('\n'.join(objectListLines))
        # with open("build/config/arc/base.uninstallIndex", "w") as f:
        #     f.write('\n'.join(packageListLines))
        if "buildCount" in config:
            config["buildCount"] = config["buildCount"] + 1
        else:
            config["buildCount"] = 1
        with open("config.yml", "w") as f:
            f.write(yaml.dump(config, indent=2))
    case "clean":
        os.system("rm -rf build/*")
    case "test":
        recursiveMkdir(pathlib.Path("build/system/suspicious").absolute())