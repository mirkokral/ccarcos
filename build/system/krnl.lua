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
term.redirect(term.native())
local oldw = _G.write
_G.write = function(...)
    local isNextSetC = false
    local nextCommand = ""
    local args = {...}
    for i, vn in ipairs(args) do
        if i > 1 then term.write(" ") end
        local v = tostring(vn)
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
_G.print = function(...) write(...) write("\n") end
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
        apiUtils.kernelPanic("Failed to turn off", system/krnl.lua, 118)
    end,
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
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
            return "arcos " .. meta.version
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
        error("Use require instead of loadAPI.")
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
                arcos.log(currentTask["user"] .. " tried to create a task with user " .. user .. " but failed the password check.")
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
        apiUtils.kernelPanic("Invalid argument: " .. args[i], system/krnl.lua, 567)
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
    apiUtils.kernelPanic("Password file not found", system/krnl.lua, 707)
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
        return "arckernel 537"
    end
}
local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), system/krnl.lua, 811)
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
            apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 825)
        else
            apiUtils.kernelPanic("Init Died with no errors.", system/krnl.lua, 827)
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 830)
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)
local function syscall(ev)
    if ev[1] == "panic" and #ev == 4 and type(ev[2]) == "string" and type(ev[3]) == "string" and type(ev[4]) == "number" then
        if arcos.getCurrentTask()["user"] == "root" then
            apiUtils.kernelPanic(ev[2], ev[3], ev[4])
            return true
        else
            return false
        end
    else
        arcos.log("Invalid syscall or syscall usage: " .. ev[1])
        return nil
    end
end
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
                    local sca = table.pack(coroutine.resume(value["crt"], table.unpack(event)))
                    local sc = {table.unpack(sca, 2, #sca)}
                    if not sca[1] then
                        table.remove(tasks, index)
                    end
                    if sc[1] == "syscall" then
                        table.insert(value.tQueue, 1, syscall({table.unpack(sc, 2, #sc)}))
                        __LEGACY.os.queueEvent("syscall_success")
                    end
                    value["env"] = _G.environ
                    if kpError then break end
                end
            else
            end
        end
    else
        local ev = table.pack(coroutine.yield())
        if ev[1] == "term_resize" then
        end 
        if ev[1] == "terminate" then
        else
            for index, value in ipairs(tasks) do
                table.insert(value.tQueue, ev)
            end
        end
    end
end
term.setBackgroundColor(0x4000)
term.setTextColor(0x8000)
term.setCursorPos(1, 1)
term.clear()
print("arcos has forcefully shut off, due to an error.")
print("If this is the first time you've seen these errors, try restarting your computer.")
print("If this problem continues:")
print("- If this started happening after an update, open an issue at github.com/mirkokral/ccarcos, and wait for an update")
print("- Try removing or disconnecting any newly installed hardware or software.")
print("- If using a multiboot/bios solution, check if your multiboot/bios solution supports TLCO and open an issue there")
print()
print(kpError)
print()
print("If needed, contact @mirko56 on discord for further assistance.")
while true do
    coroutine.yield()
end