import os, os.path
import sys
files = os.listdir('.')
for i in files:
    if os.path.isdir(i):
        with open(i + "/index", "w") as f:
            
            outfile = ""
            for root, dirs, files in os.walk(i):
                print(root, files)
                root = '/'.join(root.split("/")[1:])
                if root != "":
                    outfile = outfile + "d>" + root + "\n"
                    for i in files:
                        outfile = outfile + "f>" + root + "/" + i + "\n"
            f.write(outfile)