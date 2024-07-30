local f = http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
if f then
  local branch = textutils.unserialiseJSON(f.readAll())["sha"]
  local cur = fs.open("/system/rel", "r")
  if cur and cur.readAll() ~= branch then
    loadfile("/system/installer.lua")()
  end
  f.close() 
else
  print("Update failed")
end
local oldtr = term.redirect
local oldprr = os.pullEventRaw
local oldst = os.shutdown
local olderr = error
_G.term.redirect = function() end
_G.error = function() end
function _G.term.native()
    _G.error = olderr
    _G.term.redirect = oldtr
    _G.os.pullEventRaw = oldprr
    function _G.os.shutdown() 
        print("Successful escape")
        _G.os.shutdown = oldst
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
        local oldug = {}
        _G.__LEGACY = {
            colors = colors,
            colours = colours,
            commands = commands,
            disk = disk,
            fs = fs,
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
            window = window
        }
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
        local ok, err = pcall(loadfile("/system/bootloader.lua", nil, oldug))
        oldug["__LEGACY"].term.write(err)
        sleep(50)
    end
end
_G.os.pullEventRaw = nil
coroutine.yield()