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
    ---Executes a kernel panic
    ---@param err string Error to display
    ---@param file string File kernel panic source
    ---@param line string File line
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
    ---Reboots the system
    reboot = function ()
        __LEGACY.os.reboot()
    end,
    ---Shuts the system down
    shutdown = function ()
        __LEGACY.os.shutdown()
        apiUtils.kernelPanic("Failed to turn off", "Kernel", "71")
    end,
    ---Logs a string
    ---@param txt string String to log
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
        end
    end,
    ---Returns the arcos version
    ---@return string
    version = function ()
        return "arcos 24.08 \"Vertica\" (Alpha release)"
    end,
    ---Gets the computer name
    ---@return string
    getName = function()
        return __LEGACY.os.getComputerLabel()
    end,
    ---Sets the computer name
    ---@param new string New computer name
    setName = function(new)

        if arcos.getCurrentTask().user == "root" then
            __LEGACY.os.setComputerLabel(new)
        end
    end,
    ---@class PublicTaskIdentifier
    ---@field public pid number The process id
    ---@field public name string The process name
    ---@field public user string The process user
    ---@field public nice number The process niceness value
    ---@field public paused boolean The paused boolean
    ---@field public env table The environment of the process, exposed as environ 
    ---Gets the currrent task
    ---@return PublicTaskIdentifier
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
    ---Gets the kernel log buffer
    ---@return string?
    getKernelLogBuffer = function()
        if not currentTask or currentTask["user"] == "root" then
            return kernelLogBuffer
        else
            return nil
        end
    end,
    ---Pulls an event with respect for the arcos thread executor.
    ---@param filter string
    ---@return table
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
    ---Pulls an event with respect for the arcos thread executor. Ignores terminte
    ---@param filter string
    ---@return table
    rev = function(filter)
        r = table.pack(coroutine.yield())
        if not filter or r[1] == filter then
            return table.unpack(r)
        else 
            return arcos.ev(filter)
        end
    end,
    ---Gets the time
    ---@param t string? Timezone
    ---@return integer
    time = function(t)
        return __LEGACY.os.time(t)
    end,
    ---Gets the day
    ---@param t string? Timezone
    ---@return integer
    day = function(t)
        return __LEGACY.os.day(t)
    end,
    ---Gets the epoch
    ---@param t string? Timezone
    ---@return integer
    epoch = function(t)
        return __LEGACY.os.epoch(t)
    end,
    ---Returns a date string (or table) using a specified format.
    ---@param format string?
    ---@param time number?
    ---@return string|osdate
    date = function (format, time)
        return __LEGACY.os.date(format, time)
    end,
    ---Runs a program
    ---@param env table Environment
    ---@param path string Path to the executable
    ---@param ... any
    ---@return boolean success
    ---@return any out
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
    ---Queues an event
    ---@param ev any
    ---@param ... any
    queue = function (ev, ...)
        __LEGACY.os.queueEvent(ev, ...)
    end,
    ---Returns the clock
    ---@return number
    clock = function() return __LEGACY.os.clock() end,

    ---Loads an API. This shouldn't be used outside of the kernel, but there are cases where it's needed.
    ---@param api string
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
    ---Starts a timer
    ---@param d number Timer duration in seconds
    ---@return number id Timer id
    startTimer = function(d) 
        return __LEGACY.os.startTimer(d)
    end,
    ---Cancels a timer
    ---@param d number Timer ID
    cancelTimer = function(d) 
        return __LEGACY.os.cancelTimer(d)
    end,
    ---Sets an alarm
    ---@param d number Alarm time
    ---@return number id Alarm id
    setAlarm = function(d) 
        return __LEGACY.os.setAlarm(d)
    end,
    ---Cancels an alarm
    ---@param d number Alarm ID
    cancelAlarm = function(d) 
        return __LEGACY.os.cancelAlarm(d)
    end,

    id = __LEGACY.os.getComputerID()
}
-- C:Exc

_G.term = {
    native = function()
        return term
    end,
    current = function()
        return term
    end,
    write = function(text)
        arcos.log(i .. ": " .. text)
    end,
    blit = function(text, ...)
        arcos.log(i .. ": " .. text)
    end,
    setTextColor = function(col) end,
    setBackgroundColor = function(col) end,
    setTextColour = function(col) end,
    setBackgroundColour = function(col) end,
    getTextColour = function() return col.white end,
    getBackgroundColour = function() return col.black end,
    getTextColor = function() return col.white end,
    getBackgroundColor = function() return col.black end,
    setCursorPos = function(cx, cy) end,
    scroll = function(sx) end,
    clear = function() end,
    isColor = function() return false end,
    isColour = function() return false end,
    getSize = function ()
        return 0, 0
    end
}

-- C:End
---Sleeps for a time, respects arcos thread executor
---@param time number Sleep time
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
end
---Prints an error
---@param ... string toprint
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(col.red)
    print(...)
    term.setTextColor(oldtc)
end
_G.tasking = {

    ---Creates a task
    ---@param name string Task name
    ---@param callback function The actual code that the task runs
    ---@param nice number Task niceness, how many times to execute coroutine.resume during the tasks round
    ---@param user string Task user executor. Can only be current user and root if not root. changing to root asks for a password.
    ---@param out any The output, exposed as term to the task
    ---@param env table The task environment
    ---@return integer pid The task process id
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
    ---Kills task. Can only be current user task if not root
    ---@param pid number The actual pid
    killTask = function(pid)
        arcos.log("Killing task: " .. pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            table.remove(tasks, pid)
            
        end
    end,
    ---Gets all tasks
    ---@return PublicTaskIdentifier[]
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
    ---Sets the task paused status if not root can only be used on task of self
    ---@param pid number The pid of the task to set
    ---@param paused boolean New paused status
    setTaskPaused = function(pid, paused)
        arcos.log("Setting pf on task: " .. pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            tasks[pid]["paused"] = true
            
        end
    end,
    ---Changes the user of the current task 
    ---@param user string New user username
    ---@param password string? New user password, ignored if root
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

-- Small fix
setfenv(read, setmetatable({colors = col, colours = col}, {__index = _G}))

-- C:Exc
_G.arc = require "src.system.apis.arc"
_G.col = require "src.system.apis.col"
_G.files = require "src.system.apis.files"
_G.hashing = require "src.system.apis.hashing"
_G.rd = require "src.system.apis.rd"
_G.tutils = require "src.system.apis.tutils"
_G.ui = require "src.system.apis.ui"
-- C:End
_G.window = __LEGACY.window
local passwdFile = files.open("/config/passwd", "r")
users = tutils.dJSON(passwdFile.read())
---Gets the current home dir for the user
---@return string
_G.arcos.getHome = function ()
    return "/user/" .. arcos.getCurrentTask().user
end
---Validates user credentials
---@param user string
---@param password string
---@return boolean
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
---Creates an user
---@param user string User name
---@param password string Password
---@return boolean
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
-- C:Exc
---Prints something
---@param ... string
_G.print = function(...) end
---Just like print but doesn't write a newline
---@param ... string
_G.write = function(...) end
---Reads a line
---@param r any?
---@param v any?
---@param a any?
---@return string userInput
_G.read = function(r, v, a) return "" end
-- C:End

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
        -- sleep(5)
        -- __LEGACY.os.reboot()
    end
    -- sleep()
end
