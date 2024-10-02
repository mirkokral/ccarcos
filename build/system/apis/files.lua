local col = require("col")
local tutils = require("tutils")
local syscall = require("syscall")
local arcos = require("arcos")
local function combine(...)
    local out = {}
    for index, value in ipairs({ ... }) do
        out = {table.unpack(out), table.unpack(tutils.split(value, "/"))}
    end
    return table.concat(out, "/")
end
local function getPermissions(file, user) 
    if not user then user = arcos.getCurrentTask().user end
    return syscall.fs.getPermissions(file, user)
end
local function getPermissionsForAll(file)
    local u = {}
    for index, value in ipairs(arcos.getUsers()) do
        u[value] = getPermissions(file, value)
    end
    return u
end
local function cant(on, what)
    return not getPermissions(on)[what]
end
local function can(on, what)
    return getPermissions(on)[what]
end
local function par(path)
    return table.concat({ table.unpack(tutils.split(path, "/"), 1, #tutils.split(path, "/") - 1) }, "/")
end
local function attributes(path)
    if cant(path, "read") then
        error("No permission for this action")
    end
    local attr = syscall.fs.attributes(path)
    attr.permissions = getPermissionsForAll(path)
    return attr
end
local function readonly(path)
    return not getPermissions(path).write
end
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
local function ls(dir)
    local f = syscall.fs.list(dir)
    return f
end
local function rm(f)
    if cant(f, "write") then
        error("No permission for this action")
    end
    return syscall.fs.remove(f)
end
local function exists(f)
    if f == "" or f == "/" then return true end
    if tutils.split(f, "/")[#tutils.split(f, "/")]:sub(1,1) == "$" then
        return false
    end
    return syscall.fs.exists(f)
end
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
local function dir(d) 
    if f == "" or f == "/" then return true end
    return attributes(d).isDir
end
local function m(t, d) 
    if cant(t, "read") or cant(t, "write") or cant(d, "write") then
        error("No permission for this action")
    end
    return syscall.fs.move(t, d)
end
local function c(t, d)
    if cant(t, "read") or cant(d, "write") then
        error("No permission for this action")
    end
    return syscall.fs.copy(t, d)
end
local expect = col.expect
local field = col.field
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
        if exists(path) then out[#out + 1] = path end
    elseif part.exact then
        return find_aux(combine(path, part.contents), parts, i + 1, out)
    else
        if not dir(path) then return end
        local files = ls(path)
        for j = 1, #files do
            local file = files[j]
            if file:find(part.contents) then find_aux(combine(path, file), parts, i + 1, out) end
        end
    end
end
local find_escape = {
    ["^"] = "%^", ["$"] = "%$", ["("] = "%(", [")"] = "%)", ["%"] = "%%",
    ["."] = "%.", ["["] = "%[", ["]"] = "%]", ["+"] = "%+", ["-"] = "%-",
    ["*"] = ".*",
    ["?"] = ".",
}
local function find(pattern)
    expect(1, pattern, "string")
    pattern = combine(pattern) -- Normalise the path, removing ".."s.
    if pattern == ".." or pattern:sub(1, 3) == "../" then
        error("/" .. pattern .. ": Invalid Path", 2)
    end
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
local function name(path)
    return tutils.split(path, "/")[#tutils.split(path, "/")]
end
local function size(path)
    return attributes(path).size
end
local function drive(path)
    return syscall.fs.getMountRoot(path)
end
local function freeSpace(path)
    return attributes(path).capacity - attributes(path).size
end
local function driveRoot(sPath)
    expect(1, sPath, "string")
    return par(sPath) == ".." or drive(sPath) ~= drive(par(sPath))
end
local function capacity(path)
    return attributes(path).capacity
end
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
