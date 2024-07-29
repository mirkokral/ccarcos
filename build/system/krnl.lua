local args = {...}
local currentTask
local kernelLogBuffer = ""
local tasks = {}
local config = {
    forceNice = nil,
    init = "/apps/init.lua"
}
__LEGACY.shell.run("rm --rf /temporary/*")
local users = {}
function fetchUsers()
    f = fs.open("/")
end
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
_G.arcos = {
    kernelPanic = function(err, file, line)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.red)
        term.clear()
        term.setCursorPos(1, 1)
        print("--- KERNEL PANIC ---")
        print(err)
        print("" .. file .. " at " .. line)
        print("--------------------")
        tasks = {}
    end,
    getCurrentTask = function()
        return currentTask
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
    loadAPI = function(api)
        assert(type(api) == "string", "Invalid argument: api")
        local tabEnv = {}
        setmetatable(tabEnv, {__index = _G})
        local funcApi, err = loadfile(api, nil, tabEnv)
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
        if string.sub(v, #s-4) == ".lua" then
            v = v:sub(0, #s-5)
        end 
        _G[v] = tAPI
    end
}
_G.tasking = {
    createTask = function(name, callback, nice, user, out)
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
            out = out
        })
    end,
    killTask = function(pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
            user = "root"
        })["user"] then
            table.remove(tasks, pid)
        end
    end,
    getTasks = function(onlyThisUser)
        local returnstuff = {}
        for i, v in ipairs(tasks) do
            table.insert(returnstuff, {
                pid = i,
                name = v["name"],
                user = v["user"],
                nice = v["nice"]
            })
        end
        return returnstuff
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
for i, v in ipairs(__LEGACY.fs.list("/system/apis/")) do
    print("Loading API: " .. v)
    __LEGACY.os.loadAPI("/system/apis/" .. v)
end 
local i = 0
while true do
    i = i + 1
    if args[i] == nil then
        break
    end
    if args[i]:sub(1, 2) ~= "--" then
        arcos.kernelPanic("Invalid argument: " .. args[i], "Kernel", debug.getinfo().currentline)
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
end
tasking.createTask("Init", function()
    local ok, err = pcall(function()
        __LEGACY.shell.run(config["init"])
    end)
    arcos.kernelPanic("Init Died: " .. err, "Kernel", "173")
end, 1, "root", __LEGACY.term)
while true do
    if #tasks > 0 then
        ev = { os.pullEventRaw() }
        for d, i in ipairs(tasks) do
            for _ = 1, i["nice"], 1 do
                _G.term = i["out"]
                coroutine.resume(i["crt"], table.unpack(ev))
            end
            if coroutine.status(i["crt"]) == "dead" then
                table.remove(tasks, d)
            end
        end
    else
        tasking.createTask("Emergency shell", function ()
            term.setBackgroundColor(col.black)
            term.setTextColor(col.white)
            term.clear()
            print("Kernel Emergency Shell System - No tasks.")
            shell.run("shell")
        end, 1, "root", __LEGACY.term)
    end
end
