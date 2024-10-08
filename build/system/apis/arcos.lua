local syscall = require("syscall")
            local files   = require("files")
local arcos = {}
arcos = {
    kernelPanic = function(err, file, line)
        syscall.panic(err, file, line)
    end,
    reboot = function()
        syscall.run("reboot")
    end,
    shutdown = function()
        syscall.run("shutdown")
    end,
    log = function(txt, level)
        syscall.run("log", txt, level)
    end,
    version = function()
        return syscall.run("version")
    end,
    getName = function()
        return syscall.run("getName")
    end,
    setName = function(new)
        syscall.run("setName", new)
    end,
    getCurrentTask = function()
        return syscall.run("getCurrentTask")
    end,
    getUsers = function()
        return syscall.run("getUsers")
    end,
    getKernelLogBuffer = function()
        return syscall.run("getKernelLogBuffer")
    end,
    ev = function(filter)
        r = table.pack(coroutine.yield())
        if r[1] == "terminate" and (not r[2] or r[2] == "terminate") then
            error("")
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
            return arcos.rev(filter)
        end
    end,
    time = function(t)
        return syscall.run("time", t)
    end,
    day = function(t)
        return syscall.run("day", t)
    end,
    epoch = function(t)
        return syscall.run("epoch", t)
    end,
    date = function(format, time)
        return syscall.run("date", format, time)
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
    queue = function(ev, ...)
        syscall.run("queue", ev, ...)
    end,
    clock = function()
        return syscall.run("clock")
    end,
    loadAPI = function(api)
        error("Use require instead of loadAPI.")
    end,
    startTimer = function(d)
        return syscall.run("startTimer", d)
    end,
    cancelTimer = function(d)
        return syscall.run("cancelTimer", d)
    end,
    setAlarm = function(d)
        return syscall.run("setAlarm", d)
    end,
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