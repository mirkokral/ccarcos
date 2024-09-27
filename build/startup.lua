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
    local word = tostring(args[i])
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
    local keptAPIs = { utd = true, printError = true, require = true, print = true, write = true, read = true, keys = true, __LEGACY = true, bit32 = true, periphemu=true, bit = true, coroutine = true, debug = true, term = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
    local t = {}
    for k in pairs(oldug) do if not keptAPIs[k] then table.insert(t, k) end end
    for _, k in ipairs(t) do oldug[k] = nil end
    oldug["_G"] = oldug
    local f = __LEGACY.files.open("/system/bootloader.lua", "r")
    local ok, err = pcall(load(f.readAll(), "Bootloader", nil, oldug))
    print(err)
    while true do
      coroutine.yield()
    end
  end
end
coroutine.yield()
