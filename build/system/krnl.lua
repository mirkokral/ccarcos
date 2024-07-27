local args = {...}
local currentTask
local kernelLogBuffer = ""
local tasks = {}
local config = {
    forceNice = nil,

}
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
            write("\nEnter privilige password")
            read()
        end

        table.insert(tasks, {
            name = name,
            crt = coroutine.create(callback),
            nice = nice,
            user = user
        })
    end,
    getTasks = function(onlyThisUser)
    
    end
}

local i = 0

while true
do
    i = i + 1
    if args[i] == nil then
        break
    end
    if args[i]:sub(1, 2) ~= "--" then
        arcos.kernelPanic("Invalid argument: " .. args[i], "Kernel", debug.getinfo().currentline)
    end
    local arg = string.sub(args[i], 3)
    if arg == "forceNice" then
        i=i+1
        config["forceNice"] = tonumber(args[i])
    end
end