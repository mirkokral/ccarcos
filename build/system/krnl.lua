local args = {...}
local kpError = nil
local currentTask
local cPid
local kernelLogBuffer = "Start\n"
local tasks = {}
local permmatrix
local config = {
    forceNice = nil,
    init = "/apps/init.lua",
    printLogToConsole = false,
    printLogToFile = false,
    telemetry = true
}
local logfile = nil
if config.printLogToFile then
    logfile, error = __LEGACY.files.open("/system/log.txt", "w")
    if not logfile then
        print(error)
        while true do coroutine.yield() end
    end
end
local oldw = _G.write
_G.write = function(...)
    local isNextSetC = false
    local nextCommand = ""
    local args = {...}
    for i, v in ipairs(args) do
        for xi = 0, #v do
            local char = v:sub(xi, xi)
            if isNextSetC then
                nextCommand = char
                isNextSetC = false
            elseif #nextCommand > 0 then
                if nextCommand == "b" then
                    isNextSetC = false
                    local value = tonumber(char, 16)
                    if not value then return nil end
                    term.setBackgroundColor(2 ^ value)
                elseif nextCommand == "f" then
                    isNextSetC = false
                    local value = tonumber(char, 16)
                    if not value then return nil end
                    term.setTextColor(2 ^ value)
                end
                nextCommand = ""
            elseif char == "\011" then
                    isNextSetC = true
            else
                oldw(char)
            end
        end
    end
end
local function recursiveRemove(r)
    for _, i in ipairs(__LEGACY.files.list(r)) do
        if __LEGACY.files.isDir(i) then
            recursiveRemove(i)
        else
            __LEGACY.files.remove(i)
        end
    end
end
for _, i in ipairs(__LEGACY.files.list("/temporary/")) do
    recursiveRemove("/temporary/" .. i)
end
local users = {}
local function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end
_G.apiUtils = {
    kernelPanic = function(err, file, line)
        kpError = "Suspected location: " .. file .. ":" .. line .. "\n" .. "Error: " .. err
        tasks = {}
    end
}
_G.arcos = {
    reboot = function ()
        __LEGACY.os.reboot()
    end,
    shutdown = function ()
        __LEGACY.os.shutdown()
        apiUtils.kernelPanic("Failed to turn off", system/krnl.lua, 116)
    end,
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            term.write("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n")
        end
        if config.printLogToFile and logfile then
            logfile.write(kernelLogBuffer)
        end
    end,
    version = function ()
        if __LEGACY.files.exists("/config/arc/devenv.lock") then
            return "arcos development environment"
        end
        local f, e = __LEGACY.files.open("/config/arc/base.meta.json", "r")
        if not f then
            return "invalid package metadata"
        else
            local meta = __LEGACY.textutils.unserializeJSON(f.readAll())
            f.close()
            return meta.version
        end
    end,
    getName = function()
        return __LEGACY.os.getComputerLabel()
    end,
    setName = function(new)
        if arcos.getCurrentTask().user == "root" then
            __LEGACY.os.setComputerLabel(new)
        end
    end,
    getCurrentTask = function()
        if currentTask then
            return {
                pid = cPid,
                name = currentTask["name"],
                user = currentTask["user"],
                nice = currentTask["nice"],
                paused = currentTask["paused"],
                env = currentTask["env"]
            }
        end
        return {
            pid = -1,
            name = "kernelspace",
            user = "root",
            nice = 1,
            paused = false,
            env = {}
        }
    end,
    getUsers = function()
        local f = {}
        for index, value in ipairs(users) do
            table.insert(f, value.name)
        end
        return f
    end,
    getKernelLogBuffer = function()
        if not currentTask or currentTask["user"] == "root" then
            return kernelLogBuffer
        else
            return nil
        end
    end,
    ev = function(filter)
        r = table.pack(coroutine.yield())
        if r[1] == "terminate" then
            error("Terminated")
        end
        if not filter or r[1] == filter then
            return table.unpack(r)
        else 
            return arcos.ev(filter)
        end
    end,
    rev = function(filter)
        r = table.pack(coroutine.yield())
        if not filter or r[1] == filter then
            return table.unpack(r)
        else 
            return arcos.ev(filter)
        end
    end,
    time = function(t)
        return __LEGACY.os.time(t)
    end,
    day = function(t)
        return __LEGACY.os.day(t)
    end,
    epoch = function(t)
        return __LEGACY.os.epoch(t)
    end,
    date = function (format, time)
        return __LEGACY.os.date(format, time)
    end,
    r = function(env, path, ...) 
        assert(type(env) == "table", "Invalid argument: env")
        assert(type(path) == "string", "Invalid argument: path")
        local compEnv = {}
        for k, v in pairs(_G) do
            compEnv[k] = v
        end
        for k, v in pairs(env) do
            compEnv[k] = v
        end
        compEnv["apiUtils"] = nil
        compEnv["__LEGACY"] = nil
        compEnv["_G"] = nil
        setmetatable(compEnv, {
            __index = function (t, k)
                if k == "_G" then
                    return compEnv
                end
            end,
        })
        local f = __LEGACY.files.open(path, "r")
        local compFunc, err = load(f.readAll(), path, nil, compEnv)
        f.close()
        if compFunc == nil then
            return false, "Failed to load function: " .. err 
        else
            setfenv(compFunc, compEnv)
            local ok, err = pcall(compFunc, ...)
            return ok, err
        end
    end,
    queue = function (ev, ...)
        __LEGACY.os.queueEvent(ev, ...)
    end,
    clock = function() return __LEGACY.os.clock() end,
    loadAPI = function(api)
        assert(type(api) == "string", "Invalid argument: api")
        arcos.log(api)
        local tabEnv = {}
        local s = strsplit(api, "/")
        local v = s[#s]
        if string.sub(v, #v-3) == ".lua" then
            v = v:sub(1, #v-4)
        end 
        setmetatable(tabEnv, {__index = _G})
        local f, e = __LEGACY.files.open(api, "r")
        if not f then
            error(e)
        end
        local funcApi, err = load(f.readAll(), v, nil, tabEnv)
        f.close()
        local ok, res
        if funcApi then
            ok, res = pcall(funcApi)
            if not ok then
                error(res)
            end 
        else
            error(err)
        end
        arcos.log("Loaded api " .. v)
        _G[v] = res
    end,
    startTimer = function(d) 
        return __LEGACY.os.startTimer(d)
    end,
    cancelTimer = function(d) 
        return __LEGACY.os.cancelTimer(d)
    end,
    setAlarm = function(d) 
        return __LEGACY.os.setAlarm(d)
    end,
    cancelAlarm = function(d) 
        return __LEGACY.os.cancelAlarm(d)
    end,
    id = __LEGACY.os.getComputerID()
}
_G.os = _G.arcos
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
end
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(require("col").red)
    print(...)
    term.setTextColor(oldtc)
end
_G.tasking = {
    createTask = function(name, callback, nice, user, out, env)
        if not env then env = arcos.getCurrentTask().env or {workDir = "/"} end
        arcos.log("Creating task: "..name)
        if not user then
            if currentTask then
                user = currentTask["user"]
            else
                user = ""
            end
        end
        if currentTask and user ~= "root" then
            if user ~= currentTask["user"] and not currentTask["user"] == "root" then
                return 1
            end
        end
        if currentTask and user == "root" and currentTask["user"] ~= "root" then
            write("\nEnter root password")
            local password = read()
            if not arcos.validateUser("root", password) then
                error("Invalid password")
            end
        end
        table.insert(tasks, {
            name = name,
            crt = coroutine.create(callback),
            nice = nice,
            user = user,
            out = out,
            env = env,
            paused = false,
            tQueue = {}
        })
        return #tasks
    end,
    killTask = function(pid)
        arcos.log("Killing task: " .. pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            table.remove(tasks, pid)
        end
    end,
    getTasks = function()
        local returnstuff = {}
        for i, v in ipairs(tasks) do
            table.insert(returnstuff, {
                pid = i,
                name = v["name"],
                user = v["user"],
                nice = v["nice"],
                paused = v["paused"]
            })
        end
        return returnstuff
    end,
    setTaskPaused = function(pid, paused)
        arcos.log("Setting pf on task: " .. pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            tasks[pid]["paused"] = paused
        end
    end,
    changeUser = function (user, password)
        if arcos.getCurrentTask().user == user then return true end
        if arcos.getCurrentTask().user ~= "root" then
            if not password then return "Invalid credentials" end 
            if not arcos.validateUser(user, password) then return "Invalid credentials" end
        end
        if not currentTask then return "No current task" end
        for index, value in ipairs(users) do
            if value.name == user then
                currentTask["user"] = user
                return true
            end
        end
        return "User non-existent"
    end
}
_G.devices = {
    get = function(what)
        return __LEGACY.peripheral.wrap(what)
    end,
    find = function(what)
        return __LEGACY.peripheral.find(what)
    end,
    names = function ()
        return __LEGACY.peripheral.getNames()
    end,
    present = function (name)
        return __LEGACY.peripheral.isPresent(name)
    end,
    type = function(peripheral)
        return __LEGACY.peripheral.getType(peripheral)
    end,
    hasType = function (peripheral, peripheral_type)
        return __LEGACY.peripheral.hasType(peripheral, peripheral_type)
    end,
    methods = function(name)
        return __LEGACY.peripheral.getMethods(name)
    end,
    name = function(peripheral)
        return __LEGACY.peripheral.getName(peripheral)
    end,
    call = function(name, method, ...)
        return __LEGACY.peripheral.call(name, method, ...)
    end
}
_G.dev = {
}
setmetatable(_G.dev, {
    __index = function (t, k)
        local n = ""
        if k == "wmodem" or k == "modem" then
            local devBuf = {}
            local c = {__LEGACY.peripheral.find("modem")}
            if not c then return {} end
            for _, p in ipairs(c) do
                p["origName"] = __LEGACY.peripheral.getName(p)
                if k == "wmodem" and p.isWireless() then
                    table.insert(devBuf, p)
                end
                if k == "modem" and not p.isWireless() then
                    table.insert(devBuf, p)
                end
            end
            return devBuf
        else
            local devBuf = {}
            local c = {__LEGACY.peripheral.find(k)}
            if not c then return devBuf end
            for _, p in ipairs(c) do
                p["origName"] = __LEGACY.peripheral.getName(p)
                table.insert(devBuf, p)
            end
            return devBuf
        end
    end
})
local i = 0
while true do
    i = i + 1
    if args[i] == nil then
        break
    end
    if args[i]:sub(1, 2) ~= "--" then
        apiUtils.kernelPanic("Invalid argument: " .. args[i], system/krnl.lua, 592)
    end
    local arg = string.sub(args[i], 3)
    if arg == "forceNice" then
        i = i + 1
        config["forceNice"] = tonumber(args[i])
    end
    if arg == "init" then
        i = i + 1
        config["init"] = args[i]
    end
    if arg == "noTel" then
        config.telemetry = false
    end
    if arg == "printLog" then
        config["printLogToConsole"] = true
    end
    if arg == "fileLog" then
        config["printLogToFile"] = true
    end
end
if config.printLogToFile then
    logfile, error = __LEGACY.files.open("/system/log.txt", "w")
    if not logfile then
        print(error)
        while true do coroutine.yield() end
    end
end
_G.package = {
    preload = {
        string = string,
        table = table,
        package = package,
        arcos = arcos,
        bit32 = __LEGACY.bit32,
        bit = __LEGACY.bit,
        coroutine = coroutine,
        os = arcos,
        tasking = tasking,
        utf8 = utf8,
    },
    loaded = {
    },
    loaders = {
        function (name)
            if not package.preload[name] then
                error("no field package.preload['" .. name .. "']")
            end
            return function()
                return package.preload[name]
            end
        end,
        function (name)
            if not package.loaded[name] then
                error("no field package.loaded['" .. name .. "']")
            end
            return function()
                return package.loaded[name]
            end
        end,
        function (name)
            local searchPaths = {"/", "/system/apis", "/apis"}
            local searchSuffixes = {".lua", "init.lua"}
            if environ and environ.workDir then
                table.insert(searchPaths, environ.workDir)
            end
            for _, path in ipairs(searchPaths) do
                for _, suffix in ipairs(searchSuffixes) do
                    local file = path .. "/" .. name:gsub("%.", "/") .. suffix
                    if __LEGACY.files.exists(file) then
                        local compEnv = {}
                        for k, v in pairs(_G) do
                            compEnv[k] = v
                        end
                        if path ~= "/apis" and path ~= "/system/apis" then
                            compEnv["apiUtils"] = nil
                            compEnv["__LEGACY"] = nil
                        end
                        compEnv["_G"] = nil
                        setmetatable(compEnv, {
                            __index = function (t, k)
                                if k == "_G" then
                                    return compEnv
                                end
                            end,
                        })
                        local f, err = __LEGACY.files.open(file, "r")
                        if not f then
                            error(err)
                        end
                        local compFunc, err = load(f.readAll(), file, nil, compEnv)
                        f.close()
                        if compFunc == nil then
                            error(err)
                        end
                        return compFunc
                    end
                end
            end
            error("Package not found.")
        end
    }
}
_G.require = function(modname)
    local errors = {}
    for _, loader in ipairs(package.loaders) do
        local ok, func = pcall(loader, modname)
        if ok then
            local f = func()
            package.loaded[modname] = f
            return f
        end
        table.insert(errors, func)
    end
    error("module '" .. modname .. "' not found:\n  " .. table.concat(errors, "\n  "))
end
arcos.log("Seems like it works")
local files = require("files")
local tutils = require("tutils")
local col = require("col")
local hashing = require("hashing")
debug.setfenv(read, setmetatable({colors = col, colours = col}, {__index = _G}))
local passwdFile, e = files.open("/config/passwd", "r")
if not passwdFile then
    apiUtils.kernelPanic("Password file not found", system/krnl.lua, 732)
else
    users = tutils.dJSON(passwdFile.read())
end
_G.arcos.getHome = function ()
    if not files.exists("/user/" .. arcos.getCurrentTask().user) then
        files.mkDir("/user/" .. arcos.getCurrentTask().user)
    end
    return "/user/" .. arcos.getCurrentTask().user
end
_G.arcos.validateUser = function (user, password)
    for index, value in ipairs(users) do
        if value.name == user and value.password == hashing.sha256(password) then
            if not files.exists("/user/" .. user) then
                files.mkDir("/user/" .. user)
            end
        end
    end
    for index, value in ipairs(users) do
        if value.name == user and value.password == hashing.sha256(password) then
            return true
        end
    end
    return false
end
_G.arcos.createUser = function (user, password)
    if arcos.getCurrentTask().user ~= "root" then
        return false
    end
    for index, value in ipairs(users) do
        if value.name == user then
            return false
        end
    end
    table.insert(users, {
        name = user,
        password = hashing.sha256(password)
    })
    local ufx, e = files.open("/config/passwd", "w")
    if not ufx then
        error(e)
    end
    ufx.write(tutils.sJSON(users))
    ufx.close()
    return true
end
_G.arcos.deleteUser = function (user)
    if arcos.getCurrentTask().user ~= "root" then
        return false
    end
    if user == "root" then
        return false
    end
    local todel = nil
    for index, value in ipairs(users) do
        if value.name == user then
            todel = index
        end
    end
    if todel then
        table.remove(users, todel)
        return true
    end
    return false
end
_G.kernel = {
    uname = function ()
        return "arckernel 470"
    end
}
local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), system/krnl.lua, 836)
end
for index, value in ipairs(arcos.getUsers()) do
    if not files.exists("/user/" .. value) then
        files.mkDir("/user/" .. value)
    end    
end
tasking.createTask("Init", function()
    arcos.log("Starting Init")
    local ok, err = pcall(function()
        local ok, err = arcos.r({}, config["init"])
        if err then
            apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 850)
        else
            apiUtils.kernelPanic("Init Died with no errors.", system/krnl.lua, 852)
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 855)
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)
while kpError == nil do
    local f = 0
    for index, value in ipairs(tasks) do
        if not value.paused then
            f = f + #value.tQueue
        end
    end
    if f > 0 then
        for index, value in ipairs(tasks) do
            if not value.paused then
                if #value.tQueue > 0 then       
                    currentTask = value
                    cPid = index
                    local event = table.remove(value.tQueue, 1)
                    _G.environ = value["env"]
                    local sc = table.pack(coroutine.resume(value["crt"], table.unpack(event)))
                    value["env"] = _G.environ
                    if kpError then break end
                end
            else
            end
        end
    else
        local ev = table.pack(coroutine.yield())
        if ev[1] == "terminate" then
        else
            for index, value in ipairs(tasks) do
                table.insert(value.tQueue, ev)
            end
        end
    end
end
__LEGACY.term.setBackgroundColor(__LEGACY.colors.red)
__LEGACY.term.setTextColor(__LEGACY.colors.black)
__LEGACY.term.setCursorPos(1, 1)
__LEGACY.term.clear()
print("arcos has forcefully shut off, due to a critical error.")
print("This is probably a system issue")
print("It is safe to force restart this computer at this state. Any unsaved data has already been lost.")
print(kpError)
while true do
    coroutine.yield()
end