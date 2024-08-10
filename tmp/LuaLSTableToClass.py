import sys, random
a = sys.argv[1]

def tableToClass(className, table):
    f = table[1:-1]
    fab = f.replace(" ", "")
    fa = []
    bracketDeepness = 0
    buf = ""
    for i in fab:
        if bracketDeepness < 0:

            raise SyntaxError("Bracket deepness less than 0")
        if i == "{":
            bracketDeepness += 1
            buf += i
        elif i == "}":
            bracketDeepness -= 1
            buf += i
        elif i == "," and bracketDeepness == 0:
            fa.append(buf)
            buf = ""
        else:
            buf += i
    fa.append(buf)
    tabToType = {}
    for i in fa:
        lfa = [i.split(":")[0], ':'.join(i.split(":")[1:])]
        if lfa[1][0] == "{" and lfa[1][-1] == "}":
            genClassName = "_CLASSGENERATOR__" + str(random.randint(1, 2**127-1))

            tableToClass(genClassName, lfa[1])
            tabToType[lfa[0]] = genClassName
        else:
            tabToType[lfa[0]] = lfa[1]
    print("---@class " + className)
    for i, v in tabToType.items():
        print(f"---@field public {i} {v}")
tableToClass(sys.argv[1], sys.argv[2])