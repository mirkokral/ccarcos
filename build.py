from io import TextIOWrapper
import pathlib
import sys
import yaml
import os
with open('config.yml') as f:
    config = yaml.safe_load(f)
if not "options" in config:
    print("Missing config: options")
if not "compileFiles" in config:
    print("Missing config: compileFiles")
if not "mkDirs" in config:
    print("Missing config: mkDirs")
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
    with open(str(pathlib.Path("src/").absolute()) + "/" + filepathstr, "r") as file:
        outlines = []
        currentlyExcluding = False
        for i in file.readlines():
            if i.strip().startswith("--C:"):
                cmd = i.strip()[4:]
                match cmd:
                    case "Exc":
                        currentlyExcluding = True
                    case "End":
                        currentlyExcluding = False
                    case "Ifc":
                        currentlyExcluding = i.strip()[7:] in config["options"]
                    case "Inv":
                        currentlyExcluding = not currentlyExcluding
            else:
                if not currentlyExcluding:
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
        for i in config["mkDirs"]:
            objectListLines.append("d>" + i)
        for ind, i in enumerate(config["compileFiles"]):
            try:
                compileFile(i or "FileNameThatSurelyDoesNotExistAsWhyWouldSomeoneMakeSuchAStupidDecisionToMakeThisFileNameJustToHaveADefaultFile.ImpracticalFileExtension")
                print(f'{ind+1}/{len(config["nrFiles"]) + len(config["compileFiles"])+1} | {i}')
            except Exception as e:
                print("An error happened while parsing file: " + i)
                print(e)
            objectListLines.append("f>" + i)
        for ind, i in enumerate(config["nrFiles"]):
            # try:
            compileFile(i or "FileNameThatSurelyDoesNotExistAsWhyWouldSomeoneMakeSuchAStupidDecisionToMakeThisFileNameJustToHaveADefaultFile.ImpracticalFileExtension")
            print(f'{len(config["compileFiles"]) +ind+1}/{len(config["nrFiles"])+len(config["compileFiles"])+1} | {i}')
            
            objectListLines.append("r>" + i)
        print(f'{len(config["nrFiles"])+len(config["compileFiles"])+1}/{len(config["nrFiles"]) + len(config["compileFiles"])+1} | objList.txt')

        with open("build/objList.txt", "w") as f:
            f.write('\n'.join(objectListLines))
    case "clean":
        os.system("rm -rf build/*")
    case "test":
        recursiveMkdir(pathlib.Path("build/system/suspicious").absolute())