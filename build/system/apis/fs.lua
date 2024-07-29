function open(path, mode)
    local validModes = {"w", "r"}
    local cmodevalid = false
    for _, v in ipairs(validModes) do
        if mode == v then cmodevalid = true break end
    end
    if not cmodevalid then error("Mode not valid: " .. mode) end
    local i = {}
    file = {}
    file._f, i.err = __LEGACY.fs.open(path, mode)
    if i.err then
        error(i.err)
    end
    file.close = file._f.close
    if mode == "w" then
        file.write = function(towrite)
            file._f.write(towrite)
        end
    elseif mode == "r" then
        file.read = function()
        end
    end
end
function ls(dir)
    return __LEGACY.fs.listDir(dir)
end