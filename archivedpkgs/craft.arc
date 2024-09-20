|/apis|-1|
|/apps|-1|
|/data|-1|
|data/craft|-1|
|data/craft/util|-1|
|/index|0|
|apis/_CEXPORTS.lua|136|
|apps/craft.lua|405|
|apps/edit.lua|16971|
|data/craft/util/startup.lua|17014|
--ENDTABLE
d>apis
f>apis/_CEXPORTS.lua
d>apps
f>apps/craft.lua
f>apps/edit.lua
d>data
d>data/craft
d>data/craft/util
f>data/craft/util/startup.lua
-- This api only exists to replace the getfenv magic used by craft.lua.
-- This api is not meant to be used by anything else
return {
    paintutils = __LEGACY.paintutils,
    settings = __LEGACY.settings,
    textutils = __LEGACY.textutils,
    help = __LEGACY.help,
}local craftos_env = {}
for key, value in pairs(_G) do
    craftos_env[key] = value
end
if not _CEXPORTS then
    print("No _CEXPORTS!\nTry restarting your computer or reinstalling the package.")
    error()
end
craftos_env.colors = col
craftos_env.colours = col
craftos_env.disk = {
    isDrive = function(name)
        col.expect(1, name, "string")
        return devices.type(name) == "drive"
    end,
    isPresent = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).isDiskPresent()
        end
        return nil
    end,
    getLabel = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).getDiskLabel()
        end
        return nil
    end,
    hasData = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).hasData()
        end
        return nil
    end,
    getMountPath = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).getMountPath()
        end
        return nil
    end,
    hasAudio = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).hasAudio()
        end
        return nil
    end,
    getAudioTitle = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).getAudioTitle()
        end
        return nil
    end,
    playAudio = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).playAudio()
        end
        return nil
    end,
    stopAudio = function(name)
        if name then
            if craftos_env.disk.isDrive(name) then
                return devices.get(name).playAudio()
            end
        else
            for k, v in ipairs(devices.names()) do
                craftos_env.disk.stopAudio(v)
            end
        end
        return nil
    end,
    eject = function(name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).eject()
        end
        return nil
    end,
    
    setLabel = function(name, label)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).setDiskLabel(label)
        end
        return nil
    end,
    getId = function (name)
        if craftos_env.disk.isDrive(name) then
            return devices.get(name).getDiskID()
        end
        return nil
    end
}

craftos_env.fs = {
    complete = files.complete,
    find = files.find,
    isDriveRoot = files.driveRoot,
    list = files.ls,
    combine = files.combine,
    getName = files.name,
    getDir = files.par,
    getSize = files.size,
    exists = files.exists,
    isDir = files.dir,
    isReadOnly = files.readonly,
    makeDir = files.mkDir,
    move = files.m,
    copy = files.c,
    delete = files.rm,
    open = function (path, mode)
        local f, e = files.open(path, mode)
        if not f then return f, e end
        local rt = {}
        rt.close = f.close
        rt.write = f.write
        rt.readAll = f.read
        rt.read = f.read
        rt.readLine = f.readLine
        rt.seek = f.seekBytes
        rt.writeLine = f.writeLine
        rt.isOpen = function() return f.open end
        return rt

    end,
    getDrive = files.drive,
    getFreeSpace = files.freeSpace,
    getCapacity = files.capacity,
    attributes = files.attributes
}
craftos_env.os = {
    loadAPI = function (...)
        error("Not supported because of deprecation")
    end,
    unloadAPI = function (...)
        error("Not supported because of deprecation")
    end,
    pullEvent = arcos.ev,
    pullEventRaw = arcos.rev,
    sleep = sleep,
    version = function() return "CraftOS 1.8 Compat on " .. arcos.version() end, 
    run = arcos.r,
    queueEvent = arcos.queue,
    startTimer = arcos.startTimer,
    cancelTimer = arcos.cancelTimer,
    setAlarm = arcos.setAlarm,
    cancelAlarm = arcos.cancelAlarm,
    shutdown = arcos.shutdown,
    getComputerID = function() return arcos.id end,
    computerID = function() return arcos.id end,
    computerLabel = function() return arcos.getName() end,
    getComputerLabel = function() return arcos.getName() end,
    setComputerLabel = function(lbl) return arcos.setName(lbl) end,
    clock = arcos.clock,
    time = arcos.time,
    day = arcos.day,
    epoch = arcos.epoch,
    date = arcos.date,
}

local function makeRt(s)
    local rt = {}
    rt._closed = not s.open or false
    rt._autoclose = false
    rt.f = s
    rt.close = function(self) self.f.close() self._closed = not self.f.open end
    rt.flush = function(self) self.f.flush() end

    rt.read = function (self, ...)
        local f = self.f
        local output = {}
        if not f.open then
            error("attempt to use a closed file", 2)
        end
        if not f.read and not f.readLine then return nil, "Not opened for reading" end
        for i = 1, #{ ... } do
            local arg = ({ ... })[i]
            local res
            if type(arg) == "number" then
                if f.readBytes then
                    res = f.readBytes(arg)
                end
            elseif type(arg) == "string" then
                local format = arg:gsub("^%*", ""):sub(1, 1)
                if format == "l" then
                    if f.readLine then res = f.readLine() end
                elseif format == "L" then
                    if f.readLine then res = f.readLine() .. "\n" end
                elseif format == "a" then
                    if f.read then res = f.read() end
                elseif format == "n" then
                    res = nil
                else
                    error("bad argument #" .. i .. "(string expected)", 2)
                end
            end
            output[i] = res
            if not res then break end
        end
        -- Default to "l" if possible
        if #({ ... }) == 0 and f.readLine then return f.readLine() end
        return table.unpack(output, 1, #({ ... }))
    end
    rt.seek = function(self, whence, offset)
        if not self.f.open then error("attempt to use a closed file", 2) end

        local handle = f
        if not handle.seekBytes then return nil, "file is not seekable" end

        -- It's a tail call, so error positions are preserved
        return handle.seekBytes(whence, offset)
    end
    rt.setvbuf = function(self, m, s) end
    rt.write = function(self, ...) 
        if not self.f.open then error("attempt to use a closed file", 2) end

        local handle = f
        if not handle.write then return nil, "file is not writable" end

        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            col.expect(i, arg, "string", "number")
            handle.write(arg)
        end
        return rt
    end
    rt.lines = function(self,...) 
        if not self.f.open then
            error("attempt to use a closed file", 2)
        end
        if not self.f.read then
            return nil, "File is not readable"
        end
        local args = table.pack(...)
        return function ()
            if not self.f.open then
                error("file closed", 2)
                local f = self:read(table.unpack(args))
                if f == nil and self._autoclose and not self._closed then
                    self:close()
                end
            end
        end

    end
    return rt, nil
end

craftos_env.io = {
    CURRENT_INPUT_FILE = makeRt({readLine = _G.read}),
    CURRENT_OUTPUT_FILE = makeRt({write = _G.write}),
    stdIn = makeRt({readLine = _G.read}),
    stdOut = makeRt({write = _G.write }),
    stdErr = makeRt({write = _G.write }),
    open = function (fname, mode)
        if not mode then mode = "r" end
        local f, e = files.open(fname, mode)
        if not f then return f, e end
        return makeRt(f)
    end,
    input = function(f) 
        if not f then return craftos_env.io.CURRENT_INPUT_FILE end
        if f then craftos_env.io.CURRENT_INPUT_FILE = f end
    end,
    output = function(f) 
        if not f then return craftos_env.io.CURRENT_OUTPUT_FILE end
        if f then craftos_env.io.CURRENT_OUTPUT_FILE = f end
    end,
    close = function(file)
        file:close()
    end,
    flush = function()
        return craftos_env.io.CURRENT_OUTPUT_FILE:flush()
    end,
    lines = function(filename, ...)
        col.expect(1, filename, "string", "nil")
        if filename then
            local fr, e = craftos_env.io.open(filename, "r")
            if not fr then error(e, 2) end
            fr._autoclose = true
            return fr:lines(...)
        else
            return craftos_env.io.CURRENT_INPUT_FILE:lines(...)
        end
        
    end,
    read = function(...)
        return craftos_env.io.input():read(...)
    end,
    type = function(obj)
        if type(obj) == "table" and obj.close and obj.seek then
            if obj.f.open then
                return "file"
            else
                return "closed file"
            end
        end
        return nil
    end,
    write = function(...)
        return craftos_env.io.CURRENT_OUTPUT_FILE:write(...)
    end
}

craftos_env.keys = {

}
local tKeys = {}
tKeys[32] = 'space'
tKeys[39] = 'apostrophe'
tKeys[44] = 'comma'
tKeys[45] = 'minus'
tKeys[46] = 'period'
tKeys[47] = 'slash'
tKeys[48] = 'zero'
tKeys[49] = 'one'
tKeys[50] = 'two'
tKeys[51] = 'three'
tKeys[52] = 'four'
tKeys[53] = 'five'
tKeys[54] = 'six'
tKeys[55] = 'seven'
tKeys[56] = 'eight'
tKeys[57] = 'nine'
tKeys[59] = 'semicolon'
tKeys[61] = 'equals'
tKeys[65] = 'a'
tKeys[66] = 'b'
tKeys[67] = 'c'
tKeys[68] = 'd'
tKeys[69] = 'e'
tKeys[70] = 'f'
tKeys[71] = 'g'
tKeys[72] = 'h'
tKeys[73] = 'i'
tKeys[74] = 'j'
tKeys[75] = 'k'
tKeys[76] = 'l'
tKeys[77] = 'm'
tKeys[78] = 'n'
tKeys[79] = 'o'
tKeys[80] = 'p'
tKeys[81] = 'q'
tKeys[82] = 'r'
tKeys[83] = 's'
tKeys[84] = 't'
tKeys[85] = 'u'
tKeys[86] = 'v'
tKeys[87] = 'w'
tKeys[88] = 'x'
tKeys[89] = 'y'
tKeys[90] = 'z'
tKeys[91] = 'leftBracket'
tKeys[92] = 'backslash'
tKeys[93] = 'rightBracket'
tKeys[96] = 'grave'
tKeys[161] = 'world1'
tKeys[162] = 'world2'
tKeys[257] = 'enter'
tKeys[258] = 'tab'
tKeys[259] = 'backspace'
tKeys[260] = 'insert'
tKeys[261] = 'delete'
tKeys[262] = 'right'
tKeys[263] = 'left'
tKeys[264] = 'down'
tKeys[265] = 'up'
tKeys[266] = 'pageUp'
tKeys[267] = 'pageDown'
tKeys[268] = 'home'
tKeys[269] = 'end'
tKeys[280] = 'capsLock'
tKeys[281] = 'scrollLock'
tKeys[282] = 'numLock'
tKeys[283] = 'printScreen'
tKeys[284] = 'pause'
tKeys[290] = 'f1'
tKeys[291] = 'f2'
tKeys[292] = 'f3'
tKeys[293] = 'f4'
tKeys[294] = 'f5'
tKeys[295] = 'f6'
tKeys[296] = 'f7'
tKeys[297] = 'f8'
tKeys[298] = 'f9'
tKeys[299] = 'f10'
tKeys[300] = 'f11'
tKeys[301] = 'f12'
tKeys[302] = 'f13'
tKeys[303] = 'f14'
tKeys[304] = 'f15'
tKeys[305] = 'f16'
tKeys[306] = 'f17'
tKeys[307] = 'f18'
tKeys[308] = 'f19'
tKeys[309] = 'f20'
tKeys[310] = 'f21'
tKeys[311] = 'f22'
tKeys[312] = 'f23'
tKeys[313] = 'f24'
tKeys[314] = 'f25'
tKeys[320] = 'numPad0'
tKeys[321] = 'numPad1'
tKeys[322] = 'numPad2'
tKeys[323] = 'numPad3'
tKeys[324] = 'numPad4'
tKeys[325] = 'numPad5'
tKeys[326] = 'numPad6'
tKeys[327] = 'numPad7'
tKeys[328] = 'numPad8'
tKeys[329] = 'numPad9'
tKeys[330] = 'numPadDecimal'
tKeys[331] = 'numPadDivide'
tKeys[332] = 'numPadMultiply'
tKeys[333] = 'numPadSubtract'
tKeys[334] = 'numPadAdd'
tKeys[335] = 'numPadEnter'
tKeys[336] = 'numPadEqual'
tKeys[340] = 'leftShift'
tKeys[341] = 'leftCtrl'
tKeys[342] = 'leftAlt'
tKeys[343] = 'leftSuper'
tKeys[344] = 'rightShift'
tKeys[345] = 'rightCtrl'
tKeys[346] = 'rightAlt'
tKeys[347] = 'rightSuper'
tKeys[348] = 'menu'
for nKey, sKey in pairs(tKeys) do
    craftos_env.keys[sKey] = nKey
    
end
craftos_env.keys["return"] = craftos_env.keys.enter
craftos_env.keys["scollLock"] = craftos_env.keys.scrollLock
craftos_env.keys["cimcumflex"] = craftos_env.keys.circumflex
craftos_env.keys.getName = function(keyIndex)
    col.expect(1, keyIndex, "number")
    return tKeys[keyIndex]
end

craftos_env.paintutils = _CEXPORTS.paintutils
craftos_env.settings = _CEXPORTS.settings
craftos_env.textutils = _CEXPORTS.textutils
craftos_env.help = _CEXPORTS.help
craftos_env.window = window
craftos_env.parallel = {
    waitForAll = function (...)
        local tasks = {}
        for index, value in ipairs(table.pack(...)) do
            table.insert(tasks, tasking.createTask(
                "Parallel task #" .. index .. " from " .. arcos.getCurrentTask().name,
                function ()
                    value()
                end,
                1,
                arcos.getCurrentTask().user,
                term,
                environ
            ))
        end
        -- local r = true
        while true do
            local runningTasks = {}
            for index, value in ipairs(tasking.getTasks()) do
                for index2, value2 in ipairs(tasks) do
                    if value.pid == value2.pid then
                        table.insert(runningTasks, value2.pid)
                    end
                end
            end
            if #runningTasks == 0 then
                break
            end

        end
        for index, value in ipairs(tasks) do
            tasking.killTask(value)
        end
    end,
    waitForAny = function (...)
        local tasks = {}
        for index, value in ipairs(table.pack(...)) do
            table.insert(tasks, tasking.createTask(
                "Parallel task #" .. index .. " from " .. arcos.getCurrentTask().name,
                function ()
                    value()
                end,
                1,
                arcos.getCurrentTask().user,
                term,
                environ
            ))
        end
        -- local r = true
        while true do
            local runningTasks = {}
            for index, value in ipairs(tasking.getTasks()) do
                for index2, value2 in ipairs(tasks) do
                    if value.pid == value2.pid then
                        table.insert(runningTasks, value2.pid)
                    end
                end
            end
            if #runningTasks < #tasks then
                break
            end

        end
        for index, value in ipairs(tasks) do
            tasking.killTask(value)
        end
    end
}
craftos_env.peripheral = {
    getNames = devices.names,
    getName = devices.name,
    isPresent = devices.present,
    getType = devices.type,
    hasType = devices.hasType,
    getMethods = devices.methods,
    call = devices.call,
    wrap = devices.get,
    find = devices.find
}
craftos_env.rednet = rednet
craftos_env.redstone = {
    getSides = function () return {"top", "bottom", "left", "right", "front", "back"} end,
    setOutput = function(side, on) 
        rd.setO(side, on)
    end,
    getOutput = function(side)
        return rd.getO(side) > 0
    end,
    getInput = function(side)
        return rd.getI(side) > 0
    end,
    setAnalogOutput = function(side, on) 
        rd.setO(side, on)
    end,
    getAnalogOutput = function(side)
        return rd.getO(side)
    end,
    getAnalogInput = function(side)
        return rd.getI(side)
    end,
    setAnalogueOutput = function(side, on) 
        rd.setO(side, on)
    end,
    getAnalogueOutput = function(side)
        return rd.getO(side)
    end,
    getAnalogueInput = function(side)
        return rd.getI(side)
    end,
    setBundledOutput = function(side, bitmask)
        return rd.setBO(side, bitmask)
    end,
    getBundledOutput = function(side)
        return rd.getBO(side)
    end,
    getBundledInput = function(side)
        return rd.getBI(side)
    end,
    testBundledInput = function(side, test)
        return rd.testBI(side, test)
    end
        
}
craftos_env._G = setmetatable({}, {__index = craftos_env, __newindex = craftos_env})
craftos_env.getmetatable = getmetatable
craftos_env.setmetatable = setmetatable
craftos_env.setfenv = setfenv
craftos_env.getfenv = getfenv
craftos_env.getupvalue = debug.getupvalue
craftos_env.expect = col.expect
craftos_env.shell = nil
craftos_env.loadfile = function(file, mode, env)
    local f, e = files.open(file, "r")
    if not f then error(e) end
    local funct, ferr = load("return (function() " ..  f.read() .. " end)", files.name(file), nil, env)
    if not funct then
        error(ferr)
    end
    return funct()
end
craftos_env.dofile = function(file)
    return craftos_env.loadfile(file, nil, craftos_env)()
end
local ok, err = arcos.r(craftos_env, "/rom/programs/shell.lua", "/data/craft/util/startup.lua", ...)
if not ok then printError(err) endarcos.r({}, "/apps/craft.lua", "edit", ...)shell.setDir(environ.workDir)
term.setBackgroundColor(col.black)
term.setTextColor(col.white)
term.clear()
term.setCursorPos(1, 1)
shell.run("shell", ...)