
local f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end

local fop = files.open(fr, "r")
print(fop.read())
fop.close()