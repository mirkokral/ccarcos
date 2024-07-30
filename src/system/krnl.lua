local args = {...}
local currentTask
local cPid
local kernelLogBuffer = "Start\n"
local tasks = {}
local permmatrix
local config = {
    forceNice = nil,
    init = "/apps/init.lua",
    printLogToConsole = false
}
local function recursiveRemove(r)
    for _, i in irange(__LEGACY.fs.list(r)) do
        if __LEGACY.fs.isDir(i) then
            recursiveRemove(i)
        else
            __LEGACY.fs.remove(i)
        end
    end
end
for _, i in irange(__LEGACY.fs.list("/temporary/")) do
    recursiveRemove("/temporary/" .. i)
end
local users = {}

function _G.strsplit(inputstr, sep)
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
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.red)
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
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
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
        if not currentTask or not currentTask["user"] == "root" then
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
    r = function(env, path, ...) 
        assert(type(env) == "table", "Invalid argument: env")
        assert(type(path) == "string", "Invalid argument: path")
        local compEnv = env
        compEnv["__LEGACY"] = nil
        compEnv["apiUtils"] = nil
        setmetatable(compEnv, {__index = _G})
        local f = __LEGACY.fs.open(path, "r")
        local compFunc, err = load(f.readAll(), path, nil, compEnv)
        f.close()
        if compFunc == nil then
            return false, "Failed to load function: " .. err 
        else
            local ok, err = pcall(compFunc, ...)
            return ok, err
        end
    end,
    loadAPI = function(api)
        assert(type(api) == "string", "Invalid argument: api")
        arcos.log(api)
        local tabEnv = {}
        setmetatable(tabEnv, {__index = _G})
        local f, e = __LEGACY.fs.open(api, "r")
        if not f then
            error(e)
        end
        local funcApi, err = load(f.readAll(), api, nil, tabEnv)
        f.close()
        if funcApi then
            local ok, err = pcall(funcApi)
            if not ok then
                error(err)
            end 
        else
            error(err)
        end
        local tAPI = {}
        for k, v in pairs(tabEnv) do
            if k ~= "_ENV" then
                tAPI[k] =  v
            end
        end
        local s = strsplit(api, "/")
        local v = s[#s]
        if string.sub(v, #v-3) == ".lua" then
            v = v:sub(1, #v-4)
        end 
        arcos.log("Loaded api " .. v)
        _G[v] = tAPI
    end,
    startTimer = function(d) 
        return __LEGACY.os.startTimer(d)
    end
}
-- C:Exc
_G.term = {
    write = function(towrite) end,
    setBackgroundColor = function(col) end,
    setTextColor = function(col) end,
    setCursorPos = function(cx, cy) end
}
-- C:End
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
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
    end
}

_G.devices = {
    get = function(what)
        return peripheral.wrap(what)
    end,
    find = function(what)
        return peripheral.find(what)
    end
}

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
    if arg == "printLog" then
        config["printLogToConsole"] = true
    end
end
arcos.log("Seems like it works")
for i, v in ipairs(__LEGACY.fs.list("/system/apis/")) do
    arcos.log("Loading API: " .. v)
    arcos.loadAPI("/system/apis/" .. v)
    
end 
-- C:Exc
_G.col = require("src.system.apis.col")
_G.red = require("src.system.apis.red")
_G.fs = require("src.system.apis.fs")
-- C:End

local f, err = fs.open("/config/passwd", "r")
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
        apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "173")
    end)
    apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "173")
end, 1, "root", __LEGACY.term)
while true do
    if #tasks > 0 then
        ev = { os.pullEventRaw() }
        for d, i in ipairs(tasks) do
            for _ = 1, i["nice"], 1 do
                _G.term = i["out"] or __LEGACY.term
                if not i["paused"] then
                    currentTask = i
                    cPid = d
                    coroutine.resume(i["crt"], table.unpack(ev))
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
