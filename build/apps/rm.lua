local f = ...
if not f then error("No file specified!") end
local fr = fs.resolve(f)[1]
if not fr then error("File does not exist") end
fs.rm(fr)