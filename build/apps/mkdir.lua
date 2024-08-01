local f = ...
if not f then
    error("No file specified")
end
local rf = fs.resolve(f, true)[1]
fs.mkDir(rf)