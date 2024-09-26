|/system|-1|
|/user|-1|
|/temporary|-1|
|/services|-1|
|/data|-1|
|/config|-1|
|/apps|-1|
|/apis|-1|
|system/apis|-1|
|services/enabled|-1|
|config/apps|-1|
|/startup.lua|0|
|system/bootloader.lua|14961|
|system/rel|15910|
|system/krnl.lua|15916|
|system/apis/arc.lua|36893|
|system/apis/col.lua|50192|
|system/apis/files.lua|54316|
|system/apis/hashing.lua|65724|
|system/apis/rd.lua|70359|
|system/apis/tutils.lua|71363|
|system/apis/ui.lua|72505|
|system/apis/window.lua|93711|
|system/apis/cellui.lua|108800|
|services/arcfix.lua|252674|
|services/elevator.lua|252759|
|services/elevatorSrv.lua|255077|
|services/elevatorStep.lua|258133|
|services/oobe.lua|258725|
|services/pms.lua|264470|
|services/shell.lua|268050|
|services/enabled/9 arcfix|268080|
|services/enabled/login|268093|
|data/PRIVACY.txt|268103|
|config/aboot|268992|
|config/arcrepo|269152|
|config/arcshell|269169|
|config/hostname|269221|
|config/passwd|269226|
|apps/adduser.lua|269476|
|apps/arc.lua|269990|
|apps/cat.lua|273077|
|apps/cd.lua|273353|
|apps/cp.lua|273682|
|apps/init.lua|273951|
|apps/kmsg.lua|277170|
|apps/ls.lua|277219|
|apps/mkdir.lua|277892|
|apps/mv.lua|278038|
|apps/rm.lua|278307|
|apps/rmuser.lua|278489|
|apps/shell.lua|278893|
|apps/uitest.lua|282726|
|apps/clear.lua|288103|
|apps/shutdown.lua|288139|
|apps/reboot.lua|288155|
|apps/celluitest.lua|288169|
--ENDTABLE
if arcos then return end
term.clear()
local UIthemedefs = {
}
UIthemedefs[colors.white] = { 236, 239, 244 }
UIthemedefs[colors.orange] = { 0, 0, 0 }
UIthemedefs[colors.magenta] = { 180, 142, 173 }
UIthemedefs[colors.lightBlue] = { 0, 0, 0 }
UIthemedefs[colors.yellow] = { 235, 203, 139 }
UIthemedefs[colors.lime] = { 163, 190, 140 }
UIthemedefs[colors.pink] = { 0, 0, 0 }
UIthemedefs[colors.gray] = { 76, 86, 106 }
UIthemedefs[colors.lightGray] = { 146, 154, 170 }
UIthemedefs[colors.cyan] = { 136, 192, 208 }
UIthemedefs[colors.purple] = { 0, 0, 0 }
UIthemedefs[colors.blue] = { 129, 161, 193 }
UIthemedefs[colors.brown] = { 0, 0, 0 }
UIthemedefs[colors.green] = { 163, 190, 140 }
UIthemedefs[colors.red] = { 191, 97, 106 }
UIthemedefs[colors.black] = { 59, 66, 82 }
for index, value in pairs(UIthemedefs) do
  term.setPaletteColor(index, value[1] / 255, value[2] / 255, value[3] / 255)
end
function _G.utd() end
local live = ({ ... })[1] == "live"
if not live then
  local configFile, err = fs.open("/config/aboot", "r")
  if not configFile then configFile = { autoUpdate = true } end -- Fallback
  local f = textutils.unserialiseJSON(configFile.readAll())
  configFile.close()
end
if live then
  if not fs.exists("/config/settings") then
    local f, e = fs.open("/config/settings", "w")
    local f2, e2 = fs.open("/.settings", "r")
    if f and f2 then
      f.write(f2.readAll())
    end
    if f then
      f.close()
    end
    if f2 then
      f2.close()
    end
  end
else
  if not fs.exists("/.arcliveenv/config/settings") then
    local f, e = fs.open("/.arcliveenv/config/settings", "w")
    local f2, e2 = fs.open("/.settings", "r")
    if f and f2 then
      f.write(f2.readAll())
    end
    if f then
      f.close()
    end
    if f2 then
      f2.close()
    end
  end
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
local oldprr = os.pullEventRaw
local oldpe = os.pullEvent
local oldtr = term.redirect
local oldtn = term.native
local oldst = os.shutdown
local olderr = error
_G.__LEGACY = {}
for key, value in pairs(_G) do
  __LEGACY[key] = value
end
__LEGACY.ofs = __LEGACY.fs
if live then
  __LEGACY.fs = {
    list = function(f)
      return __LEGACY.ofs.list("/.arcliveenv/" .. f)
    end,
    delete = function(f)
      return __LEGACY.ofs.delete("/.arcliveenv/" .. f)
    end,
    exists = function(f)
      return __LEGACY.ofs.exists("/.arcliveenv/" .. f)
    end,
    makeDir = function(f)
      return __LEGACY.ofs.makeDir("/.arcliveenv/" .. f)
    end,
    isDir = function(f)
      return __LEGACY.ofs.isDir("/.arcliveenv/" .. f)
    end,
    move = function(f, k)
      return __LEGACY.ofs.move("/.arcliveenv/" .. f, "/.arcliveenv/" .. f)
    end,
    copy = function(f, k)
      return __LEGACY.ofs.copy("/.arcliveenv/" .. f, "/.arcliveenv/" .. f)
    end,
    open = function(o, m)
      return __LEGACY.ofs.open("/.arcliveenv/" .. o, m)
    end,
    complete = function(path, loc, ...)
      return __LEGACY.ofs.complete(path, "/.arcliveenv/" .. loc, ...)
    end,
    find = function(loc)
      return __LEGACY.ofs.find("/.arcliveenv/" .. loc)
    end,
    isDriveRoot = function(path)
      if path == "/" or path == "" then return true end
      return __LEGACY.ofs.isDriveRoot("/.arcliveenv/" .. loc)
    end,
    combine = __LEGACY.ofs.combine,
    getName = __LEGACY.ofs.getName,
    getDir = __LEGACY.ofs.getDir,
    getSize = function(f)
      return __LEGACY.ofs.getSize("/.arcliveenv/" .. f)
    end,
    isReadOnly = function(f)
      return __LEGACY.ofs.isReadOnly("/.arcliveenv/" .. f)
    end,
    getDrive = function(f)
      return __LEGACY.ofs.getDrive("/.arcliveenv/" .. f)
    end,
    getFreeSpace = function(f)
      return __LEGACY.ofs.getFreeSpace("/.arcliveenv/" .. f)
    end,
    getCapacity = function(f)
      return __LEGACY.ofs.getCapacity("/.arcliveenv/" .. f)
    end,
    attributes = function(f)
      return __LEGACY.ofs.attributes("/.arcliveenv/" .. f)
    end
  }
end
__LEGACY.files = __LEGACY.fs
setmetatable(__LEGACY, {
  __index = function(self, i)
    if i == "_G" or i == "_ENV" then return __LEGACY end
  end
})
local function fix(f, l)
  return f
end
for k, v in pairs(__LEGACY) do
  if k ~= "_G" and k ~= "_ENV" and k ~= "__LEGACY" then
    __LEGACY[k] = fix(v, k)
  end
end
local keptAPIs = { utd = true, printError = true, require = true, print = true, write = true, read = true, keys = true, __LEGACY = true, bit32 = true, bit = true, ccemux = true, config = true, coroutine = true, debug = true, fs = true, http = true, mounter = true, os = true, periphemu = true, peripheral = true, redstone = true, rs = true, term = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
local t = {}
for k in pairs(_G) do if not keptAPIs[k] then table.insert(t, k) end end
for _, k in ipairs(t) do _G[k] = nil end
_G.http.checkURL = _G.http.checkURLAsync
_G.http.websocket = _G.http.websocketAsync
if _G.commands then _G.commands = _G.commands.native end
if _G.turtle then _G.turtle.native, _G.turtle.craft = nil end
local delete = { os = { "version", "pullEventRaw", "pullEvent", "run", "loadAPI", "unloadAPI", "sleep" }, http = { "get", "post", "put", "delete", "patch", "options", "head", "trace", "listen", "checkURLAsync", "websocketAsync" }, fs = { "complete", "isDriveRoot" } }
for k, v in pairs(delete) do for _, a in ipairs(v) do _G[k][a] = nil end end
_G.term.redirect = function() end
_G.error = function() end
_G.read = function(_sReplaceChar, _tHistory, _fnComplete, _sDefault)
  term.setCursorBlink(true)
  local sLine
  if type(_sDefault) == "string" then
    sLine = _sDefault
  else
    sLine = ""
  end
  local nHistoryPos
  local nPos, nScroll = #sLine, 0
  if _sReplaceChar then
    _sReplaceChar = string.sub(_sReplaceChar, 1, 1)
  end
  local tCompletions
  local nCompletion
  local function recomplete()
    if _fnComplete and nPos == #sLine then
      tCompletions = _fnComplete(sLine)
      if tCompletions and #tCompletions > 0 then
        nCompletion = 1
      else
        nCompletion = nil
      end
    else
      tCompletions = nil
      nCompletion = nil
    end
  end
  local function uncomplete()
    tCompletions = nil
    nCompletion = nil
  end
  local w = term.getSize()
  local sx = term.getCursorPos()
  local function redraw(_bClear)
    local cursor_pos = nPos - nScroll
    if sx + cursor_pos >= w then
      nScroll = sx + nPos - w
    elseif cursor_pos < 0 then
      nScroll = nPos
    end
    local _, cy = term.getCursorPos()
    term.setCursorPos(sx, cy)
    local sReplace = _bClear and " " or _sReplaceChar
    if sReplace then
      term.write(string.rep(sReplace, math.max(#sLine - nScroll, 0)))
    else
      term.write(string.sub(sLine, nScroll + 1))
    end
    if nCompletion then
      local sCompletion = tCompletions[nCompletion]
      local oldText, oldBg
      if not _bClear then
        oldText = term.getTextColor()
        oldBg = term.getBackgroundColor()
        term.setTextColor(__LEGACY.colors.white)
        term.setBackgroundColor(__LEGACY.colors.gray)
      end
      if sReplace then
        term.write(string.rep(sReplace, #sCompletion))
      else
        term.write(sCompletion)
      end
      if not _bClear then
        term.setTextColor(oldText)
        term.setBackgroundColor(oldBg)
      end
    end
    term.setCursorPos(sx + nPos - nScroll, cy)
  end
  local function clear()
    redraw(true)
  end
  recomplete()
  redraw()
  local function acceptCompletion()
    if nCompletion then
      clear()
      local sCompletion = tCompletions[nCompletion]
      sLine = sLine .. sCompletion
      nPos = #sLine
      recomplete()
      redraw()
    end
  end
  while true do
    local sEvent, param, param1, param2 = coroutine.yield()
    if sEvent == "char" then
      clear()
      sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
      nPos = nPos + 1
      recomplete()
      redraw()
    elseif sEvent == "paste" then
      clear()
      sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
      nPos = nPos + #param
      recomplete()
      redraw()
    elseif sEvent == "key" then
      if param == __LEGACY.keys.enter or param == __LEGACY.keys.numPadEnter then
        if nCompletion then
          clear()
          uncomplete()
          redraw()
        end
        break
      elseif param == __LEGACY.keys.left then
        if nPos > 0 then
          clear()
          nPos = nPos - 1
          recomplete()
          redraw()
        end
      elseif param == __LEGACY.keys.right then
        if nPos < #sLine then
          clear()
          nPos = nPos + 1
          recomplete()
          redraw()
        else
          acceptCompletion()
        end
      elseif param == __LEGACY.keys.up or param == __LEGACY.keys.down then
        if nCompletion then
          clear()
          if param == __LEGACY.keys.up then
            nCompletion = nCompletion - 1
            if nCompletion < 1 then
              nCompletion = #tCompletions
            end
          elseif param == __LEGACY.keys.down then
            nCompletion = nCompletion + 1
            if nCompletion > #tCompletions then
              nCompletion = 1
            end
          end
          redraw()
        elseif _tHistory then
          clear()
          if param == __LEGACY.keys.up then
            if nHistoryPos == nil then
              if #_tHistory > 0 then
                nHistoryPos = #_tHistory
              end
            elseif nHistoryPos > 1 then
              nHistoryPos = nHistoryPos - 1
            end
          else
            if nHistoryPos == #_tHistory then
              nHistoryPos = nil
            elseif nHistoryPos ~= nil then
              nHistoryPos = nHistoryPos + 1
            end
          end
          if nHistoryPos then
            sLine = _tHistory[nHistoryPos]
            nPos, nScroll = #sLine, 0
          else
            sLine = ""
            nPos, nScroll = 0, 0
          end
          uncomplete()
          redraw()
        end
      elseif param == __LEGACY.keys.backspace then
        if nPos > 0 then
          clear()
          sLine = string.sub(sLine, 1, nPos - 1) .. string.sub(sLine, nPos + 1)
          nPos = nPos - 1
          if nScroll > 0 then nScroll = nScroll - 1 end
          recomplete()
          redraw()
        end
      elseif param == __LEGACY.keys.home then
        if nPos > 0 then
          clear()
          nPos = 0
          recomplete()
          redraw()
        end
      elseif param == __LEGACY.keys.delete then
        if nPos < #sLine then
          clear()
          sLine = string.sub(sLine, 1, nPos) .. string.sub(sLine, nPos + 2)
          recomplete()
          redraw()
        end
      elseif param == __LEGACY.keys["end"] then
        if nPos < #sLine then
          clear()
          nPos = #sLine
          recomplete()
          redraw()
        end
      elseif param == __LEGACY.keys.tab then
        acceptCompletion()
      end
    elseif sEvent == "mouse_click" or sEvent == "mouse_drag" and param == 1 then
      local _, cy = term.getCursorPos()
      if param1 >= sx and param1 <= w and param2 == cy then
        nPos = math.min(math.max(nScroll + param1 - sx, 0), #sLine)
        redraw()
      end
    elseif sEvent == "term_resize" then
      w = term.getSize()
      redraw()
    end
  end
  local _, cy = term.getCursorPos()
  term.setCursorBlink(false)
  term.setCursorPos(0, cy)
  write("\n")
  return sLine
end
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
_G.write = function(...)
  local args = table.pack(...)
  if #args < 1 then return end
  local ox, oy = term.getCursorPos()
  local sx, sy = term.getSize()
  local wordsToPrint = {}
  for i = 1, args.n do
    local word = args[i]
    for i = 0, #word do
      ox, oy = term.getCursorPos()
      local char = string.sub(word, i, i)
      if char == "\n" then
        term.setCursorPos(1, oy + 1)
        if table.pack(term.getCursorPos())[2] > sy then
          term.scroll(1)
          term.setCursorPos(1, sy)
        end
      else
        term.write(char)
      end
      ox, oy = term.getCursorPos()
      if table.pack(term.getCursorPos())[1] > sx then
        term.setCursorPos(1, oy + 1)
        if table.pack(term.getCursorPos())[2] > sy then
          term.scroll(1)
          term.setCursorPos(1, sy)
        end
      end
    end
  end
end
_G.print = function(...)
  if #{ ... } == 0 or ({ ... })[1] == nil then
    write("\n")
    return
  end
  write(..., "\n")
end
setfenv(utd, __LEGACY)
function _G.term.native()
  _G.error = olderr
  _G.term.native = oldtn
  _G.os.pullEventRaw = oldprr
  _G.os.pullEvent = oldpe
  print("Successful escape")
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(__LEGACY.colors.white)
  function os.shutdown()
    _G.term.redirect = oldtr
    os.shutdown = oldst
    local oldug = {}
    for k, v in pairs(_G) do
      oldug[k] = v
    end
    local keptAPIs = { utd = true, printError = true, require = true, print = true, write = true, read = true, keys = true, __LEGACY = true, bit32 = true, bit = true, coroutine = true, debug = true, term = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
    local t = {}
    for k in pairs(_G) do if not keptAPIs[k] then table.insert(t, k) end end
    for _, k in ipairs(t) do _G[k] = nil end
    local f = __LEGACY.files.open("/system/bootloader.lua", "r")
    local ok, err = pcall(load(f.readAll(), "Bootloader", nil, _G))
    print(err)
    while true do
      coroutine.yield()
    end
  end
end
coroutine.yield()
function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end
function main()
    local cf = __LEGACY.files.open("/config/aboot", "r")
    local config = __LEGACY.textutils.unserialiseJSON(cf.readAll())
    cf.close()
    __LEGACY.term.setTextColor(__LEGACY.colors[config["theme"]["fg"]])
    __LEGACY.term.setBackgroundColor(__LEGACY.colors[config["theme"]["bg"]])
    __LEGACY.term.clear()
    __LEGACY.term.setCursorPos(1, 1)
    local args = config["defargs"] or ""
    if not config["skipPrompt"] then
        write("krnl: ")
        args = read()
    end
    local f = __LEGACY.files.open("/system/krnl.lua", "r")
    local fn, e = load(f.readAll(), "/system/krnl.lua", nil, setmetatable({}, {__index = _G}))
    if not fn then error(e) end
    fn(table.unpack(mysplit(args, " ")))
end
main()
brokenlocal args = {...}
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
local oldw = _G.write
_G.write = function(...)
    local isNextSetC = false
    local nextCommand = ""
    local args = {...}
    for i, v in ipairs(args) do
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
    kernelPanic = function(err, file, line)
        kpError = "Suspected location: " .. file .. ":" .. line .. "\n" .. "Error: " .. err
        tasks = {}
    end
}
_G.arcos = {
    reboot = function ()
        __LEGACY.os.reboot()
    end,
    shutdown = function ()
        __LEGACY.os.shutdown()
        apiUtils.kernelPanic("Failed to turn off", system/krnl.lua, 116)
    end,
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            term.write("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n")
        end
        if config.printLogToFile and logfile then
            logfile.write(kernelLogBuffer)
        end
    end,
    version = function ()
        if __LEGACY.files.exists("/config/arc/devenv.lock") then
            return "arcos development environment"
        end
        local f, e = __LEGACY.files.open("/config/arc/base.meta.json", "r")
        if not f then
            return "invalid package metadata"
        else
            local meta = __LEGACY.textutils.unserializeJSON(f.readAll())
            f.close()
            return meta.version
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
    getUsers = function()
        local f = {}
        for index, value in ipairs(users) do
            table.insert(f, value.name)
        end
        return f
    end,
    getKernelLogBuffer = function()
        if not currentTask or currentTask["user"] == "root" then
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
    rev = function(filter)
        r = table.pack(coroutine.yield())
        if not filter or r[1] == filter then
            return table.unpack(r)
        else 
            return arcos.ev(filter)
        end
    end,
    time = function(t)
        return __LEGACY.os.time(t)
    end,
    day = function(t)
        return __LEGACY.os.day(t)
    end,
    epoch = function(t)
        return __LEGACY.os.epoch(t)
    end,
    date = function (format, time)
        return __LEGACY.os.date(format, time)
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
    queue = function (ev, ...)
        __LEGACY.os.queueEvent(ev, ...)
    end,
    clock = function() return __LEGACY.os.clock() end,
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
    startTimer = function(d) 
        return __LEGACY.os.startTimer(d)
    end,
    cancelTimer = function(d) 
        return __LEGACY.os.cancelTimer(d)
    end,
    setAlarm = function(d) 
        return __LEGACY.os.setAlarm(d)
    end,
    cancelAlarm = function(d) 
        return __LEGACY.os.cancelAlarm(d)
    end,
    id = __LEGACY.os.getComputerID()
}
_G.os = _G.arcos
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
end
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(require("col").red)
    print(...)
    term.setTextColor(oldtc)
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
            paused = false,
            tQueue = {}
        })
        return #tasks
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
            tasks[pid]["paused"] = paused
        end
    end,
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
        apiUtils.kernelPanic("Invalid argument: " .. args[i], system/krnl.lua, 592)
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
    loaders = {
        function (name)
            if not package.preload[name] then
                error("no field package.preload['" .. name .. "']")
            end
            return function()
                return package.preload[name]
            end
        end,
        function (name)
            if not package.loaded[name] then
                error("no field package.loaded['" .. name .. "']")
            end
            return function()
                return package.loaded[name]
            end
        end,
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
    apiUtils.kernelPanic("Password file not found", system/krnl.lua, 732)
else
    users = tutils.dJSON(passwdFile.read())
end
_G.arcos.getHome = function ()
    if not files.exists("/user/" .. arcos.getCurrentTask().user) then
        files.mkDir("/user/" .. arcos.getCurrentTask().user)
    end
    return "/user/" .. arcos.getCurrentTask().user
end
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
_G.kernel = {
    uname = function ()
        return "arckernel 464"
    end
}
local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), system/krnl.lua, 836)
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
            apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 850)
        else
            apiUtils.kernelPanic("Init Died with no errors.", system/krnl.lua, 852)
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, system/krnl.lua, 855)
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)
while kpError == nil do
    local f = 0
    for index, value in ipairs(tasks) do
        if not value.paused then
            f = f + #value.tQueue
        end
    end
    if f > 0 then
        for index, value in ipairs(tasks) do
            if not value.paused then
                if #value.tQueue > 0 then       
                    currentTask = value
                    cPid = index
                    local event = table.remove(value.tQueue, 1)
                    _G.environ = value["env"]
                    local sc = table.pack(coroutine.resume(value["crt"], table.unpack(event)))
                    value["env"] = _G.environ
                    if kpError then break end
                end
            else
            end
        end
    else
        local ev = table.pack(coroutine.yield())
        if ev[1] == "terminate" then
        else
            for index, value in ipairs(tasks) do
                table.insert(value.tQueue, ev)
            end
        end
    end
end
__LEGACY.term.setBackgroundColor(__LEGACY.colors.red)
__LEGACY.term.setTextColor(__LEGACY.colors.black)
__LEGACY.term.setCursorPos(1, 1)
__LEGACY.term.clear()
print("arcos has forcefully shut off, due to a critical error.")
print("This is probably a system issue")
print("It is safe to force restart this computer at this state. Any unsaved data has already been lost.")
print(kpError)
while true do
    coroutine.yield()
endlocal files = require("files")
local hashing = require("hashing")
local tutils = require("tutils")
local methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    DELETE = true,
    PATCH = true,
    TRACE = true,
}
local function getChosenRepo(rootdir)
    if not rootdir then rootdir = "/" end
    local rf, x = files.open(rootdir .. "/config/arcrepo", "r")
    if not rf then
        return "mirkokral/ccarcos" -- Default to the main arcos repo
    end
    local fx = rf.read()
    rf.close()
    return fx
end
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    return t
end
local function check_key(options, key, ty, opt)
    local value = options[key]
    local valueTy = type(value)
    if (value ~= nil or not opt) and valueTy ~= ty then
        error(("bad field '%s' (%s expected, got %s"):format(key, ty, valueTy), 4)
    end
end
local function check_request_options(options, body)
    check_key(options, "url", "string")
    if body == false then
        check_key(options, "body", "nil")
    else
        check_key(options, "body", "string", not body)
    end
    check_key(options, "headers", "table", true)
    check_key(options, "method", "string", true)
    check_key(options, "redirect", "boolean", true)
    check_key(options, "timeout", "number", true)
    if options.method and not methods[options.method] then
        error("Unsupported HTTP method", 3)
    end
end
local function wrap_request(_url, ...)
    local ok, err = __LEGACY.http.request(...)
    if ok then
        while true do
            local event, param1, param2, param3 = arcos.ev()
            if event == "http_success" and param1 == _url then
                return param2
            elseif event == "http_failure" and param1 == _url then
                return nil, param2, param3
            end
        end
    end
    return nil, err
end
local function get(_url, _headers, _binary)
    if type(_url) == "table" then
        check_request_options(_url, false)
        return wrap_request(_url.url, _url)
    end
    assert(type(_url) == "string")
    assert(type(_headers) == "table" or type(_headers) == "nil")
    assert(type(_binary) == "boolean" or type(_binary) == "nil")
    return wrap_request(_url, _url, nil, _headers, _binary)
end
local function getLatestCommit(rootdir)
    if not rootdir then rootdir = "/" end
    local f, e = __LEGACY.files.open(rootdir .. "config/arc/latestCommit.hash", "r")
    if not f then 
        return ""
    else 
        local rp = f.readAll()
        f.close()
        return rp
    end
end
local function checkForCD(rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists(rootdir .. "config") then
        __LEGACY.files.makeDir(rootdir .. "/config")
    end
    if not __LEGACY.files.exists(rootdir .. "config/arc") then
        __LEGACY.files.makeDir(rootdir .. "/config/arc")
    end
end
local function fetch(rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local f2 = __LEGACY.files.open(rootdir .. "/config/arc/latestCommit.hash", "w")    
    local fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        ["Authorization"] = "Bearer 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"
    })
    if not fr then 
        fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        })
        if not fr then
            return false
        end
    end
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    f2.write(rp)
    fr.close()
    f2.close()
    local f, e = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" ..
    getLatestCommit() .. "/repo/index.json")
    if not f then
        return false
    end
    local fa = __LEGACY.files.open(rootdir .. "/config/arc/repo.json", "w")
    fa.write(f.readAll())
    fa.close()
    f.close()
end
local function isInstalled(package, rootdir)
    if not rootdir then rootdir = "/" end
    return __LEGACY.files.exists(rootdir .. "/config/arc/" .. package .. ".uninstallIndex")
end
local function getIdata(package, rootdir)
    if not rootdir then rootdir = "/" end
    if not __LEGACY.files.exists(rootdir .. "/config/arc/" .. package .. ".meta.json") then
        return nil
    end
    local f, e = __LEGACY.files.open(rootdir .. "/config/arc/" .. package .. ".meta.json", "r")
    if not f then
        return nil
    end
    return __LEGACY.textutils.unserializeJSON(f.readAll())
end
local function getRepo(rootdir)
    if not rootdir then rootdir = "/" end
    local f = __LEGACY.files.open(rootdir .. "/config/arc/repo.json", "r")
    if not f then
        return {}
    end
    local uj = __LEGACY.textutils.unserializeJSON(f.readAll())
    f.close()
    return uj
end
local function uninstall(package, rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists(rootdir .. "/config/arc/" .. package .. ".uninstallIndex") then
        error("Package not installed.")
    end
    local toDelete = { }
    toDelete[rootdir .. "/config/arc/" .. package .. ".uninstallIndex"] = ""
    toDelete[rootdir .. "/config/arc/" .. package .. ".meta.json"] = ""
    local f = __LEGACY.files.open(rootdir .. "/config/arc/" .. package .. ".uninstallIndex", "r")
    for value in f.readLine do
        if value == nil then break end
        if value:sub(0, 1) == "f" then
            toDelete[rootdir .. "/" .. value:sub(4+64)] = value:sub(3, 3+64)
        else
            toDelete[rootdir .. "/" .. value:sub(3)] = "DIRECTORY"
        end
    end
    for value, hash in pairs(toDelete) do
        if hash == "" then
            __LEGACY.files.delete(value)
        elseif hash ~= "DIRECTORY" then
            local f, e = __LEGACY.files.open(value, "r")
            if f then
                local fhash = hashing.sha256(f.readAll())
                local hmismatch = {}
                for i = 1, #fhash, 1 do
                    local c1 = fhash:sub(i, i)
                    local c2 = hash:sub(i, i)
                    if c1 ~= c2 then
                        print("Mismatch: " .. c1 .. " != " .. c2)
                        table.insert(hmismatch, c1)
                    end
                end
                if #hmismatch == 0 then
                    __LEGACY.files.delete(value)
                else
                    __LEGACY.files.delete(value)
                end
            else
            end
        end
    end
    for value, hash in pairs(toDelete) do
        if hash == "DIRECTORY" then
            if __LEGACY.files.isDir(value) then
                if #__LEGACY.files.list(value) > 0 then
                    goto continue
                end
            end
            __LEGACY.files.delete(value)
        end
        ::continue::
    end
end
local arkivelib = {
    unarchive = function(text)
        local linebuf = ""
        local isReaderHeadInTable = true
        local offsetheader = {}
        local bufend = 0
        for k = 0, #text, 1 do
            local v = text:sub(k, k)
            if v == "\n" then
                if linebuf == "--ENDTABLE" then
                    bufend = k + 1
                    isReaderHeadInTable = false
                    break
                else
                    table.insert(offsetheader, tutils.split(linebuf, "|"))
                end
                linebuf = ""
            else
                linebuf = linebuf .. v
            end
        end
        local outputfiles = {}
        for k, v in ipairs(offsetheader) do
            if v[2] == "-1" then
                table.insert(outputfiles, { v[1], nil })
            elseif offsetheader[k + 1] then
                table.insert(outputfiles,
                    { v[1], text:sub(bufend + tonumber(v[2]), bufend + tonumber(offsetheader[k + 1][2]) - 1) })
            else
                table.insert(outputfiles, { v[1], text:sub(bufend + tonumber(v[2]), #text) })
            end
        end
        return outputfiles
    end
}
local function install(package, rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD(rootdir)
    local repo = getRepo(rootdir)
    local latestCommit = getLatestCommit(rootdir)
    local buildedpl = ""
    if not repo[package] then
        error("Package not found!")
    end
    if __LEGACY.files.exists(rootdir .. "/config/arc/" .. package .. ".meta.json") then
        local f = __LEGACY.files.open(rootdir .. "/config/arc/" .. package .. ".meta.json", "r")
        local ver = __LEGACY.textutils.unserializeJSON(f.readAll())["vId"]
        if ver < repo[package]["vId"] then
            local updateFile, e = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/upd" .. repo[package]["vId"] .. ".lua")
            if updateFile then
                local r = updateFile.readAll()
                local f, e = load(r, "Update Module", "t", setmetatable({}, { __index = _G }))
                if f then
                    local ok, err = pcall(f);
                    if not ok then error(err) end
                else
                    error(e)
                end
            end
            uninstall(package, rootdir)
        else
            error("Package already installed!")
        end
    end
    local pkg = repo[package]
    local indexFile, err = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" .. latestCommit .. "/archivedpkgs/" .. package .. ".arc")
    if not indexFile then
        error(err)
    end
    local ifx = arkivelib.unarchive(indexFile.readAll())
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not __LEGACY.files.exists(rootdir .. "/" .. value[1]) then
                __LEGACY.files.makeDir(rootdir .. "/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
        end
    end
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not __LEGACY.files.exists(rootdir .. "/" .. value[1]) then
                __LEGACY.files.makeDir(rootdir .. "/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
            if not __LEGACY.files.exists(rootdir .. "/" .. value[1]) then
                local file = value[2]
                local tfh, e = __LEGACY.files.open(rootdir .. "/" .. value[1], "w")
                if not tfh then error(e) end
                tfh.write(file)
                tfh.close()
                buildedpl = buildedpl .. "f "  .. hashing.sha256(value[2]) .. " " .. value[1] .. "\n"
            end
        end
    end
    if pkg["postInstScript"] then
        return function()
            local file, e = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/" .. "pi.lua")
            if not file then
                return;
            end
            local fd = file.readAll()
            file.close()
            local tf = __LEGACY.files.open(rootdir .. "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
            tf.write(fd)
            tf.close()
            arcos.r({}, rootdir .. "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
        end
    end
    indexFile.close()
    local insf = __LEGACY.files.open(rootdir .. "/config/arc/" .. package .. ".meta.json", "w")
    insf.write(__LEGACY.textutils.serializeJSON(pkg))
    insf.close()
    local uinsf = __LEGACY.files.open(rootdir .. "/config/arc/" .. package .. ".uninstallIndex", "w")
    uinsf.write(buildedpl)
    uinsf.close()
    return function()
    end
end
local function getUpdatable(rootdir)
    if not rootdir then rootdir = "/" end
    local updatable = {}
    for index, value in ipairs(files.ls(rootdir .. "/config/arc/")) do
        if value:sub(#value - 14) == ".uninstallIndex" then
            local pk = value:sub(0, #value - 15)
            local pf = __LEGACY.files.open(rootdir .. "/config/arc/" .. pk .. ".meta.json", "r")
            local at = pf.readAll()
            local af = __LEGACY.textutils.unserializeJSON(at)
            pf.close()
            if af["vId"] < getRepo(rootdir)[pk]["vId"] then
                table.insert(updatable, pk)
            end
        end
    end
    return updatable
end
return {
    fetch = fetch,
    getRepo = getRepo,
    install = install,
    uninstall = uninstall,
    isInstalled = isInstalled,
    getIdata = getIdata,
    getUpdatable = getUpdatable,
    getChosenRepo = getChosenRepo,
    getLatestCommit = getLatestCommit,
    get = get,
}
local bit = require("bit")
local white = 0x1
local orange = 0x2
local magenta = 0x4
local lightBlue = 0x8
local yellow = 0x10
local lime = 0x20
local pink = 0x40
local gray = 0x80
local lightGray = 0x100
local cyan = 0x200
local purple = 0x400
local blue = 0x800
local brown = 0x1000
local green = 0x2000
local red = 0x4000
local black = 0x8000
local function expect(n, v, ...)
    local r = false
    for index, value in ipairs({ ... }) do
        if type(v) == value then
            r = true
            break
        end
    end
    if not r then
        error("Argument " .. n .. " is not valid!")
    end
end
local bit32 = bit
local function combine(...)
    local r = 0
    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i, c, "number")
        r = bit32.bor(r, c)
    end
    return r
end
local function subtract(colors, ...)
    expect(1, colors, "number")
    local r = colors
    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i + 1, c, "number")
        r = bit32.band(r, bit32.bnot(c))
    end
    return r
end
local function test(colors, color)
    expect(1, colors, "number")
    expect(2, color, "number")
    return bit32.band(colors, color) == color
end
local function packRGB(r, g, b)
    expect(1, r, "number")
    expect(2, g, "number")
    expect(3, b, "number")
    return
        bit32.band(r * 255, 0xFF) * 2 ^ 16 +
        bit32.band(g * 255, 0xFF) * 2 ^ 8 +
        bit32.band(b * 255, 0xFF)
end
local function unpackRGB(rgb)
    expect(1, rgb, "number")
    return
        bit32.band(bit32.rshift(rgb, 16), 0xFF) / 255,
        bit32.band(bit32.rshift(rgb, 8), 0xFF) / 255,
        bit32.band(rgb, 0xFF) / 255
end
local function rgb8(r, g, b)
    if g == nil and b == nil then
        return unpackRGB(r)
    else
        return packRGB(r, g, b)
    end
end
local color_hex_lookup = {}
for i = 0, 15 do
    color_hex_lookup[2 ^ i] = string.format("%x", i)
end
local function toBlit(color)
    expect(1, color, "number")
    local hex = color_hex_lookup[color]
    if hex then return hex end
    if color < 0 or color > 0xffff then error("Colour out of range", 2) end
    return string.format("%x", math.floor(math.log(color, 2)))
end
local function fromBlit(hex)
    expect(1, hex, "string")
    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end
    return 2 ^ value
end
local function get_display_type(value, t)
    if t ~= "table" and t ~= "userdata" then return t end
    local metatable = debug.getmetatable(value)
    if not metatable then return t end
    local name = rawget(metatable, "__name")
    if type(name) == "string" then return name else return t end
end
local function get_type_names(...)
    local types = table.pack(...)
    for i = types.n, 1, -1 do
        if types[i] == "nil" then table.remove(types, i) end
    end
    if #types <= 1 then
        return tostring(...)
    else
        return table.concat(types, ", ", 1, #types - 1) .. " or " .. types[#types]
    end
end
local function field(tbl, index, ...)
    expect(1, tbl, "table")
    expect(2, index, "string")
    local value = tbl[index]
    local t = type(value)
    for i = 1, select("#", ...) do
        if t == select(i, ...) then return value end
    end
    t = get_display_type(value, t)
    if value == nil then
        error(("field '%s' missing from table"):format(index), 3)
    else
        error(("bad field '%s' (%s expected, got %s)"):format(index, get_type_names(...), t), 3)
    end
end
return {
    white = white,
    orange = orange,
    magenta = magenta,
    lightBlue = lightBlue,
    yellow = yellow,
    lime = lime,
    pink = pink,
    gray = gray,
    grey = gray,
    lightGray = lightGray,
    lightGrey = lightGray,
    cyan = cyan,
    purple = purple,
    blue = blue,
    brown = brown,
    green = green,
    red = red,
    black = black,
    combine = combine,
    subtract = subtract,
    test = test,
    packRGB = packRGB,
    unpackRGB = unpackRGB,
    rgb8 = rgb8,
    toBlit = toBlit,
    fromBlit = fromBlit,
    expect = expect,
    field = field
}local col = require("col")
local tutils = require("tutils")
local function combine(...)
    return __LEGACY.files.combine(...)
end
local function getPermissions(file, user) 
    local read = true
    local write = true
    local listed = true
    if user == nil then user = arcos.getCurrentTask().user end
    if __LEGACY.files.isReadOnly(file) then
        write = false
    end
    if tutils.split(file, "/")[#tutils.split(file, "/")]:sub(1,1) == "$" then -- Metadata files
        return {
            read = false,
            write = false,
            listed = false
        }
    end
    local disallowedfiles = {"startup.lua", "startup"}
    for index, value in ipairs(disallowedfiles) do
        if tutils.split(file, "/")[1] == value then -- Metadata files
            return {
                read = false,
                write = false,
                listed = false,
            }
        end
    end
    if tutils.split(file, "/")[#tutils.split(file, "/")]:sub(1,1) == "." then
        listed = false
    end
    return {
        read = read,
        write = write,
        listed = listed,
    }
end
local function getPermissionsForAll(file)
    local u = {}
    for index, value in ipairs(arcos.getUsers()) do
        u[value] = getPermissions(file, value)
    end
    return u
end
local function cant(on, what)
    return not getPermissions(on)[what]
end
local function can(on, what)
    return getPermissions(on)[what]
end
local function par(path)
    return __LEGACY.files.getDir(path)
end
local function size(path)
    if cant(path, "read") then
        error("No permission for this action")
    end
    return __LEGACY.files.getSize(path)
end
local function drive(path)
    return __LEGACY.files.getDrive(path)
end
local function freeSpace(path)
    return __LEGACY.files.getFreeSpace(path)
end
local function readonly(path)
    return not getPermissions(path).write
end
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    return t
end
local function open(path, mode)
    local validModes = {"w", "r", "w+", "r+", "a", "wb", "rb"}
    if cant(path, "read") and (mode == "r" or mode == "r+" or mode == "a" or mode == "w+" or mode == "rb") then
        return nil, "No permission for this action"
    end
    if cant(path, "write") and (mode == "w" or mode == "w+" or mode == "a" or mode == "r+" or mode == "wb") then
        return nil, "No permission for this action"
    end
    local cmodevalid = false
    for _, v in ipairs(validModes) do
        if mode == v then cmodevalid = true break end
    end
    if not cmodevalid then error("Mode not valid: " .. mode) end
    local err
    local file = {}
    file._f, err = __LEGACY.files.open(path, mode)
    if not file._f then
        return nil, err
    end
    file.open = true
    file.close = function() file._f.close() file.open = false end
    file.seekBytes = function(whence, offset)
        return file._f.seek(whence, offset)
    end
    if mode == "w" or mode == "w+" or mode == "r+" or mode == "a" then
        file.write = function(towrite)
            file._f.write(towrite)
        end
        file.writeLine = function(towrite)
            file._f.writeLine(towrite)
        end
        file.flush = function(towrite)
            file._f.write(towrite)
        end
    end
    if mode == "r" or mode == "w+" or mode == "r+" then
        local fd = file._f.readAll()
        local li = 0
        file.readBytes = function(b)
            return file._f.read(b)
        end
        file.read = function()
            return fd
        end
        file.readLine = function(withTrailing)
            li = li + 1
            if withTrailing then
                return split(fd, "\n")[li] .. "\n"
            else
                return split(fd, "\n")[li]
            end
        end
    end
    return file, nil
end
local function ls(dir)
    local listed =  __LEGACY.files.list(dir)
    local out = {}
    for index, value in ipairs(listed) do
        if can(dir .. '/' .. value, "listed") then
            table.insert(out, value)
        end
    end
    return out
end
local function rm(f)
    if cant(f, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.delete(f)
end
local function exists(f)
    if f == "" or f == "/" then return true end
    if tutils.split(f, "/")[#tutils.split(f, "/")]:sub(1,1) == "$" then
        return false
    end
    return __LEGACY.files.exists(f)
end
local function mkDir(d) 
    local fv = {}
    for key, value in pairs({table.unpack(tutils.split(d, "/"), 1, #tutils.split(d, "/")-1)}) do
        table.insert(fv, value)
    end
    if not exists(table.concat(fv, "/")) then
        error("Parent doesn't exist.")
    end
    if cant(table.concat(fv, "/"), "write") then
        error("No permission for this action");
    end
    return __LEGACY.files.makeDir(d)
end
local function resolve(f, keepNonExistent)
    local p = f:sub(1, 1) == "/" and "/" or (arcos.getCurrentTask().env.workDir or "/")
    local pa = tutils.split(p, "/")
    local fla = tutils.split(f, "/")
    local out = {}
    local frmItems = {}
    for _, i in ipairs(pa) do
        table.insert(out, i)
    end
    for _, i in ipairs(fla) do
        table.insert(out, i)
    end
    for ix, i in ipairs(out) do
        if i == "" then
            table.insert(frmItems, 1, ix)
        end
        if i == "." then
            table.insert(frmItems, 1, ix)
        end
        if i == ".." then
            if #pa + ix ~= 1 then
                table.insert(frmItems, 1, ix-1) 
            end
            table.insert(frmItems, 1, ix)
        end
    end
    if not keepNonExistent and not exists("/" .. tutils.join(out, "/")) then return {} end
    for _, rmi in ipairs(frmItems) do
        table.remove(out, rmi)
    end
    return { "/" .. tutils.join(out, "/") }
end
local function dir(d) 
    if f == "" or f == "/" then return true end
    return __LEGACY.files.isDir(d)
end
local function m(t, d) 
    if cant(t, "read") or cant(t, "write") or cant(d, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.move(t, d)
end
local function c(t, d)
    if cant(t, "read") or cant(d, "write") then
        error("No permission for this action")
    end
    return __LEGACY.files.copy(t, d)
end
local expect = col.expect
local field = col.field
local function complete(sPath, sLocation, bIncludeFiles, bIncludeDirs)
    expect(1, sPath, "string")
    expect(2, sLocation, "string")
    local bIncludeHidden = nil
    if type(bIncludeFiles) == "table" then
        bIncludeDirs = field(bIncludeFiles, "include_dirs", "boolean", "nil")
        bIncludeHidden = field(bIncludeFiles, "include_hidden", "boolean", "nil")
        bIncludeFiles = field(bIncludeFiles, "include_files", "boolean", "nil")
    else
        expect(3, bIncludeFiles, "boolean", "nil")
        expect(4, bIncludeDirs, "boolean", "nil")
    end
    bIncludeHidden = bIncludeHidden ~= false
    bIncludeFiles = bIncludeFiles ~= false
    bIncludeDirs = bIncludeDirs ~= false
    local sDir = sLocation
    local nStart = 1
    local nSlash = string.find(sPath, "[/\\]", nStart)
    if nSlash == 1 then
        sDir = ""
        nStart = 2
    end
    local sName
    while not sName do
        local nSlash = string.find(sPath, "[/\\]", nStart)
        if nSlash then
            local sPart = string.sub(sPath, nStart, nSlash - 1)
            sDir = combine(sDir, sPart)
            nStart = nSlash + 1
        else
            sName = string.sub(sPath, nStart)
        end
    end
    if dir(sDir) then
        local tResults = {}
        if bIncludeDirs and sPath == "" then
            table.insert(tResults, ".")
        end
        if sDir ~= "" then
            if sPath == "" then
                table.insert(tResults, bIncludeDirs and ".." or "../")
            elseif sPath == "." then
                table.insert(tResults, bIncludeDirs and "." or "./")
            end
        end
        local tFiles = ls(sDir)
        for n = 1, #tFiles do
            local sFile = tFiles[n]
            if #sFile >= #sName and string.sub(sFile, 1, #sName) == sName and (
                bIncludeHidden or sFile:sub(1, 1) ~= "." or sName:sub(1, 1) == "."
            ) then
                local bIsDir = dir(combine(sDir, sFile))
                local sResult = string.sub(sFile, #sName + 1)
                if bIsDir then
                    table.insert(tResults, sResult .. "/")
                    if bIncludeDirs and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                else
                    if bIncludeFiles and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                end
            end
        end
        return tResults
    end
    return {}
end
local function find_aux(path, parts, i, out)
    local part = parts[i]
    if not part then
        if exists(path) then out[#out + 1] = path end
    elseif part.exact then
        return find_aux(combine(path, part.contents), parts, i + 1, out)
    else
        if not dir(path) then return end
        local files = ls(path)
        for j = 1, #files do
            local file = files[j]
            if file:find(part.contents) then find_aux(__LEGACY.files.combine(path, file), parts, i + 1, out) end
        end
    end
end
local find_escape = {
    ["^"] = "%^", ["$"] = "%$", ["("] = "%(", [")"] = "%)", ["%"] = "%%",
    ["."] = "%.", ["["] = "%[", ["]"] = "%]", ["+"] = "%+", ["-"] = "%-",
    ["*"] = ".*",
    ["?"] = ".",
}
local function find(pattern)
    expect(1, pattern, "string")
    pattern = combine(pattern) -- Normalise the path, removing ".."s.
    if pattern == ".." or pattern:sub(1, 3) == "../" then
        error("/" .. pattern .. ": Invalid Path", 2)
    end
    if not pattern:find("[*?]") then
        if exists(pattern) then return { pattern } else return {} end
    end
    local parts = {}
    for part in pattern:gmatch("[^/]+") do
        if part:find("[*?]") then
            parts[#parts + 1] = {
                exact = false,
                contents = "^" .. part:gsub(".", find_escape) .. "$",
            }
        else
            parts[#parts + 1] = { exact = true, contents = part }
        end
    end
    local out = {}
    find_aux("", parts, 1, out)
    return out
end
local function driveRoot(sPath)
    expect(1, sPath, "string")
    return par(sPath) == ".." or drive(sPath) ~= drive(par(sPath))
end
local function name(path)
    return __LEGACY.files.getName(path)
end
local function capacity(path)
    return __LEGACY.files.getCapacity(path)
end
local function attributes(path)
    local attr = __LEGACY.files.attributes(path)
    attr.permissions = getPermissionsForAll(path)
    return attr
end
return {
    open = open,
    ls = ls,
    rm = rm, 
    exists = exists,
    resolve = resolve,
    dir = dir,
    m = m,
    c = c,
    mkDir = mkDir,
    complete = complete,
    find = find,
    driveRoot = driveRoot,
    combine = combine,
    name = name,
    size = size,
    readonly = readonly,
    drive = drive,
    freeSpace = freeSpace,
    capacity = capacity,
    attributes = attributes,
    par = par,
}
local MOD = 2^32
local MODM = MOD-1
local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end
local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a % m, b % m
			res = res + t[am][bm] * p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a + b) * p
		return res
	end
	return bitop
end
local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
	return make_bitop_uncached(op2, 2 ^ (t.n or 1))
end
local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})
local function bxor(a, b, c, ...)
	local z = nil
	if b then
		a = a % MOD
		b = b % MOD
		z = bxor1(a, b)
		if c then z = bxor(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return 0 end
end
local function band(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = ((a + b) - bxor1(a,b)) / 2
		if c then z = require("bit32").band(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return MODM end
end
local function bnot(x) return (-1 - x) % MOD end
local function lshift(a, disp)
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2 ^ disp) % 2 ^ 32
end
local function rshift1(a, disp)
	if disp < 0 then return lshift(a,-disp) end
	return math.floor(a % 2 ^ 32 / 2 ^ disp)
end
local function rshift(x, disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift1(x % MOD, disp)
end
local function rrotate(x, disp)
    x = x % MOD
    disp = disp % 32
    local low = band(x, 2 ^ disp - 1)
    return rshift(x, disp) + lshift(low, 32 - disp)
end
local k = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}
local function str2hexa(s)
	return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
end
local function num2s(l, n)
	local s = ""
	for i = 1, n do
		local rem = l % 256
		s = string.char(rem) .. s
		l = (l - rem) / 256
	end
	return s
end
local function s232num(s, i)
	local n = 0
	for i = i, i + 3 do n = n*256 + string.byte(s, i) end
	return n
end
local function preproc(msg, len)
	local extra = 64 - ((len + 9) % 64)
	len = num2s(8 * len, 8)
	msg = msg .. "\128" .. string.rep("\0", extra) .. len
	assert(#msg % 64 == 0)
	return msg
end
local function initH256(H)
	H[1] = 0x6a09e667
	H[2] = 0xbb67ae85
	H[3] = 0x3c6ef372
	H[4] = 0xa54ff53a
	H[5] = 0x510e527f
	H[6] = 0x9b05688c
	H[7] = 0x1f83d9ab
	H[8] = 0x5be0cd19
	return H
end
local function digestblock(msg, i, H)
	local w = {}
	for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
	for j = 17, 64 do
		local v = w[j - 15]
		local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
		v = w[j - 2]
		w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
	end
	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
	for i = 1, 64 do
		local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
		local maj = bxor(band(a, b), band(a, c), band(b, c))
		local t2 = s0 + maj
		local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
		local ch = bxor (band(e, f), band(bnot(e), g))
		local t1 = h + s1 + ch + k[i] + w[i]
		h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
	end
	H[1] = band(H[1] + a)
	H[2] = band(H[2] + b)
	H[3] = band(H[3] + c)
	H[4] = band(H[4] + d)
	H[5] = band(H[5] + e)
	H[6] = band(H[6] + f)
	H[7] = band(H[7] + g)
	H[8] = band(H[8] + h)
end
local function sha256(msg)
	msg = preproc(msg, #msg)
	local H = initH256({})
	for i = 1, #msg, 64 do digestblock(msg, i, H) end
	return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
		num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end
return {
	sha256 = sha256
}local function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        __LEGACY.redstone.setAnalogOutput(sd, val)
    elseif type(val) == "boolean" then
        __LEGACY.redstone.setOutput(sd, val)
    end
end
local function getO(side)
    return __LEGACY.redstone.getAnalogOutput(side)
end
local function getI(side)
    return __LEGACY.redstone.getAnalogInput(side)
end
local function setBO(sd, bitmask)
    return __LEGACY.redstone.setBundledOutput(sd, bitmask)
end
local function getBO(sd)
    return __LEGACY.redstone.getBundledOutput(sd)
end
local function getBI(sd)
    return __LEGACY.redstone.getBundledInput(sd)
end
local function testBI(sd, test)
    return __LEGACY.redstone.testtBundledInput(sd, test)
end
return {
    setO = setO,
    getO = getO,
    getI = getI,
    setBO = setBO,
    getBO = getBO,
    getBI = getBI,
    testBI = testBI,
}
local function sJSON(obj)
    return __LEGACY.textutils.serializeJSON(obj)
end
local function dJSON(obj)
    return __LEGACY.textutils.unserialiseJSON(obj)
end
local function s(obj)
    return __LEGACY.textutils.serialize(obj)
end
local function d(obj)
    return __LEGACY.textutils.unserialize(obj)
end
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    local nt = {}
    for i, v in ipairs(t) do
        if v ~= "" then
            table.insert(nt, v)
        end
    end
    if t == {} then
        t = { "" }
    end
    return nt
end
local function join(tab, sep )
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out-1)
end
local function formatTime(t, tfhour)
    return __LEGACY.textutils.formatTime(t, tfhour)
end
return {
    dJSON = dJSON,
    sJSON = sJSON,
    d = d,
    s = s,
    split = split,
    join = join,
    formatTime = formatTime,
}
local col = require("col")
local tutils = require("tutils")
local UItheme = {
    bg = col.black,
    fg = col.white,
    buttonBg = col.cyan,
    buttonFg = col.black,
    lighterBg = col.gray,
    lightBg = col.lightGray
}
local UIthemedefs = {
}
UIthemedefs[col.white] = { 236, 239, 244 }
UIthemedefs[col.orange] = { 0, 0, 0 }
UIthemedefs[col.magenta] = { 180, 142, 173 }
UIthemedefs[col.lightBlue] = { 0, 0, 0 }
UIthemedefs[col.yellow] = { 235, 203, 139 }
UIthemedefs[col.lime] = { 163, 190, 140 }
UIthemedefs[col.pink] = { 0, 0, 0 }
UIthemedefs[col.gray] = { 76, 86, 106 }
UIthemedefs[col.lightGray] = { 216, 222, 233 }
UIthemedefs[col.cyan] = { 136, 192, 208 }
UIthemedefs[col.purple] = { 0, 0, 0 }
UIthemedefs[col.blue] = { 129, 161, 193 }
UIthemedefs[col.brown] = { 0, 0, 0 }
UIthemedefs[col.green] = { 163, 190, 140 }
UIthemedefs[col.red] = { 191, 97, 106 }
UIthemedefs[col.black] = { 59, 66, 82 }
for index, value in pairs(UIthemedefs) do
    term.setPaletteColor(index, value[1] / 255, value[2] / 255, value[3] / 255)
end
W, H = term.getSize()
local function InitBuffer(mon)
    for index, value in pairs(UIthemedefs) do
        mon.setPaletteColor(index, value[1] / 255, value[2] / 255, value[3] / 255)
    end
    local buf = {}
    local W, H = mon.getSize()
    for i = 1, H, 1 do
        local tb = {}
        for i = 1, W, 1 do
            table.insert(tb, { col.white, col.black, " " })
        end
        table.insert(buf, tb)
    end
    return buf
end
local function blitAtPos(sx, sy, bgCol, forCol, text, buf)
    local x = math.floor(sx + 0.5)
    local y = math.floor(sy + 0.5)
    if x <= #buf[1] and y <= #buf and y > 0 and x > 0 then
        buf[y][x] = { bgCol, forCol, text }
    end
end
local function ScrollPane(b)
    local config = {}
    for key, value in pairs(b) do
        config[key] = value
    end
    config.scroll = 0
    if not config.hideScrollbar then
        config.width = config.width - 1
    end
    config.getTotalHeight = function()
        local h = 0
        for index, value in ipairs(config.children) do
            h = h + value.getWH()[2]
        end
        return h
    end
    local mbpressedatm = false
    local lastx, lasty = 0, 0
    config.getDrawCommands = function(termar)
        local dcBuf = {}
        local tw, th = config.width, config.height
        for i = 0, tw, 1 do
            for ix = 0, th, 1 do
                local rc = {
                    bgCol = config.col,
                    forCol = col.white,
                    text = " ",
                    x = config.x + i,
                    y = config.y + ix,
                }
                table.insert(dcBuf, rc)
            end
        end
        local yo = 0
        for index, value in ipairs(config.children) do
            if value.y + yo - config.scroll + value.getWH()[1] > 0 and value.y + yo - config.scroll <= config.height then
                local rc = value.getDrawCommands(termar)
                for index, value in ipairs(rc) do
                    table.insert(dcBuf, {
                        x = config.x + value.x - 1,
                        y = config.y + value.y - 1 - config.scroll + yo,
                        text = value.text,
                        bgCol = value.bgCol,
                        forCol = value.forCol
                    })
                end
            end
            yo = yo + value.getWH()[2]
        end
        local rmIndexes = {}
        for index, value in ipairs(dcBuf) do
            if value.x - config.x < 0 or value.x - config.x >= config.width or value.y - config.y < 0 or value.y - config.y >= config.height then
                table.insert(rmIndexes, 1, index)
            end
        end
        for index, value in ipairs(rmIndexes) do
            table.remove(dcBuf, value)
        end
        if config.showScrollBtns then
            table.insert(dcBuf, {
                text = "^",
                forCol = config.col,
                bgCol = UItheme.bg,
                x = config.x + config.width,
                y = config.y
            })
            table.insert(dcBuf, {
                text = "v",
                forCol = config.col,
                bgCol = UItheme.bg,
                x = config.x + config.width,
                y = config.y + 1
            })
        end
        if not config.hideScrollbar then
            for i = (config.showScrollBtns and 2 or 0), config.height - 1, 1 do
                table.insert(dcBuf, {
                    text = "|",
                    forCol = config.col,
                    bgCol = UItheme.bg,
                    x = config.x + config.width,
                    y = config.y + i
                })
            end
        end
        return dcBuf
    end
    config.renderFinish = function(ox, oy, termar)
        local yo = 0
        for index, value in ipairs(config.children) do
            if value.y + yo - config.scroll + value.getWH()[1] > 0 and value.y + yo - config.scroll <= config.height then
                if value.renderFinish then
                    value.renderFinish(config.x + ox, config.y + oy - config.scroll, termar)
                end
            end
            yo = yo + value.getWH()[2]
        end
    end
    config.onEvent = function(e, termar)
        local ce = e
        if ce[1] == "click" then
            local ret = false
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[3] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    if value.onEvent({ "click", ce[2], ce[3] - config.x + 1, ce[4] - config.y + config.scroll - index + 2 }, termar) then
                        ret = true
                    end
                end
            else
                for index, value in ipairs(config.children) do
                    if value.onEvent({ "defocus" }, termar) then ret = true end
                end
            end
            if config.showScrollBtns then
                if ce[3] == config.x + config.width and ce[4] == config.y then
                    config.scroll = math.max(config.scroll - 1, 0)
                    return true
                end
                if ce[3] == config.x + config.width and ce[4] == config.y + 1 then
                    config.scroll = math.min(config.scroll + 1, config.getTotalHeight() - config.height)
                    return true
                end
            end
            mbpressedatm = true
            lastx, lasty = ce[3], ce[4]
            return ret
        end
        if ce[1] == "drag" then
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[3] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    value.onEvent({ "drag", ce[2], ce[3] - config.x, ce[4] - config.y + config.scroll - index + 2 }, termar)
                end
            end
            local ret = false
            if mbpressedatm and lastx == config.x + config.width and lasty >= config.y + (config.showScrollBtns and 2 or 0) and lasty <= config.y + config.width then
                config.scroll = math.min(math.max(config.scroll + (ce[4] - lasty) * -1, 0),
                    config.getTotalHeight() - config.height)
                ret = true
            end
            lastx, lasty = ce[3], ce[4]
            return ret
        end
        if ce[1] == "up" then
            local ret = false
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[4] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    if value.onEvent({ "up", ce[2], ce[3] - config.x, ce[4] - config.y + config.scroll - index + 2 }, termar) then
                        ret = true
                    end
                end
            end
            mbpressedatm = false
            return ret
        end
        if ce[1] == "scroll" then
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[4] <= config.y + config.height then
                config.scroll = math.min(math.max(config.scroll + ce[2], 0), config.getTotalHeight() - config.height)
                return true
            end
        end
    end
    return config
end
local function Wrap(str, maxLength)
    local ostr = ""
    local cstr = ""
    for index2, value2 in ipairs(tutils.split(str, "\n")) do
        for index, value in ipairs(tutils.split(value2, " ")) do
            if #cstr + #value > maxLength then
                ostr = ostr .. cstr .. "\n"
                cstr = ""
            end
            cstr = cstr .. value .. " "
        end
        if #cstr > 0 then
            ostr = ostr .. cstr .. "\n"
            cstr = ""
        end
    end
    if #cstr > 0 then
        ostr = ostr .. cstr .. "\n"
    end
    ostr = ostr:sub(1, #ostr - 1)
    return ostr
end
local function Label(b)
    local config = {}
    for i, v in pairs(b) do
        config[i] = v
    end
    function config.getWH()
        local height = 1
        local width = 1
        local i = 1
        while string.sub(config.label, i, i) ~= "" do
            if string.sub(config.label, i, i) == "\n" then
                height = height + 1
            else
                width = width + 1
            end
            i = i + 1
        end
        width = width - 1
        return { width, height }
    end
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end
    config.getDrawCommands = function(termar)
        local rcbuffer = {}
        local rx = 0
        local ry = 0
        local i = 1
        while string.sub(config.label, i, i) ~= "" do
            if string.sub(config.label, i, i) == "\n" then
                rx = 0
                ry = ry + 1
            else
                table.insert(rcbuffer, {
                    x = config.x + rx,
                    y = config.y + ry,
                    forCol = config.textCol,
                    bgCol = config.col,
                    text = string.sub(config.label, i, i)
                })
                rx = rx + 1
            end
            i = i + 1
        end
        return rcbuffer
    end
    config.onEvent = function(ev)
    end
    return config
end
local function TextInput(b)
    local ca = b
    if not ca["col"] then ca["col"] = col.gray end
    local defaultText = ca.label
    local config = Label(ca)
    config.text = defaultText or ""
    config.textScroll = math.max(#config.text - config.width, 1)
    config.label = config.label:sub(config.textScroll, config.width + config.textScroll - 1)
    config.label = config.label .. string.rep(" ", math.max(config.width - #config.label, 0))
    local cursorPos = 1
    config.focus = false
    config.onEvent = function(e)
        if e[1] == "defocus" then
            config.focus = false
            return true
        end
        if e[1] == "click" then
            if e[3] >= config.x and e[4] >= config.y and e[3] < config.x + config.getWH()[1] and e[4] < config.y + config.getWH()[2] then
                if config.focus then
                    cursorPos = config.textScroll + e[3] - config.x
                else
                    cursorPos = #config.text
                end
                config.focus = true
                return true
            else
                config.focus = false
                return true
            end
        end
        if e[1] == "char" and config.focus then
            config.text = config.text:sub(0, cursorPos) .. e[2] .. config.text:sub(cursorPos + 1)
            cursorPos = cursorPos + 1
            return true
        end
        if e[1] == "key" and config.focus then
            if e[2] == __LEGACY.keys.enter then
                config.focus = false
            end
            if e[2] == __LEGACY.keys.backspace then
                if cursorPos > 0 then
                    config.text = config.text:sub(0, cursorPos - 1) .. config.text:sub(cursorPos + 1)
                    cursorPos = cursorPos - 1
                end
            end
            if e[2] == __LEGACY.keys.left then
                cursorPos = math.max(cursorPos - 1, 0)
            end
            if e[2] == __LEGACY.keys.right then
                cursorPos = math.min(cursorPos + 1, #config.text)
            end
            return true
        end
    end
    local oldgdc = config.getDrawCommands
    config.getDrawCommands = function(termar)
        if config.focus then
            config.label = config.text:sub(0, cursorPos) .. "|" .. config.text:sub(cursorPos + 1)
            config.textScroll = math.max(math.min(#config.text - config.width + 2, cursorPos), 1)
            config.label = config.label:sub(config.textScroll, config.width + config.textScroll - 1)
            local lout = ""
            for index, value in ipairs(tutils.split(config.label, "\n")) do
                lout = lout .. value .. string.rep(" ", math.max(config.width - #config.label, 0)) .. "\n"
            end
            lout = lout:sub(0, #lout - 1)
            config.label = lout
            config.col = col.lightGray
            config.textCol = col.black
        else
            config.label = #config.text > 0 and config.text or " "
            config.textScroll = math.max(math.min(#config.text - config.width + 1, cursorPos), 1)
            config.label = config.label:sub(config.textScroll, config.width + config.textScroll - 1)
            local lout = ""
            for index, value in ipairs(tutils.split(config.label, "\n")) do
                lout = lout .. value .. string.rep(" ", math.max(config.width - #config.label, 0)) .. "\n"
            end
            lout = lout:sub(0, #lout - 1)
            config.label = lout
            config.col = col.gray
            config.textCol = col.white
        end
        return oldgdc(termar)
    end
    return config
end
local function Button(b)
    local config = { col = UItheme.buttonBg, textCol = UItheme.buttonFg }
    for i, v in pairs(b) do
        config[i] = v
    end
    local o = Label(config)
    o.onEvent = function(e)
        local rt = false
        if e[1] == "click" then
            local wh = o.getWH()
            if e[2] == 1 and e[3] >= o.x and e[4] >= o.y and e[3] < o.x + wh[1] and e[4] < o.y + wh[2] then
                if b.callBack() then rt = true end
            end
        end
        return rt
    end
    return o
end
local function Align(x, y, widgettoalign, alignment, xw, xh)
	local widget = widgettoalign
	widget.x = 0
	widget.y = 0
	local w = {}
	local function updateXY(termar)
	  widget.x = 0
	  widget.y = 0
	  local tw, th = termar.getSize()
	  if xw then tw = xw end
	  if xh then th = xh end
	  if alignment[1] >= 0 and alignment[1] <= 1 then
	    w.x = tw*alignment[1]-(widget.getWH()[1]*alignment[1])
	  end
	  if alignment[2] >= 0 and alignment[2] <= 1 then
	    w.y = th*alignment[2]-(widget.getWH()[2]*alignment[2])
	  end
	end
  w = {
	    alignment = alignment,
	    widgettoalign = widget,
	    x = x,
	    y = y,
	    getWH = function ()
    	  return {x + widget.getWH()[1], y + widget.getWH()[2]}
      end,
      getDrawCommands = function (termar)
          print(termar)
    	  updateXY(termar)
    	  local rendercommands = {}
    	  local wrcs = widget.getDrawCommands(termar)
    	  for index,value  in ipairs(wrcs) do
          local vw = value
          vw.x = math.floor(vw.x + w.x)
          vw.y = math.floor(vw.y + w.y)
          table.insert(rendercommands, vw)
        end
        for k,v in ipairs(rendercommands) do
        	print(k, ": ", v.x, v.y, v.bgCol, v.forCol, v.text)
        end
        return rendercommands -- CHICHICHIHA
      end,
      onEvent = function (e)
        if e[1]:sub(#e[1]-6) == "resize" then
          return true
        end
      end
	}
	return w
end
local function DirectRender(wr, ox, oy, buf, terma)
    local rc
    if wr["getDrawCommands"] then
        rc = wr["getDrawCommands"](terma)
    else
        rc = wr
    end
    for i, v in ipairs(rc) do
        blitAtPos(v.x + ox, v.y + oy, v.bgCol, v.forCol, v.text, buf)
    end
end
local function Push(buf, terma)
    for ix, vy in ipairs(buf) do
        local blitText = ""
        local blitColor = ""
        local blitBgColor = ""
        for iy, vx in ipairs(vy) do
            blitBgColor = blitBgColor .. col.toBlit(vx[1])
            blitColor = blitColor .. col.toBlit(vx[2])
            blitText = blitText .. vx[3]
        end
        terma.setCursorPos(1, ix)
        terma.blit(blitText, blitColor, blitBgColor)
    end
end
local function Cpy(buf1, buf2, ox, oy)
    for iy, vy in ipairs(buf1) do
        for ix, vx in ipairs(vy) do
            blitAtPos(ix + ox, iy + oy, vx[1], vx[2], vx[3], buf2)
        end
    end
end
local function RenderWidgets(wdg, ox, oy, buf, outterm)
    local tw, th = #buf[1], #buf
    for i = 1, th, 1 do
        for ix = 1, tw, 1 do
            blitAtPos(ix + ox, i + oy, UItheme.bg, UItheme.fg, " ", buf)
        end
    end
    for index, value in ipairs(wdg) do
        DirectRender(value, ox, oy, buf, outterm)
    end
end
local function Lerp(callback, speed, deAccelAtEnd)
    local accel = 50
    local ox = 0
    speed = speed + 1
    if deAccelAtEnd then
        while ox < 99.5 do
            ox = math.min(math.max(ox + accel, 0), 100)
            accel = accel / speed
            callback(ox)
            sleep(1 / 20)
        end
    else
        accel = 1.5625
        while ox < 99.5 do
            ox = math.min(math.max(ox + accel, 0), 100)
            accel = accel * speed
            callback(ox)
            sleep(1 / 20)
        end
    end
end
local function PageTransition(widgets1, widgets2, dir, speed, ontop, terma)
    local tw, th = terma.getSize()
    local ox = 0
    local buf = InitBuffer(terma)
    local buf2 = InitBuffer(terma)
    local accel = 50
    RenderWidgets(widgets1, 0, 0, buf, terma)
    RenderWidgets(widgets2, 0, 0, buf2, terma)
    speed = speed + 1
    if ontop then
        while ox < tw - 0.5 do
            ox = math.max(((ox / tw) + (accel / 100)) * tw, 0)
            accel = accel / speed
            local sbuf = InitBuffer(terma)
            if sbuf then
                Cpy(buf, sbuf, 0, 0)
                Cpy(buf2, sbuf, (tw - ox) * (dir and -1 or 1), 0)
                Push(sbuf, terma)
            end
            sbuf = nil
            sleep(1 / 20)
        end
    else
        accel = 1.5625
        while ox < tw - 0.5 do
            ox = math.max(((ox / tw) + (accel / 100)) * tw, 0)
            accel = accel * speed
            local sbuf = InitBuffer(terma)
            if sbuf then
                Cpy(buf2, sbuf, 0, 0)
                Cpy(buf, sbuf, (ox) * (dir and -1 or 1), 0)
                Push(sbuf, terma)
            end
            sbuf = nil
            sleep(1 / 20)
        end
    end
end
local function RenderLoop(toRender, outTerm, f)
    local function reRender()
        local buf = InitBuffer(outTerm)
        if buf then
            RenderWidgets(toRender, 0, 0, buf, outTerm)
            Push(buf, outTerm)
        end
        buf = nil
    end
    if f then reRender() end
    local ev = { arcos.ev() }
    local red = false
    local isMonitor, monSide = pcall(__LEGACY.peripheral.getName, outTerm)
    if not isMonitor then
        if ev[1] == "mouse_click" then
            for i, v in ipairs(toRender) do
                if v.onEvent({ "click", ev[2], ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
            end
        elseif ev[1] == "mouse_drag" then
            for i, v in ipairs(toRender) do
                if v.onEvent({ "drag", ev[2], ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
            end
        elseif ev[1] == "mouse_up" then
            for i, v in ipairs(toRender) do
                if v.onEvent({ "up", ev[2], ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
            end
        elseif ev[1] == "mouse_scroll" then
            for i, v in ipairs(toRender) do
                if v.onEvent({ "scroll", ev[2], ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
            end
        else
            for i, v in ipairs(toRender) do
                if v.onEvent(ev, outTerm) then red = true end
            end
        end
    else
        if ev[1] == "monitor_touch" and ev[2] == monSide then
            for i, v in ipairs(toRender) do
                if v.onEvent({ "click", 1, ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
                if v.onEvent({ "up", 1, ev[3] - 0, ev[4] - 0 }, outTerm) then red = true end
            end
        else
            for i, v in ipairs(toRender) do
                if v.onEvent(ev, outTerm) then red = true end
            end
        end
    end
    return red, ev
end
return {
    Align = Align,
    Label = Label,
    Button = Button,
    DirectRender = DirectRender,
    UItheme = UItheme,
    RenderWidgets = RenderWidgets,
    PageTransition = PageTransition,
    InitBuffer = InitBuffer,
    Push = Push,
    Cpy = Cpy,
    Wrap = Wrap,
    RenderLoop = RenderLoop,
    ScrollPane = ScrollPane,
    TextInput = TextInput,
    Lerp = Lerp,
}
local col = require("col")
local expect = col.expect
local tHex = {
    [col.white] = "0",
    [col.orange] = "1",
    [col.magenta] = "2",
    [col.lightBlue] = "3",
    [col.yellow] = "4",
    [col.lime] = "5",
    [col.pink] = "6",
    [col.gray] = "7",
    [col.lightGray] = "8",
    [col.cyan] = "9",
    [col.purple] = "a",
    [col.blue] = "b",
    [col.brown] = "c",
    [col.green] = "d",
    [col.red] = "e",
    [col.black] = "f",
}
local type = type
local string_rep = string.rep
local string_sub = string.sub
local function parse_color(color)
    if type(color) ~= "number" then
        return expect(1, color, "number")
    end
    if color < 0 or color > 0xffff then error("Colour out of range", 3) end
    return 2 ^ math.floor(math.log(color, 2))
end
local function create(parent, nX, nY, nWidth, nHeight, bStartVisible)
    expect(1, parent, "table")
    expect(2, nX, "number")
    expect(3, nY, "number")
    expect(4, nWidth, "number")
    expect(5, nHeight, "number")
    expect(6, bStartVisible, "boolean", "nil")
    if parent == term then
        error("term is not a recommended window parent, try term.current() instead", 2)
    end
    local sEmptySpaceLine
    local tEmptyColorLines = {}
    local function createEmptyLines(nWidth)
        sEmptySpaceLine = string_rep(" ", nWidth)
        for n = 0, 15 do
            local nColor = 2 ^ n
            local sHex = tHex[nColor]
            tEmptyColorLines[nColor] = string_rep(sHex, nWidth)
        end
    end
    createEmptyLines(nWidth)
    local bVisible = bStartVisible ~= false
    local nCursorX = 1
    local nCursorY = 1
    local bCursorBlink = false
    local nTextColor = col.white
    local nBackgroundColor = col.black
    local tLines = {}
    local tPalette = {}
    do
        local sEmptyText = sEmptySpaceLine
        local sEmptyTextColor = tEmptyColorLines[nTextColor]
        local sEmptyBackgroundColor = tEmptyColorLines[nBackgroundColor]
        for y = 1, nHeight do
            tLines[y] = { sEmptyText, sEmptyTextColor, sEmptyBackgroundColor }
        end
        for i = 0, 15 do
            local c = 2 ^ i
            tPalette[c] = { parent.getPaletteColour(c) }
        end
    end
    local function updateCursorPos()
        if nCursorX >= 1 and nCursorY >= 1 and
           nCursorX <= nWidth and nCursorY <= nHeight then
            parent.setCursorPos(nX + nCursorX - 1, nY + nCursorY - 1)
        else
            parent.setCursorPos(0, 0)
        end
    end
    local function updateCursorBlink()
        parent.setCursorBlink(bCursorBlink)
    end
    local function updateCursorColor()
        parent.setTextColor(nTextColor)
    end
    local function redrawLine(n)
        local tLine = tLines[n]
        parent.setCursorPos(nX, nY + n - 1)
        parent.blit(tLine[1], tLine[2], tLine[3])
    end
    local function redraw()
        for n = 1, nHeight do
            redrawLine(n)
        end
    end
    local function updatePalette()
        for k, v in pairs(tPalette) do
            parent.setPaletteColour(k, v[1], v[2], v[3])
        end
    end
    local function internalBlit(sText, sTextColor, sBackgroundColor)
        local nStart = nCursorX
        local nEnd = nStart + #sText - 1
        if nCursorY >= 1 and nCursorY <= nHeight then
            if nStart <= nWidth and nEnd >= 1 then
                local tLine = tLines[nCursorY]
                if nStart == 1 and nEnd == nWidth then
                    tLine[1] = sText
                    tLine[2] = sTextColor
                    tLine[3] = sBackgroundColor
                else
                    local sClippedText, sClippedTextColor, sClippedBackgroundColor
                    if nStart < 1 then
                        local nClipStart = 1 - nStart + 1
                        local nClipEnd = nWidth - nStart + 1
                        sClippedText = string_sub(sText, nClipStart, nClipEnd)
                        sClippedTextColor = string_sub(sTextColor, nClipStart, nClipEnd)
                        sClippedBackgroundColor = string_sub(sBackgroundColor, nClipStart, nClipEnd)
                    elseif nEnd > nWidth then
                        local nClipEnd = nWidth - nStart + 1
                        sClippedText = string_sub(sText, 1, nClipEnd)
                        sClippedTextColor = string_sub(sTextColor, 1, nClipEnd)
                        sClippedBackgroundColor = string_sub(sBackgroundColor, 1, nClipEnd)
                    else
                        sClippedText = sText
                        sClippedTextColor = sTextColor
                        sClippedBackgroundColor = sBackgroundColor
                    end
                    local sOldText = tLine[1]
                    local sOldTextColor = tLine[2]
                    local sOldBackgroundColor = tLine[3]
                    local sNewText, sNewTextColor, sNewBackgroundColor
                    if nStart > 1 then
                        local nOldEnd = nStart - 1
                        sNewText = string_sub(sOldText, 1, nOldEnd) .. sClippedText
                        sNewTextColor = string_sub(sOldTextColor, 1, nOldEnd) .. sClippedTextColor
                        sNewBackgroundColor = string_sub(sOldBackgroundColor, 1, nOldEnd) .. sClippedBackgroundColor
                    else
                        sNewText = sClippedText
                        sNewTextColor = sClippedTextColor
                        sNewBackgroundColor = sClippedBackgroundColor
                    end
                    if nEnd < nWidth then
                        local nOldStart = nEnd + 1
                        sNewText = sNewText .. string_sub(sOldText, nOldStart, nWidth)
                        sNewTextColor = sNewTextColor .. string_sub(sOldTextColor, nOldStart, nWidth)
                        sNewBackgroundColor = sNewBackgroundColor .. string_sub(sOldBackgroundColor, nOldStart, nWidth)
                    end
                    tLine[1] = sNewText
                    tLine[2] = sNewTextColor
                    tLine[3] = sNewBackgroundColor
                end
                if bVisible then
                    redrawLine(nCursorY)
                end
            end
        end
        nCursorX = nEnd + 1
        if bVisible then
            updateCursorColor()
            updateCursorPos()
        end
    end
    local window = {}
    function window.write(sText)
        sText = tostring(sText)
        internalBlit(sText, string_rep(tHex[nTextColor], #sText), string_rep(tHex[nBackgroundColor], #sText))
    end
    function window.blit(sText, sTextColor, sBackgroundColor)
        if type(sText) ~= "string" then expect(1, sText, "string") end
        if type(sTextColor) ~= "string" then expect(2, sTextColor, "string") end
        if type(sBackgroundColor) ~= "string" then expect(3, sBackgroundColor, "string") end
        if #sTextColor ~= #sText or #sBackgroundColor ~= #sText then
            error("Arguments must be the same length", 2)
        end
        sTextColor = sTextColor:lower()
        sBackgroundColor = sBackgroundColor:lower()
        internalBlit(sText, sTextColor, sBackgroundColor)
    end
    function window.clear()
        local sEmptyText = sEmptySpaceLine
        local sEmptyTextColor = tEmptyColorLines[nTextColor]
        local sEmptyBackgroundColor = tEmptyColorLines[nBackgroundColor]
        for y = 1, nHeight do
            local line = tLines[y]
            line[1] = sEmptyText
            line[2] = sEmptyTextColor
            line[3] = sEmptyBackgroundColor
        end
        if bVisible then
            redraw()
            updateCursorColor()
            updateCursorPos()
        end
    end
    function window.clearLine()
        if nCursorY >= 1 and nCursorY <= nHeight then
            local line = tLines[nCursorY]
            line[1] = sEmptySpaceLine
            line[2] = tEmptyColorLines[nTextColor]
            line[3] = tEmptyColorLines[nBackgroundColor]
            if bVisible then
                redrawLine(nCursorY)
                updateCursorColor()
                updateCursorPos()
            end
        end
    end
    function window.getCursorPos()
        return nCursorX, nCursorY
    end
    function window.setCursorPos(x, y)
        if type(x) ~= "number" then expect(1, x, "number") end
        if type(y) ~= "number" then expect(2, y, "number") end
        nCursorX = math.floor(x)
        nCursorY = math.floor(y)
        if bVisible then
            updateCursorPos()
        end
    end
    function window.setCursorBlink(blink)
        if type(blink) ~= "boolean" then expect(1, blink, "boolean") end
        bCursorBlink = blink
        if bVisible then
            updateCursorBlink()
        end
    end
    function window.getCursorBlink()
        return bCursorBlink
    end
    local function isColor()
        return parent.isColor()
    end
    function window.isColor()
        return isColor()
    end
    function window.isColour()
        return isColor()
    end
    local function setTextColor(color)
        if tHex[color] == nil then color = parse_color(color) end
        nTextColor = color
        if bVisible then
            updateCursorColor()
        end
    end
    window.setTextColor = setTextColor
    window.setTextColour = setTextColor
    function window.setPaletteColour(colour, r, g, b)
        if tHex[colour] == nil then colour = parse_color(colour) end
        local tCol
        if type(r) == "number" and g == nil and b == nil then
            tCol = { col.unpackRGB(r) }
            tPalette[colour] = tCol
        else
            if type(r) ~= "number" then expect(2, r, "number") end
            if type(g) ~= "number" then expect(3, g, "number") end
            if type(b) ~= "number" then expect(4, b, "number") end
            tCol = tPalette[colour]
            tCol[1] = r
            tCol[2] = g
            tCol[3] = b
        end
        if bVisible then
            return parent.setPaletteColour(colour, tCol[1], tCol[2], tCol[3])
        end
    end
    window.setPaletteColor = window.setPaletteColour
    function window.getPaletteColour(colour)
        if tHex[colour] == nil then colour = parse_color(colour) end
        local tCol = tPalette[colour]
        return tCol[1], tCol[2], tCol[3]
    end
    window.getPaletteColor = window.getPaletteColour
    local function setBackgroundColor(color)
        if tHex[color] == nil then color = parse_color(color) end
        nBackgroundColor = color
    end
    window.setBackgroundColor = setBackgroundColor
    window.setBackgroundColour = setBackgroundColor
    function window.getSize()
        return nWidth, nHeight
    end
    function window.scroll(n)
        if type(n) ~= "number" then expect(1, n, "number") end
        if n ~= 0 then
            local tNewLines = {}
            local sEmptyText = sEmptySpaceLine
            local sEmptyTextColor = tEmptyColorLines[nTextColor]
            local sEmptyBackgroundColor = tEmptyColorLines[nBackgroundColor]
            for newY = 1, nHeight do
                local y = newY + n
                if y >= 1 and y <= nHeight then
                    tNewLines[newY] = tLines[y]
                else
                    tNewLines[newY] = { sEmptyText, sEmptyTextColor, sEmptyBackgroundColor }
                end
            end
            tLines = tNewLines
            if bVisible then
                redraw()
                updateCursorColor()
                updateCursorPos()
            end
        end
    end
    function window.getTextColor()
        return nTextColor
    end
    function window.getTextColour()
        return nTextColor
    end
    function window.getBackgroundColor()
        return nBackgroundColor
    end
    function window.getBackgroundColour()
        return nBackgroundColor
    end
    function window.getLine(y)
        if type(y) ~= "number" then expect(1, y, "number") end
        if y < 1 or y > nHeight then
            error("Line is out of range.", 2)
        end
        local line = tLines[y]
        return line[1], line[2], line[3]
    end
    function window.setVisible(visible)
        if type(visible) ~= "boolean" then expect(1, visible, "boolean") end
        if bVisible ~= visible then
            bVisible = visible
            if bVisible then
                window.redraw()
            end
        end
    end
    function window.isVisible()
        return bVisible
    end
    function window.redraw()
        if bVisible then
            redraw()
            updatePalette()
            updateCursorBlink()
            updateCursorColor()
            updateCursorPos()
        end
    end
    function window.restoreCursor()
        if bVisible then
            updateCursorBlink()
            updateCursorColor()
            updateCursorPos()
        end
    end
    function window.getPosition()
        return nX, nY
    end
    function window.reposition(new_x, new_y, new_width, new_height, new_parent)
        if type(new_x) ~= "number" then expect(1, new_x, "number") end
        if type(new_y) ~= "number" then expect(2, new_y, "number") end
        if new_width ~= nil or new_height ~= nil then
            expect(3, new_width, "number")
            expect(4, new_height, "number")
        end
        if new_parent ~= nil and type(new_parent) ~= "table" then expect(5, new_parent, "table") end
        nX = new_x
        nY = new_y
        if new_parent then parent = new_parent end
        if new_width and new_height then
            local tNewLines = {}
            createEmptyLines(new_width)
            local sEmptyText = sEmptySpaceLine
            local sEmptyTextColor = tEmptyColorLines[nTextColor]
            local sEmptyBackgroundColor = tEmptyColorLines[nBackgroundColor]
            for y = 1, new_height do
                if y > nHeight then
                    tNewLines[y] = { sEmptyText, sEmptyTextColor, sEmptyBackgroundColor }
                else
                    local tOldLine = tLines[y]
                    if new_width == nWidth then
                        tNewLines[y] = tOldLine
                    elseif new_width < nWidth then
                        tNewLines[y] = {
                            string_sub(tOldLine[1], 1, new_width),
                            string_sub(tOldLine[2], 1, new_width),
                            string_sub(tOldLine[3], 1, new_width),
                        }
                    else
                        tNewLines[y] = {
                            tOldLine[1] .. string_sub(sEmptyText, nWidth + 1, new_width),
                            tOldLine[2] .. string_sub(sEmptyTextColor, nWidth + 1, new_width),
                            tOldLine[3] .. string_sub(sEmptyBackgroundColor, nWidth + 1, new_width),
                        }
                    end
                end
            end
            nWidth = new_width
            nHeight = new_height
            tLines = tNewLines
        end
        if bVisible then
            window.redraw()
        end
    end
    if bVisible then
        window.redraw()
    end
    return window
end
return {create = create}-- Generated by Haxe 4.3.6
local _hx_hidden = {__id__=true, hx__closures=true, super=true, prototype=true, __fields__=true, __ifields__=true, __class__=true, __properties__=true, __fields__=true, __name__=true}

_hx_array_mt = {
    __newindex = function(t,k,v)
        local len = t.length
        t.length =  k >= len and (k + 1) or len
        rawset(t,k,v)
    end
}

function _hx_is_array(o)
    return type(o) == "table"
        and o.__enum__ == nil
        and getmetatable(o) == _hx_array_mt
end



function _hx_tab_array(tab, length)
    tab.length = length
    return setmetatable(tab, _hx_array_mt)
end



function _hx_print_class(obj, depth)
    local first = true
    local result = ''
    for k,v in pairs(obj) do
        if _hx_hidden[k] == nil then
            if first then
                first = false
            else
                result = result .. ', '
            end
            if _hx_hidden[k] == nil then
                result = result .. k .. ':' .. _hx_tostring(v, depth+1)
            end
        end
    end
    return '{ ' .. result .. ' }'
end

function _hx_print_enum(o, depth)
    if o.length == 2 then
        return o[0]
    else
        local str = o[0] .. "("
        for i = 2, (o.length-1) do
            if i ~= 2 then
                str = str .. "," .. _hx_tostring(o[i], depth+1)
            else
                str = str .. _hx_tostring(o[i], depth+1)
            end
        end
        return str .. ")"
    end
end

function _hx_tostring(obj, depth)
    if depth == nil then
        depth = 0
    elseif depth > 5 then
        return "<...>"
    end

    local tstr = _G.type(obj)
    if tstr == "string" then return obj
    elseif tstr == "nil" then return "null"
    elseif tstr == "number" then
        if obj == _G.math.POSITIVE_INFINITY then return "Infinity"
        elseif obj == _G.math.NEGATIVE_INFINITY then return "-Infinity"
        elseif obj == 0 then return "0"
        elseif obj ~= obj then return "NaN"
        else return _G.tostring(obj)
        end
    elseif tstr == "boolean" then return _G.tostring(obj)
    elseif tstr == "userdata" then
        local mt = _G.getmetatable(obj)
        if mt ~= nil and mt.__tostring ~= nil then
            return _G.tostring(obj)
        else
            return "<userdata>"
        end
    elseif tstr == "function" then return "<function>"
    elseif tstr == "thread" then return "<thread>"
    elseif tstr == "table" then
        if obj.__enum__ ~= nil then
            return _hx_print_enum(obj, depth)
        elseif obj.toString ~= nil and not _hx_is_array(obj) then return obj:toString()
        elseif _hx_is_array(obj) then
            if obj.length > 5 then
                return "[...]"
            else
                local str = ""
                for i=0, (obj.length-1) do
                    if i == 0 then
                        str = str .. _hx_tostring(obj[i], depth+1)
                    else
                        str = str .. "," .. _hx_tostring(obj[i], depth+1)
                    end
                end
                return "[" .. str .. "]"
            end
        elseif obj.__class__ ~= nil then
            return _hx_print_class(obj, depth)
        else
            local buffer = {}
            local ref = obj
            if obj.__fields__ ~= nil then
                ref = obj.__fields__
            end
            for k,v in pairs(ref) do
                if _hx_hidden[k] == nil then
                    _G.table.insert(buffer, _hx_tostring(k, depth+1) .. ' : ' .. _hx_tostring(obj[k], depth+1))
                end
            end

            return "{ " .. table.concat(buffer, ", ") .. " }"
        end
    else
        _G.error("Unknown Lua type", 0)
        return ""
    end
end

local function _hx_obj_newindex(t,k,v)
    t.__fields__[k] = true
    rawset(t,k,v)
end

local _hx_obj_mt = {__newindex=_hx_obj_newindex, __tostring=_hx_tostring}

local function _hx_a(...)
  local __fields__ = {};
  local ret = {__fields__ = __fields__};
  local max = select('#',...);
  local tab = {...};
  local cur = 1;
  while cur < max do
    local v = tab[cur];
    __fields__[v] = true;
    ret[v] = tab[cur+1];
    cur = cur + 2
  end
  return setmetatable(ret, _hx_obj_mt)
end

local function _hx_e()
  return setmetatable({__fields__ = {}}, _hx_obj_mt)
end

local function _hx_o(obj)
  return setmetatable(obj, _hx_obj_mt)
end

local function _hx_new(prototype)
  return setmetatable({__fields__ = {}}, {__newindex=_hx_obj_newindex, __index=prototype, __tostring=_hx_tostring})
end

function _hx_field_arr(obj)
    local res = {}
    local idx = 0
    if obj.__fields__ ~= nil then
        obj = obj.__fields__
    end
    for k,v in pairs(obj) do
        if _hx_hidden[k] == nil then
            res[idx] = k
            idx = idx + 1
        end
    end
    return _hx_tab_array(res, idx)
end

local _hxClasses = {}
local Int = _hx_e();
local Dynamic = _hx_e();
local Float = _hx_e();
local Bool = _hx_e();
local Class = _hx_e();
local Enum = _hx_e();

local _hx_exports = _hx_exports or {}
_hx_exports["typedefs"] = _hx_exports["typedefs"] or _hx_e()
local Array = _hx_e()
local Transition = _hx_e()
local Command = _hx_e()
local Widget = _hx_e()
local SimpleContainer = _hx_e()
local Button = _hx_e()
local Color = _hx_e()
local RGBColor = _hx_e()
local Colors = _hx_e()
local MouseButton = _hx_e()
local Label = _hx_e()
___Label_Label_Fields_ = _hx_e()
local String = _hx_e()
local Std = _hx_e()
local Math = _hx_e()
__lua_PairTools = _hx_e()
local TextArea = _hx_e()
local ScrollContainer = _hx_e()
local Values = _hx_e()
local Date = _hx_e()
local CCOS = _hx_e()
local Lambda = _hx_e()
local Main = _hx_e()
local Reflect = _hx_e()
local RenderCommand = _hx_e()
local PositionedRenderCommand = _hx_e()
local Buffer = _hx_e()
local Renderer = _hx_e()
local StringBuf = _hx_e()
local StringTools = _hx_e()
local ValueType = _hx_e()
local Type = _hx_e()
local Runner = _hx_e()
local UILoader = _hx_e()
local ScreenManager = _hx_e()
local Vector2f = _hx_e()
local Style = _hx_e()
__haxe_IMap = _hx_e()
__haxe_Exception = _hx_e()
__haxe_Json = _hx_e()
__haxe_NativeStackTrace = _hx_e()
__haxe_ValueException = _hx_e()
__haxe_ds_StringMap = _hx_e()
__haxe_exceptions_PosException = _hx_e()
__haxe_exceptions_NotImplementedException = _hx_e()
__haxe_format_JsonParser = _hx_e()
__haxe_format_JsonPrinter = _hx_e()
__haxe_iterators_ArrayIterator = _hx_e()
__haxe_iterators_ArrayKeyValueIterator = _hx_e()
__haxe_macro_Error = _hx_e()
__hxease_IEasing = _hx_e()
__hxease_BackEaseIn = _hx_e()
__hxease_BackEaseInOut = _hx_e()
__hxease_BackEaseOut = _hx_e()
__hxease_Back = _hx_e()
__hxease_LinearEaseNone = _hx_e()
__hxease_LinearEaseStep = _hx_e()
__hxease_Linear = _hx_e()
__lua_Boot = _hx_e()
__lua_UserData = _hx_e()
__lua_Thread = _hx_e()
__typedefs_Terminal = _hx_e()
__typedefs_Simpleterminal = _hx_e()
__typedefs_CCTerminal = _hx_e()

local _hx_bind, _hx_bit, _hx_staticToInstance, _hx_funcToField, _hx_maxn, _hx_print, _hx_apply_self, _hx_box_mr, _hx_bit_clamp, _hx_table, _hx_bit_raw
local _hx_pcall_default = {};
local _hx_pcall_break = {};

Array.new = function() 
  local self = _hx_new(Array.prototype)
  Array.super(self)
  return self
end
Array.super = function(self) 
  _hx_tab_array(self, 0);
end
Array.__name__ = true
Array.prototype = _hx_e();
Array.prototype.length= nil;
Array.prototype.concat = function(self,a) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self;
  while (_g1 < _g2.length) do _hx_do_first_1 = false;
    
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    _g:push(i);
  end;
  local ret = _g;
  local _g = 0;
  while (_g < a.length) do _hx_do_first_1 = false;
    
    local i = a[_g];
    _g = _g + 1;
    ret:push(i);
  end;
  do return ret end
end
Array.prototype.join = function(self,sep) 
  local tbl = ({});
  local _g_current = 0;
  local _g_array = self;
  while (_g_current < _g_array.length) do _hx_do_first_1 = false;
    
    _g_current = _g_current + 1;
    local i = _g_array[_g_current - 1];
    _G.table.insert(tbl, Std.string(i));
  end;
  do return _G.table.concat(tbl, sep) end
end
Array.prototype.pop = function(self) 
  if (self.length == 0) then 
    do return nil end;
  end;
  local ret = self[self.length - 1];
  self[self.length - 1] = nil;
  self.length = self.length - 1;
  do return ret end
end
Array.prototype.push = function(self,x) 
  self[self.length] = x;
  do return self.length end
end
Array.prototype.reverse = function(self) 
  local tmp;
  local i = 0;
  while (i < Std.int(self.length / 2)) do _hx_do_first_1 = false;
    
    tmp = self[i];
    self[i] = self[(self.length - i) - 1];
    self[(self.length - i) - 1] = tmp;
    i = i + 1;
  end;
end
Array.prototype.shift = function(self) 
  if (self.length == 0) then 
    do return nil end;
  end;
  local ret = self[0];
  if (self.length == 1) then 
    self[0] = nil;
  else
    if (self.length > 1) then 
      self[0] = self[1];
      _G.table.remove(self, 1);
    end;
  end;
  local tmp = self;
  tmp.length = tmp.length - 1;
  do return ret end
end
Array.prototype.slice = function(self,pos,_end) 
  if ((_end == nil) or (_end > self.length)) then 
    _end = self.length;
  else
    if (_end < 0) then 
      _end = _G.math.fmod((self.length - (_G.math.fmod(-_end, self.length))), self.length);
    end;
  end;
  if (pos < 0) then 
    pos = _G.math.fmod((self.length - (_G.math.fmod(-pos, self.length))), self.length);
  end;
  if ((pos > _end) or (pos > self.length)) then 
    do return _hx_tab_array({}, 0) end;
  end;
  local ret = _hx_tab_array({}, 0);
  local _g = pos;
  local _g1 = _end;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    ret:push(self[i]);
  end;
  do return ret end
end
Array.prototype.sort = function(self,f) 
  local i = 0;
  local l = self.length;
  while (i < l) do _hx_do_first_1 = false;
    
    local swap = false;
    local j = 0;
    local max = (l - i) - 1;
    while (j < max) do _hx_do_first_2 = false;
      
      if (f(self[j], self[j + 1]) > 0) then 
        local tmp = self[j + 1];
        self[j + 1] = self[j];
        self[j] = tmp;
        swap = true;
      end;
      j = j + 1;
    end;
    if (not swap) then 
      break;
    end;
    i = i + 1;
  end;
end
Array.prototype.splice = function(self,pos,len) 
  if ((len < 0) or (pos > self.length)) then 
    do return _hx_tab_array({}, 0) end;
  else
    if (pos < 0) then 
      pos = self.length - (_G.math.fmod(-pos, self.length));
    end;
  end;
  len = Math.min(len, self.length - pos);
  local ret = _hx_tab_array({}, 0);
  local _g = pos;
  local _g1 = pos + len;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    ret:push(self[i]);
    self[i] = self[i + len];
  end;
  local _g = pos + len;
  local _g1 = self.length;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    self[i] = self[i + len];
  end;
  local tmp = self;
  tmp.length = tmp.length - len;
  do return ret end
end
Array.prototype.toString = function(self) 
  local tbl = ({});
  _G.table.insert(tbl, "[");
  _G.table.insert(tbl, self:join(","));
  _G.table.insert(tbl, "]");
  do return _G.table.concat(tbl, "") end
end
Array.prototype.unshift = function(self,x) 
  local len = self.length;
  local _g = 0;
  local _g1 = len;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    self[len - i] = self[(len - i) - 1];
  end;
  self[0] = x;
end
Array.prototype.insert = function(self,pos,x) 
  if (pos > self.length) then 
    pos = self.length;
  end;
  if (pos < 0) then 
    pos = self.length + pos;
    if (pos < 0) then 
      pos = 0;
    end;
  end;
  local cur_len = self.length;
  while (cur_len > pos) do _hx_do_first_1 = false;
    
    self[cur_len] = self[cur_len - 1];
    cur_len = cur_len - 1;
  end;
  self[pos] = x;
end
Array.prototype.remove = function(self,x) 
  local _g = 0;
  local _g1 = self.length;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    if (self[i] == x) then 
      local _g = i;
      local _g1 = self.length - 1;
      while (_g < _g1) do _hx_do_first_2 = false;
        
        _g = _g + 1;
        local j = _g - 1;
        self[j] = self[j + 1];
      end;
      self[self.length - 1] = nil;
      self.length = self.length - 1;
      do return true end;
    end;
  end;
  do return false end
end
Array.prototype.contains = function(self,x) 
  local _g = 0;
  local _g1 = self.length;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    if (self[i] == x) then 
      do return true end;
    end;
  end;
  do return false end
end
Array.prototype.indexOf = function(self,x,fromIndex) 
  local _end = self.length;
  if (fromIndex == nil) then 
    fromIndex = 0;
  else
    if (fromIndex < 0) then 
      fromIndex = self.length + fromIndex;
      if (fromIndex < 0) then 
        fromIndex = 0;
      end;
    end;
  end;
  local _g = fromIndex;
  local _g1 = _end;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    if (x == self[i]) then 
      do return i end;
    end;
  end;
  do return -1 end
end
Array.prototype.lastIndexOf = function(self,x,fromIndex) 
  if ((fromIndex == nil) or (fromIndex >= self.length)) then 
    fromIndex = self.length - 1;
  else
    if (fromIndex < 0) then 
      fromIndex = self.length + fromIndex;
      if (fromIndex < 0) then 
        do return -1 end;
      end;
    end;
  end;
  local i = fromIndex;
  while (i >= 0) do _hx_do_first_1 = false;
    
    if (self[i] == x) then 
      do return i end;
    else
      i = i - 1;
    end;
  end;
  do return -1 end
end
Array.prototype.copy = function(self) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self;
  while (_g1 < _g2.length) do _hx_do_first_1 = false;
    
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    _g:push(i);
  end;
  do return _g end
end
Array.prototype.map = function(self,f) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self;
  while (_g1 < _g2.length) do _hx_do_first_1 = false;
    
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    _g:push(f(i));
  end;
  do return _g end
end
Array.prototype.filter = function(self,f) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self;
  while (_g1 < _g2.length) do _hx_do_first_1 = false;
    
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    if (f(i)) then 
      _g:push(i);
    end;
  end;
  do return _g end
end
Array.prototype.iterator = function(self) 
  do return __haxe_iterators_ArrayIterator.new(self) end
end
Array.prototype.keyValueIterator = function(self) 
  do return __haxe_iterators_ArrayKeyValueIterator.new(self) end
end
Array.prototype.resize = function(self,len) 
  if (self.length < len) then 
    self.length = len;
  else
    if (self.length > len) then 
      local _g = len;
      local _g1 = self.length;
      while (_g < _g1) do _hx_do_first_1 = false;
        
        _g = _g + 1;
        local i = _g - 1;
        self[i] = nil;
      end;
      self.length = len;
    end;
  end;
end

Array.prototype.__class__ =  Array

Transition.new = function(direction,anim,curve,duration) 
  local self = _hx_new(Transition.prototype)
  Transition.super(self,direction,anim,curve,duration)
  return self
end
Transition.super = function(self,direction,anim,curve,duration) 
  self.duration = 1000;
  self.curve = "easein";
  self.anim = "over";
  self.direction = "left";
  if (direction ~= nil) then 
    self.direction = direction;
  end;
  if (anim ~= nil) then 
    self.anim = anim;
  end;
  if (curve ~= nil) then 
    self.curve = curve;
  end;
  if (duration ~= nil) then 
    self.duration = duration;
  end;
end
_hx_exports["Transition"] = Transition
Transition.__name__ = true
Transition.prototype = _hx_e();
Transition.prototype.direction= nil;
Transition.prototype.anim= nil;
Transition.prototype.curve= nil;
Transition.prototype.duration= nil;
Transition.prototype.run = function(self,callback,min,max) 
  local l = max - min;
  local divider = 2;
  local el = l / divider;
  local la = self.duration / el;
  local _g_min = 0;
  local _g_max = Std.int(la);
  while (_g_min < _g_max) do _hx_do_first_1 = false;
    
    _g_min = _g_min + 1;
    local i = _g_min - 1;
    callback((self:getValue(i / l) * l) + min);
    sleep((self.duration / 1000) / la);
  end;
end
Transition.prototype.copy = function(self) 
  do return Transition.new(self.direction, self.anim, self.curve, self.duration) end
end
Transition.prototype.runForScreens = function(self,callback,screenwidth,screenheight) 
  local _gthis = self;
  local cb = function(n) 
    local e = Std.int(n);
    local _g = _gthis.anim;
    if (_g) == "over" then 
      local _g = _gthis.direction;
      if (_g) == "bottom" then 
        callback(0, 0, 0, e - screenheight, false, n / screenheight);
      elseif (_g) == "left" then 
        callback(0, 0, e - screenwidth, 0, false, n / screenwidth);
      elseif (_g) == "right" then 
        callback(0, 0, screenwidth - e, 0, false, n / screenwidth);
      elseif (_g) == "top" then 
        callback(0, 0, 0, screenheight - e, false, n / screenheight); end;
    elseif (_g) == "slide" then 
      local _g = _gthis.direction;
      if (_g) == "bottom" then 
        callback(0, e, 0, e - screenheight, false, n / screenheight);
      elseif (_g) == "left" then 
        callback(e, 0, e - screenwidth, 0, false, n / screenwidth);
      elseif (_g) == "right" then 
        callback(-e, 0, screenwidth - e, 0, false, n / screenwidth);
      elseif (_g) == "top" then 
        callback(0, -e, 0, screenheight - e, false, n / screenheight); end;
    elseif (_g) == "under" then 
      local _g = _gthis.direction;
      if (_g) == "bottom" then 
        callback(0, e, 0, 0, true, n / screenheight);
      elseif (_g) == "left" then 
        callback(e, 0, 0, 0, true, n / screenwidth);
      elseif (_g) == "right" then 
        callback(-e, 0, 0, 0, true, n / screenwidth);
      elseif (_g) == "top" then 
        callback(0, -e, 0, 0, true, n / screenheight); end; end;
  end;
  local _g = self.direction;
  if (_g) == "bottom" or (_g) == "top" then 
    self:run(cb, 0, screenheight);
  elseif (_g) == "left" or (_g) == "right" then 
    self:run(cb, 0, screenwidth); end;
end
Transition.prototype.getValue = function(self,ratioa) 
  local ratio = ratioa * 1.5;
  local _g = self.curve;
  if (_g) == "ease" then 
    do return __hxease_BackEaseInOut.new(0):calculate(ratio) end;
  elseif (_g) == "easein" then 
    do return __hxease_BackEaseIn.new(0):calculate(ratio) end;
  elseif (_g) == "easeout" then 
    do return __hxease_BackEaseOut.new(0):calculate(ratio) end;else
  do return __hxease_LinearEaseNone.new():calculate(ratio) end; end;
end

Transition.prototype.__class__ =  Transition

Command.new = function(type,value,transition) 
  local self = _hx_new(Command.prototype)
  Command.super(self,type,value,transition)
  return self
end
Command.super = function(self,type,value,transition) 
  self.transition = Transition.new("left", "over", "easein");
  self.value = "-- Target is the widget which runs this command\nlocal target = { ... }";
  self.type = "execLua";
  if (type ~= nil) then 
    self.type = type;
  end;
  if (value ~= nil) then 
    self.value = value;
  end;
  if (transition ~= nil) then 
    self.transition = transition;
  end;
end
_hx_exports["Command"] = Command
Command.__name__ = true
Command.deserialize = function(d) 
  local o = d;
  if (not ((function() 
    local _hx_1
    if ((_G.type(o) == "function") and not ((function() 
      local _hx_2
      if (_G.type(o) ~= "table") then 
      _hx_2 = false; else 
      _hx_2 = o.__name__; end
      return _hx_2
    end )() or (function() 
      local _hx_3
      if (_G.type(o) ~= "table") then 
      _hx_3 = false; else 
      _hx_3 = o.__ename__; end
      return _hx_3
    end )())) then 
    _hx_1 = false; elseif ((_G.type(o) == "string") and (String.prototype.type ~= nil)) then 
    _hx_1 = true; elseif (o.__fields__ ~= nil) then 
    _hx_1 = o.__fields__.type ~= nil; else 
    _hx_1 = o.type ~= nil; end
    return _hx_1
  end )()) or (Reflect.field(d, "type") ~= "Command")) then 
    _G.error(__haxe_Exception.new("Not a command."),0);
  end;
  local t = Reflect.field(d, "transition");
  do return Command.new(Reflect.field(d, "ctype"), Reflect.field(d, "value"), Transition.new(Reflect.field(t, "dir"), Reflect.field(t, "anim"), Reflect.field(t, "curve"), Reflect.field(t, "duration"))) end;
end
Command.prototype = _hx_e();
Command.prototype.type= nil;
Command.prototype.value= nil;
Command.prototype.transition= nil;
Command.prototype.serialize = function(self) 
  do return _hx_o({__fields__={type=true,ctype=true,value=true,transition=true},type="Command",ctype=self.type,value=self.value,transition=_hx_o({__fields__={dir=true,anim=true,curve=true,duration=true},dir=self.transition.direction,anim=self.transition.anim,curve=self.transition.curve,duration=self.transition.duration})}) end
end
Command.prototype.execute = function(self,runner,screenwidth,screenheight) 
  local _g = self.type;
  if (_g) == "execLua" then 
    local _hx_1_l_func, _hx_1_l_message = _G.load(self.value);
    local tmp = _hx_1_l_func == nil;
    l.func(runner);
  elseif (_g) == "goToScreen" then 
    local s1 = Buffer.new(Std.int(screenwidth), Std.int(screenheight));
    local s2 = Buffer.new(Std.int(screenwidth), Std.int(screenheight));
    local _g = 0;
    local _g1 = runner:getWman():current():getPRenderCommands(screenwidth, screenheight, false);
    while (_g < _g1.length) do _hx_do_first_1 = false;
      
      local command = _g1[_g];
      _g = _g + 1;
      s1:addPRC(command);
    end;
    runner:getWman().screens[Std.parseInt(self.value)].x = 0;
    runner:getWman().screens[Std.parseInt(self.value)].y = 0;
    runner:getWman().screens[Std.parseInt(self.value)].width = Std.int(runner:getWman().term:getSize().x);
    runner:getWman().screens[Std.parseInt(self.value)].height = Std.int(runner:getWman().term:getSize().y);
    local _g = 0;
    local _g1 = runner:getWman().screens[Std.parseInt(self.value)]:getPRenderCommands(screenwidth, screenheight, false);
    while (_g < _g1.length) do _hx_do_first_1 = false;
      
      local command = _g1[_g];
      _g = _g + 1;
      s2:addPRC(command);
    end;
    self.transition:runForScreens(function(prevx,prevy,newx,newy,firstOnTop,progress) 
      local b = Buffer.new(Std.int(screenwidth), Std.int(screenheight));
      if (firstOnTop) then 
        b:blitBuffer(s2, newx, newy);
        b:blitBuffer(s1, prevx, prevy);
      else
        b:blitBuffer(s1, prevx, prevy);
        b:blitBuffer(s2, newx, newy);
      end;
      b:draw(runner:getWman().term);
    end, Std.int(screenwidth), Std.int(screenheight));
    runner:getWman().currentScreen = Std.parseInt(self.value);
    runner:requestRerender();
    runner:requestRerender(); end;
end

Command.prototype.__class__ =  Command

Widget.new = function() 
  local self = _hx_new(Widget.prototype)
  Widget.super(self)
  return self
end
Widget.super = function(self) 
  self.requestsRerender = false;
  self.lsh = 0.0;
  self.lsw = 0.0;
  self.id = Std.string(_G.math.random() * 1000000000);
  self.wman = nil;
  self.style = Style.new();
  self.parent = nil;
  self.visible = true;
  self.children = _hx_tab_array({}, 0);
  self.oh = 1;
  self.ow = 10;
  self.height = 1;
  self.width = 10;
  self.hexpand = 0;
  self.vexpand = 0;
  self.ya = 0;
  self.xa = 0;
  self.y = 0;
  self.x = 0;
end
_hx_exports["Widget"] = Widget
Widget.__name__ = true
Widget.deserialize = function(data) 
  local this1 = Values.typenames;
  local key = Reflect.field(data, "typeName");
  if (this1.h[key] ~= nil) then 
    local this1 = Values.typenames;
    local key = Reflect.field(data, "typeName");
    local ret = this1.h[key];
    local ObjectType = (function() 
      local _hx_1
      if (ret == __haxe_ds_StringMap.tnull) then 
      _hx_1 = nil; else 
      _hx_1 = ret; end
      return _hx_1
    end )();
    local obj = ObjectType();
    obj:deserializeAdditional(data);
    local _g = __haxe_ds_StringMap.new();
    local value = Float;
    if (value == nil) then 
      _g.h.x = __haxe_ds_StringMap.tnull;
    else
      _g.h.x = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.y = __haxe_ds_StringMap.tnull;
    else
      _g.h.y = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.xa = __haxe_ds_StringMap.tnull;
    else
      _g.h.xa = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.ya = __haxe_ds_StringMap.tnull;
    else
      _g.h.ya = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.vexpand = __haxe_ds_StringMap.tnull;
    else
      _g.h.vexpand = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.hexpand = __haxe_ds_StringMap.tnull;
    else
      _g.h.hexpand = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.width = __haxe_ds_StringMap.tnull;
    else
      _g.h.width = value;
    end;
    local value = Float;
    if (value == nil) then 
      _g.h.height = __haxe_ds_StringMap.tnull;
    else
      _g.h.height = value;
    end;
    local value = String;
    if (value == nil) then 
      _g.h.id = __haxe_ds_StringMap.tnull;
    else
      _g.h.id = value;
    end;
    local value = Dynamic;
    if (value == nil) then 
      _g.h.style = __haxe_ds_StringMap.tnull;
    else
      _g.h.style = value;
    end;
    local value = Dynamic;
    if (value == nil) then 
      _g.h.children = __haxe_ds_StringMap.tnull;
    else
      _g.h.children = value;
    end;
    local deserializeValues = _g;
    local map = deserializeValues;
    local _g_map = map;
    local _g_keys = map:keys();
    while (_g_keys:hasNext()) do _hx_do_first_1 = false;
      
      local key = _g_keys:next();
      local _g_value = _g_map:get(key);
      local _g_key = key;
      local name = _g_key;
      local type = _g_value;
      if (__lua_Boot.__instanceof(Reflect.field(data, name), type)) then 
        if (name == "children") then 
          obj.children = _hx_tab_array({}, 0);
          local _g = 0;
          local _g1 = __lua_Boot.__cast(Reflect.field(data, "children") , Array);
          while (_g < _g1.length) do _hx_do_first_2 = false;
            
            local i = _g1[_g];
            _g = _g + 1;
            local w = Widget.deserialize(i);
            obj:addChild(w);
          end;
        else
          if (name == "style") then 
            local f = Reflect.field(data, name);
            local nstyle = Style.new();
            nstyle.fgColor = Colors.fromBlit(Reflect.field(f, "fgColor"));
            nstyle.bgColor = Colors.fromBlit(Reflect.field(f, "bgColor"));
            obj.style = nstyle;
          else
            obj[name] = Reflect.field(data, name);
          end;
        end;
      end;
    end;
    do return obj end;
  else
    do return data end;
  end;
end
Widget.fromJSON = function(json) 
  do return Widget.deserialize(__haxe_Json.parse(json)) end;
end
Widget.prototype = _hx_e();
Widget.prototype.x= nil;
Widget.prototype.y= nil;
Widget.prototype.xa= nil;
Widget.prototype.ya= nil;
Widget.prototype.vexpand= nil;
Widget.prototype.hexpand= nil;
Widget.prototype.width= nil;
Widget.prototype.height= nil;
Widget.prototype.ow= nil;
Widget.prototype.oh= nil;
Widget.prototype.children= nil;
Widget.prototype.visible= nil;
Widget.prototype.parent= nil;
Widget.prototype.style= nil;
Widget.prototype.wman= nil;
Widget.prototype.id= nil;
Widget.prototype.lsw= nil;
Widget.prototype.lsh= nil;
Widget.prototype.requestsRerender= nil;
Widget.prototype.requestRerender = function(self) 
  self.requestsRerender = true;
end
Widget.prototype.getWman = function(self) 
  if (self.wman ~= nil) then 
    do return self.wman end;
  else
    if (self.parent ~= nil) then 
      do return self.parent:getWman() end;
    else
      do return ScreenManager.new(nil) end;
    end;
  end;
end
Widget.prototype.fixedWidth = function(self,screenwidth,screenheight,ignoreParent) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  do return _G.math.floor((self.width + (self.hexpand * (function() 
    local _hx_1
    if (ignoreParent) then 
    _hx_1 = screenwidth; else 
    _hx_1 = self.parent:fixedWidth(screenwidth, screenheight); end
    return _hx_1
  end )())) + 0.5) end
end
Widget.prototype.fixedHeight = function(self,screenwidth,screenheight,ignoreParent) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  do return _G.math.floor((self.height + (self.vexpand * (function() 
    local _hx_1
    if (ignoreParent) then 
    _hx_1 = screenheight; else 
    _hx_1 = self.parent.height; end
    return _hx_1
  end )())) + 0.5) end
end
Widget.prototype.getPRenderCommands = function(self,screenwidth,screenheight,respectPosition) 
  if (respectPosition == nil) then 
    respectPosition = true;
  end;
  self.lsw = screenwidth;
  self.lsh = screenheight;
  if (not self.visible) then 
    do return _hx_tab_array({}, 0) end;
  end;
  local oldw = (self.width + 1) - 1;
  local oldh = (self.height + 1) - 1;
  self.ow = oldw;
  self.oh = oldh;
  local fwidth = self:fixedWidth(screenwidth, screenheight);
  local fheight = self:fixedHeight(screenwidth, screenheight);
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local c = _g1[_g];
    _g = _g + 1;
    c.parent = self;
  end;
  local rc = _hx_tab_array({}, 0);
  local _g = 0;
  local _g1 = fwidth;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    local _g = 0;
    local _g1 = fheight;
    while (_g < _g1) do _hx_do_first_2 = false;
      
      _g = _g + 1;
      local ix = _g - 1;
      rc:push(PositionedRenderCommand.new(i, ix, " ", self.id, self.style.fgColor, self.style.bgColor));
    end;
  end;
  local _g = 0;
  local _g1 = self:renderImpl(screenwidth, screenheight, fwidth, fheight);
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local i = _g1[_g];
    _g = _g + 1;
    rc:push(i);
  end;
  local nrc = _hx_tab_array({}, 0);
  local _g = 0;
  local _hx_continue_1 = false;
  while (_g < rc.length) do _hx_do_first_1 = false;
    repeat 
    local command = rc[_g];
    _g = _g + 1;
    if ((((command.x >= fwidth) or (command.y >= fheight)) or (command.x < 0)) or (command.y < 0)) then 
      break;
    end;
    if (respectPosition) then 
      command.x = _G.math.floor(self:fixedXC(command.x, screenwidth, screenheight, true, true));
      command.y = _G.math.floor(self:fixedYC(command.y, screenwidth, screenheight, true, true));
    end;
    nrc:push(command);until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  self.width = oldw;
  self.height = oldh;
  do return nrc end
end
Widget.prototype.fixedX = function(self,screenwidth,screenheight,ignoreParent) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  local x = self:fixedXC(0, screenwidth, screenheight, ignoreParent, true);
  do return x end
end
Widget.prototype.fixedY = function(self,screenwidth,screenheight,ignoreParent) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  local x = self:fixedYC(0, screenwidth, screenheight, ignoreParent, true);
  do return x end
end
Widget.prototype.fixedXC = function(self,xc,screenwidth,screenheight,ignoreParent,includeThis) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  if (not ignoreParent) then 
    screenwidth = self.parent:fixedWidth(screenwidth, screenheight);
    screenheight = self.parent:fixedHeight(screenwidth, screenheight);
  end;
  do return _G.math.floor((((xc + (function() 
    local _hx_1
    if (includeThis) then 
    _hx_1 = self.x; else 
    _hx_1 = 0; end
    return _hx_1
  end )()) + (self.xa * screenwidth)) + (function() 
    local _hx_2
    if (ignoreParent) then 
    _hx_2 = 0; else 
    _hx_2 = self.parent:fixedX(screenwidth, screenheight); end
    return _hx_2
  end )()) - (self.xa * self:fixedWidth(screenwidth, screenheight))) end
end
Widget.prototype.fixedYC = function(self,yc,screenwidth,screenheight,ignoreParent,includeThis) 
  if (ignoreParent == nil) then 
    ignoreParent = false;
  end;
  if (self.parent == nil) then 
    ignoreParent = true;
  end;
  if (not ignoreParent) then 
    screenwidth = self.parent:fixedWidth(screenwidth, screenheight);
    screenheight = self.parent:fixedHeight(screenwidth, screenheight);
  end;
  do return _G.math.floor((((yc + (function() 
    local _hx_1
    if (includeThis) then 
    _hx_1 = self.y; else 
    _hx_1 = 0; end
    return _hx_1
  end )()) + (self.ya * screenheight)) + (function() 
    local _hx_2
    if (ignoreParent) then 
    _hx_2 = 0; else 
    _hx_2 = self.parent:fixedY(screenwidth, screenheight); end
    return _hx_2
  end )()) - (self.ya * self:fixedHeight(screenwidth, screenheight))) end
end
Widget.prototype.addChild = function(self,child) 
  child.parent = self;
  self.children:push(child);
end
Widget.prototype.remChild = function(self,child) 
  child.parent = nil;
  self.children:remove(child);
end
Widget.prototype.getChildByID = function(self,id) 
  local _g = 0;
  local _g1 = self:recFilterChildren(function(w) 
    do return w.id == id end;
  end);
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    do return widget end;
  end;
  _G.error(__haxe_Exception.new(Std.string("Cannot find child with id ") .. Std.string(id)),0);
end
Widget.prototype.recFilterChildren = function(self,filter) 
  local ch = _hx_tab_array({}, 0);
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    if (filter(widget)) then 
      ch:push(widget);
    end;
    ch = ch:concat(widget:recFilterChildren(filter));
  end;
  ch:reverse();
  do return ch end
end
Widget.prototype.recFilterChildrenUF = function(self,filter) 
  local ch = _hx_tab_array({}, 0);
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    local cha = widget:recFilterChildrenUF(filter);
    local r = widget;
    r.children = cha;
    if (filter(widget)) then 
      ch:push(widget);
    end;
  end;
  ch:reverse();
  do return ch end
end
Widget.prototype.getTypename= nil;
Widget.prototype.getSize = function(self) 
  if (not self.visible) then 
    do return Vector2f.new(0, 0) end;
  end;
  do return Vector2f.new(self.width, self.height) end
end
Widget.prototype.renderImpl= nil;
Widget.prototype.onClick = function(self,pos,mb,wself) 
end
Widget.prototype.onDrag = function(self,startpos,pos,mb,wself) 
end
Widget.prototype.onClickUp = function(self,startpos,pos,mb,wself) 
end
Widget.prototype.onScroll = function(self,pos,dir,wself) 
end
Widget.prototype.onCustom = function(self,c) 
end
Widget.prototype.onRender = function(self) 
end
Widget.prototype.deserializeAdditional= nil;
Widget.prototype.additionalEditorFields= nil;
Widget.prototype.getEditorFields = function(self) 
  local a = self:additionalEditorFields();
  local _g = __haxe_ds_StringMap.new();
  _g.h.style = "Style";
  _g.h.id = "ID";
  _g.h.x = "X";
  _g.h.y = "Y";
  _g.h.width = "Width";
  _g.h.height = "Height";
  _g.h.xa = "X align";
  _g.h.ya = "Y align";
  _g.h.hexpand = "Expand on X axis";
  _g.h.vexpand = "Expand on Y axis";
  local map = _g;
  local _g_map = map;
  local _g_keys = map:keys();
  while (_g_keys:hasNext()) do _hx_do_first_1 = false;
    
    local key = _g_keys:next();
    local _g_value = _g_map:get(key);
    local _g_key = key;
    local s = _g_key;
    local v = _g_value;
    if (v == nil) then 
      a.h[s] = __haxe_ds_StringMap.tnull;
    else
      a.h[s] = v;
    end;
  end;
  do return a end
end
Widget.prototype.serializeAdditional= nil;
Widget.prototype.serialize = function(self) 
  local data = __haxe_ds_StringMap.new();
  local map = self:serializeAdditional();
  local _g_map = map;
  local _g_keys = map:keys();
  while (_g_keys:hasNext()) do _hx_do_first_1 = false;
    
    local key = _g_keys:next();
    local _g_value = _g_map:get(key);
    local _g_key = key;
    local k = _g_key;
    local v = _g_value;
    local v = v;
    local value = v;
    if (value == nil) then 
      data.h[k] = __haxe_ds_StringMap.tnull;
    else
      data.h[k] = value;
    end;
  end;
  local _g = __haxe_ds_StringMap.new();
  local value = Float;
  if (value == nil) then 
    _g.h.x = __haxe_ds_StringMap.tnull;
  else
    _g.h.x = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.y = __haxe_ds_StringMap.tnull;
  else
    _g.h.y = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.xa = __haxe_ds_StringMap.tnull;
  else
    _g.h.xa = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.ya = __haxe_ds_StringMap.tnull;
  else
    _g.h.ya = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.vexpand = __haxe_ds_StringMap.tnull;
  else
    _g.h.vexpand = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.hexpand = __haxe_ds_StringMap.tnull;
  else
    _g.h.hexpand = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.width = __haxe_ds_StringMap.tnull;
  else
    _g.h.width = value;
  end;
  local value = Float;
  if (value == nil) then 
    _g.h.height = __haxe_ds_StringMap.tnull;
  else
    _g.h.height = value;
  end;
  local value = String;
  if (value == nil) then 
    _g.h.id = __haxe_ds_StringMap.tnull;
  else
    _g.h.id = value;
  end;
  local value = Array;
  if (value == nil) then 
    _g.h.children = __haxe_ds_StringMap.tnull;
  else
    _g.h.children = value;
  end;
  local value = Style;
  if (value == nil) then 
    _g.h.style = __haxe_ds_StringMap.tnull;
  else
    _g.h.style = value;
  end;
  local serializeValues = _g;
  local map = serializeValues;
  local _g_map = map;
  local _g_keys = map:keys();
  while (_g_keys:hasNext()) do _hx_do_first_1 = false;
    
    local key = _g_keys:next();
    local _g_value = _g_map:get(key);
    local _g_key = key;
    local name = _g_key;
    local type = _g_value;
    local rp = name;
    if (rp == "width") then 
      rp = "ow";
    end;
    if (rp == "height") then 
      rp = "oh";
    end;
    local v = Reflect.getProperty(self, rp);
    local value = v;
    if (value == nil) then 
      data.h[name] = __haxe_ds_StringMap.tnull;
    else
      data.h[name] = value;
    end;
    local ret = data.h[name];
    if (__lua_Boot.__instanceof((function() 
      local _hx_1
      if (ret == __haxe_ds_StringMap.tnull) then 
      _hx_1 = nil; else 
      _hx_1 = ret; end
      return _hx_1
    end )(), Style)) then 
      local _g = __haxe_ds_StringMap.new();
      local value = self.style.fgColor.blit;
      if (value == nil) then 
        _g.h.fgColor = __haxe_ds_StringMap.tnull;
      else
        _g.h.fgColor = value;
      end;
      local value = self.style.bgColor.blit;
      if (value == nil) then 
        _g.h.bgColor = __haxe_ds_StringMap.tnull;
      else
        _g.h.bgColor = value;
      end;
      local newData = _g;
      local value = newData;
      if (value == nil) then 
        data.h[name] = __haxe_ds_StringMap.tnull;
      else
        data.h[name] = value;
      end;
    end;
    if (name == "children") then 
      local ncmd = _hx_tab_array({}, 0);
      local _g = 0;
      local _g1 = self.children;
      while (_g < _g1.length) do _hx_do_first_2 = false;
        
        local widget = _g1[_g];
        _g = _g + 1;
        ncmd:push(widget:serialize());
      end;
      local value = ncmd;
      if (value == nil) then 
        data.h[name] = __haxe_ds_StringMap.tnull;
      else
        data.h[name] = value;
      end;
    end;
  end;
  local v = self:getTypename();
  local value = v;
  if (value == nil) then 
    data.h.typeName = __haxe_ds_StringMap.tnull;
  else
    data.h.typeName = value;
  end;
  do return data end
end
Widget.prototype.toJSON = function(self) 
  do return __haxe_Json.stringify(self:serialize()) end
end

Widget.prototype.__class__ =  Widget

SimpleContainer.new = function(widgets) 
  local self = _hx_new(SimpleContainer.prototype)
  SimpleContainer.super(self,widgets)
  return self
end
SimpleContainer.super = function(self,widgets) 
  self.offset = Vector2f.new(0, 0);
  Widget.super(self);
  if (_hx_bind(widgets,widgets.push) == nil) then 
    local length = nil;
    local tab = __lua_PairTools.copy(widgets);
    local length = length;
    if (length == nil) then 
      length = _hx_table.maxn(tab);
      if (length > 0) then 
        local head = tab[1];
        _G.table.remove(tab, 1);
        tab[0] = head;
        widgets = _hx_tab_array(tab, length);
      else
        widgets = _hx_tab_array({}, 0);
      end;
    else
      widgets = _hx_tab_array(tab, length);
    end;
  end;
  self.children = widgets;
end
_hx_exports["SimpleContainer"] = SimpleContainer
SimpleContainer.__name__ = true
SimpleContainer.prototype = _hx_e();
SimpleContainer.prototype.offset= nil;
SimpleContainer.prototype.getMostWidgetHeight = function(self) 
  local w = 0.0;
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    w = Math.max(w, widget:fixedY(self.width, self.height, true) + widget:fixedHeight(self.width, self.height, true));
  end;
  do return w end
end
SimpleContainer.prototype.renderImpl = function(self,screenwidth,screenheight,width,height) 
  local _gthis = self;
  local rc = _hx_tab_array({}, 0);
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    local _g = _hx_tab_array({}, 0);
    local _g1 = 0;
    local _g2 = widget:getPRenderCommands(width, height);
    while (_g1 < _g2.length) do _hx_do_first_2 = false;
      
      local i = _g2[_g1];
      _g1 = _g1 + 1;
      local i1 = i;
      i1.x = i1.x + _gthis.offset.x;
      local i1 = i;
      i1.y = i1.y + _gthis.offset.y;
      _g:push(i);
    end;
    rc = rc:concat(_g);
  end;
  do return rc end
end
SimpleContainer.prototype.onClick = function(self,pos,mb,wself) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local e = _g1[_g];
    _g = _g + 1;
    local xp = Vector2f.add(pos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local termSize = Vector2f.new(self.lsw, self.lsh);
    local wwself = (((xp.x >= 0) and (xp.y >= 0)) and (xp.x < e:fixedWidth(self.lsw, self.lsh, true))) and (xp.y < e:fixedHeight(self.lsw, self.lsh, true));
    local wwself1 = wwself;
    e:onClick(xp, mb, wwself);
    if (e.requestsRerender) then 
      self:requestRerender();
    end;
  end;
end
SimpleContainer.prototype.onDrag = function(self,startpos,pos,mb,wself) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local e = _g1[_g];
    _g = _g + 1;
    local sxp = Vector2f.add(startpos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local xp = Vector2f.add(pos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local termSize = Vector2f.new(self.lsw, self.lsh);
    local wwself = (((xp.x >= 0) and (xp.y >= 0)) and (xp.x < e.width)) and (xp.y < e.height);
    e:onDrag(sxp, xp, mb, wwself);
    if (e.requestsRerender) then 
      self:requestRerender();
    end;
  end;
end
SimpleContainer.prototype.onClickUp = function(self,startpos,pos,mb,wself) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local e = _g1[_g];
    _g = _g + 1;
    local sxp = Vector2f.add(startpos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local xp = Vector2f.add(pos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local termSize = Vector2f.new(self.lsw, self.lsh);
    local wwself = (((xp.x >= 0) and (xp.y >= 0)) and (xp.x < e.width)) and (xp.y < e.height);
    e:onClickUp(sxp, xp, mb, wwself);
    if (e.requestsRerender) then 
      self:requestRerender();
    end;
  end;
end
SimpleContainer.prototype.onScroll = function(self,pos,dir,wself) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local e = _g1[_g];
    _g = _g + 1;
    local xp = Vector2f.add(pos, self.offset):addInts(-e:fixedX(self.lsw, self.lsh, true), -e:fixedY(self.lsw, self.lsh, true)):addInts(-1, -1);
    local termSize = Vector2f.new(self.lsw, self.lsh);
    local wwself = (((xp.x >= 0) and (xp.y >= 0)) and (xp.x < e.width)) and (xp.y < e.height);
    e:onScroll(xp, dir, wwself);
    if (e.requestsRerender) then 
      self:requestRerender();
    end;
  end;
end
SimpleContainer.prototype.onCustom = function(self,c) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    widget:onCustom(c);
    if (widget.requestsRerender) then 
      self:requestRerender();
    end;
  end;
end
SimpleContainer.prototype.onRender = function(self) 
  local _g = 0;
  local _g1 = self.children;
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local widget = _g1[_g];
    _g = _g + 1;
    widget:onRender();
    widget.requestsRerender = false;
  end;
end
SimpleContainer.prototype.deserializeAdditional = function(self,data) 
  do return self end
end
SimpleContainer.prototype.serializeAdditional = function(self) 
  do return __haxe_ds_StringMap.new() end
end
SimpleContainer.prototype.additionalEditorFields = function(self) 
  do return __haxe_ds_StringMap.new() end
end
SimpleContainer.prototype.getTypename = function(self) 
  do return "Container" end
end

SimpleContainer.prototype.__class__ =  SimpleContainer
SimpleContainer.__super__ = Widget
setmetatable(SimpleContainer.prototype,{__index=Widget.prototype})

Button.new = function(widgets,command) 
  local self = _hx_new(Button.prototype)
  Button.super(self,widgets,command)
  return self
end
Button.super = function(self,widgets,command) 
  self.command = nil;
  SimpleContainer.super(self,widgets);
  self.command = command;
end
_hx_exports["Button"] = Button
Button.__name__ = true
Button.prototype = _hx_e();
Button.prototype.command= nil;
Button.prototype.getTypename = function(self) 
  do return "Button" end
end
Button.prototype.deserializeAdditional = function(self,data) 
  self.command = Command.deserialize(data.cmd);
  do return self end
end
Button.prototype.serializeAdditional = function(self) 
  local _g = __haxe_ds_StringMap.new();
  local value = self.command:serialize();
  if (value == nil) then 
    _g.h.cmd = __haxe_ds_StringMap.tnull;
  else
    _g.h.cmd = value;
  end;
  do return _g end
end
Button.prototype.additionalEditorFields = function(self) 
  local _g = __haxe_ds_StringMap.new();
  _g.h.command = "On Click";
  do return _g end
end
Button.prototype.onClick = function(self,pos,mb,wself) 
  Runner.log(Std.string(Std.string(Std.string(Std.string(Std.string("Position: ") .. Std.string(pos.x)) .. Std.string(", ")) .. Std.string(pos.y)) .. Std.string(" Self: ")) .. Std.string(Std.string(wself)), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/Button.hx",lineNumber=247,className="Button",methodName="onClick"}));
  if (wself) then 
    self.command:execute(self, self.lsw, self.lsh);
  end;
end

Button.prototype.__class__ =  Button
Button.__super__ = SimpleContainer
setmetatable(Button.prototype,{__index=SimpleContainer.prototype})

Color.new = function(blitText,palNumber,bitASC) 
  local self = _hx_new(Color.prototype)
  Color.super(self,blitText,palNumber,bitASC)
  return self
end
Color.super = function(self,blitText,palNumber,bitASC) 
  self.blit = "f";
  self.palNumber = palNumber;
  self.bitASC = bitASC;
  self.blit = blitText;
end
_hx_exports["Color"] = Color
Color.__name__ = true
Color.prototype = _hx_e();
Color.prototype.palNumber= nil;
Color.prototype.bitASC= nil;
Color.prototype.blit= nil;

Color.prototype.__class__ =  Color

RGBColor.new = function(r,g,b) 
  local self = _hx_new(RGBColor.prototype)
  RGBColor.super(self,r,g,b)
  return self
end
RGBColor.super = function(self,r,g,b) 
  self.red = r;
  self.green = g;
  self.blue = b;
end
_hx_exports["RGBColor"] = RGBColor
RGBColor.__name__ = true
RGBColor.prototype = _hx_e();
RGBColor.prototype.red= nil;
RGBColor.prototype.green= nil;
RGBColor.prototype.blue= nil;

RGBColor.prototype.__class__ =  RGBColor

Colors.new = {}
_hx_exports["Colors"] = Colors
Colors.__name__ = true
Colors.fromBlit = function(b) 
  local b = b;
  if (b) == "0" then 
    do return Colors.white end;
  elseif (b) == "1" then 
    do return Colors.orange end;
  elseif (b) == "2" then 
    do return Colors.magenta end;
  elseif (b) == "3" then 
    do return Colors.lightBlue end;
  elseif (b) == "4" then 
    do return Colors.yellow end;
  elseif (b) == "5" then 
    do return Colors.lime end;
  elseif (b) == "6" then 
    do return Colors.pink end;
  elseif (b) == "7" then 
    do return Colors.gray end;
  elseif (b) == "8" then 
    do return Colors.lightGray end;
  elseif (b) == "9" then 
    do return Colors.cyan end;
  elseif (b) == "a" then 
    do return Colors.purple end;
  elseif (b) == "b" then 
    do return Colors.blue end;
  elseif (b) == "c" then 
    do return Colors.brown end;
  elseif (b) == "d" then 
    do return Colors.green end;
  elseif (b) == "e" then 
    do return Colors.red end;
  elseif (b) == "f" then 
    do return Colors.black end;else
  do return Colors.white end; end;
end
_hxClasses["MouseButton"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="NONE","LEFT","MIDDLE","RIGHT"},4)}
MouseButton = _hxClasses["MouseButton"];
MouseButton.NONE = _hx_tab_array({[0]="NONE",0,__enum__ = MouseButton},2)

MouseButton.LEFT = _hx_tab_array({[0]="LEFT",1,__enum__ = MouseButton},2)

MouseButton.MIDDLE = _hx_tab_array({[0]="MIDDLE",2,__enum__ = MouseButton},2)

MouseButton.RIGHT = _hx_tab_array({[0]="RIGHT",3,__enum__ = MouseButton},2)


Label.new = function(x,y,text) 
  local self = _hx_new(Label.prototype)
  Label.super(self,x,y,text)
  return self
end
Label.super = function(self,x,y,text) 
  self.text = "<empty>";
  Widget.super(self);
  self.x = x;
  self.y = y;
  self.text = text;
  local s = ___Label_Label_Fields_.getTheoreticalWH(text);
  self.width = s[0];
  self.height = s[1];
end
_hx_exports["Label"] = Label
Label.__name__ = true
Label.prototype = _hx_e();
Label.prototype.text= nil;
Label.prototype.renderImpl = function(self,screenwidth,screenheight,width,height) 
  local o = _hx_tab_array({}, 0);
  local cposx = 0;
  local cposy = 0;
  local _g = 0;
  local _g1 = #self.text;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    local char = _G.string.sub(self.text, i + 1, i + 1);
    if (char == "\n") then 
      cposx = 0;
      cposy = cposy + 1;
    else
      o:push(PositionedRenderCommand.new(cposx, cposy, char, self.id, self.style.fgColor, self.style.bgColor));
      cposx = cposx + 1;
    end;
  end;
  do return o end
end
Label.prototype.deserializeAdditional = function(self,data) 
  if (__lua_Boot.__instanceof(data.labelText, String)) then 
    self.text = data.labelText;
  end;
  do return self end
end
Label.prototype.serializeAdditional = function(self) 
  local _g = __haxe_ds_StringMap.new();
  local value = self.text;
  if (value == nil) then 
    _g.h.labelText = __haxe_ds_StringMap.tnull;
  else
    _g.h.labelText = value;
  end;
  do return _g end
end
Label.prototype.additionalEditorFields = function(self) 
  local _g = __haxe_ds_StringMap.new();
  _g.h.text = "Label";
  do return _g end
end
Label.prototype.getTypename = function(self) 
  do return "Label" end
end

Label.prototype.__class__ =  Label
Label.__super__ = Widget
setmetatable(Label.prototype,{__index=Widget.prototype})

___Label_Label_Fields_.new = {}
___Label_Label_Fields_.__name__ = true
___Label_Label_Fields_.getTheoreticalWH = function(str) 
  local cposx = 0;
  local cposy = 0;
  local maxw = 0;
  local maxh = 1;
  local _g = 0;
  local _g1 = #str;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    local char = _G.string.sub(str, i + 1, i + 1);
    if (char == "\n") then 
      cposx = 0;
      cposy = cposy + 1;
      maxh = maxh + 1;
    else
      cposx = cposx + 1;
      maxw = Std.int(Math.max(cposx, maxw));
    end;
  end;
  do return _hx_tab_array({[0]=maxw, maxh}, 2) end;
end

String.new = function(string) 
  local self = _hx_new(String.prototype)
  String.super(self,string)
  self = string
  return self
end
String.super = function(self,string) 
end
String.__name__ = true
String.__index = function(s,k) 
  if (k == "length") then 
    do return _G.string.len(s) end;
  else
    local o = String.prototype;
    local field = k;
    if ((function() 
      local _hx_1
      if ((_G.type(o) == "function") and not ((function() 
        local _hx_2
        if (_G.type(o) ~= "table") then 
        _hx_2 = false; else 
        _hx_2 = o.__name__; end
        return _hx_2
      end )() or (function() 
        local _hx_3
        if (_G.type(o) ~= "table") then 
        _hx_3 = false; else 
        _hx_3 = o.__ename__; end
        return _hx_3
      end )())) then 
      _hx_1 = false; elseif ((_G.type(o) == "string") and ((String.prototype[field] ~= nil) or (field == "length"))) then 
      _hx_1 = true; elseif (o.__fields__ ~= nil) then 
      _hx_1 = o.__fields__[field] ~= nil; else 
      _hx_1 = o[field] ~= nil; end
      return _hx_1
    end )()) then 
      do return String.prototype[k] end;
    else
      if (String.__oldindex ~= nil) then 
        if (_G.type(String.__oldindex) == "function") then 
          do return String.__oldindex(s, k) end;
        else
          if (_G.type(String.__oldindex) == "table") then 
            do return String.__oldindex[k] end;
          end;
        end;
        do return nil end;
      else
        do return nil end;
      end;
    end;
  end;
end
String.indexOfEmpty = function(s,startIndex) 
  local length = _G.string.len(s);
  if (startIndex < 0) then 
    startIndex = length + startIndex;
    if (startIndex < 0) then 
      startIndex = 0;
    end;
  end;
  if (startIndex > length) then 
    do return length end;
  else
    do return startIndex end;
  end;
end
String.fromCharCode = function(code) 
  do return _G.string.char(code) end;
end
String.prototype = _hx_e();
String.prototype.length= nil;
String.prototype.toUpperCase = function(self) 
  do return _G.string.upper(self) end
end
String.prototype.toLowerCase = function(self) 
  do return _G.string.lower(self) end
end
String.prototype.indexOf = function(self,str,startIndex) 
  if (startIndex == nil) then 
    startIndex = 1;
  else
    startIndex = startIndex + 1;
  end;
  if (str == "") then 
    do return String.indexOfEmpty(self, startIndex - 1) end;
  end;
  local r = _G.string.find(self, str, startIndex, true);
  if ((r ~= nil) and (r > 0)) then 
    do return r - 1 end;
  else
    do return -1 end;
  end;
end
String.prototype.lastIndexOf = function(self,str,startIndex) 
  local ret = -1;
  if (startIndex == nil) then 
    startIndex = #self;
  end;
  while (true) do _hx_do_first_1 = false;
    
    local p = String.prototype.indexOf(self, str, ret + 1);
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  do return ret end
end
String.prototype.split = function(self,delimiter) 
  local idx = 1;
  local ret = _hx_tab_array({}, 0);
  while (idx ~= nil) do _hx_do_first_1 = false;
    
    local newidx = 0;
    if (#delimiter > 0) then 
      newidx = _G.string.find(self, delimiter, idx, true);
    else
      if (idx >= #self) then 
        newidx = nil;
      else
        newidx = idx + 1;
      end;
    end;
    if (newidx ~= nil) then 
      local match = _G.string.sub(self, idx, newidx - 1);
      ret:push(match);
      idx = newidx + #delimiter;
    else
      ret:push(_G.string.sub(self, idx, #self));
      idx = nil;
    end;
  end;
  do return ret end
end
String.prototype.toString = function(self) 
  do return self end
end
String.prototype.substring = function(self,startIndex,endIndex) 
  if (endIndex == nil) then 
    endIndex = #self;
  end;
  if (endIndex < 0) then 
    endIndex = 0;
  end;
  if (startIndex < 0) then 
    startIndex = 0;
  end;
  if (endIndex < startIndex) then 
    do return _G.string.sub(self, endIndex + 1, startIndex) end;
  else
    do return _G.string.sub(self, startIndex + 1, endIndex) end;
  end;
end
String.prototype.charAt = function(self,index) 
  do return _G.string.sub(self, index + 1, index + 1) end
end
String.prototype.charCodeAt = function(self,index) 
  do return _G.string.byte(self, index + 1) end
end
String.prototype.substr = function(self,pos,len) 
  if ((len == nil) or (len > (pos + #self))) then 
    len = #self;
  else
    if (len < 0) then 
      len = #self + len;
    end;
  end;
  if (pos < 0) then 
    pos = #self + pos;
  end;
  if (pos < 0) then 
    pos = 0;
  end;
  do return _G.string.sub(self, pos + 1, pos + len) end
end

String.prototype.__class__ =  String

Std.new = {}
Std.__name__ = true
Std.string = function(s) 
  do return _hx_tostring(s, 0) end;
end
Std.int = function(x) 
  if (not Math.isFinite(x) or Math.isNaN(x)) then 
    do return 0 end;
  else
    do return _hx_bit_clamp(x) end;
  end;
end
Std.parseInt = function(x) 
  if (x == nil) then 
    do return nil end;
  end;
  local sign, numString = _G.string.match(x, "^%s*([%-+]?)0[xX]([%da-fA-F]*)");
  if (numString ~= nil) then 
    if (sign == "-") then 
      do return -_G.tonumber(numString, 16) end;
    else
      do return _G.tonumber(numString, 16) end;
    end;
  end;
  local intMatch = _G.string.match(x, "^%s*[%-+]?%d*");
  if (intMatch == nil) then 
    do return nil end;
  end;
  do return _G.tonumber(intMatch) end;
end
Std.parseFloat = function(x) 
  if ((x == nil) or (x == "")) then 
    do return (0/0) end;
  end;
  local digitMatch = _G.string.match(x, "^%s*[%.%-+]?[0-9]%d*");
  if (digitMatch == nil) then 
    do return (0/0) end;
  end;
  x = String.prototype.substr(x, #digitMatch);
  local decimalMatch = _G.string.match(x, "^%.%d*");
  if (decimalMatch == nil) then 
    decimalMatch = "";
  end;
  x = String.prototype.substr(x, #decimalMatch);
  local eMatch = _G.string.match(x, "^[eE][+%-]?%d+");
  if (eMatch == nil) then 
    eMatch = "";
  end;
  local result = _G.tonumber(Std.string(Std.string(digitMatch) .. Std.string(decimalMatch)) .. Std.string(eMatch));
  if (result ~= nil) then 
    do return result end;
  else
    do return (0/0) end;
  end;
end

Math.new = {}
Math.__name__ = true
Math.isNaN = function(f) 
  do return f ~= f end;
end
Math.isFinite = function(f) 
  if (f > -_G.math.huge) then 
    do return f < _G.math.huge end;
  else
    do return false end;
  end;
end
Math.max = function(a,b) 
  if (Math.isNaN(a) or Math.isNaN(b)) then 
    do return (0/0) end;
  else
    do return _G.math.max(a, b) end;
  end;
end
Math.min = function(a,b) 
  if (Math.isNaN(a) or Math.isNaN(b)) then 
    do return (0/0) end;
  else
    do return _G.math.min(a, b) end;
  end;
end

__lua_PairTools.new = {}
__lua_PairTools.__name__ = true
__lua_PairTools.copy = function(table1) 
  local ret = ({});
  for k,v in _G.pairs(table1) do ret[k] = v end;
  do return ret end;
end

TextArea.new = function(x,y,placeholder) 
  local self = _hx_new(TextArea.prototype)
  TextArea.super(self,x,y,placeholder)
  return self
end
TextArea.super = function(self,x,y,placeholder) 
  self.onTab = Command.new();
  self.onSubmit = Command.new();
  self.ctrlPressed = false;
  self.scroll = Vector2f.new(0, 0);
  self.cursorPos = Vector2f.new(0, 0);
  self.focused = false;
  self.isFocused = false;
  self.value = "";
  self.placeholder = "";
  Widget.super(self);
  self.x = x;
  self.y = y;
  self.placeholder = placeholder;
  self.style.bgColor = Colors.gray;
end
_hx_exports["TextArea"] = TextArea
TextArea.__name__ = true
TextArea.prototype = _hx_e();
TextArea.prototype.placeholder= nil;
TextArea.prototype.value= nil;
TextArea.prototype.isFocused= nil;
TextArea.prototype.focused= nil;
TextArea.prototype.cursorPos= nil;
TextArea.prototype.scroll= nil;
TextArea.prototype.ctrlPressed= nil;
TextArea.prototype.onSubmit= nil;
TextArea.prototype.onTab= nil;
TextArea.prototype.onClick = function(self,pos,mb,wself) 
  if (self.focused and wself) then 
    local pos1 = pos.y;
    local tmp = String.prototype.split(self.value, "\n").length - 1;
    self.cursorPos.y = Math.min(pos1, tmp);
    local pos = pos.x;
    local tmp = String.prototype.split(self.value, "\n");
    local tmp1 = Std.int(self.cursorPos.y);
    self.cursorPos.x = Math.min(pos, #tmp[tmp1]);
  end;
  self.focused = wself;
  self:requestRerender();
end
TextArea.prototype.onCustom = function(self,c) 
  if (not self.focused or ((c[0] ~= "key") and (c[0] ~= "char"))) then 
    do return end;
  end;
  local cursorPosAsInt = 0;
  local _g = 0;
  local _g1 = Std.int(self.cursorPos.y);
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    cursorPosAsInt = cursorPosAsInt + (#String.prototype.split(self.value, "\n")[i] + 1);
  end;
  cursorPosAsInt = cursorPosAsInt + Std.int(self.cursorPos.x);
  if (c[0] == "key_up") then 
    if (c[1] == keys.control) then 
      self.ctrlPressed = false;
    end;
  end;
  if (c[0] == "key") then 
    if (c[1] == keys.control) then 
      self.ctrlPressed = true;
    end;
    if ((self.ctrlPressed and (c[1] == keys.u)) and self.focused) then 
      self.value = "";
    end;
    if ((c[1] == keys.backspace) and not ((self.cursorPos.y < 1) and (self.cursorPos.x < 1))) then 
      self.value = Std.string(String.prototype.substring(self.value, 0, cursorPosAsInt - 1)) .. Std.string(String.prototype.substring(self.value, cursorPosAsInt));
      self.cursorPos.x = self.cursorPos.x - 1;
      if (self.cursorPos.x < 0) then 
        self.cursorPos.y = self.cursorPos.y - 1;
        local tmp = String.prototype.split(self.value, "\n");
        local tmp1 = Std.int(self.cursorPos.y);
        self.cursorPos.x = #tmp[tmp1];
      end;
    end;
    if (c[1] == keys.home) then 
      self.cursorPos.x = 0;
    end;
    if (c[1] == keys["end"]) then 
      local tmp = String.prototype.split(self.value, "\n");
      local tmp1 = Std.int(self.cursorPos.y);
      self.cursorPos.x = #tmp[tmp1];
    end;
    if (c[1] == keys.delete) then 
      self.value = Std.string(String.prototype.substring(self.value, 0, cursorPosAsInt)) .. Std.string(String.prototype.substring(self.value, cursorPosAsInt + 1));
    end;
    if (c[1] == keys.left) then 
      self.cursorPos.x = self.cursorPos.x - 1;
      if (self.cursorPos.x < 0) then 
        if (self.cursorPos.y > 0) then 
          self.cursorPos.y = self.cursorPos.y - 1;
          local tmp = String.prototype.split(self.value, "\n");
          local tmp1 = Std.int(self.cursorPos.y);
          self.cursorPos.x = #tmp[tmp1];
        else
          self.cursorPos.x = self.cursorPos.x + 1;
        end;
      end;
      local tmp = self.cursorPos.y;
      local tmp1 = String.prototype.split(self.value, "\n").length - 1;
      self.cursorPos.y = Math.min(tmp, tmp1);
      local tmp = self.cursorPos.x;
      local tmp1 = #String.prototype.split(self.value, "\n")[Std.int(self.cursorPos.y)] - 1;
      self.cursorPos.x = Math.min(tmp, tmp1);
    end;
    if (c[1] == keys.right) then 
      self.cursorPos.x = self.cursorPos.x + 1;
      if (self.cursorPos.x > #String.prototype.split(self.value, "\n")[Std.int(self.cursorPos.y)]) then 
        self.cursorPos.x = self.cursorPos.x - 1;
        if (String.prototype.split(self.value, "\n").length > (self.cursorPos.y + 1)) then 
          self.cursorPos.y = self.cursorPos.y + 1;
          self.cursorPos.x = 0;
        end;
      end;
      local tmp = self.cursorPos.y;
      local tmp1 = String.prototype.split(self.value, "\n").length - 1;
      self.cursorPos.y = Math.min(tmp, tmp1);
      local tmp = self.cursorPos.x;
      local tmp1 = String.prototype.split(self.value, "\n");
      local tmp2 = Std.int(self.cursorPos.y);
      self.cursorPos.x = Math.min(tmp, #tmp1[tmp2]);
    end;
    if (c[1] == keys.up) then 
      self.cursorPos.y = self.cursorPos.y - 1;
      local tmp = self.cursorPos.y;
      local tmp1 = String.prototype.split(self.value, "\n").length - 1;
      self.cursorPos.y = Math.min(tmp, tmp1);
      local tmp = self.cursorPos.x;
      local tmp1 = String.prototype.split(self.value, "\n");
      local tmp2 = Std.int(self.cursorPos.y);
      self.cursorPos.x = Math.min(tmp, #tmp1[tmp2]);
    end;
    if (c[1] == keys.down) then 
      self.cursorPos.y = self.cursorPos.y + 1;
      local tmp = self.cursorPos.y;
      local tmp1 = String.prototype.split(self.value, "\n").length - 1;
      self.cursorPos.y = Math.min(tmp, tmp1);
      local tmp = self.cursorPos.x;
      local tmp1 = String.prototype.split(self.value, "\n");
      local tmp2 = Std.int(self.cursorPos.y);
      self.cursorPos.x = Math.min(tmp, #tmp1[tmp2]);
    end;
    if ((c[1] == keys.enter) and (self.height > 1)) then 
      self.value = Std.string(Std.string(String.prototype.substring(self.value, 0, cursorPosAsInt)) .. Std.string("\n")) .. Std.string(String.prototype.substring(self.value, cursorPosAsInt));
      self.cursorPos.y = self.cursorPos.y + 1;
      self.cursorPos.x = 0;
    else
      if ((c[1] == keys.enter) and (self.height <= 1)) then 
        self.onSubmit:execute(self, self.lsw, self.lsh);
      end;
    end;
    self:requestRerender();
  else
    if (c[0] == "char") then 
      self.value = Std.string(Std.string(String.prototype.substring(self.value, 0, cursorPosAsInt)) .. Std.string(Std.string(c[1]))) .. Std.string(String.prototype.substring(self.value, cursorPosAsInt));
      self.cursorPos.x = self.cursorPos.x + 1;
      self:requestRerender();
    end;
  end;
end
TextArea.prototype.onRender = function(self) 
  if ((self.focused and ((self.cursorPos.x + self.scroll.x) < self:fixedWidth(self.lsw, self.lsh))) and ((self.cursorPos.y + self.scroll.y) < self:fixedHeight(self.lsw, self.lsh))) then 
    local ts = self:getWman().term:getSize();
    self:getWman().term:setCursorPos(Std.int(((self:fixedX(ts.x, ts.y, false) + self.cursorPos.x) + self.scroll.x) + 1), Std.int(((self:fixedY(ts.x, ts.y, false) + self.cursorPos.y) + self.scroll.y) + 1));
    self:getWman().term:setCursorBlink(true);
  end;
end
TextArea.prototype.renderImpl = function(self,screenwidth,screenheight,width,height) 
  local tmp = self.cursorPos.y;
  local tmp1 = String.prototype.split(self.value, "\n").length - 1;
  self.cursorPos.y = Math.min(tmp, tmp1);
  local tmp = self.cursorPos.x;
  local tmp1 = String.prototype.split(self.value, "\n");
  local tmp2 = Std.int(self.cursorPos.y);
  self.cursorPos.x = Math.min(tmp, #tmp1[tmp2]);
  local text = (function() 
    local _hx_1
    if (#self.value > 0) then 
    _hx_1 = self.value; else 
    _hx_1 = self.placeholder; end
    return _hx_1
  end )();
  local o = _hx_tab_array({}, 0);
  local cposx = 0;
  local cposy = 0;
  local _g = 0;
  local _g1 = #text;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    local char = _G.string.sub(text, i + 1, i + 1);
    if (char == "\n") then 
      cposx = 0;
      cposy = cposy + 1;
    else
      o:push(PositionedRenderCommand.new(cposx + self.scroll.x, cposy + self.scroll.y, char, self.id, (function() 
        local _hx_2
        if (#self.value > 0) then 
        _hx_2 = self.style.fgColor; else 
        _hx_2 = Colors.lightGray; end
        return _hx_2
      end )(), self.style.bgColor));
      cposx = cposx + 1;
    end;
  end;
  do return o end
end
TextArea.prototype.getTypename = function(self) 
  do return "TextArea" end
end
TextArea.prototype.serializeAdditional = function(self) 
  local _g = __haxe_ds_StringMap.new();
  local value = self.placeholder;
  if (value == nil) then 
    _g.h.placeholder = __haxe_ds_StringMap.tnull;
  else
    _g.h.placeholder = value;
  end;
  do return _g end
end
TextArea.prototype.deserializeAdditional = function(self,dt) 
  local data = dt;
  self.placeholder = Reflect.field(data, "placeholder");
  do return self end
end
TextArea.prototype.additionalEditorFields = function(self) 
  local _g = __haxe_ds_StringMap.new();
  _g.h.placeholder = "Placeholder";
  do return _g end
end

TextArea.prototype.__class__ =  TextArea
TextArea.__super__ = Widget
setmetatable(TextArea.prototype,{__index=Widget.prototype})

ScrollContainer.new = function(widgets) 
  local self = _hx_new(ScrollContainer.prototype)
  ScrollContainer.super(self,widgets)
  return self
end
ScrollContainer.super = function(self,widgets) 
  SimpleContainer.super(self,widgets);
end
_hx_exports["ScrollContainer"] = ScrollContainer
ScrollContainer.__name__ = true
ScrollContainer.prototype = _hx_e();
ScrollContainer.prototype.getTypename = function(self) 
  do return "ScrollContainer" end
end
ScrollContainer.prototype.onScroll = function(self,pos,dir,wself) 
  if (not wself) then 
    do return end;
  end;
  local fh = self.offset;
  fh.y = fh.y + -dir;
  local tmp = Math.max(self.offset.y, -(self:getMostWidgetHeight() - self:fixedHeight(self.lsw, self.lsh)));
  self.offset.y = Math.min(tmp, 0);
  self:requestRerender();
end

ScrollContainer.prototype.__class__ =  ScrollContainer
ScrollContainer.__super__ = SimpleContainer
setmetatable(ScrollContainer.prototype,{__index=SimpleContainer.prototype})

Values.new = {}
_hx_exports["Values"] = Values
Values.__name__ = true

Date.new = function(year,month,day,hour,min,sec) 
  local self = _hx_new(Date.prototype)
  Date.super(self,year,month,day,hour,min,sec)
  return self
end
Date.super = function(self,year,month,day,hour,min,sec) 
  self.t = _G.os.time(_hx_o({__fields__={year=true,month=true,day=true,hour=true,min=true,sec=true},year=year,month=month + 1,day=day,hour=hour,min=min,sec=sec}));
  self.d = _G.os.date("*t", self.t);
  self.dUTC = _G.os.date("!*t", self.t);
end
Date.__name__ = true
Date.prototype = _hx_e();
Date.prototype.d= nil;
Date.prototype.dUTC= nil;
Date.prototype.t= nil;
Date.prototype.getHours = function(self) 
  do return self.d.hour end
end
Date.prototype.getMinutes = function(self) 
  do return self.d.min end
end
Date.prototype.getSeconds = function(self) 
  do return self.d.sec end
end
Date.prototype.getFullYear = function(self) 
  do return self.d.year end
end
Date.prototype.getMonth = function(self) 
  do return self.d.month - 1 end
end
Date.prototype.getDate = function(self) 
  do return self.d.day end
end

Date.prototype.__class__ =  Date

CCOS.new = {}
CCOS.__name__ = true
CCOS.pullEvent = function() 
  
        if arcos then return arcos.ev() else return os.pullEvent() end
        ;
  do return nil end;
end

Lambda.new = {}
Lambda.__name__ = true
Lambda.has = function(it,elt) 
  local x = it:iterator();
  while (x:hasNext()) do _hx_do_first_1 = false;
    
    local x = x:next();
    if (x == elt) then 
      do return true end;
    end;
  end;
  do return false end;
end

Main.new = {}
Main.__name__ = true
Main.main = function() 
end

Reflect.new = {}
Reflect.__name__ = true
Reflect.field = function(o,field) 
  if (_G.type(o) == "string") then 
    if (field == "length") then 
      do return _hx_wrap_if_string_field(o,'length') end;
    else
      do return String.prototype[field] end;
    end;
  else
    local _hx_status, _hx_result = pcall(function() 
    
        do return o[field] end;
      return _hx_pcall_default
    end)
    if not _hx_status and _hx_result == "_hx_pcall_break" then
    elseif not _hx_status then 
      local _g = _hx_result;
      do return nil end;
    elseif _hx_result ~= _hx_pcall_default then
      return _hx_result
    end;
  end;
end
Reflect.getProperty = function(o,field) 
  if (o == nil) then 
    do return nil end;
  else
    if ((o.__properties__ ~= nil) and (Reflect.field(o, Std.string("get_") .. Std.string(field)) ~= nil)) then 
      do return Reflect.callMethod(o,Reflect.field(o, Std.string("get_") .. Std.string(field)),_hx_tab_array({}, 0)) end;
    else
      do return Reflect.field(o, field) end;
    end;
  end;
end
Reflect.callMethod = function(o,func,args) 
  if ((args == nil) or (args.length == 0)) then 
    do return func(o) end;
  else
    local self_arg = false;
    if ((o ~= nil) and (o.__name__ == nil)) then 
      self_arg = true;
    end;
    if (self_arg) then 
      do return func(o, _hx_table.unpack(args, 0, args.length - 1)) end;
    else
      do return func(_hx_table.unpack(args, 0, args.length - 1)) end;
    end;
  end;
end
Reflect.fields = function(o) 
  if (_G.type(o) == "string") then 
    do return Reflect.fields(String.prototype) end;
  else
    do return _hx_field_arr(o) end;
  end;
end
Reflect.isFunction = function(f) 
  if (_G.type(f) == "function") then 
    do return not ((function() 
      local _hx_1
      if (_G.type(f) ~= "table") then 
      _hx_1 = false; else 
      _hx_1 = f.__name__; end
      return _hx_1
    end )() or (function() 
      local _hx_2
      if (_G.type(f) ~= "table") then 
      _hx_2 = false; else 
      _hx_2 = f.__ename__; end
      return _hx_2
    end )()) end;
  else
    do return false end;
  end;
end

RenderCommand.new = function(char,belongsToID,fgColor,bgColor) 
  local self = _hx_new(RenderCommand.prototype)
  RenderCommand.super(self,char,belongsToID,fgColor,bgColor)
  return self
end
RenderCommand.super = function(self,char,belongsToID,fgColor,bgColor) 
  self.bgColor = Colors.black;
  self.fgColor = Colors.white;
  self.char = char;
  self.belongsToID = belongsToID;
  if (fgColor ~= nil) then 
    self.fgColor = fgColor;
  end;
  if (bgColor ~= nil) then 
    self.bgColor = bgColor;
  end;
end
_hx_exports["RenderCommand"] = RenderCommand
RenderCommand.__name__ = true
RenderCommand.prototype = _hx_e();
RenderCommand.prototype.char= nil;
RenderCommand.prototype.belongsToID= nil;
RenderCommand.prototype.fgColor= nil;
RenderCommand.prototype.bgColor= nil;

RenderCommand.prototype.__class__ =  RenderCommand

PositionedRenderCommand.new = function(x,y,char,belongsToID,fgColor,bgColor) 
  local self = _hx_new(PositionedRenderCommand.prototype)
  PositionedRenderCommand.super(self,x,y,char,belongsToID,fgColor,bgColor)
  return self
end
PositionedRenderCommand.super = function(self,x,y,char,belongsToID,fgColor,bgColor) 
  self.x = x;
  self.y = y;
  RenderCommand.super(self,char,belongsToID,fgColor,bgColor);
end
_hx_exports["PositionedRenderCommand"] = PositionedRenderCommand
PositionedRenderCommand.__name__ = true
PositionedRenderCommand.prototype = _hx_e();
PositionedRenderCommand.prototype.x= nil;
PositionedRenderCommand.prototype.y= nil;

PositionedRenderCommand.prototype.__class__ =  PositionedRenderCommand
PositionedRenderCommand.__super__ = RenderCommand
setmetatable(PositionedRenderCommand.prototype,{__index=RenderCommand.prototype})

Buffer.new = function(width,height) 
  local self = _hx_new(Buffer.prototype)
  Buffer.super(self,width,height)
  return self
end
Buffer.super = function(self,width,height) 
  self.matrix = _hx_tab_array({}, 0);
  self.height = 2;
  self.width = 2;
  self.width = width;
  self.height = height;
  self:reinitBuffer();
end
_hx_exports["Buffer"] = Buffer
Buffer.__name__ = true
Buffer.prototype = _hx_e();
Buffer.prototype.width= nil;
Buffer.prototype.height= nil;
Buffer.prototype.matrix= nil;
Buffer.prototype.reinitBuffer = function(self,bgcolor) 
  if (bgcolor ~= nil) then 
    bgcolor = Colors.black;
  end;
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self.height;
  while (_g1 < _g2) do _hx_do_first_1 = false;
    
    _g1 = _g1 + 1;
    local x = _g1 - 1;
    local _g1 = _hx_tab_array({}, 0);
    local _g2 = 0;
    local _g3 = self.width;
    while (_g2 < _g3) do _hx_do_first_2 = false;
      
      _g2 = _g2 + 1;
      local y = _g2 - 1;
      _g1:push(RenderCommand.new(" ", "Renderer"));
    end;
    _g:push(_g1);
  end;
  self.matrix = _g;
end
Buffer.prototype.addPRC = function(self,rc) 
  if (((self.matrix.length > Std.int(rc.y)) and (rc.y >= 0)) and (rc.x >= 0)) then 
    if (self.matrix[Std.int(rc.y)].length > Std.int(rc.x)) then 
      self.matrix[Std.int(rc.y)][Std.int(rc.x)] = rc;
    end;
  end;
end
Buffer.prototype.draw = function(self,term) 
  term:setCursorBlink(false);
  local _g_current = 0;
  local _g_array = self.matrix;
  while (_g_current < _g_array.length) do _hx_do_first_1 = false;
    
    local _g_value = _g_array[_g_current];
    _g_current = _g_current + 1;
    local _g_key = _g_current - 1;
    local index = _g_key;
    local array = _g_value;
    local t = "";
    local fg = "";
    local bg = "";
    local _g = 0;
    while (_g < array.length) do _hx_do_first_2 = false;
      
      local command = array[_g];
      _g = _g + 1;
      t = Std.string(t) .. Std.string(command.char);
      fg = Std.string(fg) .. Std.string(command.fgColor.blit);
      bg = Std.string(bg) .. Std.string(command.bgColor.blit);
    end;
    term:setCursorPos(1, index + 1);
    term:blit(t, fg, bg);
  end;
end
Buffer.prototype.blitBuffer = function(self,buffer,ox,oy) 
  local _g_current = 0;
  local _g_array = buffer.matrix;
  while (_g_current < _g_array.length) do _hx_do_first_1 = false;
    
    local _g_value = _g_array[_g_current];
    _g_current = _g_current + 1;
    local _g_key = _g_current - 1;
    local iy = _g_key;
    local line = _g_value;
    local _g_current = 0;
    local _g_array = line;
    while (_g_current < _g_array.length) do _hx_do_first_2 = false;
      
      local _g_value = _g_array[_g_current];
      _g_current = _g_current + 1;
      local _g_key = _g_current - 1;
      local ix = _g_key;
      local command = _g_value;
      local fixedX = ix + ox;
      local fixedY = iy + oy;
      if ((((self.matrix.length > fixedY) and (self.matrix[Std.int(fixedY)].length > fixedX)) and (fixedY >= 0)) and (fixedX >= 0)) then 
        self.matrix[Std.int(fixedY)][Std.int(fixedX)] = command;
      end;
    end;
  end;
end

Buffer.prototype.__class__ =  Buffer

Renderer.new = function(terminal) 
  local self = _hx_new(Renderer.prototype)
  Renderer.super(self,terminal)
  return self
end
Renderer.super = function(self,terminal) 
  self.currentBuffer = false;
  self.buffer1 = Buffer.new(0, 0);
  self.term = terminal;
end
_hx_exports["Renderer"] = Renderer
Renderer.__name__ = true
Renderer.prototype = _hx_e();
Renderer.prototype.buffer1= nil;
Renderer.prototype.currentBuffer= nil;
Renderer.prototype.term= nil;
Renderer.prototype.renderToBuffer = function(self,scr,ox,oy,buffer) 
  scr.width = buffer.width;
  scr.height = buffer.height;
  scr.x = 0;
  scr.xa = 0;
  scr.y = 0;
  scr.ya = 0;
  scr.parent = nil;
  local _g = 0;
  local _g1 = scr:getPRenderCommands(buffer.width, buffer.height, false);
  while (_g < _g1.length) do _hx_do_first_1 = false;
    
    local rc = _g1[_g];
    _g = _g + 1;
    local rc1 = rc;
    rc1.x = rc1.x + ox;
    local rc1 = rc;
    rc1.y = rc1.y + oy;
    buffer:addPRC(rc);
  end;
end
Renderer.prototype.render = function(self,scr) 
  self.buffer1:reinitBuffer();
  self:renderToBuffer(scr, 0, 0, self.buffer1);
  self.buffer1:draw(self.term);
end
Renderer.prototype.resize = function(self,x,y) 
  self.buffer1.width = Std.int(x + 1);
  self.buffer1.height = Std.int(y + 1);
  self.buffer1:reinitBuffer();
end

Renderer.prototype.__class__ =  Renderer

StringBuf.new = function() 
  local self = _hx_new(StringBuf.prototype)
  StringBuf.super(self)
  return self
end
StringBuf.super = function(self) 
  self.b = ({});
  self.length = 0;
end
StringBuf.__name__ = true
StringBuf.prototype = _hx_e();
StringBuf.prototype.b= nil;
StringBuf.prototype.length= nil;

StringBuf.prototype.__class__ =  StringBuf

StringTools.new = {}
StringTools.__name__ = true
StringTools.lpad = function(s,c,l) 
  if (#c <= 0) then 
    do return s end;
  end;
  local buf_b = ({});
  local buf_length = 0;
  l = l - #s;
  while (buf_length < l) do _hx_do_first_1 = false;
    
    local str = Std.string(c);
    _G.table.insert(buf_b, str);
    buf_length = buf_length + #str;
  end;
  local str = Std.string(s);
  _G.table.insert(buf_b, str);
  buf_length = buf_length + #str;
  do return _G.table.concat(buf_b) end;
end
_hxClasses["ValueType"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"},9)}
ValueType = _hxClasses["ValueType"];
ValueType.TNull = _hx_tab_array({[0]="TNull",0,__enum__ = ValueType},2)

ValueType.TInt = _hx_tab_array({[0]="TInt",1,__enum__ = ValueType},2)

ValueType.TFloat = _hx_tab_array({[0]="TFloat",2,__enum__ = ValueType},2)

ValueType.TBool = _hx_tab_array({[0]="TBool",3,__enum__ = ValueType},2)

ValueType.TObject = _hx_tab_array({[0]="TObject",4,__enum__ = ValueType},2)

ValueType.TFunction = _hx_tab_array({[0]="TFunction",5,__enum__ = ValueType},2)

ValueType.TClass = function(c) local _x = _hx_tab_array({[0]="TClass",6,c,__enum__=ValueType}, 3); return _x; end 
ValueType.TEnum = function(e) local _x = _hx_tab_array({[0]="TEnum",7,e,__enum__=ValueType}, 3); return _x; end 
ValueType.TUnknown = _hx_tab_array({[0]="TUnknown",8,__enum__ = ValueType},2)


Type.new = {}
Type.__name__ = true
Type.getClass = function(o) 
  if (o == nil) then 
    do return nil end;
  end;
  local o = o;
  if (__lua_Boot.__instanceof(o, Array)) then 
    do return Array end;
  else
    if (__lua_Boot.__instanceof(o, String)) then 
      do return String end;
    else
      local cl = o.__class__;
      if (cl ~= nil) then 
        do return cl end;
      else
        do return nil end;
      end;
    end;
  end;
end
Type.getInstanceFields = function(c) 
  local p = c.prototype;
  local a = _hx_tab_array({}, 0);
  while (p ~= nil) do _hx_do_first_1 = false;
    
    local _g = 0;
    local _g1 = Reflect.fields(p);
    while (_g < _g1.length) do _hx_do_first_2 = false;
      
      local f = _g1[_g];
      _g = _g + 1;
      if (not Lambda.has(a, f)) then 
        a:push(f);
      end;
    end;
    local mt = _G.getmetatable(p);
    if ((mt ~= nil) and (mt.__index ~= nil)) then 
      p = mt.__index;
    else
      p = nil;
    end;
  end;
  do return a end;
end
Type.typeof = function(v) 
  local _g = _G.type(v);
  if (_g) == "boolean" then 
    do return ValueType.TBool end;
  elseif (_g) == "function" then 
    if ((function() 
      local _hx_1
      if (_G.type(v) ~= "table") then 
      _hx_1 = false; else 
      _hx_1 = v.__name__; end
      return _hx_1
    end )() or (function() 
      local _hx_2
      if (_G.type(v) ~= "table") then 
      _hx_2 = false; else 
      _hx_2 = v.__ename__; end
      return _hx_2
    end )()) then 
      do return ValueType.TObject end;
    end;
    do return ValueType.TFunction end;
  elseif (_g) == "nil" then 
    do return ValueType.TNull end;
  elseif (_g) == "number" then 
    if (_G.math.ceil(v) == (_G.math.fmod(v, 2147483648.0))) then 
      do return ValueType.TInt end;
    end;
    do return ValueType.TFloat end;
  elseif (_g) == "string" then 
    do return ValueType.TClass(String) end;
  elseif (_g) == "table" then 
    local e = v.__enum__;
    if (e ~= nil) then 
      do return ValueType.TEnum(e) end;
    end;
    local c;
    if (__lua_Boot.__instanceof(v, Array)) then 
      c = Array;
    else
      if (__lua_Boot.__instanceof(v, String)) then 
        c = String;
      else
        local cl = v.__class__;
        c = (function() 
          local _hx_3
          if (cl ~= nil) then 
          _hx_3 = cl; else 
          _hx_3 = nil; end
          return _hx_3
        end )();
      end;
    end;
    if (c ~= nil) then 
      do return ValueType.TClass(c) end;
    end;
    do return ValueType.TObject end;else
  do return ValueType.TUnknown end; end;
end

Runner.new = function(term,root,peripheralName) 
  local self = _hx_new(Runner.prototype)
  Runner.super(self,term,root,peripheralName)
  return self
end
Runner.super = function(self,term,root,peripheralName) 
  self.cs = Vector2f.new(0, 0);
  self.renderer = Renderer.new(nil);
  self.peripheralName = nil;
  self.root = ScreenManager.new(nil);
  self.term = nil;
  self.root.term = term;
  self.root:addScreen(root);
  self.term = term;
  self.peripheralName = peripheralName;
  self.renderer.term = self.term;
  Runner.log("Created runner", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/UI.hx",lineNumber=60,className="Runner",methodName="new"}));
end
_hx_exports["Runner"] = Runner
Runner.__name__ = true
Runner.log = function(t,posInfos) 
  local _hx_status, _hx_result = pcall(function() 
  
      peripheral.wrap("back").transmit(630, 630, t);
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
end
Runner.prototype = _hx_e();
Runner.prototype.term= nil;
Runner.prototype.root= nil;
Runner.prototype.peripheralName= nil;
Runner.prototype.renderer= nil;
Runner.prototype.cs= nil;
Runner.prototype.run = function(self) 
  self.renderer:resize(self.term:getSize().x - 1, self.term:getSize().y - 1);
  self.renderer:render(self.root:current());
  while (true) do _hx_do_first_1 = false;
    
    local length = nil;
    local tab = __lua_PairTools.copy(_hx_table.pack(CCOS.pullEvent()));
    local length = length;
    local ev;
    if (length == nil) then 
      length = _hx_table.maxn(tab);
      if (length > 0) then 
        local head = tab[1];
        _G.table.remove(tab, 1);
        tab[0] = head;
        ev = _hx_tab_array(tab, length);
      else
        ev = _hx_tab_array({}, 0);
      end;
    else
      ev = _hx_tab_array(tab, length);
    end;
    self:event(ev);
  end;
end
Runner.prototype.render = function(self) 
  self.renderer:render(self.root:current());
  self.root:current():onRender();
end
Runner.prototype.event = function(self,ev) 
  if ((self.peripheralName ~= nil) and (ev[0] == "monitor_resize")) then 
    self.renderer:resize(self.term:getSize().x - 1, self.term:getSize().y - 1);
    self:render();
  end;
  if ((self.peripheralName == nil) and (ev[0] == "term_resize")) then 
    self.renderer:resize(self.term:getSize().x - 1, self.term:getSize().y - 1);
    self:render();
  end;
  if (((self.peripheralName ~= nil) and (ev[0] == "monitor_touch")) and (ev[1] == self.peripheralName)) then 
    self.root:current():onClick(Vector2f.new(ev[2], ev[3]), MouseButton.LEFT, true);
    self.root:current():onClickUp(Vector2f.new(ev[2], ev[3]), Vector2f.new(ev[2], ev[3]), MouseButton.LEFT, true);
  end;
  if (self.peripheralName == nil) then 
    local _g = ev[0];
    if (_g) == "mouse_click" then 
      self.cs = Vector2f.new(ev[2], ev[3]);
      self.root:current():onClick(self.cs, ev[1], true);
    elseif (_g) == "mouse_drag" then 
      self.root:current():onDrag(self.cs, Vector2f.new(ev[2], ev[3]), ev[1], true);
    elseif (_g) == "mouse_scroll" then 
      self.root:current():onScroll(Vector2f.new(ev[2], ev[3]), ev[1], true);
    elseif (_g) == "mouse_up" then 
      self.root:current():onClickUp(self.cs, Vector2f.new(ev[2], ev[3]), ev[1], true); end;
  end;
  self.root:current():onCustom(ev);
  if (self.root:current().requestsRerender) then 
    self:render();
    self.root:current().requestsRerender = false;
  end;
end

Runner.prototype.__class__ =  Runner

UILoader.new = function(ui) 
  local self = _hx_new(UILoader.prototype)
  UILoader.super(self,ui)
  return self
end
UILoader.super = function(self,ui) 
  self.uiData = __haxe_Json.parse(ui);
end
_hx_exports["UILoader"] = UILoader
UILoader.__name__ = true
UILoader.prototype = _hx_e();
UILoader.prototype.uiData= nil;

UILoader.prototype.__class__ =  UILoader

ScreenManager.new = function(terminal) 
  local self = _hx_new(ScreenManager.prototype)
  ScreenManager.super(self,terminal)
  return self
end
ScreenManager.super = function(self,terminal) 
  self.term = nil;
  self.currentScreen = 0;
  self.screens = _hx_tab_array({}, 0);
  self.term = terminal;
end
_hx_exports["ScreenManager"] = ScreenManager
ScreenManager.__name__ = true
ScreenManager.fromJSON = function(term,json) 
  local obj = __haxe_Json.parse(json);
  local sm = ScreenManager.new(term);
  if (__lua_Boot.__instanceof(obj, Array)) then 
    sm.screens = obj:map(function(e) 
      do return Widget.deserialize(e) end;
    end);
  else
    sm.screens = _hx_tab_array({[0]=Widget.deserialize(obj)}, 1);
  end;
  do return sm end;
end
ScreenManager.prototype = _hx_e();
ScreenManager.prototype.screens= nil;
ScreenManager.prototype.currentScreen= nil;
ScreenManager.prototype.term= nil;
ScreenManager.prototype.addScreen = function(self,scr) 
  scr.x = 0;
  scr.y = 0;
  scr.width = Std.int(self.term:getSize().x);
  scr.height = Std.int(self.term:getSize().y);
  scr.wman = self;
  self.screens:push(scr);
end
ScreenManager.prototype.rmScreen = function(self,scr) 
  self.screens:remove(scr);
end
ScreenManager.prototype.current = function(self) 
  if (self.screens.length <= self.currentScreen) then 
    do return Label.new(1, 1, "No screen created.") end;
  end;
  self.screens[self.currentScreen].x = 0;
  self.screens[self.currentScreen].y = 0;
  self.screens[self.currentScreen].width = Std.int(self.term:getSize().x);
  self.screens[self.currentScreen].height = Std.int(self.term:getSize().y);
  self.screens[self.currentScreen].wman = self;
  do return self.screens[self.currentScreen] end
end
ScreenManager.prototype.toJSON = function(self) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = self.screens;
  while (_g1 < _g2.length) do _hx_do_first_1 = false;
    
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    _g:push(i:serialize());
  end;
  do return __haxe_Json.stringify(_g) end
end

ScreenManager.prototype.__class__ =  ScreenManager

Vector2f.new = function(x,y) 
  local self = _hx_new(Vector2f.prototype)
  Vector2f.super(self,x,y)
  return self
end
Vector2f.super = function(self,x,y) 
  self.y = 0.0;
  self.x = 0.0;
  self.x = x;
  self.y = y;
end
_hx_exports["Vector2f"] = Vector2f
Vector2f.__name__ = true
Vector2f.add = function(vec1,vec) 
  do return Vector2f.new(vec1.x + vec.x, vec1.y + vec.y) end;
end
Vector2f.prototype = _hx_e();
Vector2f.prototype.x= nil;
Vector2f.prototype.y= nil;
Vector2f.prototype.addInts = function(self,x,y) 
  do return Vector2f.new(self.x + x, self.y + y) end
end

Vector2f.prototype.__class__ =  Vector2f

Style.new = function() 
  local self = _hx_new(Style.prototype)
  Style.super(self)
  return self
end
Style.super = function(self) 
  self.fgColor = Colors.white;
  self.bgColor = Colors.black;
end
_hx_exports["Style"] = Style
Style.__name__ = true
Style.prototype = _hx_e();
Style.prototype.bgColor= nil;
Style.prototype.fgColor= nil;

Style.prototype.__class__ =  Style

__haxe_IMap.new = {}
__haxe_IMap.__name__ = true
__haxe_IMap.prototype = _hx_e();
__haxe_IMap.prototype.get= nil;
__haxe_IMap.prototype.keys= nil;

__haxe_IMap.prototype.__class__ =  __haxe_IMap

__haxe_Exception.new = function(message,previous,native) 
  local self = _hx_new(__haxe_Exception.prototype)
  __haxe_Exception.super(self,message,previous,native)
  return self
end
__haxe_Exception.super = function(self,message,previous,native) 
  self.__skipStack = 0;
  self.__exceptionMessage = message;
  self.__previousException = previous;
  if (native ~= nil) then 
    self.__nativeException = native;
    self.__nativeStack = __haxe_NativeStackTrace.exceptionStack();
  else
    self.__nativeException = self;
    self.__nativeStack = __haxe_NativeStackTrace.callStack();
    self.__skipStack = 1;
  end;
end
__haxe_Exception.__name__ = true
__haxe_Exception.thrown = function(value) 
  if (__lua_Boot.__instanceof(value, __haxe_Exception)) then 
    do return value:get_native() end;
  else
    local e = __haxe_ValueException.new(value);
    e.__skipStack = e.__skipStack + 1;
    do return e end;
  end;
end
__haxe_Exception.prototype = _hx_e();
__haxe_Exception.prototype.__exceptionMessage= nil;
__haxe_Exception.prototype.__nativeStack= nil;
__haxe_Exception.prototype.__skipStack= nil;
__haxe_Exception.prototype.__nativeException= nil;
__haxe_Exception.prototype.__previousException= nil;
__haxe_Exception.prototype.toString = function(self) 
  do return self:get_message() end
end
__haxe_Exception.prototype.get_message = function(self) 
  do return self.__exceptionMessage end
end
__haxe_Exception.prototype.get_native = function(self) 
  do return self.__nativeException end
end

__haxe_Exception.prototype.__class__ =  __haxe_Exception

__haxe_Exception.prototype.__properties__ =  {get_native="get_native",get_message="get_message"}

__haxe_Json.new = {}
__haxe_Json.__name__ = true
__haxe_Json.parse = function(text) 
  do return __haxe_format_JsonParser.new(text):doParse() end;
end
__haxe_Json.stringify = function(value,replacer,space) 
  do return __haxe_format_JsonPrinter.print(value, replacer, space) end;
end

__haxe_NativeStackTrace.new = {}
__haxe_NativeStackTrace.__name__ = true
__haxe_NativeStackTrace.saveStack = function(exception) 
end
__haxe_NativeStackTrace.callStack = function() 
  local _g = debug.traceback();
  if (_g == nil) then 
    do return _hx_tab_array({}, 0) end;
  else
    local s = _g;
    do return String.prototype.split(s, "\n"):slice(3) end;
  end;
end
__haxe_NativeStackTrace.exceptionStack = function() 
  do return _hx_tab_array({}, 0) end;
end

__haxe_ValueException.new = function(value,previous,native) 
  local self = _hx_new(__haxe_ValueException.prototype)
  __haxe_ValueException.super(self,value,previous,native)
  return self
end
__haxe_ValueException.super = function(self,value,previous,native) 
  __haxe_Exception.super(self,(function() 
    local _hx_1
    if (value == nil) then 
    _hx_1 = "null"; else 
    _hx_1 = Std.string(value); end
    return _hx_1
  end )(),previous,native);
  self.value = value;
end
__haxe_ValueException.__name__ = true
__haxe_ValueException.prototype = _hx_e();
__haxe_ValueException.prototype.value= nil;

__haxe_ValueException.prototype.__class__ =  __haxe_ValueException
__haxe_ValueException.__super__ = __haxe_Exception
setmetatable(__haxe_ValueException.prototype,{__index=__haxe_Exception.prototype})
setmetatable(__haxe_ValueException.prototype.__properties__,{__index=__haxe_Exception.prototype.__properties__})

__haxe_ds_StringMap.new = function() 
  local self = _hx_new(__haxe_ds_StringMap.prototype)
  __haxe_ds_StringMap.super(self)
  return self
end
__haxe_ds_StringMap.super = function(self) 
  self.h = ({});
end
__haxe_ds_StringMap.__name__ = true
__haxe_ds_StringMap.__interfaces__ = {__haxe_IMap}
__haxe_ds_StringMap.prototype = _hx_e();
__haxe_ds_StringMap.prototype.h= nil;
__haxe_ds_StringMap.prototype.get = function(self,key) 
  local ret = self.h[key];
  if (ret == __haxe_ds_StringMap.tnull) then 
    do return nil end;
  end;
  do return ret end
end
__haxe_ds_StringMap.prototype.keys = function(self) 
  local _gthis = self;
  local next = _G.next;
  local cur = next(self.h, nil);
  do return _hx_o({__fields__={next=true,hasNext=true},next=function(self) 
    local ret = cur;
    cur = next(_gthis.h, cur);
    do return ret end;
  end,hasNext=function(self) 
    do return cur ~= nil end;
  end}) end
end

__haxe_ds_StringMap.prototype.__class__ =  __haxe_ds_StringMap

__haxe_exceptions_PosException.new = function(message,previous,pos) 
  local self = _hx_new(__haxe_exceptions_PosException.prototype)
  __haxe_exceptions_PosException.super(self,message,previous,pos)
  return self
end
__haxe_exceptions_PosException.super = function(self,message,previous,pos) 
  __haxe_Exception.super(self,message,previous);
  if (pos == nil) then 
    self.posInfos = _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="(unknown)",lineNumber=0,className="(unknown)",methodName="(unknown)"});
  else
    self.posInfos = pos;
  end;
end
__haxe_exceptions_PosException.__name__ = true
__haxe_exceptions_PosException.prototype = _hx_e();
__haxe_exceptions_PosException.prototype.posInfos= nil;
__haxe_exceptions_PosException.prototype.toString = function(self) 
  do return Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string("") .. Std.string(__haxe_Exception.prototype.toString(self))) .. Std.string(" in ")) .. Std.string(self.posInfos.className)) .. Std.string(".")) .. Std.string(self.posInfos.methodName)) .. Std.string(" at ")) .. Std.string(self.posInfos.fileName)) .. Std.string(":")) .. Std.string(self.posInfos.lineNumber) end
end

__haxe_exceptions_PosException.prototype.__class__ =  __haxe_exceptions_PosException
__haxe_exceptions_PosException.__super__ = __haxe_Exception
setmetatable(__haxe_exceptions_PosException.prototype,{__index=__haxe_Exception.prototype})
setmetatable(__haxe_exceptions_PosException.prototype.__properties__,{__index=__haxe_Exception.prototype.__properties__})

__haxe_exceptions_NotImplementedException.new = function(message,previous,pos) 
  local self = _hx_new(__haxe_exceptions_NotImplementedException.prototype)
  __haxe_exceptions_NotImplementedException.super(self,message,previous,pos)
  return self
end
__haxe_exceptions_NotImplementedException.super = function(self,message,previous,pos) 
  if (message == nil) then 
    message = "Not implemented";
  end;
  __haxe_exceptions_PosException.super(self,message,previous,pos);
end
__haxe_exceptions_NotImplementedException.__name__ = true
__haxe_exceptions_NotImplementedException.prototype = _hx_e();

__haxe_exceptions_NotImplementedException.prototype.__class__ =  __haxe_exceptions_NotImplementedException
__haxe_exceptions_NotImplementedException.__super__ = __haxe_exceptions_PosException
setmetatable(__haxe_exceptions_NotImplementedException.prototype,{__index=__haxe_exceptions_PosException.prototype})
setmetatable(__haxe_exceptions_NotImplementedException.prototype.__properties__,{__index=__haxe_exceptions_PosException.prototype.__properties__})

__haxe_format_JsonParser.new = function(str) 
  local self = _hx_new(__haxe_format_JsonParser.prototype)
  __haxe_format_JsonParser.super(self,str)
  return self
end
__haxe_format_JsonParser.super = function(self,str) 
  self.str = str;
  self.pos = 0;
end
__haxe_format_JsonParser.__name__ = true
__haxe_format_JsonParser.prototype = _hx_e();
__haxe_format_JsonParser.prototype.str= nil;
__haxe_format_JsonParser.prototype.pos= nil;
__haxe_format_JsonParser.prototype.doParse = function(self) 
  local result = self:parseRec();
  local c;
  while (true) do _hx_do_first_1 = false;
    
    c = self:nextChar();
    if (not (c ~= nil)) then 
      break;
    end;
    local c = c;
    if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then else
    self:invalidChar(); end;
  end;
  do return result end
end
__haxe_format_JsonParser.prototype.parseRec = function(self) 
  while (true) do _hx_do_first_1 = false;
    
    local c = self:nextChar();
    local c1 = c;
    if (c1) == 9 or (c1) == 10 or (c1) == 13 or (c1) == 32 then 
    elseif (c1) == 34 then 
      do return self:parseString() end;
    elseif (c1) == 45 or (c1) == 48 or (c1) == 49 or (c1) == 50 or (c1) == 51 or (c1) == 52 or (c1) == 53 or (c1) == 54 or (c1) == 55 or (c1) == 56 or (c1) == 57 then 
      local c = c;
      local start = self.pos - 1;
      local minus = c == 45;
      local digit = not minus;
      local zero = c == 48;
      local point = false;
      local e = false;
      local pm = false;
      local _end = false;
      local _hx_do_first_2 = true;
      while (not _end) or _hx_do_first_2 do 
        _hx_do_first_2 = false;
        
        c = self:nextChar();
        local c = c;
        if (c) == 43 or (c) == 45 then 
          if (not e or pm) then 
            self:invalidNumber(start);
          end;
          digit = false;
          pm = true;
        elseif (c) == 46 then 
          if ((minus or point) or e) then 
            self:invalidNumber(start);
          end;
          digit = false;
          point = true;
        elseif (c) == 48 then 
          if (zero and not point) then 
            self:invalidNumber(start);
          end;
          if (minus) then 
            minus = false;
            zero = true;
          end;
          digit = true;
        elseif (c) == 49 or (c) == 50 or (c) == 51 or (c) == 52 or (c) == 53 or (c) == 54 or (c) == 55 or (c) == 56 or (c) == 57 then 
          if (zero and not point) then 
            self:invalidNumber(start);
          end;
          if (minus) then 
            minus = false;
          end;
          digit = true;
          zero = false;
        elseif (c) == 69 or (c) == 101 then 
          if ((minus or zero) or e) then 
            self:invalidNumber(start);
          end;
          digit = false;
          e = true;else
        if (not digit) then 
          self:invalidNumber(start);
        end;
        self.pos = self.pos - 1;
        _end = true; end;
      end;
      local f = Std.parseFloat(String.prototype.substr(self.str, start, self.pos - start));
      local i = Std.int(f);
      if (i == f) then 
        do return i end;
      else
        do return f end;
      end;
    elseif (c1) == 91 then 
      local arr = _hx_tab_array({}, 0);
      local comma = nil;
      while (true) do _hx_do_first_2 = false;
        
        local c = self:nextChar();
        local c = c;
        if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then 
        elseif (c) == 44 then 
          if (comma) then 
            comma = false;
          else
            self:invalidChar();
          end;
        elseif (c) == 93 then 
          if (comma == false) then 
            self:invalidChar();
          end;
          do return arr end;else
        if (comma) then 
          self:invalidChar();
        end;
        self.pos = self.pos - 1;
        arr:push(self:parseRec());
        comma = true; end;
      end;
    elseif (c1) == 102 then 
      local save = self.pos;
      if ((((self:nextChar() ~= 97) or (self:nextChar() ~= 108)) or (self:nextChar() ~= 115)) or (self:nextChar() ~= 101)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return false end;
    elseif (c1) == 110 then 
      local save = self.pos;
      if (((self:nextChar() ~= 117) or (self:nextChar() ~= 108)) or (self:nextChar() ~= 108)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return nil end;
    elseif (c1) == 116 then 
      local save = self.pos;
      if (((self:nextChar() ~= 114) or (self:nextChar() ~= 117)) or (self:nextChar() ~= 101)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return true end;
    elseif (c1) == 123 then 
      local obj = _hx_e();
      local field = nil;
      local comma = nil;
      while (true) do _hx_do_first_2 = false;
        
        local c = self:nextChar();
        local c = c;
        if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then 
        elseif (c) == 34 then 
          if ((field ~= nil) or comma) then 
            self:invalidChar();
          end;
          field = self:parseString();
        elseif (c) == 44 then 
          if (comma) then 
            comma = false;
          else
            self:invalidChar();
          end;
        elseif (c) == 58 then 
          if (field == nil) then 
            self:invalidChar();
          end;
          obj[field] = self:parseRec();
          field = nil;
          comma = true;
        elseif (c) == 125 then 
          if ((field ~= nil) or (comma == false)) then 
            self:invalidChar();
          end;
          do return obj end;else
        self:invalidChar(); end;
      end;else
    self:invalidChar(); end;
  end;
end
__haxe_format_JsonParser.prototype.parseString = function(self) 
  local start = self.pos;
  local buf = nil;
  local prev = -1;
  while (true) do _hx_do_first_1 = false;
    
    local c = self:nextChar();
    if (c == 34) then 
      break;
    end;
    if (c == 92) then 
      if (buf == nil) then 
        buf = StringBuf.new();
      end;
      local s = self.str;
      local len = (self.pos - start) - 1;
      local part = (function() 
        local _hx_1
        if (len == nil) then 
        _hx_1 = String.prototype.substr(s, start); else 
        _hx_1 = String.prototype.substr(s, start, len); end
        return _hx_1
      end )();
      _G.table.insert(buf.b, part);
      local buf1 = buf;
      buf1.length = buf1.length + #part;
      c = self:nextChar();
      local c1 = c;
      if (c1) == 34 or (c1) == 47 or (c1) == 92 then 
        _G.table.insert(buf.b, _G.string.char(c));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 98 then 
        _G.table.insert(buf.b, _G.string.char(8));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 102 then 
        _G.table.insert(buf.b, _G.string.char(12));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 110 then 
        _G.table.insert(buf.b, _G.string.char(10));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 114 then 
        _G.table.insert(buf.b, _G.string.char(13));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 116 then 
        _G.table.insert(buf.b, _G.string.char(9));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 117 then 
        local uc = Std.parseInt(Std.string("0x") .. Std.string(String.prototype.substr(self.str, self.pos, 4)));
        local tmp = self;
        tmp.pos = tmp.pos + 4;
        if (prev ~= -1) then 
          if ((uc < 56320) or (uc > 57343)) then 
            _G.table.insert(buf.b, _G.string.char(65533));
            local buf = buf;
            buf.length = buf.length + 1;
            prev = -1;
          else
            _G.table.insert(buf.b, _G.string.char(((_hx_bit.lshift(prev - 55296,10)) + (uc - 56320)) + 65536));
            local buf = buf;
            buf.length = buf.length + 1;
            prev = -1;
          end;
        else
          if ((uc >= 55296) and (uc <= 56319)) then 
            prev = uc;
          else
            _G.table.insert(buf.b, _G.string.char(uc));
            local buf = buf;
            buf.length = buf.length + 1;
          end;
        end;else
      _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid escape sequence \\") .. Std.string(_G.string.char(c))) .. Std.string(" at position ")) .. Std.string((self.pos - 1))),0); end;
      start = self.pos;
    else
      if (c >= 128) then 
        self.pos = self.pos + 1;
        if (c >= 252) then 
          local tmp = self;
          tmp.pos = tmp.pos + 4;
        else
          if (c >= 248) then 
            local tmp = self;
            tmp.pos = tmp.pos + 3;
          else
            if (c >= 240) then 
              local tmp = self;
              tmp.pos = tmp.pos + 2;
            else
              if (c >= 224) then 
                self.pos = self.pos + 1;
              end;
            end;
          end;
        end;
      else
        if (c == nil) then 
          _G.error(__haxe_Exception.thrown("Unclosed string"),0);
        end;
      end;
    end;
  end;
  if (buf == nil) then 
    do return String.prototype.substr(self.str, start, (self.pos - start) - 1) end;
  else
    local s = self.str;
    local len = (self.pos - start) - 1;
    local part = (function() 
      local _hx_2
      if (len == nil) then 
      _hx_2 = String.prototype.substr(s, start); else 
      _hx_2 = String.prototype.substr(s, start, len); end
      return _hx_2
    end )();
    _G.table.insert(buf.b, part);
    local buf1 = buf;
    buf1.length = buf1.length + #part;
    do return _G.table.concat(buf.b) end;
  end;
end
__haxe_format_JsonParser.prototype.nextChar = function(self) 
  self.pos = self.pos + 1;
  do return _G.string.byte(self.str, self.pos) end
end
__haxe_format_JsonParser.prototype.invalidChar = function(self) 
  self.pos = self.pos - 1;
  _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid char ") .. Std.string(_G.string.byte(self.str, self.pos))) .. Std.string(" at position ")) .. Std.string(self.pos)),0);
end
__haxe_format_JsonParser.prototype.invalidNumber = function(self,start) 
  _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid number at position ") .. Std.string(start)) .. Std.string(": ")) .. Std.string(String.prototype.substr(self.str, start, self.pos - start))),0);
end

__haxe_format_JsonParser.prototype.__class__ =  __haxe_format_JsonParser

__haxe_format_JsonPrinter.new = function(replacer,space) 
  local self = _hx_new(__haxe_format_JsonPrinter.prototype)
  __haxe_format_JsonPrinter.super(self,replacer,space)
  return self
end
__haxe_format_JsonPrinter.super = function(self,replacer,space) 
  self.replacer = replacer;
  self.indent = space;
  self.pretty = space ~= nil;
  self.nind = 0;
  self.buf = StringBuf.new();
end
__haxe_format_JsonPrinter.__name__ = true
__haxe_format_JsonPrinter.print = function(o,replacer,space) 
  local printer = __haxe_format_JsonPrinter.new(replacer, space);
  printer:write("", o);
  do return _G.table.concat(printer.buf.b) end;
end
__haxe_format_JsonPrinter.prototype = _hx_e();
__haxe_format_JsonPrinter.prototype.buf= nil;
__haxe_format_JsonPrinter.prototype.replacer= nil;
__haxe_format_JsonPrinter.prototype.indent= nil;
__haxe_format_JsonPrinter.prototype.pretty= nil;
__haxe_format_JsonPrinter.prototype.nind= nil;
__haxe_format_JsonPrinter.prototype.write = function(self,k,v) 
  if (self.replacer ~= nil) then 
    v = self.replacer(k, v);
  end;
  local _g = Type.typeof(v);
  local tmp = _g[1];
  if (tmp) == 0 then 
    local _this = self.buf;
    local str = "null";
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 1 then 
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 2 then 
    local v = (function() 
      local _hx_1
      if (Math.isFinite(v)) then 
      _hx_1 = Std.string(v); else 
      _hx_1 = "null"; end
      return _hx_1
    end )();
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 3 then 
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 4 then 
    self:fieldsString(v, Reflect.fields(v));
  elseif (tmp) == 5 then 
    local _this = self.buf;
    local str = "\"<fun>\"";
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 6 then 
    local c = _g[2];
    if (c == String) then 
      self:quote(v);
    else
      if (c == Array) then 
        local v = v;
        local _this = self.buf;
        _G.table.insert(_this.b, _G.string.char(91));
        local _this = _this;
        _this.length = _this.length + 1;
        local len = v.length;
        local last = len - 1;
        local _g = 0;
        local _g1 = len;
        while (_g < _g1) do _hx_do_first_1 = false;
          
          _g = _g + 1;
          local i = _g - 1;
          if (i > 0) then 
            local _this = self.buf;
            _G.table.insert(_this.b, _G.string.char(44));
            local _this = _this;
            _this.length = _this.length + 1;
          else
            self.nind = self.nind + 1;
          end;
          if (self.pretty) then 
            local _this = self.buf;
            _G.table.insert(_this.b, _G.string.char(10));
            local _this = _this;
            _this.length = _this.length + 1;
          end;
          if (self.pretty) then 
            local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
            local _this = self.buf;
            local str = Std.string(v);
            _G.table.insert(_this.b, str);
            local _this = _this;
            _this.length = _this.length + #str;
          end;
          self:write(i, v[i]);
          if (i == last) then 
            self.nind = self.nind - 1;
            if (self.pretty) then 
              local _this = self.buf;
              _G.table.insert(_this.b, _G.string.char(10));
              local _this = _this;
              _this.length = _this.length + 1;
            end;
            if (self.pretty) then 
              local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
              local _this = self.buf;
              local str = Std.string(v);
              _G.table.insert(_this.b, str);
              local _this = _this;
              _this.length = _this.length + #str;
            end;
          end;
        end;
        local _this = self.buf;
        _G.table.insert(_this.b, _G.string.char(93));
        local _this = _this;
        _this.length = _this.length + 1;
      else
        if (c == __haxe_ds_StringMap) then 
          local v = v;
          local o = _hx_e();
          local k = v:keys();
          while (k:hasNext()) do _hx_do_first_1 = false;
            
            local k = k:next();
            local ret = v.h[k];
            o[k] = (function() 
              local _hx_2
              if (ret == __haxe_ds_StringMap.tnull) then 
              _hx_2 = nil; else 
              _hx_2 = ret; end
              return _hx_2
            end )();
          end;
          local v = o;
          self:fieldsString(v, Reflect.fields(v));
        else
          if (c == Date) then 
            local v = v;
            self:quote(__lua_Boot.dateStr(v));
          else
            self:classString(v);
          end;
        end;
      end;
    end;
  elseif (tmp) == 7 then 
    local _g = _g[2];
    local i = v[1];
    local v = Std.string(i);
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str;
  elseif (tmp) == 8 then 
    local _this = self.buf;
    local str = "\"???\"";
    _G.table.insert(_this.b, str);
    local _this = _this;
    _this.length = _this.length + #str; end;
end
__haxe_format_JsonPrinter.prototype.classString = function(self,v) 
  self:fieldsString(v, Type.getInstanceFields(Type.getClass(v)));
end
__haxe_format_JsonPrinter.prototype.fieldsString = function(self,v,fields) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  local _this = _this;
  _this.length = _this.length + 1;
  local len = fields.length;
  local empty = true;
  local _g = 0;
  local _g1 = len;
  local _hx_continue_1 = false;
  while (_g < _g1) do _hx_do_first_1 = false;
    repeat 
    _g = _g + 1;
    local i = _g - 1;
    local f = fields[i];
    local value = Reflect.field(v, f);
    if (Reflect.isFunction(value)) then 
      break;
    end;
    if (empty) then 
      self.nind = self.nind + 1;
      empty = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      local _this = _this;
      _this.length = _this.length + 1;
    end;
    if (self.pretty) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(10));
      local _this = _this;
      _this.length = _this.length + 1;
    end;
    if (self.pretty) then 
      local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
      local _this = self.buf;
      local str = Std.string(v);
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    end;
    self:quote(f);
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(58));
    local _this = _this;
    _this.length = _this.length + 1;
    if (self.pretty) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(32));
      local _this = _this;
      _this.length = _this.length + 1;
    end;
    self:write(f, value);until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  if (not empty) then 
    self.nind = self.nind - 1;
    if (self.pretty) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(10));
      local _this = _this;
      _this.length = _this.length + 1;
    end;
    if (self.pretty) then 
      local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
      local _this = self.buf;
      local str = Std.string(v);
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  local _this = _this;
  _this.length = _this.length + 1;
end
__haxe_format_JsonPrinter.prototype.quote = function(self,s) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(34));
  local _this = _this;
  _this.length = _this.length + 1;
  local i = 0;
  local length = #s;
  while (i < length) do _hx_do_first_1 = false;
    
    i = i + 1;
    local c = _G.string.byte(s, (i - 1) + 1);
    local c1 = c;
    if (c1) == 8 then 
      local _this = self.buf;
      local str = "\\b";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 9 then 
      local _this = self.buf;
      local str = "\\t";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 10 then 
      local _this = self.buf;
      local str = "\\n";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 12 then 
      local _this = self.buf;
      local str = "\\f";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 13 then 
      local _this = self.buf;
      local str = "\\r";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 34 then 
      local _this = self.buf;
      local str = "\\\"";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;
    elseif (c1) == 92 then 
      local _this = self.buf;
      local str = "\\\\";
      _G.table.insert(_this.b, str);
      local _this = _this;
      _this.length = _this.length + #str;else
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(c));
    local _this = _this;
    _this.length = _this.length + 1; end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(34));
  local _this = _this;
  _this.length = _this.length + 1;
end

__haxe_format_JsonPrinter.prototype.__class__ =  __haxe_format_JsonPrinter

__haxe_iterators_ArrayIterator.new = function(array) 
  local self = _hx_new(__haxe_iterators_ArrayIterator.prototype)
  __haxe_iterators_ArrayIterator.super(self,array)
  return self
end
__haxe_iterators_ArrayIterator.super = function(self,array) 
  self.current = 0;
  self.array = array;
end
__haxe_iterators_ArrayIterator.__name__ = true
__haxe_iterators_ArrayIterator.prototype = _hx_e();
__haxe_iterators_ArrayIterator.prototype.array= nil;
__haxe_iterators_ArrayIterator.prototype.current= nil;
__haxe_iterators_ArrayIterator.prototype.hasNext = function(self) 
  do return self.current < self.array.length end
end
__haxe_iterators_ArrayIterator.prototype.next = function(self) 
  do return self.array[(function() 
  local _hx_obj = self;
  local _hx_fld = 'current';
  local _ = _hx_obj[_hx_fld];
  _hx_obj[_hx_fld] = _hx_obj[_hx_fld]  + 1;
   return _;
   end)()] end
end

__haxe_iterators_ArrayIterator.prototype.__class__ =  __haxe_iterators_ArrayIterator

__haxe_iterators_ArrayKeyValueIterator.new = function(array) 
  local self = _hx_new(__haxe_iterators_ArrayKeyValueIterator.prototype)
  __haxe_iterators_ArrayKeyValueIterator.super(self,array)
  return self
end
__haxe_iterators_ArrayKeyValueIterator.super = function(self,array) 
  self.current = 0;
  self.array = array;
end
__haxe_iterators_ArrayKeyValueIterator.__name__ = true
__haxe_iterators_ArrayKeyValueIterator.prototype = _hx_e();
__haxe_iterators_ArrayKeyValueIterator.prototype.current= nil;
__haxe_iterators_ArrayKeyValueIterator.prototype.array= nil;
__haxe_iterators_ArrayKeyValueIterator.prototype.hasNext = function(self) 
  do return self.current < self.array.length end
end
__haxe_iterators_ArrayKeyValueIterator.prototype.next = function(self) 
  do return _hx_o({__fields__={value=true,key=true},value=self.array[self.current],key=(function() 
  local _hx_obj = self;
  local _hx_fld = 'current';
  local _ = _hx_obj[_hx_fld];
  _hx_obj[_hx_fld] = _hx_obj[_hx_fld]  + 1;
   return _;
   end)()}) end
end

__haxe_iterators_ArrayKeyValueIterator.prototype.__class__ =  __haxe_iterators_ArrayKeyValueIterator

__haxe_macro_Error.new = function(message,pos,previous) 
  local self = _hx_new(__haxe_macro_Error.prototype)
  __haxe_macro_Error.super(self,message,pos,previous)
  return self
end
__haxe_macro_Error.super = function(self,message,pos,previous) 
  __haxe_Exception.super(self,message,previous);
  self.pos = pos;
end
__haxe_macro_Error.__name__ = true
__haxe_macro_Error.prototype = _hx_e();
__haxe_macro_Error.prototype.pos= nil;

__haxe_macro_Error.prototype.__class__ =  __haxe_macro_Error
__haxe_macro_Error.__super__ = __haxe_Exception
setmetatable(__haxe_macro_Error.prototype,{__index=__haxe_Exception.prototype})
setmetatable(__haxe_macro_Error.prototype.__properties__,{__index=__haxe_Exception.prototype.__properties__})

__hxease_IEasing.new = {}
__hxease_IEasing.__name__ = true
__hxease_IEasing.prototype = _hx_e();
__hxease_IEasing.prototype.calculate= nil;

__hxease_IEasing.prototype.__class__ =  __hxease_IEasing

__hxease_BackEaseIn.new = function(overshoot) 
  local self = _hx_new(__hxease_BackEaseIn.prototype)
  __hxease_BackEaseIn.super(self,overshoot)
  return self
end
__hxease_BackEaseIn.super = function(self,overshoot) 
  self.overshoot = overshoot;
end
__hxease_BackEaseIn.__name__ = true
__hxease_BackEaseIn.__interfaces__ = {__hxease_IEasing}
__hxease_BackEaseIn.prototype = _hx_e();
__hxease_BackEaseIn.prototype.overshoot= nil;
__hxease_BackEaseIn.prototype.calculate = function(self,ratio) 
  if (ratio == 1) then 
    do return 1 end;
  end;
  do return (ratio * ratio) * (((self.overshoot + 1.0) * ratio) - self.overshoot) end
end

__hxease_BackEaseIn.prototype.__class__ =  __hxease_BackEaseIn

__hxease_BackEaseInOut.new = function(overshoot) 
  local self = _hx_new(__hxease_BackEaseInOut.prototype)
  __hxease_BackEaseInOut.super(self,overshoot)
  return self
end
__hxease_BackEaseInOut.super = function(self,overshoot) 
  self.overshoot = overshoot;
end
__hxease_BackEaseInOut.__name__ = true
__hxease_BackEaseInOut.__interfaces__ = {__hxease_IEasing}
__hxease_BackEaseInOut.prototype = _hx_e();
__hxease_BackEaseInOut.prototype.overshoot= nil;
__hxease_BackEaseInOut.prototype.calculate = function(self,ratio) 
  local over = self.overshoot;
  ratio = ratio * 2;
  if (ratio < 1) then 
    over = over * 1.525;
    do return 0.5 * ((ratio * ratio) * (((over + 1) * ratio) - over)) end;
  end;
  ratio = ratio - 2;
  over = over * 1.525;
  do return 0.5 * (((ratio * ratio) * (((over + 1) * ratio) + over)) + 2) end
end

__hxease_BackEaseInOut.prototype.__class__ =  __hxease_BackEaseInOut

__hxease_BackEaseOut.new = function(overshoot) 
  local self = _hx_new(__hxease_BackEaseOut.prototype)
  __hxease_BackEaseOut.super(self,overshoot)
  return self
end
__hxease_BackEaseOut.super = function(self,overshoot) 
  self.overshoot = overshoot;
end
__hxease_BackEaseOut.__name__ = true
__hxease_BackEaseOut.__interfaces__ = {__hxease_IEasing}
__hxease_BackEaseOut.prototype = _hx_e();
__hxease_BackEaseOut.prototype.overshoot= nil;
__hxease_BackEaseOut.prototype.calculate = function(self,ratio) 
  if (ratio == 0) then 
    do return 0 end;
  end;
  ratio = ratio - 1;
  do return ((ratio * ratio) * (((self.overshoot + 1) * ratio) + self.overshoot)) + 1 end
end

__hxease_BackEaseOut.prototype.__class__ =  __hxease_BackEaseOut

__hxease_Back.new = {}
__hxease_Back.__name__ = true

__hxease_LinearEaseNone.new = function() 
  local self = _hx_new(__hxease_LinearEaseNone.prototype)
  __hxease_LinearEaseNone.super(self)
  return self
end
__hxease_LinearEaseNone.super = function(self) 
end
__hxease_LinearEaseNone.__name__ = true
__hxease_LinearEaseNone.__interfaces__ = {__hxease_IEasing}
__hxease_LinearEaseNone.prototype = _hx_e();
__hxease_LinearEaseNone.prototype.calculate = function(self,ratio) 
  do return ratio end
end

__hxease_LinearEaseNone.prototype.__class__ =  __hxease_LinearEaseNone

__hxease_LinearEaseStep.new = function() 
  local self = _hx_new(__hxease_LinearEaseStep.prototype)
  __hxease_LinearEaseStep.super(self)
  return self
end
__hxease_LinearEaseStep.super = function(self) 
end
__hxease_LinearEaseStep.__name__ = true
__hxease_LinearEaseStep.__interfaces__ = {__hxease_IEasing}
__hxease_LinearEaseStep.prototype = _hx_e();
__hxease_LinearEaseStep.prototype.calculate = function(self,ratio) 
  if (ratio < 1) then 
    do return 0 end;
  else
    do return 1 end;
  end;
end

__hxease_LinearEaseStep.prototype.__class__ =  __hxease_LinearEaseStep

__hxease_Linear.new = {}
__hxease_Linear.__name__ = true

__lua_Boot.new = {}
__lua_Boot.__name__ = true
__lua_Boot.__instanceof = function(o,cl) 
  if (cl == nil) then 
    do return false end;
  end;
  local cl1 = cl;
  if (cl1) == Array then 
    do return __lua_Boot.isArray(o) end;
  elseif (cl1) == Bool then 
    do return _G.type(o) == "boolean" end;
  elseif (cl1) == Dynamic then 
    do return o ~= nil end;
  elseif (cl1) == Float then 
    do return _G.type(o) == "number" end;
  elseif (cl1) == Int then 
    if (_G.type(o) == "number") then 
      do return _hx_bit_clamp(o) == o end;
    else
      do return false end;
    end;
  elseif (cl1) == String then 
    do return _G.type(o) == "string" end;
  elseif (cl1) == _G.table then 
    do return _G.type(o) == "table" end;
  elseif (cl1) == __lua_Thread then 
    do return _G.type(o) == "thread" end;
  elseif (cl1) == __lua_UserData then 
    do return _G.type(o) == "userdata" end;else
  if (((o ~= nil) and (_G.type(o) == "table")) and (_G.type(cl) == "table")) then 
    local tmp;
    if (__lua_Boot.__instanceof(o, Array)) then 
      tmp = Array;
    else
      if (__lua_Boot.__instanceof(o, String)) then 
        tmp = String;
      else
        local cl = o.__class__;
        tmp = (function() 
          local _hx_1
          if (cl ~= nil) then 
          _hx_1 = cl; else 
          _hx_1 = nil; end
          return _hx_1
        end )();
      end;
    end;
    if (__lua_Boot.extendsOrImplements(tmp, cl)) then 
      do return true end;
    end;
    if ((function() 
      local _hx_2
      if (cl == Class) then 
      _hx_2 = o.__name__ ~= nil; else 
      _hx_2 = false; end
      return _hx_2
    end )()) then 
      do return true end;
    end;
    if ((function() 
      local _hx_3
      if (cl == Enum) then 
      _hx_3 = o.__ename__ ~= nil; else 
      _hx_3 = false; end
      return _hx_3
    end )()) then 
      do return true end;
    end;
    do return o.__enum__ == cl end;
  else
    do return false end;
  end; end;
end
__lua_Boot.isArray = function(o) 
  if (_G.type(o) == "table") then 
    if ((o.__enum__ == nil) and (_G.getmetatable(o) ~= nil)) then 
      do return _G.getmetatable(o).__index == Array.prototype end;
    else
      do return false end;
    end;
  else
    do return false end;
  end;
end
__lua_Boot.__cast = function(o,t) 
  if ((o == nil) or __lua_Boot.__instanceof(o, t)) then 
    do return o end;
  else
    _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Cannot cast ") .. Std.string(Std.string(o))) .. Std.string(" to ")) .. Std.string(Std.string(t))),0);
  end;
end
__lua_Boot.dateStr = function(date) 
  local m = date:getMonth() + 1;
  local d = date:getDate();
  local h = date:getHours();
  local mi = date:getMinutes();
  local s = date:getSeconds();
  do return Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(date:getFullYear()) .. Std.string("-")) .. Std.string(((function() 
    local _hx_1
    if (m < 10) then 
    _hx_1 = Std.string("0") .. Std.string(m); else 
    _hx_1 = Std.string("") .. Std.string(m); end
    return _hx_1
  end )()))) .. Std.string("-")) .. Std.string(((function() 
    local _hx_2
    if (d < 10) then 
    _hx_2 = Std.string("0") .. Std.string(d); else 
    _hx_2 = Std.string("") .. Std.string(d); end
    return _hx_2
  end )()))) .. Std.string(" ")) .. Std.string(((function() 
    local _hx_3
    if (h < 10) then 
    _hx_3 = Std.string("0") .. Std.string(h); else 
    _hx_3 = Std.string("") .. Std.string(h); end
    return _hx_3
  end )()))) .. Std.string(":")) .. Std.string(((function() 
    local _hx_4
    if (mi < 10) then 
    _hx_4 = Std.string("0") .. Std.string(mi); else 
    _hx_4 = Std.string("") .. Std.string(mi); end
    return _hx_4
  end )()))) .. Std.string(":")) .. Std.string(((function() 
    local _hx_5
    if (s < 10) then 
    _hx_5 = Std.string("0") .. Std.string(s); else 
    _hx_5 = Std.string("") .. Std.string(s); end
    return _hx_5
  end )())) end;
end
__lua_Boot.extendsOrImplements = function(cl1,cl2) 
  if ((cl1 == nil) or (cl2 == nil)) then 
    do return false end;
  else
    if (cl1 == cl2) then 
      do return true end;
    else
      if (cl1.__interfaces__ ~= nil) then 
        local intf = cl1.__interfaces__;
        local _g = 1;
        local _g1 = _hx_table.maxn(intf) + 1;
        while (_g < _g1) do _hx_do_first_1 = false;
          
          _g = _g + 1;
          local i = _g - 1;
          if (__lua_Boot.extendsOrImplements(intf[i], cl2)) then 
            do return true end;
          end;
        end;
      end;
    end;
  end;
  do return __lua_Boot.extendsOrImplements(cl1.__super__, cl2) end;
end

__lua_UserData.new = {}
__lua_UserData.__name__ = true

__lua_Thread.new = {}
__lua_Thread.__name__ = true

__typedefs_Terminal.new = function() 
  local self = _hx_new(__typedefs_Terminal.prototype)
  __typedefs_Terminal.super(self)
  return self
end
__typedefs_Terminal.super = function(self) 
  self.size = Vector2f.new(51, 19);
end
_hx_exports["typedefs"]["Terminal"] = __typedefs_Terminal
__typedefs_Terminal.__name__ = true
__typedefs_Terminal.prototype = _hx_e();
__typedefs_Terminal.prototype.write= nil;
__typedefs_Terminal.prototype.clear= nil;
__typedefs_Terminal.prototype.setCursorPos= nil;
__typedefs_Terminal.prototype.getSize= nil;
__typedefs_Terminal.prototype.setPaletteColor= nil;
__typedefs_Terminal.prototype.blit= nil;
__typedefs_Terminal.prototype.setCursorBlink= nil;
__typedefs_Terminal.prototype.size= nil;

__typedefs_Terminal.prototype.__class__ =  __typedefs_Terminal

__typedefs_Simpleterminal.new = function(pf) 
  local self = _hx_new(__typedefs_Simpleterminal.prototype)
  __typedefs_Simpleterminal.super(self,pf)
  return self
end
__typedefs_Simpleterminal.super = function(self,pf) 
  self.apalette = _hx_tab_array({[0]=RGBColor.new(236, 239, 244), RGBColor.new(0, 0, 0), RGBColor.new(180, 142, 173), RGBColor.new(0, 0, 0), RGBColor.new(235, 203, 139), RGBColor.new(163, 190, 140), RGBColor.new(0, 0, 0), RGBColor.new(76, 86, 106), RGBColor.new(216, 222, 233), RGBColor.new(136, 192, 208), RGBColor.new(0, 0, 0), RGBColor.new(129, 161, 193), RGBColor.new(0, 0, 0), RGBColor.new(163, 190, 140), RGBColor.new(191, 97, 106), RGBColor.new(59, 66, 82)}, 16);
  __typedefs_Terminal.super(self);
  self.printFunction = pf;
  self.apalette = __typedefs_Simpleterminal.apalettea;
end
_hx_exports["typedefs"]["Simpleterminal"] = __typedefs_Simpleterminal
__typedefs_Simpleterminal.__name__ = true
__typedefs_Simpleterminal.prototype = _hx_e();
__typedefs_Simpleterminal.prototype.apalette= nil;
__typedefs_Simpleterminal.prototype.get_palette = function(self) 
  do return self.apalette end
end
__typedefs_Simpleterminal.prototype.printFunction= nil;
__typedefs_Simpleterminal.prototype.write = function(self,s) 
  self.printFunction(s);
end
__typedefs_Simpleterminal.prototype.clear = function(self) 
  self.printFunction("\027[2J");
end
__typedefs_Simpleterminal.prototype.setTextColor = function(self,col) 
  self.printFunction(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string("\027[38;2;") .. Std.string(self.apalette[col.palNumber].red)) .. Std.string(";")) .. Std.string(self.apalette[col.palNumber].green)) .. Std.string(";")) .. Std.string(self.apalette[col.palNumber].blue)) .. Std.string("m"));
end
__typedefs_Simpleterminal.prototype.setBackgroundColor = function(self,col) 
  self.printFunction(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string("\027[48;2;") .. Std.string(self.apalette[col.palNumber].red)) .. Std.string(";")) .. Std.string(self.apalette[col.palNumber].green)) .. Std.string(";")) .. Std.string(self.apalette[col.palNumber].blue)) .. Std.string("m"));
end
__typedefs_Simpleterminal.prototype.setCursorPos = function(self,x,y) 
  self.printFunction(Std.string(Std.string(Std.string(Std.string("\027[") .. Std.string(y)) .. Std.string(";")) .. Std.string(x)) .. Std.string("H"));
end
__typedefs_Simpleterminal.prototype.set_palette = function(self,newc) 
  local i = 0;
  local _g = 0;
  while (_g < newc.length) do _hx_do_first_1 = false;
    
    local color = newc[_g];
    _g = _g + 1;
    i = i + 1;
    self.apalette[i - 1] = color;
  end;
  do return self.apalette end
end
__typedefs_Simpleterminal.prototype.setPaletteColor = function(self,paln,r,g,b) 
  local apaln = Std.int(_G.math.log(paln));
  self.apalette[apaln] = RGBColor.new(Std.int(r), Std.int(g), Std.int(b));
end
__typedefs_Simpleterminal.prototype.getSize = function(self) 
  do return self.size end
end
__typedefs_Simpleterminal.prototype.blit = function(self,a,b,c) 
  local _g = 0;
  local _g1 = #a;
  while (_g < _g1) do _hx_do_first_1 = false;
    
    _g = _g + 1;
    local i = _g - 1;
    local c = _G.string.sub(a, i + 1, i + 1);
    local fg = Colors.fromBlit(_G.string.sub(b, i + 1, i + 1));
    local bg = Colors.fromBlit(_G.string.sub(c, i + 1, i + 1));
    self:setTextColor(fg);
    self:setBackgroundColor(bg);
    self:write(c);
  end;
end
__typedefs_Simpleterminal.prototype.setCursorBlink = function(self,b) 
end

__typedefs_Simpleterminal.prototype.__class__ =  __typedefs_Simpleterminal

__typedefs_Simpleterminal.prototype.__properties__ =  {set_palette="set_palette",get_palette="get_palette"}
__typedefs_Simpleterminal.__super__ = __typedefs_Terminal
setmetatable(__typedefs_Simpleterminal.prototype,{__index=__typedefs_Terminal.prototype})

__typedefs_CCTerminal.new = function(term) 
  local self = _hx_new(__typedefs_CCTerminal.prototype)
  __typedefs_CCTerminal.super(self,term)
  return self
end
__typedefs_CCTerminal.super = function(self,term) 
  __typedefs_Terminal.super(self);
  self.termxe = term;
  local _g_current = 0;
  local _g_array = __typedefs_Simpleterminal.apalettea;
  while (_g_current < _g_array.length) do _hx_do_first_1 = false;
    
    local _g_value = _g_array[_g_current];
    _g_current = _g_current + 1;
    local _g_key = _g_current - 1;
    local i = _g_key;
    local v = _g_value;
    self:setPaletteColor(Std.int(_G.math.pow(2, i)), v.red / 255, v.green / 255, v.blue / 255);
  end;
end
_hx_exports["typedefs"]["CCTerminal"] = __typedefs_CCTerminal
__typedefs_CCTerminal.__name__ = true
__typedefs_CCTerminal.prototype = _hx_e();
__typedefs_CCTerminal.prototype.termxe= nil;
__typedefs_CCTerminal.prototype.write = function(self,s) 
  self.termxe.write(s);
end
__typedefs_CCTerminal.prototype.clear = function(self) 
  self.termxe.clear();
end
__typedefs_CCTerminal.prototype.setCursorPos = function(self,x,y) 
  self.termxe.setCursorPos(x, y);
end
__typedefs_CCTerminal.prototype.getSize = function(self) 
  local _hx_1_s_x, _hx_1_s_y = self.termxe.getSize();
  do return Vector2f.new(_hx_1_s_x, _hx_1_s_y) end
end
__typedefs_CCTerminal.prototype.setPaletteColor = function(self,paln,r,g,b) 
  self.termxe.setPaletteColor(paln, r, g, b);
end
__typedefs_CCTerminal.prototype.blit = function(self,text,fgColors,bgColors) 
  self.termxe.blit(text, fgColors, bgColors);
end
__typedefs_CCTerminal.prototype.setCursorBlink = function(self,b) 
  self.termxe.setCursorBlink(b);
end

__typedefs_CCTerminal.prototype.__class__ =  __typedefs_CCTerminal
__typedefs_CCTerminal.__super__ = __typedefs_Terminal
setmetatable(__typedefs_CCTerminal.prototype,{__index=__typedefs_Terminal.prototype})
local hasBit32, bit32 = pcall(require, 'bit32')
if hasBit32 then --if we are on Lua 5.1, bit32 will be the default.
  _hx_bit_raw = bit32
  _hx_bit = setmetatable({}, { __index = _hx_bit_raw })
  -- lua 5.2 weirdness
  _hx_bit.bnot = function(...) return _hx_bit_clamp(_hx_bit_raw.bnot(...)) end
  _hx_bit.bxor = function(...) return _hx_bit_clamp(_hx_bit_raw.bxor(...)) end
else
  --If we do not have bit32, fallback to 'bit'
  local hasBit, bit = pcall(require, 'bit')
  if not hasBit then
    error("Failed to load bit or bit32")
  end
  _hx_bit_raw = bit
  _hx_bit = setmetatable({}, { __index = _hx_bit_raw })
end

-- see https://github.com/HaxeFoundation/haxe/issues/8849
_hx_bit.bor = function(...) return _hx_bit_clamp(_hx_bit_raw.bor(...)) end
_hx_bit.band = function(...) return _hx_bit_clamp(_hx_bit_raw.band(...)) end
_hx_bit.arshift = function(...) return _hx_bit_clamp(_hx_bit_raw.arshift(...)) end

if _hx_bit_raw then
    _hx_bit_clamp = function(v)
    if v <= 2147483647 and v >= -2147483648 then
        if v > 0 then return _G.math.floor(v)
        else return _G.math.ceil(v)
        end
    end
    if v > 2251798999999999 then v = v*2 end;
    if (v ~= v or math.abs(v) == _G.math.huge) then return nil end
    return _hx_bit_raw.band(v, 2147483647 ) - math.abs(_hx_bit_raw.band(v, 2147483648))
    end
else
    _hx_bit_clamp = function(v)
        if v < -2147483648 then
            return -2147483648
        elseif v > 2147483647 then
            return 2147483647
        elseif v > 0 then
            return _G.math.floor(v)
        else
            return _G.math.ceil(v)
        end
    end
end;



_hx_array_mt.__index = Array.prototype

if package.loaded.luv then
  _hx_luv = _G.require("luv");
else
  _hx_luv = {
    run=function(mode) return false end,
    loop_alive=function() return false end
  }
end
local _hx_static_init = function()
  
  String.__name__ = true;
  Array.__name__ = true;Colors.white = Color.new("0", 0, 1);
  
  Colors.orange = Color.new("1", 1, 2);
  
  Colors.magenta = Color.new("2", 2, 4);
  
  Colors.lightBlue = Color.new("3", 3, 8);
  
  Colors.yellow = Color.new("4", 4, 16);
  
  Colors.lime = Color.new("5", 5, 32);
  
  Colors.pink = Color.new("6", 6, 64);
  
  Colors.gray = Color.new("7", 7, 128);
  
  Colors.lightGray = Color.new("8", 8, 256);
  
  Colors.cyan = Color.new("9", 9, 512);
  
  Colors.purple = Color.new("a", 10, 1024);
  
  Colors.blue = Color.new("b", 11, 2048);
  
  Colors.brown = Color.new("c", 12, 4096);
  
  Colors.green = Color.new("d", 13, 8192);
  
  Colors.red = Color.new("e", 14, 16384);
  
  Colors.black = Color.new("f", 15, 32768);
  
  Values.typenames = (function() 
    local _hx_1
    
    local _g = __haxe_ds_StringMap.new();
    
    local value = function() 
      local o = Label.new(0, 0, "");
      do return o end;
    end;
    if (value == nil) then 
      _g.h.Label = __haxe_ds_StringMap.tnull;
    else
      _g.h.Label = value;
    end;
    
    local value = function() 
      do return SimpleContainer.new(_hx_tab_array({}, 0)) end;
    end;
    if (value == nil) then 
      _g.h.Container = __haxe_ds_StringMap.tnull;
    else
      _g.h.Container = value;
    end;
    
    local value = function() 
      do return Button.new(_hx_tab_array({}, 0), Command.new()) end;
    end;
    if (value == nil) then 
      _g.h.Button = __haxe_ds_StringMap.tnull;
    else
      _g.h.Button = value;
    end;
    
    local value = function() 
      do return TextArea.new(0, 0, "") end;
    end;
    if (value == nil) then 
      _g.h.TextArea = __haxe_ds_StringMap.tnull;
    else
      _g.h.TextArea = value;
    end;
    
    local value = function() 
      do return ScrollContainer.new(_hx_tab_array({}, 0)) end;
    end;
    if (value == nil) then 
      _g.h.ScrollContainer = __haxe_ds_StringMap.tnull;
    else
      _g.h.ScrollContainer = value;
    end;
    
    _hx_1 = _g;
    return _hx_1
  end )();
  
  __haxe_ds_StringMap.tnull = ({});
  
  __hxease_Back.DEFAULT_OVERSHOOT = 1.70158;
  
  __hxease_Back.easeIn = __hxease_BackEaseIn.new(1.70158);
  
  __hxease_Back.easeInOut = __hxease_BackEaseInOut.new(1.70158);
  
  __hxease_Back.easeOut = __hxease_BackEaseOut.new(1.70158);
  
  __hxease_Linear.easeNone = __hxease_LinearEaseNone.new();
  
  __hxease_Linear.easeStep = __hxease_LinearEaseStep.new();
  
  __typedefs_Simpleterminal.apalettea = _hx_tab_array({[0]=RGBColor.new(236, 239, 244), RGBColor.new(0, 0, 0), RGBColor.new(180, 142, 173), RGBColor.new(0, 0, 0), RGBColor.new(235, 203, 139), RGBColor.new(163, 190, 140), RGBColor.new(0, 0, 0), RGBColor.new(76, 86, 106), RGBColor.new(146, 154, 170), RGBColor.new(136, 192, 208), RGBColor.new(0, 0, 0), RGBColor.new(129, 161, 193), RGBColor.new(0, 0, 0), RGBColor.new(163, 190, 140), RGBColor.new(191, 97, 106), RGBColor.new(59, 66, 82)}, 16);
  
  
end

_hx_bind = function(o,m)
  if m == nil then return nil end;
  local f;
  if o._hx__closures == nil then
    _G.rawset(o, '_hx__closures', {});
  else
    f = o._hx__closures[m];
  end
  if (f == nil) then
    f = function(...) return m(o, ...) end;
    o._hx__closures[m] = f;
  end
  return f;
end

_G.math.randomseed(_G.os.time());

_hx_table = {}
_hx_table.pack = _G.table.pack or function(...)
    return {...}
end
_hx_table.unpack = _G.table.unpack or _G.unpack
_hx_table.maxn = _G.table.maxn or function(t)
  local maxn=0;
  for i in pairs(t) do
    maxn=type(i)=='number'and i>maxn and i or maxn
  end
  return maxn
end;

_hx_wrap_if_string_field = function(o, fld)
  if _G.type(o) == 'string' then
    if fld == 'length' then
      return _G.string.len(o)
    else
      return String.prototype[fld]
    end
  else
    return o[fld]
  end
end

function _hx_handle_error(obj)
  local message = tostring(obj)
  if _G.debug and _G.debug.traceback then
    -- level 2 to skip _hx_handle_error
    message = _G.debug.traceback(message, 2)
  end
  return setmetatable({}, { __tostring = function() return message end })
end

_hx_static_init();
local success, err = _G.xpcall(function() 
  Main.main();
  _hx_luv.run();
end, _hx_handle_error)
if not success then _G.error(err) end
return _hx_exports
if arcos.getCurrentTask().user ~= "root" then
    error("Not root!")
end
ackFinish()
local modem
local selectedFloor = -1
local col = require("col")
if arcos then
    modem = devices.find("modem")
else
    modem = peripheral.find("modem")
end
local theme
if arcos then
    theme = {
        bg = col.black,
        elFloor = col.blue,
        elFloorSel = col.magenta,
        buttonColor = col.white
    }
else
    theme = {
        bg = colors.black,
        elFloor = colors.brown,
        elFloorSel = colors.yellow,
        buttonColor = colors.white
    }
end
local floors = {
    {id=8, name="Outside"},
    {id=3, name="Living"},
    {id=4, name="Lab"},
    {id=9, name="Spatial"},
    {id=7, name="Bunker"}
}
local buttons = {
    {
        text = "[()]",
        pos = 1,
        callback = function()
            modem.transmit(4590, 0, "")
        end
    },
    {
        text = "[ ]",
        pos = 6,
        callback = function()
            modem.transmit(713, 0, "MatDoorOpen")
        end
    },
    {
        text = "[:]",
        pos = 10,
        callback = function()
            modem.transmit(713, 0, "MatDoorClose")
        end
    }
}
local function reDraw()
    term.setBackgroundColor(theme.bg)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(theme.buttonColor)
    for i, v in ipairs(buttons) do
        term.setCursorPos(v["pos"], 1)
        write(v["text"])
    end
    term.setCursorPos(1, 2)
    for i, v in ipairs(floors) do
        if selectedFloor == v["id"] then
            term.setTextColor(theme.elFloorSel)
            print("> " .. v["name"])
        else
            term.setTextColor(theme.elFloor)
            print("| " .. v["name"])
        end
    end
end
modem.open(711)
reDraw()
while true do
    local seev
    if arcos then
        seev = table.pack(arcos.ev())
    else
        seev = table.pack(os.pullEvent())
    end
    if seev[1] == "modem_message" then
        selectedFloor = seev[5]+1
        reDraw()
    end
    if seev[1] == "mouse_click" then
        if seev[4] == 1 then
            for i, v in ipairs(buttons) do
                if seev[3] >= v["pos"] and seev[3] <= v["pos"]+#v["text"] then
                    v["callback"]()
                end
            end
        end
        if floors[seev[4]-1] then
            modem.transmit(476, 0, floors[seev[4]-1]["id"]-1)
            reDraw()
        end
    end
endlocal currentFloor = -1
local doorWaitFloor = 8
local queue = {}
local enderModem = dev.wmodem[1]
local wiredModem = dev.modem[1]
print("Hello!")
print("EnderModem: " .. tostring(enderModem))
print("WiredModem: " .. tostring(wiredModem))
wiredModem.open(712)
wiredModem.open(476)
enderModem.open(476)
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
local function changeFloor(floor, fakeit)
    enderModem.transmit(711, 712, floor-1)
    wiredModem.transmit(711, 712, floor-1)
    print("Actual moving: " .. tostring(floor))
    if floor == doorWaitFloor then
        wiredModem.transmit(713, 712, "TopDoorOpen")
    else
        wiredModem.transmit(713, 712, "TopDoorClose")
    end
    local port = math.random(1, 65534)
    wiredModem.transmit(713, port, (floor == 3 and "CCDoorOpen" or "CCDoorClose"))
    print(floor == 3 and "CCDoorOpen" or "CCDoorClose")
    if floor == doorWaitFloor then
        print("Waiting for door")
        local e
        repeat
            e = {arcos.ev("modem_message")}
        until e[3] == 712 and e[5] == "TopDoorAck"
    end
    if not fakeit then
        devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("front", true)
        sleep(0.1)
        devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("front", false)
        sleep(0.1)
        repeat
            local r = devices.get("redstoneIntegrator_" .. tostring(floor)).getInput("front")
            sleep(0.1)
        until r
    end
end
tasking.createTask("Queue task", function()
    while true do
        local newFloor = table.remove(queue, 1)
        if newFloor then
            print("Moving to floor: " .. tostring(newFloor))
            changeFloor(newFloor)
            print("Finished moving")
            if #queue > 0 then sleep(5) end
        else
            sleep(1)
        end
    end
end, 1, "root", term)
tasking.createTask("PDtask", function ()
    local pd = dev.playerDetector[1]
    while true do
        if pd.isPlayerInCoords({-2740, 66, 9016}, {-2738, 67, 9014}, "ChanesawWhatever") or pd.isPlayerInCoords({-2740, 66, 9016}, {-2738, 67, 9014}, "kkk8GJ") and currentFloor ~= 8 and not has_value(queue, 8)  then
            table.insert(queue, 8)
            print("Sending")
        end
        sleep(1)
    end
end, 1, "root", term, {})
while true do
    local event, side, channel, repChannel, msg, dist = arcos.ev("modem_message")
    if channel == 476 and not contains(queue, tonumber(msg+1)) then
        print("Queued floor " .. tonumber(msg + 1))
        table.insert(queue, tonumber(msg + 1))
    elseif channel == 477 and not contains(queue, tonumber(msg+1)) then
        print("Faking floor " .. tonumber(msg + 1))
        changeFloor(tonumber(msg+1), true)
    else
        print(channel)
    end
end
local mdm = devices.find("modem")
local currentFloor = -1
if not mdm then
    error("Modem not found")
end
local whitelistedPlayers = {
    "ChanesawWhatever",
    "emireri1498",
    "kkk8GJ"
}
mdm.open(711)
mdm.open(713)
while true do
    local _, side, channel, rc, msg, dist = arcos.ev("modem_message")
    if channel == 713 then
        print(msg)
        if msg == "TopDoorOpen" then
            rd.setO("back", true)
        elseif msg == "TopDoorClose" then
            rd.setO("back", false)
        end
    elseif channel == 711 then
        currentFloor = tonumber(msg)
    end
end
arc.fetch()
local w, h = term.getSize()
local pages = {}
local page = 2
local tobeinstalled = {}
local atobeinstalled = {}
local ipchildren = {}
local init = "shell.lua"
pages[1] = {
    ui.Label({
        label = "An error happened during setup!",
        x = 2, y = 2,
        textCol = col.red
    }),
    ui.Label({
        label = "<insert error>",
        x = 2, y = 4,
        textCol = col.magenta
    })
}
pages[2] = {}
table.insert(pages[2],
    ui.Label({
        label = "Welcome to ",
        x = 2,
        y = 2
    })
)
table.insert(pages[2],
    ui.Label({
        label = "cc",
        x = 13,
        y = 2,
        textCol = col.gray
    })
)
table.insert(pages[2],
    ui.Label({
        label = "arcos",
        x = 15,
        y = 2,
        textCol = col.cyan
    })
)
table.insert(pages[2],
    ui.Label({
        label = ui.Wrap("This wizard will guide you through the basic setup steps of arcos.", w-2),
        x = 2,
        y = 4,
        textCol = ui.UItheme.lightBg
    })
)
table.insert(pages[2],
    ui.Button({
        callBack = function ()
            ui.PageTransition(pages[2], pages[3], false, 1, true, term)
            page = 3
            return true
        end,
        label = " Next ",
        x = w-1-6,
        y = h-1
    })
)
pages[3] = {}
table.insert(pages[3], ui.Label({
    label = "Select a login screen.",
    x = 2,
    y = 2
}))
table.insert(pages[3], ui.Label({
    label = ui.Wrap("A login screen is the program you see right after the init system.", w-2),
    x = 2,
    y = 3,
    textCol = ui.UItheme.lightBg
}))
table.insert(pages[3], ui.ScrollPane({
    x = 2,
    y = 4+pages[3][2].getWH()[2],
    col = ui.UItheme.lighterBg,
    children = {
        ui.Button{
            label = "audm",
            callBack = function ()
                table.insert(tobeinstalled, "audm")
                init = "audm.lua"
                ui.PageTransition(pages[3], pages[4], false, 1, true, term)
                page = 4
                return true
            end,
            x = 1,
            y = 1
        },
        ui.Button{
            label = "Shell",
            callBack = function ()
                init = "shell.lua"
                ui.PageTransition(pages[3], pages[4], false, 1, true, term)
                page = 4
                return true
            end,
            x = 1,
            y = 1
        }
    },
    height = h - 4-pages[3][2].getWH()[2],
    width = w - 2,
    showScrollBtns = false
}))
local repo = arc.getRepo()
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
local function pushPackageWithDependencies(pkg)
    if repo[pkg] then
        for _, v in ipairs(repo[pkg].dependencies) do
            pushPackageWithDependencies(v)
        end
        if (not arc.isInstalled(pkg) or arc.getIdata(pkg)["vId"] < repo[pkg]["vId"]) and not has_value(atobeinstalled, pkg) then
            table.insert(atobeinstalled, pkg)
        end
    end
end
pages[4] = {
    ui.Label{
        label = "Set computer label",
        x = 2,
        y = 2
    },
    ui.Label{
        label = ui.Wrap("A computer label sets the computer's name in the inventory, and with mods like Jade also shows on the blockinfo.", w-2),
        x = 2,
        y = 3,
        textCol = ui.UItheme.lightBg
    },
    ui.TextInput{
        label = "arcos",
        x = 2,
        y = 3,
        width = w-2
    },
    ui.Button{
        label = "Done",
        callBack = function ()
            if pages[4][3].text ~= "" then
                arcos.setName(pages[4][3].text)
            end
            for index, value in ipairs(tobeinstalled) do
                pushPackageWithDependencies(value)
            end
            for index, value in ipairs(atobeinstalled) do
                table.insert(ipchildren, ui.Label{
                    label = value,
                    x = 1,
                    y = 1
                })
            end
            ui.PageTransition(pages[4], pages[5], false, 1, true, term)
            page = 5
            return true
        end,
        x = w-4,
        y = h-1
    }
}
pages[4][3].y = 4 + pages[4][2].getWH()[2]
pages[5] = {
    ui.Label{
        label = "Install packages",
        x = 2,
        y = 2
    },
    ui.ScrollPane{
        height = h - 6,
        width = w - 2,
        x = 2,
        y = 4,
        children = ipchildren,
        col = col.gray
    },
    ui.Button{
        label = " Install ",
        x = w-9,
        y = h-1,
        callBack = function ()
            term.setCursorPos(w-10, h-1)
            term.setBackgroundColor(col.gray)
            term.setTextColor(col.white)
            term.write("Installing")
            term.setBackgroundColor(col.black)
            term.setTextColor(col.white)
            local afi = {}
            for index, value in ipairs(atobeinstalled) do
                table.insert(afi, arc.install(value))
            end
            for index, value in ipairs(afi) do
                value()
            end
            local f, e = files.open("/services/enabled/login", "w")
            f.write("o " .. init)
            f.close()
            ui.PageTransition(pages[5], pages[6], false, 1, true, term)
            page = 6
            return true
        end
    }
}
pages[6] = {
    ui.Label{
        label = "All finished!",
        textCol = col.green,
        x = 2,
        y = 2
    },
    ui.Button{
        callBack = function ()
            arcos.reboot()
            return true
        end,
        label = " Reboot ",
        x = w-1-8,
        y = h-1
    }
}
local ls = true
while true do
    ls = ui.RenderLoop(pages[page], term, ls)
endlocal currentPowerUsage = 0
local f, e = files.open("/config/pmst", "r")
local titemcount = 0
local iup = 0
local monitor = devices.get("left")
local ed = dev.energyDetector[1]
local me = dev.meBridge[1]
local total = 0
local rd = true
if f then
    total = tonumber(f.read())
    f.close()
else
    total = 0
end
monitor.setTextScale(0.5)
local function formatNum(number)
    if not number then
        return 0, ""
    end
    local on = number
    local unitprefix = ""
    if on > 1000 then
        unitprefix = "k"
        on = on / 1000
    end
    if on > 1000 then
        unitprefix = "M"
        on = on / 1000
    end
    if on > 1000 then
        unitprefix = "G"
        on = on / 1000
    end
    return math.floor(on), unitprefix
end
local screen = {
    ui.Label({
        label = "Current energy usage",
        x = 2,
        y = 4,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total energy usage",
        x = 2,
        y = 6,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total ME item count",
        x = 2,
        y = 8,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Storage used",
        x = 2,
        y = 10,
        textCol = ui.UItheme.lighterBg
    })
}
local ceu = ui.Label({
    label = " 0fe/t ",
    x = 23,
    y = 4,
    col = ui.UItheme.lighterBg,
})
local teu = ui.Label({
    label = " 0fe ",
    x = 23,
    y = 6,
    col = ui.UItheme.lighterBg,
})
local tic = ui.Label({
    label = " 0 items ",
    x = 23,
    y = 8,
    col = ui.UItheme.lighterBg,
})
local uic = ui.Label({
    label = " 0% ",
    x = 23,
    y = 10,
    col = ui.UItheme.lighterBg,
})
local time = ui.Label({
    label = "00:00",
    x = ({ monitor.getSize() })[1]-1-5,
    y = 2,
})
local btn1 = ui.Button({
    label = " Lights on ",
    x = 2,
    y = 2,
    callBack = function ()
        dev.modem[1].transmit(713, 0, "MainLightsOn")
    end
})
local btn2 = ui.Button({
    label = " Lights off ",
    x = 14,
    y = 2,
    callBack = function ()
        dev.modem[1].transmit(713, 0, "MainLightsOff")
    end
})
local ls = false
local tid = arcos.startTimer(2.5)
while rd do
    local e
    ls, e = ui.RenderLoop({ screen[1], screen[2], screen[3], screen[4], time, teu, ceu, tic, uic, btn1, btn2}, monitor, ls)
    if e[1] == "timer" and e[2] == tid then
        local nf, err = files.open("/config/pmst", "w")
        if nf then
            nf.write(tostring(total))
            nf.close()
        end
        sleep(0.1)
        pcall(function (...)
            currentPowerUsage = ed.getTransferRate()
            total = total + ed.getTransferRate() * 10
            titemcount = me.getUsedItemStorage()
            iup = math.floor(me.getUsedItemStorage() / me.getTotalItemStorage()*100)
        end)
        local s = tutils.formatTime(arcos.time("ingame"))
        time.x = ({ monitor.getSize() })[1]-1-#s
        time.label = s
        local teufmt, teuext
        if total then
            teufmt, teuext = formatNum(total)
            teu.label = " " .. tostring(teufmt) .. teuext .. "fe "
        end
        if currentPowerUsage then
            teufmt, teuext = formatNum(currentPowerUsage)
            ceu.label = " " .. tostring(teufmt) .. teuext .. "fe/t "
        end
        if titemcount then
            teufmt, teuext = formatNum(titemcount)
            tic.label = " " .. tostring(teufmt) .. teuext .. " items "
        end
        uic.label = " " .. tostring(iup) .. "% "
        ls = true
        tid = arcos.startTimer(0.5)
    end
endarcos.r({}, "/apps/shell.lua")l|arcfix.lua
o oobe.luaBy using arcos, you automatically agree to these
terms. Agreement to this file is also required By
the stock arcos installer.
We (the arcos development team) may:
- Collect telemetry information.
Telemetry sample data:
For an error: 
    - Message: text must not be nil
    - File: /system/krnl.lua
    - Line: 2
For a kernel panic:
    - Debug: <all info from the whole stack of 
    debug.getinfo>
    - Message: Argument invalid
If there is no file at /temporary/telemetry, no 
telemetry has been collected and no telemetry will be
collected.
(every telemetry call checks for 
/temporary/telemetry, if it's not found it skips 
telemetry else it overrides it with the new
telemetry and sends the telemetry to the server)
Turning off telemetry:
To turn off telemetry, use gconfig or (if gconfig
doesn't have telemetry stuff) modify /config/aboot,
find the "telemetry" field and disable it{
    "theme": {
        "fg": "white",
        "bg": "black"
    },
    "skipPrompt": true,
    "defargs": "",
    "autoUpdate": true,
    "telemetry": false
}mirkokral/ccarcos{
    "path": [
        "/apps",
        "."
    ]
}arcos[
    {
        "name": "user",
        "password": "04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb"
    },
    {
        "name": "root",
        "password": "ce5ca673d13b36118d54a7cf13aeb0ca012383bf771e713421b4d1fd841f539a"
    }
]if arcos.getCurrentTask().user ~= "root" then
    write("[escalation] Enter root password: ")
    local pass = read("*")
    local f = tasking.changeUser("root", pass)
    if not f then
        error("Invalid password!")
    end
end
local args = { ... }
local username = args[1]
local password = "notset"
if #args == 1 then
    write("New Password: ")
    password = read("*")
elseif #args == 2 then
    password = args[2]
else
    error("Too little or too many arguments")
end
arcos.createUser(username, password)local arc = require("arc")
local files = require("files")
local col = require("col")
local args = { ... }
local cmd = table.remove(args, 1)
local repo = arc.getRepo()
local function getTBI(a, b)
    if not repo[a] then
        error("Package not found: " .. a)
    end
    for index, value in ipairs(repo[a]["dependencies"]) do
        getTBI(value, b)
    end
    if (not arc.isInstalled(a)) or arc.getIdata(a)["vId"] < repo[a]["vId"] then
        table.insert(b, a)
    end
end
if cmd == "fetch" then
    arc.fetch()
elseif cmd == "setrepo" then
    col.expect(2, args[1], "string")
    local fty, e = files.open("/config/arcrepo", "w")
    if fty then
        fty.write(args[1])
        fty.close()
        print("New repo: " .. args[1])
    else
        print("Failed to set new repo (check permissions)")
    end
elseif cmd == "install" then
    local tobeinstalled = {}
    local afterFunctions = {}
    for index, value in ipairs(args) do
        if not repo[value] then
            error("Package not found: " .. value)
        end
        getTBI(value, tobeinstalled)
    end
    if #tobeinstalled > 0 then
        term.setTextColor(col.lightGray)
        print("These packages will be installed:")
        print()
        term.setTextColor(col.green)
        print(table.concat(tobeinstalled, " "))
        term.setTextColor(col.white)
        print()
        print("Do you want to proceed? [y/n] ")
        local out = ({ arcos.ev("char") })[2]
        if out == "y" then
            for index, value in ipairs(tobeinstalled) do
                print("(" .. index .. "/" .. #tobeinstalled .. ") " .. value)
                table.insert(afterFunctions, arc.install(value))
            end
        else
            print("Installation Aborted.")
        end
        for index, value in ipairs(afterFunctions) do
            value()
        end
    end
    print("Done")
elseif cmd == "uninstall" then
    for index, value in ipairs(args) do
        if not arc.isInstalled(value) then
            error("Package not installed: " .. value)
        end
    end
    term.setTextColor(col.lightGray)
    print("These packages will be uninstalled:")
    print()
    term.setTextColor(col.red)
    print(table.concat(args, " "))
    print()
    term.setTextColor(col.white)
    write("Do you want to proceed? [y/n] ")
    local out = ({ arcos.ev("char") })[2]
    print()
    if out == "y" then
        for index, value in ipairs(args) do
            arc.uninstall(value)
        end
    else
        print("Unistallation Aborted.")
    end
elseif cmd == "update" then
    local toUpdate = arc.getUpdatable()
    print("These packages will be updated:")
    print()
    term.setTextColor(col.magenta)
    print(table.concat(toUpdate, " "))
    print()
    term.setTextColor(col.white)
    write("Do you want to proceed? [y/n] ")
    local out = ({ arcos.ev("char") })[2]
    print()
    if out == "y" then
        for index, value in ipairs(toUpdate) do
            arc.install(value)
        end
    else
        print("Update Aborted.")
    end
else
    printError("No command.")
endlocal files = require("files")
local f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end
local fop, e = files.open(fr, "r")
if fop then
    print(fop.read())
    fop.close()
else
    error(e)
endlocal files = require("files")
local path = ...
if not path then
    error("No directory specified!")
end
local p = files.resolve(path)[1]
if not files.exists(p) then
    error(p .. ": Specified directory does not exist")
end
if not files.dir(p) then
    error(p .. ": Specified path is not a directory.")
end
environ.workDir = plocal files = require("files")
local s, t = ...
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
local v, n = files.resolve(s)[1], files.resolve(t, true)[1]
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
files.c(v, n)local files = require("files")
local col = require("col")
write("\011f8Welcome to \011f2arcos\011f8!\n")
for index, value in ipairs(files.ls("/services/enabled")) do
    local servFile, err = files.open("/services/enabled/"..value, "r")
    if not servFile then
        printError(err)
        error()
    end
    write("\011f2Group \011f0" .. value .. "\n")
    for i in servFile.readLine do
        if i:sub(1, 1) ~= "#" then 
            arcos.log("Starting service: " .. i)
            local currentServiceDone = false
            local threadterm
            if i:sub(1,1) == "l" then
                local ttcp = {1, 1}
                threadterm = {
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
                    setCursorPos = function(cx, cy) ttcp = {cx, cy} end,
                    getCursorPos = function() return ttcp[1], ttcp[2] end,
                    scroll = function(sx) ttcp[2] = ttcp[2] - sx end,
                    clear = function() end,
                    isColor = function() return false end,
                    isColour = function() return false end,
                    getSize = function ()
                        return 51, 19
                    end
                }
            else
                threadterm = term
            end    
            tasking.createTask("Service: " .. i:sub(3), function()
                local ok, err = arcos.r({
                    ackFinish = function()
                        currentServiceDone = true
                    end
                }, "/services/" .. i:sub(3))
                if ok then
                    arcos.log("Service " .. i:sub(3) .. " ended.")
                else
                    arcos.log("Service " .. i:sub(3) .. " failed with error: " .. tostring(err))
                    write("\011f7[\011fe Failed \011f7 \011f0" .. i:sub(3) .. "\n")
                end
                sleep(1)
            end, 1, "root", threadterm)
            if i:sub(2,2) == "|" then
                repeat sleep(0.2)
                until currentServiceDone
            end
            write("| \011f7[\011fd OK \011f7] \011f0" .. require("tutils").split(i:sub(3), ".")[1] .. "\n")
            arcos.log("Started")
        end
    end
end
tasking.setTaskPaused(arcos.getCurrentTask()["pid"], true)
coroutine.yield()
local klb = arcos.getKernelLogBuffer()
print(klb)local files = require("files")
local col = require("col")
local path = ... or environ.workDir
local f = files.resolve(path)
for _, fp in ipairs(f) do
    if files.exists(fp) then
        if files.dir(fp) then
            for _, i in ipairs(files.ls(fp)) do
                if files.dir(fp) then
                    term.setTextColor(col.green)
                else
                    term.setTextColor(col.white)
                end
                write(i .. " ")
            end
            write("\n")
        else
            printError(fp .. " is not a directory.")
        end
    else
        printError(fp .. " does not exist on this disk/filesystem.")
    end
endlocal files = require("files")
local f = ...
if not f then
    error("No file specified")
end
local rf = files.resolve(f, true)[1]
files.mkDir(rf)local files = require('files')
local s, t = ...
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end
local v, n = files.resolve(s)[1], files.resolve(t, true)[1]
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end
files.m(v, n)local files = require("files")
local f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end
files.rm(fr)if arcos.getCurrentTask().user ~= "root" then
    write("[escalation] Enter root password: ")
    local pass = read("*")
    local f = tasking.changeUser("root", pass)
    if not f then
        error("Invalid password!")
    end
end
local args = { ... }
if #args ~= 1 then
    error("Too many or too few args.")
end
local u = arcos.deleteUser(args[1])
if not u then
    print("Failed removing user.")
endlocal col = require("col")
local files = require("files")
local tutils = require("tutils")
local arc = require("arc")
term.setTextColor(col.blue)
print(arcos.version())
term.setTextColor(col.gray)
arc.fetch()
if #arc.getUpdatable() > 0 then
    write(#arc.getUpdatable() .. " updates are availabe. Use ")
    term.setTextColor(col.magenta)
    write("arc update")
    term.setTextColor(col.gray)
    print(" to update.")
end
local secRisks = {}
if arcos.validateUser("root", "toor") then
    table.insert(secRisks, "The root account password has not yet been changed.")
end
if arcos.validateUser("user", "user") then
    table.insert(secRisks, "The user account password has not yet been changed.")
end
if #secRisks > 0 then
    print()
    term.setTextColor(col.red)
    print("Security risks")
    term.setTextColor(col.lightGray)
    print("- " .. table.concat(secRisks, "\n- "))
end
print()
local confile = files.open("/config/arcshell", "r")
local conf = {}
if confile then
    conf = tutils.dJSON(confile.read())
    confile.close()
else
    return
end
local luaGlobal = setmetatable({}, {__index = _G})
if not environ.workDir then environ.workDir = "/" end
local function run(a1, ...) 
    local cmd = nil
    if not a1 or a1 == "" then
        return true
    end
    if a1:sub(1, 1) == "/" then
        if files.exists(a1) then
            cmd = a1
        else
            printError("File not found")
            return false
        end
    elseif a1:sub(1, 2) == "./" then
        if files.resolve(a1, false)[1] then
            cmd = files.resolve(a1, false)[1]
        else
            printError("File not found")
            return false
        end
    else
        for i, v in ipairs(conf["path"]) do
            for i, s in ipairs(files.ls(v)) do
                local t = s
                if t:sub(#t-3, #t) == ".lua" then
                    t = t:sub(1, #t-4)
                end
                if t == a1 then
                    cmd = v .. "/" .. s
                end
            end
        end
    end
    if cmd == nil then
        local cq = tutils.join({ a1, ... }, " ")
        local chunkl, err = load(cq, "eval", nil, luaGlobal)
        local chunklb, errb = load("return " .. cq, "eval", nil, luaGlobal)
        if chunklb then
            chunkl = chunklb
            err = errb
        else
            print(errb)
        end
        if(err and err:sub(20, 36) == "syntax error near") then
            err = "Command not found."
        end
        if not chunkl then
            printError(err)
            return false
        end
        local ok, err = pcall(chunkl)
        if not ok then
            printError(err)
        else
            print(tutils.s(err))
        end
        return ok
    end
    local ok, err = arcos.r({}, cmd, ...)
    if not ok then
        printError(err)
    end
    return ok, err
end
local history = {}
while true
do
    local cTask = arcos.getCurrentTask()
    if cTask.user == "root" then
        term.setTextColor(col.red)
    else
        term.setTextColor(col.green)
    end
    write(cTask.user)
    local a, err = pcall(arcos.getName)
    if a then
        term.setTextColor(col.gray)
        write("@")
        term.setTextColor(col.magenta)
        if not pcall(write, tostring(err)) then
            write("(none)")
        end
    end
    write(" ")
    if environ.envType then
        term.setTextColor(col.yellow)
        write("(" .. tostring(environ.envType) .. ") ")
    end
    term.setTextColor(col.gray) 
    write(environ.workDir)
    write(" ")
    write(arcos.getCurrentTask().user == "root" and "# " or "$ ")
    term.setTextColor(col.white)
    local cmd = read(nil, history)
    table.insert(history, cmd)
    local r, k = pcall(run, table.unpack(tutils.split(cmd, " ")))
    if not r then
        pcall(printError, k)
    end
endlocal ui = require("ui")
local col = require("col")
if term then
    local monitors = dev.monitor
    local selecting = true
    local terma = term
    term.setPaletteColor(col.lightGray, 171/255, 171/255, 171/255)
    local selection = {
        ui.Button({
            label = "Local",
            x = 1,
            y = 1,
            callBack = function ()
                terma = term
                selecting = false
                return false
            end,
            col = ui.UItheme.lighterBg,
            textCol = ui.UItheme.fg
        }),
    }
    for _, i in ipairs(monitors) do
        table.insert(selection, 
            ui.Button({
                label = i.origName,
                callBack = function ()
                    terma = i
                    selecting = false
                    return false
                end,
                x = 1,
                y = 1,
                col = ui.UItheme.lighterBg,
                textCol = ui.UItheme.fg
            })
        )
    end
    local ttw, tth = terma.getSize()
    local monSelPage = {
        ui.Label({
            label = "Select an Output",
            x=2,
            y=2
        }),
        ui.ScrollPane({
            children = selection,
            height = tth-4,
            width = ttw-2,
            x = 2,
            y = 4,
            col = ui.UItheme.lighterBg,
            showScrollBtns = false,
        })
    }
    ui.RenderLoop(monSelPage, term, true)
    while selecting do
        if term then
            ui.RenderLoop(monSelPage, term)
        end
    end
    local counter = 0
    local ox, oy = 0,0 
    local tw, th = terma.getSize()
    local pages = {}
    local page = 1
    pages[1] = {
        ui.Label({
            label = "Counter: "..counter,
            x = 1,
            y = 1
        }),
        ui.Label({
            label = "I'm green!",
            x = 1,
            y = 2,
            textCol = col.green
        }),
        ui.Label({
            label = "I'm light blue on the background!",
            x = 1,
            y = 3,
            col = col.lightBlue
        }),
        ui.Label({
            label = "I'm multiline!\nSee?",
            x = 1,
            y = 4,
            col = col.red,
            textCol = col.white
        }),
        ui.Label({
            x=13,
            y=1,
            label = "No key yet pressed"
        }),
    }
    table.insert(
        pages[1],
        ui.Button(
            {
                callBack = function ()
                    ui.PageTransition(pages[1], pages[2], false, 1, true, terma)
                    page = 2
                    return true
                end,
                x = tw - 5,
                y = th - 1,
                label = "Next",
            }
        )
    )
    local btn = ui.Button({
        callBack = function ()
            counter = counter + 1
            pages[1][1].label = "Counter: " .. counter
            return true
        end,
        label = "Increase counter",
        x = 1,
        y = 7,
        col = ui.UItheme.buttonBg,
        textCol = ui.UItheme.buttonFg
    })
    table.insert(pages[1], btn)
    table.insert(pages[1],
    ui.Label({
        label = "Button width: " .. tostring(btn.getWH()[1]) .. ", height: " .. tostring(btn.getWH()[2]),
        x = 1,
        y = 8
    })
    )
    local lbls = {}
    for i = 1, 40, 1 do
        table.insert(lbls, ui.Label({
            label = "Hello world: " .. tostring(i),
            x = 1,
            y = 1
        }))
    end
    local alignObject = ui.Align(1, 1, ui.Label{x=0, y=0, label="Center"}, {0.5, 0.5})
    print(tostring(alignObject))
    pages[2] = {
        ui.Label({
            label = "Level!",
            x = 3,
            y = 7,
        }),
        ui.Label({
            label = "Level2!",
            x = 3,
            y = 17,
        }),
        ui.Label({
            label = "XLevel!",
            x = 20,
            y = 2,
        }),
        ui.Label({
            label = "XLevel2!",
            x = 40,
            y = 2,
        }),
        ui.ScrollPane({
            width= 20,
            height= 10,
            x = 20,
            y = 7,
            children = lbls,
            col = col.gray,
            showScrollBtns = true
        }),
        alignObject
    }
    table.insert(
        pages[2],
        ui.Button(
            {
                callBack = function ()
                    ui.PageTransition(pages[2], pages[1], false, 1, false, terma)
                    page = 1
                    return true
                end,
                x = tw - 5,
                y = th - 1,
                label = "Back",
                col = col.gray,
                textCol = col.white
            }
        )
    )
    if terma == term then
        ui.PageTransition(monSelPage, pages[page], false, 1, true, terma)
    else
        ui.PageTransition(monSelPage, {
            ui.Label{
                label = "Test is being displayed on monitor." .. tostring(alignObject),
                x = 2,
                y = 2
            }
        }, false, 1, true, term)
    end
    local ls = false
    ui.RenderLoop(pages[page], terma, true)
    while true do
        if terma then
            ls = ui.RenderLoop(pages[page], terma, ls)
            pages[2][2].label = tostring(pages[2][5].scroll)
        end
    end
end
term.clear()
term.setCursorPos(1, 1)arcos.shutdown()arcos.reboot()local x = require("cellui")
local runner = x["Runner"].new(x["typedefs"].CCTerminal.new(term),x["ScrollContainer"].new({}),nil)
local tests = {
}
runner:run()