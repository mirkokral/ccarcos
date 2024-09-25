-- Aligator billiard
-- Bordel pruser margaret
-- Ventilator multikabel
-- Freddy kruger imbecil
runfs = function(dir)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Loading FS at " .. dir .. "\n")
    
    local oldfs = _G.fs
    function removeStartingDDot()
    end
    function od(olddir)
        
        if oldfs.combine(olddir:sub(1, 4)) == "disk" and oldfs.exists(olddir) and oldfs.isDir(olddir) and oldfs.isDriveRoot(olddir) then
            return olddir -- To keep disks
        end
        if oldfs.combine(olddir):sub(1, 3) == "rom" then
            return olddir -- Keep rom directory
        end
        return dir .. "/" ..  oldfs.combine(olddir) 
    end
    function death(state, message)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.red)
        term.clear()
        term.setCursorPos(1, 1)
        local pf = nil
        if print then
            pf = print
        else
            pf = function(f) term.write(f) term.write("\n") end
        end
        pf("An error occured while running operating system")
        pf("During: " .. state)
        pf("Error: " .. message)
        if state == "Running OS" then
            pf("Send this error to your OS developer for further assistance.")
        else
            pf("Send this error to @mirko56 for further assistance.")
        end
        local x,y = term.getSize()
        for i = 10, 1, -1 do
            term.setCursorPos(2, y-1)
            pf("Rebooting in " .. i .. " seconds ")
            sleep(1)
        end
        os.reboot()
        while true do coroutine.yield() end
    end
    if not oldfs.exists(dir .. "/.bios.lua") then
        
        local biosf, e = http.get("https://raw.githubusercontent.com/cc-tweaked/CC-Tweaked/mc-1.20.x/projects/core/src/main/resources/data/computercraft/lua/bios.lua") -- HAHHAHA FUCK YOU CCPL LICENSE GFU
        if not biosf then
            death("Downloading bios", e)
        end
        local illegal = biosf.readAll()
        local biosfiled, bfde = oldfs.open(dir .. "/.bios.lua", "w")
        if not biosfiled then
            death("Writing bios", bfde)
        end
        biosfiled.write(illegal)
        biosf.close()
        biosfiled.close()
    end
    local fakefs = {
        complete = function(path, location, incf, incd)
            return oldfs.complete(path, od(location), incf, incd)
        end,
        find = function(path)
            local df = oldfs.find(dir .. "/" .. path)
            local of = {}
            for index, value in ipairs(df) do
                table.insert(of,value:sub(#dir+1))
                
            end
            return of
        end,
        isDriveRoot = function (path)
            if path == "" or path == "/" then return true end -- Fake the root path being a drive
            return oldfs.isDriveRoot(od(path))
        end,
        list = function(path)
            local out = oldfs.list(od(path))
            if oldfs.combine(path) == "" then
                table.insert(out, "rom")
                for index, value in ipairs(oldfs.list("/")) do
                    if value:sub(1,4) == "disk" and oldfs.isDir(value) and oldfs.isDriveRoot(value) then
                        table.insert(out, value)
                    end
                end
            end
            return out
        end,
        combine = oldfs.combine,
        getName = oldfs.getName,
        getDir = oldfs.getDir,
        getSize = function (path)
            return oldfs.getSize(od(path))
        end,
        exists = function(path)
            return oldfs.exists(od(path))
        end,
        isDir = function(path)
            return oldfs.isDir(od(path))
        end,
        isReadOnly = function(path)
            return oldfs.isReadOnly(od(path))
        end,
        makeDir = function(path)
            return oldfs.makeDir(od(path))
        end,
        move = function(path, dest)
            return oldfs.move(od(path), od(dest))
        end,
        copy = function(path, dest)
            return oldfs.copy(od(path), od(dest))
        end,
        delete = function(path)
            return oldfs.delete(od(path))
        end,
        open = function(path, mode)
            return oldfs.open(od(path), mode)
        end,
        getDrive = function(path)
            if oldfs.combine(path) == "" then
                return "hdd"
            end
            return oldfs.getDrive(od(path))
        end,
        getFreeSpace = function(path)
            return oldfs.getFreeSpace(od(path))
        end,
        getCapacity = function(path)
            return oldfs.getCapacity(od(path))
        end,
        attributes = function(path)
            return oldfs.attributes(od(path))
        end
    }
    local fileToRun = ""
    if oldfs.exists(dir .. "/startup.lua") then
        fileToRun = dir.."/startup.lua"
    else
        fileToRun = "/rom/programs/shell.lua"
    end
    local fd, fde = oldfs.open(fileToRun, "r")
    if not fd then
        death("Opening OS startup", fde)
    end
    local readed = fd.readAll()
    if not readed then
        death("Reading OS startup", "Unknown")
    end
    fd.close()
    local bfd, bfde = oldfs.open(fileToRun, "r")
    if not bfd then
        death("Opening BIOS", fde)
    end
    local breaded = bfd.readAll()
    if not breaded then
        death("Reading BIOS", "Unknown")
    end
    function fix(i, t)
        -- print(i)
        if type(t) == "table" and i ~= "_G" and i ~= "_ENV" then
            local newt = {}
            for key, value in pairs(t) do
                newt[key] = fix(key, value)
            end
            -- print(require("cc.pretty").pretty(newt))
            -- sleep(1)
            return newt
        end
        if type(t) == "function" then
            local ta = t
            pcall(setfenv, ta, env)
            return ta
        end
        return t
    end
    bfd.close()
    local env = {}
    for k,va in pairs(_G) do
        local v = va
        
        env[k] = fix(k, v)
        
    end
    env["fs"] = fakefs
    env["xe7oldfs"] = oldfs
    
    env["_G"] = env
    local deleteApis = {"io", "gps"}
    for index, value in ipairs(deleteApis) do
        env[value] = nil
    end
    for index,value in ipairs(deleteApis) do
        le = setmetatable({}, {__index = env})
        loadfile("/rom/apis/" .. value .. ".lua", "t", le)()
        env[value] = {}
        for index2, value2 in pairs(le) do
            if index ~= "_ENV" then
                env[value][index2] = value2
            end
        end
    end
    local lf, lfe = load("os.run(_G, \"/rom/programs/shell.lua\")", "startup.lua", "t", env)
    setfenv(lf, env)
    if not getfenv(lf)["xe7oldfs"] then
        death("Faking FS", "Environment failure")
    end
    if not lf then
        death("Running OS", lfe)
    end
    local st, ste = pcall(lf);
    -- if not st then
        death("Running OS", ste)
    -- end
end