local path = ...
if not path then
    error("No directory specified!")
end

local p = fs.resolve(path)[1]

if not fs.exists(p) then
    error(p .. ": Specified directory does not exist")
end

if not fs.dir(p) then
    error(p .. ": Specified path is not a directory.")
end

environ.workDir = p