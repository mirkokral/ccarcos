local files = require("files")
local f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end
local fop, e = files.open(fr, "r")
if fop then
    print(fop.read())
    fop.close()
else
    error(e)
end