local methods = {
    GET = true, POST = true, HEAD = true,
    OPTIONS = true, PUT = true, DELETE = true,
    PATCH = true, TRACE = true,
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
    local fr = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main")
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    fr.close()
    return rp
end
local function checkForCD()
    if not __LEGACY.files.exists("/config/arc") then
        __LEGACY.files.makeDir("/config/arc")
    end
end
local function fetch()
    checkForCD()
    local f = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/".. getLatestCommit() .."/repo/index.json")
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
    local f, e = __LEGACY.files.open("/config/arc/".. package .. ".meta.json", "r")
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
local function uninstall(package)
    if not __LEGACY.files.exists("/config/arc/" .. package .. ".uninstallIndex") then
        error("Package not installed.")
    end
    local toDelete = {"/config/arc/" .. package .. ".uninstallIndex", "/config/arc/" .. package .. ".meta.json"}
    local f = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "r")
    for value in f.readLine do
        if value == nil then break end
        table.insert(toDelete, 1, "/" .. value:sub(3))
    end
    for index, value in ipairs(toDelete) do
        __LEGACY.files.delete(value)
    end
end
local function install(package)
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
            uninstall(package)
        else
            error("Package already installed!")
        end
    end
    local pkg = repo[package]
    local indexFile = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/"..latestCommit.."/repo/"..package.."/index")
    local ifx = indexFile.readAll()
    for index, value in ipairs(split(ifx, "\n")) do
        if value:sub(1, 1) == "d" then
            if not __LEGACY.files.exists("/" .. value:sub(3)) then
                __LEGACY.files.makeDir("/" .. value:sub(3))
                buildedpl = buildedpl .. value .. "\n"
            end
        elseif value:sub(1, 1) == "f" then
            if not __LEGACY.files.exists("/" .. value:sub(3)) then
                local file = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/"..latestCommit.."/repo/"..package.."/" .. value:sub(3):gsub("%s", "%%20"))
                local tfh = __LEGACY.files.open("/" .. value:sub(3), "w")
                tfh.write(file.readAll())
                tfh.close()
                file.close()
                buildedpl = buildedpl .. value .. "\n"
            end
        end
    end
    if pkg["postInstScript"] then
        return function()
            local file = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/"..latestCommit.."/repo/"..package.."/" .. "pi.lua")
            local fd = file.readAll()
            file.close()
            local tf = __LEGACY.files.open("/temporary/arc."..package.."." .. latestCommit .. ".postInst.lua")
            tf.write(fd)
            tf.close()
            arcos.r({}, "/temporary/arc."..package.."." .. latestCommit .. ".postInst.lua")
        end
    end
    indexFile.close()
    local insf = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "w")
    insf.write(__LEGACY.textutils.serializeJSON(pkg))
    insf.close()
    local uinsf = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "w")
    uinsf.write(buildedpl)
    uinsf.close()
    return function ()
    end
end
local function getUpdatable()
    local updatable = {}
    for index, value in ipairs(files.ls("/config/arc/")) do
        if value:sub(#value-14) == ".uninstallIndex" then
            local pk = value:sub(0, #value-15)
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