---@class FileH
---@field close fun(): nil Close the file handle
---@field open boolean Gets if fh open
---@field seekBytes fun(whence: string?, offset: string?): nil

---@class FileHRead: FileH
---@field read fun(): string Gets all contents of file
---@field readLine fun(): string Gets a single file line
---@field readBytes fun(amount): number | number[]

---@class FileHWrite: FileH
---@field write fun(towrite: string): nil Erases file and writes towrite to it
---@field writeLine fun(line: string): nil Write line
---@field flush fun(): nil Flushes file
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
---Open a file
---@param path string
---@param mode string
---@return FileHRead | FileHWrite? handle
---@return string? error
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

---Returs an array of all files in a directory.
---@param dir string
---@return string[]
local function ls(dir)
    return __LEGACY.fs.list(dir)
end

---Removes a file
---@param f string
---@return nil
local function rm(f)
    return __LEGACY.fs.delete(f)
end

---Returns a boolean if a file exists
---@param f string
---@return boolean
local function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.exists(f)
end
---Makes a directory
---@param d string Dir path
local function mkDir(d)
    return __LEGACY.fs.makeDir(d)
end

---Resolves a relative path.
---@param f string File str to resolve
---@param keepNonExistent boolean? Keep non existent files 
---@return string[]
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
---Returns if said path is a directory
---@param d string
---@return boolean
local function dir(d) 
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.isDir(d)
end
---Moves t to d
---@param t string
---@param d string
---@return nil
local function m(t, d) 
    return __LEGACY.fs.move(t, d)
end
---Copies t to d
---@param t string
---@param d string
---@return nil
local function c(t, d)
    return __LEGACY.fs.copy(t, d)
end

---Completes path at locale
---@param path string
---@param loc string
---@param ... any
---@return string[]
local function complete(path, loc, ...)
    return __LEGACY.fs.complete(path, loc, ...)
end

---Wildcards a path
---@param path string
---@return string[]
local function find(path)
    return __LEGACY.fs.find(path)
end

---Returns true if a path is a filesystem
---@param path string
---@return boolean
local function driveRoot(path)
    return __LEGACY.fs.isDriveRoot(path)
end
---Combine paths
---@param ... string
---@return string
local function combine(...)
    return __LEGACY.fs.combine(...)
end
---Gets the name of a filepath
---@param path string
---@return string
local function name(path)
    return __LEGACY.fs.getName(path)
end
---Gets the parent dir of a filepath
---@param path string
---@return string
local function par(path)
    return __LEGACY.fs.getDir(path)
end
---Gets the size of a file
---@param path string
---@return number   
local function size(path)
    return __LEGACY.fs.getSize(path)
end
---Gets the readonly status of a file
---@param path string
---@return boolean
local function readonly(path)
    return __LEGACY.fs.isReadOnly(path)
end
---Gets the drive path for path
---@param path string
---@return string
local function drive(path)
    return __LEGACY.fs.getDrive(path)
end
---Gets free space at path
---@param path string
---@return number
local function freeSpace(path)
    return __LEGACY.fs.getFreeSpace(path)
end
---Gets path capacity
---@param path string
---@return number
local function capacity(path)
    return __LEGACY.fs.getCapacity(path)
end
---Gets path attributes
---@param path string
---@return {size: number, isDir: number, isReadOnly: number, created: number, modified: number}
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