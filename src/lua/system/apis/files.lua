local col = require("col")
local tutils = require("tutils")
local syscall = require("syscall")
local arcos = require("arcos")

---Combine paths
---@param ... string
---@return string
local function combine(...)
    local out = {}
    for index, value in ipairs({ ... }) do
        out = {table.unpack(out), table.unpack(tutils.split(value, "/"))}
    end
    return table.concat(out, "/")
end
---Gets the permissions for this user for a file
---@param file string File path
---@param user string? User
---@return {read: boolean, write: boolean, listed: boolean} perm Permission
local function getPermissions(file, user) 
    if not user then user = arcos.getCurrentTask().user end
    return syscall.fs.getPermissions(file, user)
end

---Get perms for all users on a file
---@param file string The file path
---@return table<string, {read: boolean, write: boolean, listed: boolean}>
local function getPermissionsForAll(file)
    local u = {}
    for index, value in ipairs(arcos.getUsers()) do
        u[value] = getPermissions(file, value)
    end
    return u
end

---Used in if statements - gets if you can't do so.
---@param on any
---@param what "read" | "write" | "listed"
---@return boolean
local function cant(on, what)
    return not getPermissions(on)[what]
end
---Used in if statements - gets if you can do so.
---@param on any
---@param what "read" | "write" | "listed"
---@return boolean
local function can(on, what)
    return getPermissions(on)[what]
end

---Gets the parent dir of a filepath
---@param path string
---@return string
local function par(path)
    return table.concat({ table.unpack(tutils.split(path, "/"), 1, #tutils.split(path, "/") - 1) }, "/")
end

---@class FileAttributes
---@field public size number
---@field public isDir boolean
---@field public isReadOnly boolean
---@field public created number
---@field public modified number
---@field public capacity number
---@field public driveRoot boolean
---@field public permissions table<string, {read: boolean, write: boolean, listed: boolean}>

---Gets path attributes
---@param path string
---@return FileAttributes
local function attributes(path)
    if cant(path, "read") then
        error("No permission for this action")
    end
    local attr = syscall.fs.attributes(path)
    attr.permissions = getPermissionsForAll(path)
    return attr
end

---Gets the readonly status of a file
---@param path string
---@return boolean
local function readonly(path)
    return not getPermissions(path).write
end

---@class FileH
---@field public close fun(): nil Close the file handle
---@field public open boolean Gets if fh open
---@field public seekBytes fun(whence: string?, offset: number?): nil

---@class FileHRead: FileH
---@field public read fun(n: number?): string Gets all contents of file
---@field public readLine fun(): string Gets a single file line
---@field public readBytes fun(amount: number): number | number[]

---@class FileHWrite: FileH
---@field public write fun(towrite: string): nil Erases file and writes towrite to it
---@field public writeLine fun(line: string): nil Write line
---@field public flush fun(): nil Flushes file

---Open a file
---@param path string
---@param mode string
---@return FileHRead | FileHWrite? handle
---@return string? error
local function open(path, mode)
    local ok, h = pcall(syscall.fs.open, path, mode)
    if not ok then return nil, h end
    local isopen = true
    return {
        read = function(n)
            return syscall.fs.fRead(h, n)
        end,
        readLine = function()
            return syscall.fs.fReadLine(h)
        end,
        readBytes = function(amount)
            return syscall.fs.fReadBytes(h, amount)
        end,
        write = function(towrite)
            return syscall.fs.fWrite(h, towrite)
        end,
        writeLine = function(line)
            return syscall.fs.fWriteLine(h, line)
        end,
        flush = function()
            return syscall.fs.fSync(h)
        end,
        close = function()
            isopen = false
            return syscall.fs.fClose(h)
        end,
        seek = function(whence, offset)
            return syscall.fs.fSeek(h, whence, offset)
        end,
        open = isopen
    }
end

---Returs an array of all files in a directory.
---@param dir string
---@return string[]
local function ls(dir)
    local f = syscall.fs.list(dir)
    return f
end

---Removes a file
---@param f string
---@return nil
local function rm(f)
    if cant(f, "write") then
        error("No permission for this action")
    end
    return syscall.fs.remove(f)
end

---Returns a boolean if a file exists
---@param f string
---@return boolean
local function exists(f)
    if f == "" or f == "/" then return true end

    if tutils.split(f, "/")[#tutils.split(f, "/")]:sub(1,1) == "$" then
        return false
    end
    
    return syscall.fs.exists(f)
end
---Makes a directory
---@param d string Dir path
local function mkDir(d) 
    local fv = {}
    for key, value in pairs({table.unpack(tutils.split(d, "/"), 1, #tutils.split(d, "/")-1)}) do
        table.insert(fv, value)
    end
    if not exists(table.concat(fv, "/")) then
        error("Parent doesn't exist.")
    end
    if cant(table.concat(fv, "/"), "write") then
        error("No permission for this action");
    end
    return syscall.fs.mkDir(d)
end

---Resolves a relative path.
---@param f string File str to resolve
---@param keepNonExistent boolean? Keep non existent files 
---@return string[]
local function resolve(f, keepNonExistent)
    local p = f:sub(1, 1) == "/" and "/" or (arcos.getCurrentTask().env.workDir or "/")
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
    if not keepNonExistent and not exists("/" .. tutils.join(out, "/")) then return {} end
    for _, rmi in ipairs(frmItems) do
        
        table.remove(out, rmi)
    end
    
    return { "/" .. tutils.join(out, "/") }
end
---Returns if said path is a directory
---@param d string
---@return boolean
local function dir(d) 
    if f == "" or f == "/" then return true end
    return attributes(d).isDir
end
---Moves t to d
---@param t string
---@param d string
---@return nil
local function m(t, d) 
    if cant(t, "read") or cant(t, "write") or cant(d, "write") then
        error("No permission for this action")
    end
    return syscall.fs.move(t, d)
end
---Copies t to d
---@param t string
---@param d string
---@return nil
local function c(t, d)
    if cant(t, "read") or cant(d, "write") then
        error("No permission for this action")
    end
    return syscall.fs.copy(t, d)
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
            sDir = combine(sDir, sPart)
            nStart = nSlash + 1
        else
            sName = string.sub(sPath, nStart)
        end
    end

    if dir(sDir) then
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
        local tFiles = ls(sDir)
        for n = 1, #tFiles do
            local sFile = tFiles[n]
            if #sFile >= #sName and string.sub(sFile, 1, #sName) == sName and (
                bIncludeHidden or sFile:sub(1, 1) ~= "." or sName:sub(1, 1) == "."
            ) then
                local bIsDir = dir(combine(sDir, sFile))
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
        if exists(path) then out[#out + 1] = path end
    elseif part.exact then
        -- If we're an exact match, just recurse into this directory.
        return find_aux(combine(path, part.contents), parts, i + 1, out)
    else
        -- Otherwise we're a pattern. Check we're a directory, then recurse into each
        -- matching file.
        if not dir(path) then return end

        local files = ls(path)
        for j = 1, #files do
            local file = files[j]
            if file:find(part.contents) then find_aux(combine(path, file), parts, i + 1, out) end
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

    pattern = combine(pattern) -- Normalise the path, removing ".."s.

    -- If the pattern is trying to search outside the computer root, just abort.
    -- This will fail later on anyway.
    if pattern == ".." or pattern:sub(1, 3) == "../" then
        error("/" .. pattern .. ": Invalid Path", 2)
    end

    -- If we've no wildcards, just check the file exists.
    if not pattern:find("[*?]") then
        if exists(pattern) then return { pattern } else return {} end
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


---Gets the name of a filepath
---@param path string
---@return string
local function name(path)
    return tutils.split(path, "/")[#tutils.split(path, "/")]
end



---Gets the size of a file
---@param path string
---@return number   
local function size(path)
    return attributes(path).size
end
---Gets the drive path for path
---@param path string
---@return string
local function drive(path)
    return syscall.fs.getMountRoot(path)
end
---Gets free space at path
---@param path string
---@return number
local function freeSpace(path)
    return attributes(path).capacity - attributes(path).size
end
---Returns true if a path is a filesystem
---@param sPath string
---@return boolean
local function driveRoot(sPath)
    expect(1, sPath, "string")
    -- Force the root directory to be a mount.
    return par(sPath) == ".." or drive(sPath) ~= drive(par(sPath))
end

---Gets path capacity
---@param path string
---@return number
local function capacity(path)
    return attributes(path).capacity
end

---Read a file
---@param path string
---@return string?
---@return string?
local function read(path) 
    local file, error = open(path, "r")
    if not file then
        return nil, error
    end
    local r = file.read()
    file.close()
    return r, nil
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
    read = read,
}
