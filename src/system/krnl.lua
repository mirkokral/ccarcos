local args = {...}
local currentTask
local kernelLogBuffer = ""
local tasks = {}
local config = {
    forceNice = nil

}

-- C:Exc
function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

-- C:End

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
    end
}

_G.tasking = {
    createTask = function(name, callback, nice, user)
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
            user = user
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
end
tasking.createTask("Shell", function()
    while true do
        print("Task 1")
        coroutine.yield()
    end
end, 1, "root")
tasking.createTask("Test2", function()
    while true do
        print("Task 2")
        coroutine.yield()
    end
end, 1, "root")
while true do
    if #tasks > 0 then
        for _, i in ipairs(tasks) do
            for _ = 1, i["nice"], 1 do
                coroutine.resume(i["crt"], os.pullEvent())
            end
        end
    else
        print("No tasks")
        sleep(5)
        error()
    end
    sleep()
end
