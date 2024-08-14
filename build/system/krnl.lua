local args = {...}
local currentTask
local cPid
local kernelLogBuffer = "Start\n"
local tasks = {}
local permmatrix
local config = {
    forceNice = nil,
    init = "/apps/init.lua",
    printLogToConsole = false,
    telemetry = true
}
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
        term.setBackgroundColor(__LEGACY.colors.black)
        term.setTextColor(__LEGACY.colors.red)
        arcos.log("--- KERNEL PANIC ---")
        arcos.log(err)
        arcos.log("" .. file .. " at " .. line)
        arcos.log("--------------------")
        tasks = {}
        while true do
            coroutine.yield()
        end
    end
}
_G.arcos = {
    reboot = function ()
        __LEGACY.os.reboot()
    end,
    shutdown = function ()
        __LEGACY.os.shutdown()
        apiUtils.kernelPanic("Failed to turn off", "Kernel", "71")
    end,
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
        end
    end,
    version = function ()
        return "arcos 24.08 \"Vertica\" (Alpha release)"
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
        return {
            pid = cPid,
            name = currentTask["name"],
            user = currentTask["user"],
            nice = currentTask["nice"],
            paused = currentTask["paused"],
            env = currentTask["env"]
        }
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
            __newindex = function (t, k, v)
                if k == "_G" then
                    compEnv[k] = v
                end
            end
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
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
end
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(col.red)
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
            paused = false
        })
        sleep(0.1) -- Yield so that the task can actually start
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
            tasks[pid]["paused"] = true
        end
    end,
    changeUser = function (user, password)
        if arcos.getCurrentTask().user == user then return true end
        if arcos.getCurrentTask().user ~= "root" and not arcos.validateUser(user, password) then return "Invalid credentials" end
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
        apiUtils.kernelPanic("Invalid argument: " .. args[i], "Kernel", debug.getinfo().currentline)
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
end
arcos.log("Seems like it works")
for i, v in ipairs(__LEGACY.files.list("/system/apis/")) do
    arcos.log("Loading API: " .. v)
    arcos.loadAPI("/system/apis/" .. v)
end 
for i, v in ipairs(files.ls("/apis/")) do
    arcos.log("Loading UserAPI: " .. v)
    arcos.loadAPI("/apis/" .. v)
end
setfenv(read, setmetatable({colors = col, colours = col}, {__index = _G}))
_G.window = __LEGACY.window
local passwdFile = files.open("/config/passwd", "r")
users = tutils.dJSON(passwdFile.read())
_G.arcos.getHome = function ()
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
    local ufx = files.open("/config/passwd", "w")
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
local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), "Kernel", "174")
end
tasking.createTask("Init", function()
    arcos.log("Starting Init")
    local ok, err = pcall(function()
        local ok, err = arcos.r({}, config["init"])
        if err then
            apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "422")
        else
            apiUtils.kernelPanic("Init Died with no errors.", "Kernel", "422")
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "424")
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)
while true do
    if #tasks > 0 then
        ev = { os.pullEventRaw() }
        for d, i in ipairs(tasks) do
            for _ = 1, i["nice"], 1 do
                _G.term = i["out"] or __LEGACY.term
                if not i["paused"] then
                    currentTask = i
                    cPid = d
                    _G.environ = i["env"]
                    coroutine.resume(i["crt"], table.unpack(ev))
                    i["env"] = _G.environ
                end
            end
            if coroutine.status(i["crt"]) == "dead" then
                arcos.log("Task " .. i["name"] .. " died.")
                table.remove(tasks, d)
            end
        end
    end
    if #tasks <= 0 then
        tasking.createTask("Emergency shell", function ()
            term.setBackgroundColor(col.black)
            term.setTextColor(col.white)
            print("Kernel Emergency Shell System - No tasks.")
            arcos.r({}, "/apps/shell.lua")
        end, 1, "root", __LEGACY.term, {workDir = "/"})
    end
end
