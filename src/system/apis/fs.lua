---@class FileH
---@field close fun(): nil Close the file handle


---@class FileHRead: FileH
---@field read fun(): string Gets all contents of file
---@field readLine fun(): string Gets a single file line

---@class FileHWrite: FileH
---@field write fun(towrite: string): nil Erases file and writes towrite to it

---Open a file
---@param path string
---@param mode string
---@return FileHRead | FileHWrite? handle
---@return string? error
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

---Returs an array of all files in a directory.
---@param dir string
---@return string[]
function ls(dir)
    return __LEGACY.fs.list(dir)
end

---Removes a file
---@param f string
---@return nil
function rm(f)
    return __LEGACY.fs.delete(f)
end

---Returns a boolean if a file exists
---@param f string
---@return boolean
function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.exists(f)
end
---Makes a directory
---@param d string Dir path
function mkDir(d)
    return __LEGACY.fs.makeDir(d)
end

---Resolves a relative path.
---@param f string File str to resolve
---@param keepNonExistent boolean? Keep non existent files 
---@return string[]
function resolve(f, keepNonExistent)
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
function dir(d) 
    if d == "" or d == "/" then return true end
    return __LEGACY.fs.isDir(d)
end
---Moves t to d
---@param t string
---@param d string
---@return nil
function m(t, d) 
    return __LEGACY.fs.move(t, d)
end
---Copies t to d
---@param t string
---@param d string
---@return nil
function c(t, d)
    return __LEGACY.fs.copy(t, d)
end

-- C:Exc
_G.fs = {
    open = open,
    ls = ls,
    rm = rm, 
    exists = exists,
    resolve = resolve,
    dir = dir,
    m = m,
    c = c,
    mkDir = mkDir,
}
-- C:End