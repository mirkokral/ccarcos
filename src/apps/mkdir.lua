
local f = ...
if not f then
    error("No file specified")
end
local rf = files.resolve(f, true)[1]
files.mkDir(rf)