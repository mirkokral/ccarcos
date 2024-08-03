local UIthemedefs = {
}
UIthemedefs[col.white] = {236, 239, 244}
UIthemedefs[col.orange] = {0, 0, 0}
UIthemedefs[col.magenta] = {180, 142, 173}
UIthemedefs[col.lightBlue] = {0, 0, 0}
UIthemedefs[col.yellow] = {235, 203, 139}
UIthemedefs[col.lime] = {163, 190, 140}
UIthemedefs[col.pink] = {0, 0, 0}
UIthemedefs[col.gray] = {76, 86, 106}
UIthemedefs[col.lightGray] = {216, 222, 233}
UIthemedefs[col.cyan] = {136, 192, 208}
UIthemedefs[col.purple] = {0, 0, 0}
UIthemedefs[col.blue] = {129, 161, 193}
UIthemedefs[col.brown] = {0, 0, 0}
UIthemedefs[col.green] = {163, 190, 140}
UIthemedefs[col.red] = {191, 97, 106}
UIthemedefs[col.black] = {59, 66, 82}
for index, value in pairs(UIthemedefs) do
    term.setPaletteColor(index, value[1]/255, value[2]/255, value[3]/255) 
end
local live = ({ ... })[1] == "live"
if not live then
  local f = http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
  if f then
    local branch = textutils.unserialiseJSON(f.readAll())["sha"]
    local cur = fs.open("/system/rel", "r")
    if cur and cur.readAll() ~= branch then
      shell.run("/system/installer.lua")
    end
    f.close()
  else
    print("Update failed")
  end
end
local oldprr = os.pullEventRaw
local oldpe = os.pullEvent
local oldtr = term.redirect
local oldst = os.shutdown
local olderr = error
_G.__LEGACY = {
  colors = colors,
  colours = colours,
  commands = commands,
  disk = disk,
  fs = fs,
  ofs = fs,
  gps = gps,
  help = help,
  http = http,
  io = io,
  keys = keys,
  os = os,
  paintutils = paintutils,
  parallel = parallel,
  peripheral = peripheral,
  pocket = pocket,
  rednet = rednet,
  redstone = redstone,
  settings = settings,
  shell = shell,
  term = term,
  textutils = textutils,
  turtle = turtle,
  vector = vector,
  window = window,
  require = require
}
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
    end
  }
end
local keptAPIs = { printError = true, require = true, print = true, write = true, read = true, keys = true, __LEGACY = true, bit32 = true, bit = true, ccemux = true, config = true, coroutine = true, debug = true, fs = true, http = true, mounter = true, os = true, periphemu = true, peripheral = true, redstone = true, rs = true, term = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
local t = {}
for k in pairs(_G) do if not keptAPIs[k] then table.insert(t, k) end end
for _, k in ipairs(t) do _G[k] = nil end
local native = _G.term.native()
for _, method in ipairs { "nativePaletteColor", "nativePaletteColour", "screenshot" } do native[method] = _G.term
  [method] end
_G.term = native
_G.http.checkURL = _G.http.checkURLAsync
_G.http.websocket = _G.http.websocketAsync
if _G.commands then _G.commands = _G.commands.native end
if _G.turtle then _G.turtle.native, _G.turtle.craft = nil end
local delete = { os = { "version", "pullEventRaw", "pullEvent", "run", "loadAPI", "unloadAPI", "sleep" }, http = { "get", "post", "put", "delete", "patch", "options", "head", "trace", "listen", "checkURLAsync", "websocketAsync" }, fs = { "complete", "isDriveRoot" } }
for k, v in pairs(delete) do for _, a in ipairs(v) do _G[k][a] = nil end end
_G.term.redirect = function() end
_G.error = function() end
function _G.term.native()
  _G.error = olderr
  _G.term.redirect = oldtr
  _G.os.pullEventRaw = oldprr
  _G.os.pullEvent = oldpe
  print("Successful escape")
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(__LEGACY.colors.white)
  function os.shutdown()
    os.shutdown = oldst
    local oldug = {}
    for k, v in pairs(_G) do
      oldug[k] = v
    end
    oldug["colors"] = nil
    oldug["colours"] = nil
    oldug["commands"] = nil
    oldug["disk"] = nil
    oldug["fs"] = nil
    oldug["gps"] = nil
    oldug["help"] = nil
    oldug["http"] = nil
    oldug["io"] = nil
    oldug["keys"] = nil
    oldug["os"] = nil
    oldug["paintutils"] = nil
    oldug["parallel"] = nil
    oldug["peripheral"] = nil
    oldug["pocket"] = nil
    oldug["rednet"] = nil
    oldug["redstone"] = nil
    oldug["settings"] = nil
    oldug["shell"] = nil
    oldug["term"] = nil
    oldug["textutils"] = nil
    oldug["turtle"] = nil
    oldug["vector"] = nil
    oldug["window"] = nil
    oldug["require"] = __LEGACY.require
    local f = __LEGACY.fs.open("/system/bootloader.lua", "r")
    local ok, err = pcall(load(f.readAll(), "Bootloader", nil, oldug))
    print(err)
    print("Press any key to continue")
    __LEGACY.os.pullEvent("key")
    __LEGACY.os.reboot()
  end
  local oldug = {}
  for k, v in pairs(_G) do
    oldug[k] = v
  end
end
coroutine.yield()
