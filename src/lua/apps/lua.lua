local arcos = require "arcos"
local tutils = require "tutils"

print("\011f0" .. _VERSION .. "\011f8 repl on \011fb" .. arcos.version())
print("\011f8Use .exit to exit.")
print("\011f7Already loaded apis: arcos, files, tasking. Use require() to load more")

local luaGlobal = {}

for i, v in pairs(_G) do
    luaGlobal[i] = v
end

luaGlobal.arcos = require("arcos")
luaGlobal.tasking = require("tasking")
luaGlobal.files = require("files")

while true do
    write("\011f8> \011f0")
    local cq = read()
    if cq == ".exit" then
        break
    end
    if not cq then goto continue end
    local chunkl, err = load(cq, "eval", nil, luaGlobal)
    local chunklb, errb = load("return " .. cq, "eval", nil, luaGlobal)
    if chunklb then
        chunkl = chunklb
        err = errb
    else
        -- print(errb)
    end
    if not chunkl then
        printError(err)
        goto continue
    end
    local ok, err = pcall(chunkl)
    if not ok then
        printError(err)
    else
        print(tutils.s(err, true))
    end
    
    ::continue::
end