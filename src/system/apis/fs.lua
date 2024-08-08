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
    file._f, err = __LEGACY.files.open(path, mode)
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
    return __LEGACY.files.list(dir)
end

---Removes a file
---@param f string
---@return nil
local function rm(f)
    return __LEGACY.files.delete(f)
end

---Returns a boolean if a file exists
---@param f string
---@return boolean
local function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.files.exists(f)
end
---Makes a directory
---@param d string Dir path
local function mkDir(d)
    return __LEGACY.files.makeDir(d)
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
    if not keepNonExistent and not files.exists("/" .. tutils.join(out, "/")) then return {} end
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
    return __LEGACY.files.isDir(d)
end
---Moves t to d
---@param t string
---@param d string
---@return nil
local function m(t, d) 
    return __LEGACY.files.move(t, d)
end
---Copies t to d
---@param t string
---@param d string
---@return nil
local function c(t, d)
    return __LEGACY.files.copy(t, d)
end

local expect = col.expect
local field = col.field

---Completes path at locale
---@param sPath string
---@param sLocation string
---@param bIncludeFiles boolean
---@param bIncludeDirs boolean
---@return string[]
local function complete(sPath, sLocation, bIncludeFiles, bIncludeDirs)

    expect(1, sPath, "string")
    expect(2, sLocation, "string")
    local bIncludeHidden = nil
    if type(bIncludeFiles) == "table" then
        bIncludeDirs = field(bIncludeFiles, "include_dirs", "boolean", "nil")
        bIncludeHidden = field(bIncludeFiles, "include_hidden", "boolean", "nil")
        bIncludeFiles = field(bIncludeFiles, "include_files", "boolean", "nil")
    else
        expect(3, bIncludeFiles, "boolean", "nil")
        expect(4, bIncludeDirs, "boolean", "nil")
    end

    bIncludeHidden = bIncludeHidden ~= false
    bIncludeFiles = bIncludeFiles ~= false
    bIncludeDirs = bIncludeDirs ~= false
    local sDir = sLocation
    local nStart = 1
    local nSlash = string.find(sPath, "[/\\]", nStart)
    if nSlash == 1 then
        sDir = ""
        nStart = 2
    end
    local sName
    while not sName do
        local nSlash = string.find(sPath, "[/\\]", nStart)
        if nSlash then
            local sPart = string.sub(sPath, nStart, nSlash - 1)
            sDir = files.combine(sDir, sPart)
            nStart = nSlash + 1
        else
            sName = string.sub(sPath, nStart)
        end
    end

    if files.dir(sDir) then
        local tResults = {}
        if bIncludeDirs and sPath == "" then
            table.insert(tResults, ".")
        end
        if sDir ~= "" then
            if sPath == "" then
                table.insert(tResults, bIncludeDirs and ".." or "../")
            elseif sPath == "." then
                table.insert(tResults, bIncludeDirs and "." or "./")
            end
        end
        local tFiles = files.ls(sDir)
        for n = 1, #tFiles do
            local sFile = tFiles[n]
            if #sFile >= #sName and string.sub(sFile, 1, #sName) == sName and (
                bIncludeHidden or sFile:sub(1, 1) ~= "." or sName:sub(1, 1) == "."
            ) then
                local bIsDir = files.dir(files.combine(sDir, sFile))
                local sResult = string.sub(sFile, #sName + 1)
                if bIsDir then
                    table.insert(tResults, sResult .. "/")
                    if bIncludeDirs and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                else
                    if bIncludeFiles and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                end
            end
        end
        return tResults
    end

    return {}
end

local function find_aux(path, parts, i, out)
    local part = parts[i]
    if not part then
        -- If we're at the end of the pattern, ensure our path exists and append it.
        if files.exists(path) then out[#out + 1] = path end
    elseif part.exact then
        -- If we're an exact match, just recurse into this directory.
        return find_aux(files.combine(path, part.contents), parts, i + 1, out)
    else
        -- Otherwise we're a pattern. Check we're a directory, then recurse into each
        -- matching file.
        if not files.dir(path) then return end

        local files = files.ls(path)
        for j = 1, #files do
            local file = files[j]
            if file:find(part.contents) then find_aux(files.combine(path, file), parts, i + 1, out) end
        end
    end
end

local find_escape = {
    -- Escape standard Lua pattern characters
    ["^"] = "%^", ["$"] = "%$", ["("] = "%(", [")"] = "%)", ["%"] = "%%",
    ["."] = "%.", ["["] = "%[", ["]"] = "%]", ["+"] = "%+", ["-"] = "%-",
    -- Aside from our wildcards.
    ["*"] = ".*",
    ["?"] = ".",
}

---Wildcards a path
---@param pattern string
---@return string[]
local function find(pattern)
    expect(1, pattern, "string")

    pattern = files.combine(pattern) -- Normalise the path, removing ".."s.

    -- If the pattern is trying to search outside the computer root, just abort.
    -- This will fail later on anyway.
    if pattern == ".." or pattern:sub(1, 3) == "../" then
        error("/" .. pattern .. ": Invalid Path", 2)
    end

    -- If we've no wildcards, just check the file exists.
    if not pattern:find("[*?]") then
        if files.exists(pattern) then return { pattern } else return {} end
    end

    local parts = {}
    for part in pattern:gmatch("[^/]+") do
        if part:find("[*?]") then
            parts[#parts + 1] = {
                exact = false,
                contents = "^" .. part:gsub(".", find_escape) .. "$",
            }
        else
            parts[#parts + 1] = { exact = true, contents = part }
        end
    end

    local out = {}
    find_aux("", parts, 1, out)
    return out
end

---Returns true if a path is a filesystem
---@param sPath string
---@return boolean
local function driveRoot(sPath)
    expect(1, sPath, "string")
    -- Force the root directory to be a mount.
    return files.par(sPath) == ".." or files.drive(sPath) ~= files.drive(files.par(sPath))
end
---Combine paths
---@param ... string
---@return string
local function combine(...)
    return __LEGACY.files.combine(...)
end
---Gets the name of a filepath
---@param path string
---@return string
local function name(path)
    return __LEGACY.files.getName(path)
end
---Gets the parent dir of a filepath
---@param path string
---@return string
local function par(path)
    return __LEGACY.files.getDir(path)
end
---Gets the size of a file
---@param path string
---@return number   
local function size(path)
    return __LEGACY.files.getSize(path)
end
---Gets the readonly status of a file
---@param path string
---@return boolean
local function readonly(path)
    return __LEGACY.files.isReadOnly(path)
end
---Gets the drive path for path
---@param path string
---@return string
local function drive(path)
    return __LEGACY.files.getDrive(path)
end
---Gets free space at path
---@param path string
---@return number
local function freeSpace(path)
    return __LEGACY.files.getFreeSpace(path)
end
---Gets path capacity
---@param path string
---@return number
local function capacity(path)
    return __LEGACY.files.getCapacity(path)
end
---Gets path attributes
---@param path string
---@return {size: number, isDir: number, isReadOnly: number, created: number, modified: number}
local function attributes(path)
    return __LEGACY.files.attributes(path)
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