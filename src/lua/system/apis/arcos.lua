---@class PublicTaskIdentifier
---@field public pid number The process id
---@field public name string The process name
---@field public user string The process user
---@field public nice number The process niceness value
---@field public paused boolean The paused boolean
---@field public env table The environment of the process, exposed as environ

local syscall = require("syscall")
            local files   = require("files")
local arcos = {}
arcos = {
    ---Executes a kernel panic
    ---@param err string Error to display
    ---@param file string File kernel panic source
    ---@param line number File line
    kernelPanic = function(err, file, line)
        syscall.panic(err, file, line)
    end,
    ---Reboots the system
    reboot = function()
        syscall.run("reboot")
    end,
    ---Shuts the system down
    shutdown = function()
        syscall.run("shutdown")
    end,
    ---Logs a string
    ---@param txt string String to log
    ---@param level number The log level. 0 = Print to console only if printlog flag, 1 = Print to console unless quiet flag is set, 2 = Always print to console
    log = function(txt, level)
        syscall.run("log", txt, level)
    end,
    ---Returns the arcos version
    ---@return string
    version = function()
        return syscall.run("version")
    end,
    ---Gets the computer name
    ---@return string
    getName = function()
        return syscall.run("getName")
    end,
    ---Sets the computer name
    ---@param new string New computer name
    setName = function(new)
        syscall.run("setName", new)
    end,
    ---Gets the currrent task
    ---@return PublicTaskIdentifier
    getCurrentTask = function()
        return syscall.run("getCurrentTask")
    end,

    ---Gets all user names in the system
    ---@return table<number,string>
    getUsers = function()
        return syscall.run("getUsers")
    end,

    ---Gets the kernel log buffer
    ---@return string?
    getKernelLogBuffer = function()
        return syscall.run("getKernelLogBuffer")
    end,
    ---Pulls an event with respect for the arcos thread executor.
    ---@param filter string?
    ---@return table
    ev = function(filter)
        r = table.pack(coroutine.yield())
        -- print(require("tutils").s(r));
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
            return arcos.rev(filter)
        end
    end,
    ---Gets the time
    ---@param t string? Timezone
    ---@return integer
    time = function(t)
        return syscall.run("time", t)
    end,
    ---Gets the day
    ---@param t string? Timezone
    ---@return integer
    day = function(t)
        return syscall.run("day", t)
    end,
    ---Gets the epoch
    ---@param t string? Timezone
    ---@return integer
    epoch = function(t)
        return syscall.run("epoch", t)
    end,
    ---Returns a date string (or table) using a specified format.
    ---@param format string?
    ---@param time number?
    ---@return string|osdate
    date = function(format, time)
        return syscall.run("date", format, time)
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
        compEnv["KDriversImpl"] = nil
        compEnv["xnarcos"] = nil
        compEnv["_G"] = nil
        compEnv.tasking = require("tasking")
        compEnv.arcos = require("arcos")
        compEnv.devices = require("devices")
        compEnv.sleep = compEnv.arcos.sleep

        setmetatable(compEnv, {
            __index = function(t, k)
                if k == "_G" then
                    return compEnv
                end
            end,
        })
        local f, e = files.open(path, "r")
        if not f then return false,e end
        local compFunc, err = load(f.read(), path, nil, compEnv)
        f.close()
        if compFunc == nil then
            return false,err
        else
            if debug and debug.setfenv then debug.setfenv(compFunc, compEnv) end
            local ok, err = pcall(compFunc, ...)
            return ok,err
        end
    end,
    ---Queues an event
    ---@param ev any
    ---@param ... any
    queue = function(ev, ...)
        syscall.run("queue", ev, ...)
    end,
    ---Returns the clock
    ---@return number
    clock = function()
        return syscall.run("clock")
    end,

    ---Loads an API. This shouldn't be used outside of the kernel, but there are cases where it's needed.
    ---@param api string
    loadAPI = function(api)
        error("Use require instead of loadAPI.")
    end,
    ---Starts a timer
    ---@param d number Timer duration in seconds
    ---@return number id Timer id
    startTimer = function(d)
        return syscall.run("startTimer", d)
    end,
    ---Cancels a timer
    ---@param d number Timer ID
    cancelTimer = function(d)
        return syscall.run("cancelTimer", d)
    end,
    ---Sets an alarm
    ---@param d number Alarm time
    ---@return number id Alarm id
    setAlarm = function(d)
        return syscall.run("setAlarm", d)
    end,
    ---Cancels an alarm
    ---@param d number Alarm ID
    cancelAlarm = function(d)
        return syscall.run("cancelAlarm", d)
    end,
    id = syscall.run("getID"),

    getHome = function()
        return syscall.run("getHome")
    end,

    validateUser = function(user, pass)
        return syscall.run("validateUser", user, pass)
    end,

    createUser = function(user, pass)
        return syscall.run("createUser", user, pass)
    end,

    deleteUser = function(user)
        return syscall.run("deleteUser", user)
    end,

    sleep = function(d)
        local tId = arcos.startTimer(d)
        local rt = -1
        repeat _, rt = arcos.ev("timer")
        until rt == tId
        return
    end

}
return arcos