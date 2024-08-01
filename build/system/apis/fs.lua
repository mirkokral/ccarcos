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
        return nil, i.err
    end
    file.close = file._f.close
    if mode == "w" then
        file.write = function(towrite)
            file._f.write(towrite)
        end
    elseif mode == "r" then
        file.read = function()
            return file._f.readAll()
        end
        file.readLine = function()
            return file._f.readLine()
        end
    end
    return file, nil
end
function ls(dir)
    return __LEGACY.fs.list(dir)
end
function rm(f)
    return __LEGACY.fs.remove(f)
end
function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.exists(f)
end
function resolve(f)
    local p = f:sub(1, 1) == "/" and "/" or (environ.workDir or "/")
    local pa = tutils.split(p, "/")
    local rmItems = {}
    for ix, i in ipairs(pa) do
        if i == "" then
            table.insert(rmItems, 1, ix)
        end
        if i == "." then
            table.insert(rmItems, 1, ix)
        end
        if i == ".." then
            table.insert(rmItems, 1, ix)
            if ix ~= 1 then
                table.insert(rmItems, 1, ix-1) 
            end
        end
    end
    for _, rmi in ipairs(rmItems) do
        table.remove(pa, rmi)
    end
    local fla = tutils.split(f, "/")
    local out = {}
    local frmItems = {}
    for _, i in ipairs(pa) do
        table.insert(out, i)
    end
    for _, i in ipairs(fla) do
        table.insert(out, i)
    end
    for ix, i in ipairs(out) do
        if i == "" then
            table.insert(frmItems, 1, ix)
        end
        if i == "." then
            table.insert(frmItems, 1, ix)
        end
        if i == ".." then
            table.insert(frmItems, 1, ix)
            if #pa + ix ~= 1 then
                table.insert(frmItems, 1, ix-1) 
            end
        end
    end
    for _, rmi in ipairs(frmItems) do
        table.remove(out, rmi)
    end
    return { "/" .. tutils.join(out, "/") }
end
function dir(d) 
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.isDir(d)
end