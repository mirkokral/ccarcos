local files = require("files")

local f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end

files.rm(fr)