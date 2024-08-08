if arcos then return end
local UIthemedefs = {
}
UIthemedefs[colors.white] = {236, 239, 244}
UIthemedefs[colors.orange] = {0, 0, 0}
UIthemedefs[colors.magenta] = {180, 142, 173}
UIthemedefs[colors.lightBlue] = {0, 0, 0}
UIthemedefs[colors.yellow] = {235, 203, 139}
UIthemedefs[colors.lime] = {163, 190, 140}
UIthemedefs[colors.pink] = {0, 0, 0}
UIthemedefs[colors.gray] = {76, 86, 106}
UIthemedefs[colors.lightGray] = {216, 222, 233}
UIthemedefs[colors.cyan] = {136, 192, 208}
UIthemedefs[colors.purple] = {0, 0, 0}
UIthemedefs[colors.blue] = {129, 161, 193}
UIthemedefs[colors.brown] = {0, 0, 0}
UIthemedefs[colors.green] = {163, 190, 140}
UIthemedefs[colors.red] = {191, 97, 106}
UIthemedefs[colors.black] = {59, 66, 82}
for index, value in pairs(UIthemedefs) do
    term.setPaletteColor(index, value[1]/255, value[2]/255, value[3]/255) 
end
function _G.utd() end
local live = ({ ... })[1] == "live"
if not live then
  local f = http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
  if f then
    local branch = textutils.unserialiseJSON(f.readAll())["sha"]
    local cur = files.open("/system/rel", "r")
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
_G.__LEGACY = {}
for key, value in pairs(_G) do
  __LEGACY[key] = value
end
if live then
  __LEGACY.files = {
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
local keptAPIs = { utd = true, printError = true, require = true, print = true, write = true, read = true, keys = true, __LEGACY = true, bit32 = true, bit = true, ccemux = true, config = true, coroutine = true, debug = true, fs = true, http = true, mounter = true, os = true, periphemu = true, peripheral = true, redstone = true, rs = true, term = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
local t = {}
for k in pairs(_G) do if not keptAPIs[k] then table.insert(t, k) end end
for _, k in ipairs(t) do _G[k] = nil end
local native = _G.term.native()
for _, method in ipairs { "nativePaletteColor", "nativePaletteColour", "screenshot" } do native[method] = _G.term[method] end
_G.term = native
_G.http.checkURL = _G.http.checkURLAsync
_G.http.websocket = _G.http.websocketAsync
if _G.commands then _G.commands = _G.commands.native end
if _G.turtle then _G.turtle.native, _G.turtle.craft = nil end
local delete = { os = { "version", "pullEventRaw", "pullEvent", "run", "loadAPI", "unloadAPI", "sleep" }, http = { "get", "post", "put", "delete", "patch", "options", "head", "trace", "listen", "checkURLAsync", "websocketAsync" }, fs = { "complete", "isDriveRoot" } }
for k, v in pairs(delete) do for _, a in ipairs(v) do _G[k][a] = nil end end
_G.term.redirect = function() end
_G.error = function() end
setfenv(utd, __LEGACY)
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
    local f = __LEGACY.files.open("/system/bootloader.lua", "r")
    local ok, err = pcall(load(f.readAll(), "Bootloader", nil, _G))
    print(err)
    print("Press any key to continue")
    __LEGACY.os.pullEvent("key")
    __LEGACY.os.reboot()
  end
end
coroutine.yield()
