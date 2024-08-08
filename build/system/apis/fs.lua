local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    return t
end
local function open(path, mode)
    local validModes = {"w", "r", "w+", "r+", "a"}
    local cmodevalid = false
    for _, v in ipairs(validModes) do
        if mode == v then cmodevalid = true break end
    end
    if not cmodevalid then error("Mode not valid: " .. mode) end
    local err
    file = {}
    file._f, err = __LEGACY.fs.open(path, mode)
    if not file._f then
        return nil, err
    end
    file.open = true
    file.close = function() file._f.close() open = false end
    file.seekBytes = function(whence, offset)
        return file._f.seek(whence, offset)
    end
    if mode == "w" or mode == "w+" or mode == "r+" or mode == "a" then
        file.write = function(towrite)
            file._f.write(towrite)
        end
        file.writeLine = function(towrite)
            file._f.writeLine(towrite)
        end
        file.flush = function(towrite)
            file._f.write(towrite)
        end
    end
    if mode == "r" or mode == "w+" or mode == "r+" then
        local fd = file._f.readAll()
        local li = 0
        file.readBytes = function(b)
            return file._f.read(b)
        end
        file.read = function()
            return fd
        end
        file.readLine = function(withTrailing)
            li = li + 1
            if withTrailing then
                return split(fd, "\n")[li] .. "\n"
            else
                return split(fd, "\n")[li]
            end
        end
    end
    return file, nil
end
local function ls(dir)
    return __LEGACY.fs.list(dir)
end
local function rm(f)
    return __LEGACY.fs.delete(f)
end
local function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.exists(f)
end
local function mkDir(d)
    return __LEGACY.fs.makeDir(d)
end
local function resolve(f, keepNonExistent)
    local p = f:sub(1, 1) == "/" and "/" or (environ.workDir or "/")
    local pa = tutils.split(p, "/")
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
            if #pa + ix ~= 1 then
                table.insert(frmItems, 1, ix-1) 
            end
            table.insert(frmItems, 1, ix)
        end
    end
    if not keepNonExistent and not fs.exists("/" .. tutils.join(out, "/")) then return {} end
    for _, rmi in ipairs(frmItems) do
        table.remove(out, rmi)
    end
    return { "/" .. tutils.join(out, "/") }
end
local function dir(d) 
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.isDir(d)
end
local function m(t, d) 
    return __LEGACY.fs.move(t, d)
end
local function c(t, d)
    return __LEGACY.fs.copy(t, d)
end
local function complete(path, loc, ...)
    return getfenv(utd).fs.complete(path, loc, ...)
end
local function find(path)
    return __LEGACY.fs.find(path)
end
local function driveRoot(path)
    return __LEGACY.fs.isDriveRoot(path)
end
local function combine(...)
    return __LEGACY.fs.combine(...)
end
local function name(path)
    return __LEGACY.fs.getName(path)
end
local function par(path)
    return __LEGACY.fs.getDir(path)
end
local function size(path)
    return __LEGACY.fs.getSize(path)
end
local function readonly(path)
    return __LEGACY.fs.isReadOnly(path)
end
local function drive(path)
    return __LEGACY.fs.getDrive(path)
end
local function freeSpace(path)
    return __LEGACY.fs.getFreeSpace(path)
end
local function capacity(path)
    return __LEGACY.fs.getCapacity(path)
end
local function attributes(path)
    return __LEGACY.fs.attributes(path)
end
return {
    open = open,
    ls = ls,
    rm = rm, 
    exists = exists,
    resolve = resolve,
    dir = dir,
    m = m,
    c = c,
    mkDir = mkDir,
    complete = complete,
    find = find,
    driveRoot = driveRoot,
    combine = combine,
    name = name,
    size = size,
    readonly = readonly,
    drive = drive,
    freeSpace = freeSpace,
    capacity = capacity,
    attributes = attributes,
    par = par,
}