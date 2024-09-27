---@diagnostic disable: duplicate-set-field
-- C:Exc
_G.__CPOSINFOFILE__ = "" -- Defined by the builder
_G.__CPOSINFOLINE__ = 0 --  Defined by the builder
_G.__CCOMPILECOUNT__ = 0 -- Defined by the builder
-- C:End
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
    ---Executes a kernel panic
    ---@param err string Error to display
    ---@param file string File kernel panic source
    ---@param line number File line
    kernelPanic = function(err, file, line)
        kpError = "Suspected location: " .. file .. ":" .. line .. "\n" .. "Error: " .. err
        tasks = {}
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
        apiUtils.kernelPanic("Failed to turn off", __CPOSINFOFILE__, __CPOSINFOLINE__)
    end,
    ---Logs a string
    ---@param txt string String to log
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
        end
        if config.printLogToFile and logfile then
            logfile.write(kernelLogBuffer)
        end
    end,
    ---Returns the arcos version
    ---@return string           
    version = function ()
        -- parse it from the package "base"
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

    ---Gets all user names in the system
    ---@return table<number,string>
    getUsers = function()
        local f = {}
        for index, value in ipairs(users) do
            table.insert(f, value.name)
        end
        return f
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
    ---@param filter string?
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
    ---@param filter string?
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
        error("Use require instead of loadAPI.")
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

_G.os = _G.arcos

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
    getTextColour = function() return require("col").white end,
    getBackgroundColour = function() return require("col").black end,
    getTextColor = function() return require("col").white end,
    getBackgroundColor = function() return require("col").black end,
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
    term.setTextColor(require("col").red)
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
    ---@param env table? The task environment
    ---@return integer pid The task process id
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
    ---Kills task. Can only be current user task if not root
    ---@param pid number The actual pid
    killTask = function(pid)
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
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            tasks[pid]["paused"] = paused
            
        end
    end,
    ---Changes the user of the current task 
    ---@param user string New user username
    ---@param password string? New user password, ignored if root
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
        apiUtils.kernelPanic("Invalid argument: " .. args[i], __CPOSINFOFILE__, __CPOSINFOLINE__)
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

---@type table
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
    ---@type table<function>
    loaders = {
        ---@param name string
        ---@return function
        function (name)
            if not package.preload[name] then
                error("no field package.preload['" .. name .. "']")
            end
            return function()
                return package.preload[name]
            end
        end,
        ---@param name string
        ---@return function
        function (name)
            if not package.loaded[name] then
                error("no field package.loaded['" .. name .. "']")
            end
            return function()
                return package.loaded[name]
            end
        end,
        ---@param name string
        ---@return function
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
    apiUtils.kernelPanic("Password file not found", __CPOSINFOFILE__, __CPOSINFOLINE__)
    
else
    users = tutils.dJSON(passwdFile.read())
end
---Gets the current home dir for the user
---@return string
_G.arcos.getHome = function ()
    if not files.exists("/user/" .. arcos.getCurrentTask().user) then
        files.mkDir("/user/" .. arcos.getCurrentTask().user)
    end
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

_G.kernel = {
    uname = function ()
        return "arckernel __CCOMPILECOUNT__"
    end
}

local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), __CPOSINFOFILE__, __CPOSINFOLINE__)
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
            apiUtils.kernelPanic("Init Died: " .. err, __CPOSINFOFILE__, __CPOSINFOLINE__)
        else
            apiUtils.kernelPanic("Init Died with no errors.", __CPOSINFOFILE__, __CPOSINFOLINE__)
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, __CPOSINFOFILE__, __CPOSINFOLINE__)
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)

---Execute a syscall
---@param ev any[]
---@param v any[][]
---@return any
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
        --[[
        For some reason the following coded has these side-effects:
        - Literally makes the fucking server crash
        - Uses 100% cpu
        - What the fuck
        ]] 

        -- __LEGACY.os.queueEvent("fakeevent")
        -- local f = {}
        -- repeat 
        --     table.insert(f, table.pack(coroutine.yield()))
        -- until f[#f][1] == "fakeevent"
        -- for index, value in ipairs(tasks) do
        --     for i, v in ipairs(f) do
        --         table.insert(value.tQueue, v)
        --     end
        -- end

        for index, value in ipairs(tasks) do
            if not value.paused then
                -- print("Not Paused task: " .. value.name)
                if #value.tQueue > 0 then       
                    -- print("Task has queue: " .. value.name)
                    currentTask = value
                    cPid = index
                    local event = table.remove(value.tQueue, 1)
                    _G.environ = value["env"]
                    local sca = table.pack(coroutine.resume(value["crt"], table.unpack(event)))
                    local sc = {table.unpack(sca, 2, #sca)}
                    if not sca[1] then
                        -- Delete task
                        table.remove(tasks, index)
                    end
                    -- print(require("tutils").s(sc[1]))
                    if sc[1] == "syscall" then
                        table.insert(value.tQueue, syscall({table.unpack(sc, 2, #sc)}))
                        __LEGACY.os.queueEvent("syscall_success")
                    end
                    value["env"] = _G.environ
                    if kpError then break end
                end
            else
                -- print("Paused task: " .. value.name)
            end
        end
    else
        -- print("Pulling")
        local ev = table.pack(coroutine.yield())
        -- print(ev[1])
        if ev[1] == "term_resize" then
            
        end 
        if ev[1] == "terminate" then
        else

            for index, value in ipairs(tasks) do
                table.insert(value.tQueue, ev)
            end
        end
    end
    -- print("Fake")
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