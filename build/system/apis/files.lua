local col = require("col")
local tutils = require("tutils")
local function combine(...)
    return __LEGACY.files.combine(...)
end
local function getPermissions(file, user) 
    local read = true
    local write = true
    local listed = true
    if user == nil then user = arcos.getCurrentTask().user end
    if __LEGACY.files.isReadOnly(file) then
        write = false
    end
    if tutils.split(file, "/")[#tutils.split(file, "/")]:sub(1,1) == "$" then -- Metadata files
        return {
            read = false,
            write = false,
            listed = false
        }
    end
    local disallowedfiles = {"startup.lua", "startup"}
    for index, value in ipairs(disallowedfiles) do
        if tutils.split(file, "/")[1] == value then -- Metadata files
            return {
                read = false,
                write = false,
                listed = false,
            }
        end
    end
    if tutils.split(file, "/")[#tutils.split(file, "/")]:sub(1,1) == "." then
        listed = false
    end
    return {
        read = read,
        write = write,
        listed = listed,
    }
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
    return __LEGACY.files.getDir(path)
end
local function size(path)
    if cant(path, "read") then
        error("No permission for this action")
    end
    return __LEGACY.files.getSize(path)
end
local function drive(path)
    return __LEGACY.files.getDrive(path)
end
local function freeSpace(path)
    return __LEGACY.files.getFreeSpace(path)
end
local function readonly(path)
    return not getPermissions(path).write
end
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
    local validModes = {"w", "r", "w+", "r+", "a", "wb", "rb"}
    if cant(path, "read") and (mode == "r" or mode == "r+" or mode == "a" or mode == "w+" or mode == "rb") then
        return nil, "No permission for this action"
    end
    if cant(path, "write") and (mode == "w" or mode == "w+" or mode == "a" or mode == "r+" or mode == "wb") then
        return nil, "No permission for this action"
    end
    local cmodevalid = false
    for _, v in ipairs(validModes) do
        if mode == v then cmodevalid = true break end
    end
    if not cmodevalid then error("Mode not valid: " .. mode) end
    local err
    local file = {}
    file._f, err = __LEGACY.files.open(path, mode)
    if not file._f then
        return nil, err
    end
    file.open = true
    file.close = function() file._f.close() file.open = false end
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
    local listed =  __LEGACY.files.list(dir)
    local out = {}
    for index, value in ipairs(listed) do
        if can(dir .. '/' .. value, "listed") then
            table.insert(out, value)
        end
    end
    return out
end
local function rm(f)
    if cant(f, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.delete(f)
end
local function exists(f)
    if f == "" or f == "/" then return true end
    if tutils.split(f, "/")[#tutils.split(f, "/")]:sub(1,1) == "$" then
        return false
    end
    return __LEGACY.files.exists(f)
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
    return __LEGACY.files.makeDir(d)
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
    if not keepNonExistent and not exists("/" .. tutils.join(out, "/")) then return {} end
    for _, rmi in ipairs(frmItems) do
        table.remove(out, rmi)
    end
    return { "/" .. tutils.join(out, "/") }
end
local function dir(d) 
    if f == "" or f == "/" then return true end
    return __LEGACY.files.isDir(d)
end
local function m(t, d) 
    if cant(t, "read") or cant(t, "write") or cant(d, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.move(t, d)
end
local function c(t, d)
    if cant(t, "read") or cant(d, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.copy(t, d)
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
            if file:find(part.contents) then find_aux(__LEGACY.files.combine(path, file), parts, i + 1, out) end
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
local function driveRoot(sPath)
    expect(1, sPath, "string")
    return par(sPath) == ".." or drive(sPath) ~= drive(par(sPath))
end
local function name(path)
    return __LEGACY.files.getName(path)
end
local function capacity(path)
    return __LEGACY.files.getCapacity(path)
end
local function attributes(path)
    local attr = __LEGACY.files.attributes(path)
    attr.permissions = getPermissionsForAll(path)
    return attr
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
