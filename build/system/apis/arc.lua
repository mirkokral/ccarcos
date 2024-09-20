local methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    DELETE = true,
    PATCH = true,
    TRACE = true,
}
local function getChosenRepo()
    local rf = files.open("/config/arcrepo", "r")
    local fx = rf.read()
    rf.close()
    return fx
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
local function check_key(options, key, ty, opt)
    local value = options[key]
    local valueTy = type(value)
    if (value ~= nil or not opt) and valueTy ~= ty then
        error(("bad field '%s' (%s expected, got %s"):format(key, ty, valueTy), 4)
    end
end
local function check_request_options(options, body)
    check_key(options, "url", "string")
    if body == false then
        check_key(options, "body", "nil")
    else
        check_key(options, "body", "string", not body)
    end
    check_key(options, "headers", "table", true)
    check_key(options, "method", "string", true)
    check_key(options, "redirect", "boolean", true)
    check_key(options, "timeout", "number", true)
    if options.method and not methods[options.method] then
        error("Unsupported HTTP method", 3)
    end
end
local function wrap_request(_url, ...)
    local ok, err = __LEGACY.http.request(...)
    if ok then
        while true do
            local event, param1, param2, param3 = os.pullEvent()
            if event == "http_success" and param1 == _url then
                return param2
            elseif event == "http_failure" and param1 == _url then
                return nil, param2, param3
            end
        end
    end
    return nil, err
end
local function get(_url, _headers, _binary)
    if type(_url) == "table" then
        check_request_options(_url, false)
        return wrap_request(_url.url, _url)
    end
    assert(type(_url) == "string")
    assert(type(_headers) == "table" or type(_headers) == "nil")
    assert(type(_binary) == "boolean" or type(_binary) == "nil")
    return wrap_request(_url, _url, nil, _headers, _binary)
end
local function getLatestCommit()
    local f, e = __LEGACY.files.open("/config/arc/latestCommit.hash", "r")
    if not f then 
        return ""
    else 
        local rp = f.readAll()
        f.close()
        return rp
    end
end
local function checkForCD()
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists("/config/arc") then
        __LEGACY.files.makeDir("/config/arc")
    end
end
local function fetch()
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local f2 = __LEGACY.files.open("/config/arc/latestCommit.hash", "w")    
    local fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        ["Authorization"] = "Bearer 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"
    })
    if not fr then error(e) end
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    f2.write(rp)
    fr.close()
    f2.close()
    local f = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" ..
    getLatestCommit() .. "/repo/index.json")
    local fa = __LEGACY.files.open("/config/arc/repo.json", "w")
    fa.write(f.readAll())
    fa.close()
    f.close()
end
local function isInstalled(package)
    return __LEGACY.files.exists("/config/arc/" .. package .. ".uninstallIndex")
end
local function getIdata(package)
    if not __LEGACY.files.exists("/config/arc/" .. package .. ".meta.json") then
        return nil
    end
    local f, e = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "r")
    if not f then
        return nil
    end
    return __LEGACY.textutils.unserializeJSON(f.readAll())
end
local function getRepo()
    local f = __LEGACY.files.open("/config/arc/repo.json", "r")
    if not f then
        return {}
    end
    local uj = __LEGACY.textutils.unserializeJSON(f.readAll())
    f.close()
    return uj
end
local function getOwners()
    local owners = {}
end
local function isDependant(pkg)
    local l = __LEGACY.files.list("")
end
local function uninstall(package)
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists("/config/arc/" .. package .. ".uninstallIndex") then
        error("Package not installed.")
    end
    local toDelete = { }
    toDelete["/config/arc/" .. package .. ".uninstallIndex"] = ""
    toDelete["/config/arc/" .. package .. ".meta.json"] = ""
    local f = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "r")
    for value in f.readLine do
        if value == nil then break end
        if value:sub(0, 1) == "f" then
            toDelete["/" .. value:sub(4+64)] = value:sub(3, 3+64)
        else
            toDelete["/" .. value:sub(3)] = "DIRECTORY"
        end
    end
    for value, hash in pairs(toDelete) do
        if hash == "" then
            __LEGACY.files.delete(value)
        elseif hash ~= "DIRECTORY" then
            local f, e = __LEGACY.files.open(value, "r")
            if f then
                local fhash = hashing.sha256(f.readAll())
                local hmismatch = {}
                for i = 1, #fhash, 1 do
                    local c1 = fhash:sub(i, i)
                    local c2 = hash:sub(i, i)
                    if c1 ~= c2 then
                        print("Mismatch: " .. c1 .. " != " .. c2)
                        table.insert(hmismatch, c1)
                    end
                end
                if #hmismatch == 0 then
                    __LEGACY.files.delete(value)
                else
                end
            end
        end
    end
    for value, hash in pairs(toDelete) do
        if hash == "DIRECTORY" then
            if __LEGACY.files.isDir(value) then
                if #__LEGACY.files.list(value) > 0 then
                    goto continue
                end
            end
            __LEGACY.files.delete(value)
        end
        ::continue::
    end
end
local arkivelib = {
    unarchive = function(text)
        local linebuf = ""
        local isReaderHeadInTable = true
        local offsetheader = {}
        local bufend = 0
        for k = 0, #text, 1 do
            local v = text:sub(k, k)
            if v == "\n" then
                if linebuf == "--ENDTABLE" then
                    bufend = k + 1
                    isReaderHeadInTable = false
                    break
                else
                    table.insert(offsetheader, tutils.split(linebuf, "|"))
                end
                linebuf = ""
            else
                linebuf = linebuf .. v
            end
        end
        local outputfiles = {}
        for k, v in ipairs(offsetheader) do
            if v[2] == "-1" then
                table.insert(outputfiles, { v[1], nil })
            elseif offsetheader[k + 1] then
                table.insert(outputfiles,
                    { v[1], text:sub(bufend + tonumber(v[2]), bufend + tonumber(offsetheader[k + 1][2]) - 1) })
            else
                table.insert(outputfiles, { v[1], text:sub(bufend + tonumber(v[2]), #text) })
            end
        end
        return outputfiles
    end
}
local function install(package)
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local repo = getRepo()
    local latestCommit = getLatestCommit()
    local buildedpl = ""
    if not repo[package] then
        error("Package not found!")
    end
    if __LEGACY.files.exists("/config/arc/" .. package .. ".meta.json") then
        local f = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "r")
        local ver = __LEGACY.textutils.unserializeJSON(f.readAll())["vId"]
        if ver < repo[package]["vId"] then
            local updateFile, e = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/upd" .. repo[package]["vId"] .. ".lua")
            if updateFile then
                local r = updateFile.readAll()
                local f, e = load(r, "Update Module", "t", setmetatable({}, { __index = _G }))
                if f then
                    local ok, err = pcall(f);
                    if not ok then error(err) end
                else
                    error(e)
                end
            end
            uninstall(package)
        else
            error("Package already installed!")
        end
    end
    local pkg = repo[package]
    local indexFile, err = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" .. latestCommit .. "/archivedpkgs/" .. package .. ".arc")
    if not indexFile then
        error(err)
    end
    local ifx = arkivelib.unarchive(indexFile.readAll())
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not __LEGACY.files.exists("/" .. value[1]) then
                __LEGACY.files.makeDir("/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
        end
    end
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not __LEGACY.files.exists("/" .. value[1]) then
                __LEGACY.files.makeDir("/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
            if not __LEGACY.files.exists("/" .. value[1]) then
                local file = value[2]
                local tfh, e = __LEGACY.files.open("/" .. value[1], "w")
                if not tfh then error(e) end
                tfh.write(file)
                tfh.close()
                buildedpl = buildedpl .. "f "  .. hashing.sha256(value[2]) .. " " .. value[1] .. "\n"
            end
        end
    end
    if pkg["postInstScript"] then
        return function()
            local file = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/" .. "pi.lua")
            local fd = file.readAll()
            file.close()
            local tf = __LEGACY.files.open("/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
            tf.write(fd)
            tf.close()
            arcos.r({}, "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
        end
    end
    indexFile.close()
    local insf = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "w")
    insf.write(__LEGACY.textutils.serializeJSON(pkg))
    insf.close()
    local uinsf = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "w")
    uinsf.write(buildedpl)
    uinsf.close()
    return function()
    end
end
local function getUpdatable()
    local updatable = {}
    for index, value in ipairs(files.ls("/config/arc/")) do
        if value:sub(#value - 14) == ".uninstallIndex" then
            local pk = value:sub(0, #value - 15)
            local pf = __LEGACY.files.open("/config/arc/" .. pk .. ".meta.json", "r")
            local at = pf.readAll()
            local af = __LEGACY.textutils.unserializeJSON(at)
            pf.close()
            if af["vId"] < getRepo()[pk]["vId"] then
                table.insert(updatable, pk)
            end
        end
    end
    return updatable
end
return {
    fetch = fetch,
    getRepo = getRepo,
    install = install,
    uninstall = uninstall,
    isInstalled = isInstalled,
    getIdata = getIdata,
    getUpdatable = getUpdatable,
    getChosenRepo = getChosenRepo,
    getLatestCommit = getLatestCommit,
    get = get,
}
