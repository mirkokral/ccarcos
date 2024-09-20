|/apps|-1|
|/config|-1|
|/services|-1|
|/system|-1|
|/temporary|-1|
|/user|-1|
|/apis|-1|
|/data|-1|
|config/apps|-1|
|config/arc|-1|
|services/enabled|-1|
|system/apis|-1|
|/startup.lua|0|
|/objList.txt|6832|
|apps/adduser.lua|8031|
|apps/arc.lua|8545|
|apps/cat.lua|11439|
|apps/cd.lua|11639|
|apps/cp.lua|11937|
|apps/init.lua|12175|
|apps/kmsg.lua|15048|
|apps/ls.lua|15097|
|apps/mkdir.lua|15712|
|apps/mv.lua|15827|
|apps/rm.lua|16065|
|apps/rmuser.lua|16216|
|apps/shell.lua|16620|
|apps/uitest.lua|19292|
|apps/clear.lua|24617|
|apps/shutdown.lua|24653|
|apps/reboot.lua|24669|
|config/aboot|24683|
|config/arcrepo|24843|
|config/arcshell|24860|
|config/hostname|24912|
|config/passwd|24917|
|config/arc/base.meta.json|25167|
|config/arc/base.uninstallIndex|25435|
|services/arcfix.lua|26634|
|services/elevator.lua|26719|
|services/elevatorSrv.lua|29010|
|services/elevatorStep.lua|32066|
|services/oobe.lua|32658|
|services/pms.lua|38403|
|services/shell.lua|41983|
|services/enabled/9 arcfix|42013|
|services/enabled/login|42026|
|system/bootloader.lua|42036|
|system/devinstaller.lua|42985|
|system/installer.lua|47146|
|system/krnl.lua|51592|
|system/liveinst.lua|67851|
|system/rel|70103|
|system/apis/arc.lua|70109|
|system/apis/col.lua|82010|
|system/apis/files.lua|86083|
|system/apis/hashing.lua|94717|
|system/apis/rd.lua|99341|
|system/apis/tutils.lua|100345|
|system/apis/ui.lua|101316|
|system/apis/window.lua|122220|
|data/PRIVACY.txt|137282|
--ENDTABLE
if arcos then return end
term.clear()
local UIthemedefs = {
}
local ghToken = "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" -- I know this is stupid but it works
local headers = {
}
UIthemedefs[colors.white] = { 236, 239, 244 }
UIthemedefs[colors.orange] = { 0, 0, 0 }
UIthemedefs[colors.magenta] = { 180, 142, 173 }
UIthemedefs[colors.lightBlue] = { 0, 0, 0 }
UIthemedefs[colors.yellow] = { 235, 203, 139 }
UIthemedefs[colors.lime] = { 163, 190, 140 }
UIthemedefs[colors.pink] = { 0, 0, 0 }
UIthemedefs[colors.gray] = { 76, 86, 106 }
UIthemedefs[colors.lightGray] = { 216, 222, 233 }
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
  if not configFile then configFile = {autoUpdate = true} end -- Fallback
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
local oldst = os.shutdown
local olderr = error
_G.__LEGACY = {}
for key, value in pairs(_G) do
  __LEGACY[key] = value
end
__LEGACY.ofs = __LEGACY.fs
__LEGACY.files = __LEGACY.fs
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
d>apps
d>config
d>services
d>system
d>temporary
d>user
d>apis
d>data
d>config/apps
d>config/arc
d>services/enabled
d>system/apis
f>startup.lua
f>apps/adduser.lua
f>apps/arc.lua
f>apps/cat.lua
f>apps/cd.lua
f>apps/cp.lua
f>apps/init.lua
f>apps/kmsg.lua
f>apps/ls.lua
f>apps/mkdir.lua
f>apps/mv.lua
f>apps/rm.lua
f>apps/rmuser.lua
f>apps/shell.lua
f>apps/uitest.lua
f>apps/clear.lua
f>apps/shutdown.lua
f>apps/reboot.lua
f>config/aboot
f>config/arcrepo
f>config/arcshell
f>config/hostname
f>config/passwd
f>config/arc/base.meta.json
f>config/arc/base.uninstallIndex
f>services/arcfix.lua
f>services/elevator.lua
f>services/elevatorSrv.lua
f>services/elevatorStep.lua
f>services/oobe.lua
f>services/pms.lua
f>services/shell.lua
f>services/enabled/9 arcfix
f>services/enabled/login
f>system/bootloader.lua
f>system/devinstaller.lua
f>system/installer.lua
f>system/krnl.lua
f>system/liveinst.lua
f>system/rel
f>system/apis/arc.lua
f>system/apis/col.lua
f>system/apis/files.lua
f>system/apis/hashing.lua
f>system/apis/rd.lua
f>system/apis/tutils.lua
f>system/apis/ui.lua
f>system/apis/window.lua
f>data/PRIVACY.txt
r>services/enabled/login
r>config/passwd
r>config/aboot
r>config/arcshell
r>config/arcrepoif arcos.getCurrentTask().user ~= "root" then
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
arcos.createUser(username, password)local args = { ... }
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
    local fty = files.open("/config/arcrepo", "w")
    fty.write(args[1])
    fty.close()
    print("New repo: " .. args[1])
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
endlocal f = ...
if not f then error("No file specified!") end
local fr = files.resolve(f)[1]
if not fr then error("File does not exist") end
local fop = files.open(fr, "r")
print(fop.read())
fop.close()local path = ...
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
environ.workDir = plocal s, t = ...
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
local v, n = files.resolve(s)[1], files.resolve(t, true)[1]
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
files.c(v, n)for index, value in ipairs(files.ls("/services/enabled")) do
    local servFile, err = files.open("/services/enabled/"..value, "r")
    if not servFile then
        printError(err)
        error()
    end
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
                end
                sleep(1)
            end, 1, "root", threadterm)
            if i:sub(2,2) == "|" then
                repeat sleep(0.2)
                until currentServiceDone
            end
            arcos.log("Started")
        end
    end
end
tasking.setTaskPaused(arcos.getCurrentTask()["pid"], true)
coroutine.yield()
local klb = arcos.getKernelLogBuffer()
print(klb)local path = ... or environ.workDir
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
endlocal f = ...
if not f then
    error("No file specified")
end
local rf = files.resolve(f, true)[1]
files.mkDir(rf)local s, t = ...
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end
local v, n = files.resolve(s)[1], files.resolve(t, true)[1]
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end
files.m(v, n)local f = ...
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
endterm.setTextColor(col.blue)
print(arcos.version())
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
endif term then
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
term.setCursorPos(1, 1)arcos.shutdown()arcos.reboot(){
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
]{
    "friendlyName": "arcos itself",
    "description": "The package that has all the arcos files",
    "owner": "arcos Development Team and contributors",
    "version": "24.08.1",                   
    "vId": 0,
    "dependencies": [],
    "isIndependable": true
}d>apps
d>config
d>services
d>system
d>temporary
d>user
d>apis
d>data
d>config/apps
d>config/arc
d>services/enabled
d>system/apis
f>startup.lua
f>apps/adduser.lua
f>apps/arc.lua
f>apps/cat.lua
f>apps/cd.lua
f>apps/cp.lua
f>apps/init.lua
f>apps/kmsg.lua
f>apps/ls.lua
f>apps/mkdir.lua
f>apps/mv.lua
f>apps/rm.lua
f>apps/rmuser.lua
f>apps/shell.lua
f>apps/uitest.lua
f>apps/clear.lua
f>apps/shutdown.lua
f>apps/reboot.lua
f>config/aboot
f>config/arcrepo
f>config/arcshell
f>config/hostname
f>config/passwd
f>config/arc/base.meta.json
f>config/arc/base.uninstallIndex
f>services/arcfix.lua
f>services/elevator.lua
f>services/elevatorSrv.lua
f>services/elevatorStep.lua
f>services/oobe.lua
f>services/pms.lua
f>services/shell.lua
f>services/enabled/9 arcfix
f>services/enabled/login
f>system/bootloader.lua
f>system/devinstaller.lua
f>system/installer.lua
f>system/krnl.lua
f>system/liveinst.lua
f>system/rel
f>system/apis/arc.lua
f>system/apis/col.lua
f>system/apis/files.lua
f>system/apis/hashing.lua
f>system/apis/rd.lua
f>system/apis/tutils.lua
f>system/apis/ui.lua
f>system/apis/window.lua
f>data/PRIVACY.txt
f>services/enabled/login
f>config/passwd
f>config/aboot
f>config/arcshell
f>config/arcrepoif arcos.getCurrentTask().user ~= "root" then
    error("Not root!")
end
ackFinish()
local modem
local selectedFloor = -1
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
o oobe.luafunction mysplit(inputstr, sep)
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
term.setPaletteColor(colors.white, 236/255, 239/255, 244/255)
term.setPaletteColor(colors.orange, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.magenta, 180/255, 142/255, 173/255)
term.setPaletteColor(colors.lightBlue, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.yellow, 235/255, 203/255, 139/255)
term.setPaletteColor(colors.lime, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.pink, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.gray, 174/255, 179/255, 187/255)
term.setPaletteColor(colors.lightGray, 216/255, 222/255, 233/255)
term.setPaletteColor(colors.cyan, 136/255, 192/255, 208/255)
term.setPaletteColor(colors.purple, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.blue, 129/255, 161/255, 193/255)
term.setPaletteColor(colors.brown, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.green, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.red, 191/255, 97/255, 106/255)
term.setPaletteColor(colors.black, 59/255, 66/255, 82/255)
local loaderLoaded = 0
function drawLoader()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(math.floor(w/2), h/2-2)
    term.setBackgroundColor(loaderLoaded == 0 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2-2)
    term.setBackgroundColor(loaderLoaded == 1 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2)
    term.setBackgroundColor(loaderLoaded == 2 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2+2)
    term.setBackgroundColor(loaderLoaded == 3 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2), h/2+2)
    term.setBackgroundColor(loaderLoaded == 4 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2+2)
    term.setBackgroundColor(loaderLoaded == 5 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2)
    term.setBackgroundColor(loaderLoaded == 6 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2-2)
    term.setBackgroundColor(loaderLoaded == 7 and colors.white or colors.gray)
    term.write("  ")
    loaderLoaded = (loaderLoaded + 1) % 8
end
write("GitHub repo (for example: mirkokral/ccarcos) > ")
local repo = read()
drawLoader()
if not fs.exists("/system/krnl.lua") then
    for _, i in ipairs(fs.list("/")) do
        if not i == "rom" then fs.delete(i) end
    end
else
    fs.delete("/system")
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
local fr = http.get("https://api.github.com/repos/".. repo .."/commits/main")
local branch
if fr then
    branch = textutils.unserialiseJSON(fr.readAll())["sha"]
else
    write(">")
    branch = read()
end
file = http.get("https://raw.githubusercontent.com/"..repo.."/"..branch.."/build/objList.txt")
cont = file.readAll()
file.close()
for _,i in ipairs(strsplit(cont, "\n")) do
    drawLoader()
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        fs.makeDir("/" .. filename)
    end
    if action == "f" then
        fs.delete("/" .. filename)
        f = fs.open(filename, "w")
        hf = http.get("https://raw.githubusercontent.com/"..repo.."/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not fs.exists("/" .. filename) then
        f = fs.open(filename, "w")
        hf = http.get("https://raw.githubusercontent.com/"..repo.."/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
end
f = fs.open("/system/rel", "w")
f.write(branch)
f.close()
f = fs.open("/config/aboot", "r")
local a = textutils.unserialiseJSON(f.readAll())
f.close()
f = fs.open("/config/aboot", "w")
a["autoUpdate"] = false
f.write(textutils.serializeJSON(a))
f.close()
os.reboot()term.setPaletteColor(colors.white, 236/255, 239/255, 244/255)
term.setPaletteColor(colors.orange, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.magenta, 180/255, 142/255, 173/255)
term.setPaletteColor(colors.lightBlue, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.yellow, 235/255, 203/255, 139/255)
term.setPaletteColor(colors.lime, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.pink, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.gray, 174/255, 179/255, 187/255)
term.setPaletteColor(colors.lightGray, 216/255, 222/255, 233/255)
term.setPaletteColor(colors.cyan, 136/255, 192/255, 208/255)
term.setPaletteColor(colors.purple, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.blue, 129/255, 161/255, 193/255)
term.setPaletteColor(colors.brown, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.green, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.red, 191/255, 97/255, 106/255)
term.setPaletteColor(colors.black, 59/255, 66/255, 82/255)
local ghToken = "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" -- I know this is stupid but it works
local loaderLoaded = 0
function drawLoader()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(math.floor(w/2), h/2-2)
    term.setBackgroundColor(loaderLoaded == 0 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2-2)
    term.setBackgroundColor(loaderLoaded == 1 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2)
    term.setBackgroundColor(loaderLoaded == 2 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)+3, h/2+2)
    term.setBackgroundColor(loaderLoaded == 3 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2), h/2+2)
    term.setBackgroundColor(loaderLoaded == 4 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2+2)
    term.setBackgroundColor(loaderLoaded == 5 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2)
    term.setBackgroundColor(loaderLoaded == 6 and colors.white or colors.gray)
    term.write("  ")
    term.setCursorPos(math.floor(w/2)-3, h/2-2)
    term.setBackgroundColor(loaderLoaded == 7 and colors.white or colors.gray)
    term.write("  ")
    loaderLoaded = (loaderLoaded + 1) % 8
end
drawLoader()
if not fs.exists("/system/krnl.lua") then
    for _, i in ipairs(fs.list("/")) do
        if i ~= "rom" and i:sub(1, 4) ~= "disk"  then fs.delete(i) end
    end
else
    fs.delete("/system")
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
local fr, e = http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main", {
})
local branch
if fr then
    branch = textutils.unserialiseJSON(fr.readAll())["sha"]
else
    term.clear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clear()
    print("Automatically fetching the latest commit failed because: " .. e .. ". Go to arcos, get latest commit hash and paste it in here.")
    write(">")
    branch = read()
end
file = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/"..branch.."/build/objList.txt")
cont = file.readAll()
file.close()
for _,i in ipairs(strsplit(cont, "\n")) do
    drawLoader()
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        fs.makeDir("/" .. filename)
    end
    if action == "f" then
        fs.delete("/" .. filename)
        f = fs.open(filename, "w")
        hf = http.get(table.pack(("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename):gsub(" ", "%%20"))[1])
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not fs.exists("/" .. filename) then
        f = fs.open(filename, "w")
        hf = http.get(table.pack(("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename):gsub(" ", "%%20"))[1])
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
end
f = fs.open("/system/rel", "w")
f.write(branch)
f.close()
os.reboot()
local args = {...}
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
        __LEGACY.term.setBackgroundColor(__LEGACY.colors.red)
        __LEGACY.term.setTextColor(__LEGACY.colors.black)
        __LEGACY.term.setCursorPos(1, 1)
        __LEGACY.term.clear()
        print("arcos has forcefully shut off, due to a critical error.")
        print("This is probably a system issue")
        print("It is safe to force restart this computer at this state. Any unsaved data has already been lost.")
        print("Suspected location: " .. debug.getinfo(2).short_src .. ":" .. debug.getinfo(2).currentline)
        print("Error: " .. err)
        tasks = {}
        if tasking then tasking.createTask("n", function() while true do coroutine.yield() end end, 1, "root", __LEGACY.term, environ) end
        while true do
            coroutine.yield()
        end
    end
}
_G.arcos = {
    reboot = function ()
        __LEGACY.os.reboot()
    end,
    shutdown = function ()
        __LEGACY.os.shutdown()
        apiUtils.kernelPanic("Failed to turn off", "Kernel", "71")
    end,
    log = function(txt)
        kernelLogBuffer = kernelLogBuffer .. "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if config["printLogToConsole"] then
            __LEGACY.term.write("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n")
        end
        if config.printLogToFile and logfile then
            logfile.write(kernelLogBuffer)
        end
    end,
    version = function ()
        return "arcos 24.08 \"Vertica\" (Alpha release)"
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
            user = "krunner",
            nice = 1,
            paused = false,
            env = {}
        }
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
            __newindex = function (t, k, v)
                if k == "_G" then
                    compEnv[k] = v
                end
            end
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
function _G.sleep(time)
    if not time then time=0.05 end
    local tId = arcos.startTimer(time)
    repeat _, i = arcos.ev("timer")
    until i == tId
end
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(col.red)
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
            paused = false
        })
        sleep(0.1) -- Yield so that the task can actually start
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
            tasks[pid]["paused"] = true
        end
    end,
    changeUser = function (user, password)
        if arcos.getCurrentTask().user == user then return true end
        if arcos.getCurrentTask().user ~= "root" and not arcos.validateUser(user, password) then return "Invalid credentials" end
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
        apiUtils.kernelPanic("Invalid argument: " .. args[i], "Kernel", debug.getinfo(1).currentline)
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
arcos.log("Seems like it works")
for i, v in ipairs(__LEGACY.files.list("/system/apis/")) do
    arcos.log("Loading API: " .. v)
    arcos.loadAPI("/system/apis/" .. v)
end 
for i, v in ipairs(files.ls("/apis/")) do
    arcos.log("Loading UserAPI: " .. v)
    arcos.loadAPI("/apis/" .. v)
end
setfenv(read, setmetatable({colors = col, colours = col}, {__index = _G}))
local passwdFile = files.open("/config/passwd", "r")
users = tutils.dJSON(passwdFile.read())
_G.arcos.getHome = function ()
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
    local ufx = files.open("/config/passwd", "w")
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
local f, err = files.open("/config/passwd", "r")
local tab
if f then
    tab = tutils.dJSON(f.read())
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), "Kernel", "174")
end
tasking.createTask("Init", function()
    arcos.log("Starting Init")
    local ok, err = pcall(function()
        local ok, err = arcos.r({}, config["init"])
        if err then
            apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "422")
        else
            apiUtils.kernelPanic("Init Died with no errors.", "Kernel", "422")
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, "Kernel", "424")
end, 1, "root", __LEGACY.term, {workDir = "/user/root"})
arcos.startTimer(0.2)
while true do
    if #tasks > 0 then
        ev = { os.pullEventRaw() }
        for d, i in ipairs(tasks) do
            for _ = 1, i["nice"], 1 do
                _G.term = i["out"] or __LEGACY.term
                if not i["paused"] then
                    currentTask = i
                    cPid = d
                    _G.environ = i["env"]
                    coroutine.resume(i["crt"], table.unpack(ev))
                    i["env"] = _G.environ
                end
            end
            if coroutine.status(i["crt"]) == "dead" then
                arcos.log("Task " .. i["name"] .. " died.")
                table.remove(tasks, d)
            end
        end
    end
    if #tasks <= 0 then
        tasking.createTask("Emergency shell", function ()
            term.setBackgroundColor(col.black)
            term.setTextColor(col.white)
            print("Kernel Emergency Shell System - No tasks.")
            arcos.r({}, "/apps/shell.lua")
        end, 1, "root", __LEGACY.term, {workDir = "/"})
    end
end
if files.exists("/.arcliveenv") then
    files.delete("/.arcliveenv")
end
files.makeDir("/.arcliveenv")
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
local fr = http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
local branch
if fr then
    branch = textutils.unserialiseJSON(fr.readAll())["sha"]
else
    write(">")
    branch = read()
end
file = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/"..branch.."/build/objList.txt")
cont = file.readAll()
file.close()
for _,i in ipairs(strsplit(cont, "\n")) do
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        files.makeDir("/.arcliveenv/" .. filename)
    end
    if action == "f" then
        f = files.open("/.arcliveenv/" .. filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not files.exists("/.arcliveenv/" .. filename) then
        f = files.open("/.arcliveenv/" .. filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
end
f = files.open("/.arcliveenv/system/rel", "w")
f.write(branch)
f.close()
if files.exists("/startup.lua") then
    if files.exists("/.startup.lua.albackup") then
        files.delete("/.startup.lua.albackup")
    end
    files.copy("/startup.lua", "/.startup.lua.albackup")
    files.delete("/startup.lua")
end
local f = files.open("/startup.lua", "w")
if f then
    f.write("settings.set(\"shell.allow_disk_startup\", true) settings.save() fs.delete(\"/startup.lua\") if fs.exists(\"/.startup.lua.albackup\") then fs.move(\"/.startup.lua.albackup\", \"/startup.lua\") end shell.run(\"/.arcliveenv/startup.lua live\")")
    f.close()
else
    print("Error while making temporary installation")
end
settings.set("")
settings.set("shell.allow_disk_startup", false) settings.save()
os.reboot()brokenlocal methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    DELETE = true,
    PATCH = true,
    TRACE = true,
}
local function getChosenRepo()
    local rf = files.open("/config/arcrepo", "r")
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
            local event, param1, param2, param3 = os.pullEvent()
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
local function getLatestCommit()
    local f, e = __LEGACY.files.open("/config/arc/latestCommit.hash", "r")
    if not f then 
        return ""
    else 
        local rp = f.readAll()
        f.close()
        return rp
    end
end
local function checkForCD()
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists("/config/arc") then
        __LEGACY.files.makeDir("/config/arc")
    end
end
local function fetch()
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local f2 = __LEGACY.files.open("/config/arc/latestCommit.hash", "w")    
    local fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        ["Authorization"] = "Bearer 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"
    })
    if not fr then error(e) end
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    f2.write(rp)
    fr.close()
    f2.close()
    local f = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" ..
    getLatestCommit() .. "/repo/index.json")
    local fa = __LEGACY.files.open("/config/arc/repo.json", "w")
    fa.write(f.readAll())
    fa.close()
    f.close()
end
local function isInstalled(package)
    return __LEGACY.files.exists("/config/arc/" .. package .. ".uninstallIndex")
end
local function getIdata(package)
    if not __LEGACY.files.exists("/config/arc/" .. package .. ".meta.json") then
        return nil
    end
    local f, e = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "r")
    if not f then
        return nil
    end
    return __LEGACY.textutils.unserializeJSON(f.readAll())
end
local function getRepo()
    local f = __LEGACY.files.open("/config/arc/repo.json", "r")
    if not f then
        return {}
    end
    local uj = __LEGACY.textutils.unserializeJSON(f.readAll())
    f.close()
    return uj
end
local function getOwners()
    local owners = {}
end
local function isDependant(pkg)
    local l = __LEGACY.files.list("")
end
local function uninstall(package)
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not __LEGACY.files.exists("/config/arc/" .. package .. ".uninstallIndex") then
        error("Package not installed.")
    end
    local toDelete = { }
    toDelete["/config/arc/" .. package .. ".uninstallIndex"] = ""
    toDelete["/config/arc/" .. package .. ".meta.json"] = ""
    local f = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "r")
    for value in f.readLine do
        if value == nil then break end
        if value:sub(0, 1) == "f" then
            toDelete["/" .. value:sub(4+64)] = value:sub(3, 3+64)
        else
            toDelete["/" .. value:sub(3)] = "DIRECTORY"
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
                end
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
local function install(package)
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local repo = getRepo()
    local latestCommit = getLatestCommit()
    local buildedpl = ""
    if not repo[package] then
        error("Package not found!")
    end
    if __LEGACY.files.exists("/config/arc/" .. package .. ".meta.json") then
        local f = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "r")
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
            uninstall(package)
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
            if not __LEGACY.files.exists("/" .. value[1]) then
                __LEGACY.files.makeDir("/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
        end
    end
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not __LEGACY.files.exists("/" .. value[1]) then
                __LEGACY.files.makeDir("/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
            if not __LEGACY.files.exists("/" .. value[1]) then
                local file = value[2]
                local tfh, e = __LEGACY.files.open("/" .. value[1], "w")
                if not tfh then error(e) end
                tfh.write(file)
                tfh.close()
                buildedpl = buildedpl .. "f "  .. hashing.sha256(value[2]) .. " " .. value[1] .. "\n"
            end
        end
    end
    if pkg["postInstScript"] then
        return function()
            local file = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/" .. "pi.lua")
            local fd = file.readAll()
            file.close()
            local tf = __LEGACY.files.open("/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
            tf.write(fd)
            tf.close()
            arcos.r({}, "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
        end
    end
    indexFile.close()
    local insf = __LEGACY.files.open("/config/arc/" .. package .. ".meta.json", "w")
    insf.write(__LEGACY.textutils.serializeJSON(pkg))
    insf.close()
    local uinsf = __LEGACY.files.open("/config/arc/" .. package .. ".uninstallIndex", "w")
    uinsf.write(buildedpl)
    uinsf.close()
    return function()
    end
end
local function getUpdatable()
    local updatable = {}
    for index, value in ipairs(files.ls("/config/arc/")) do
        if value:sub(#value - 14) == ".uninstallIndex" then
            local pk = value:sub(0, #value - 15)
            local pf = __LEGACY.files.open("/config/arc/" .. pk .. ".meta.json", "r")
            local at = pf.readAll()
            local af = __LEGACY.textutils.unserializeJSON(at)
            pf.close()
            if af["vId"] < getRepo()[pk]["vId"] then
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
    r = false
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
}local function split(inputstr, sep)
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
    local validModes = {"w", "r", "w+", "r+", "a"}
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
    return __LEGACY.files.list(dir)
end
local function rm(f)
    return __LEGACY.files.delete(f)
end
local function exists(f)
    if d == "" or d == "/" then return true end
    return __LEGACY.files.exists(f)
end
local function mkDir(d) 
    return __LEGACY.files.makeDir(d)
end
local function resolve(f, keepNonExistent)
    local p = f:sub(1, 1) == "/" and "/" or (environ.workDir or "/")
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
    if not keepNonExistent and not files.exists("/" .. tutils.join(out, "/")) then return {} end
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
    return __LEGACY.files.move(t, d)
end
local function c(t, d)
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
            sDir = files.combine(sDir, sPart)
            nStart = nSlash + 1
        else
            sName = string.sub(sPath, nStart)
        end
    end
    if files.dir(sDir) then
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
        local tFiles = files.ls(sDir)
        for n = 1, #tFiles do
            local sFile = tFiles[n]
            if #sFile >= #sName and string.sub(sFile, 1, #sName) == sName and (
                bIncludeHidden or sFile:sub(1, 1) ~= "." or sName:sub(1, 1) == "."
            ) then
                local bIsDir = files.dir(files.combine(sDir, sFile))
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
        if files.exists(path) then out[#out + 1] = path end
    elseif part.exact then
        return find_aux(files.combine(path, part.contents), parts, i + 1, out)
    else
        if not files.dir(path) then return end
        local files = files.ls(path)
        for j = 1, #files do
            local file = files[j]
            if file:find(part.contents) then find_aux(files.combine(path, file), parts, i + 1, out) end
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
    pattern = files.combine(pattern) -- Normalise the path, removing ".."s.
    if pattern == ".." or pattern:sub(1, 3) == "../" then
        error("/" .. pattern .. ": Invalid Path", 2)
    end
    if not pattern:find("[*?]") then
        if files.exists(pattern) then return { pattern } else return {} end
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
    return files.par(sPath) == ".." or files.drive(sPath) ~= files.drive(files.par(sPath))
end
local function combine(...)
    return __LEGACY.files.combine(...)
end
local function name(path)
    return __LEGACY.files.getName(path)
end
local function par(path)
    return __LEGACY.files.getDir(path)
end
local function size(path)
    return __LEGACY.files.getSize(path)
end
local function readonly(path)
    return __LEGACY.files.isReadOnly(path)
end
local function drive(path)
    return __LEGACY.files.getDrive(path)
end
local function freeSpace(path)
    return __LEGACY.files.getFreeSpace(path)
end
local function capacity(path)
    return __LEGACY.files.getCapacity(path)
end
local function attributes(path)
    return __LEGACY.files.attributes(path)
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
		if c then z = bit32_band(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return MODM end
end
local function bnot(x) return (-1 - x) % MOD end
local function rshift1(a, disp)
	if disp < 0 then return lshift(a,-disp) end
	return math.floor(a % 2 ^ 32 / 2 ^ disp)
end
local function rshift(x, disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift1(x % MOD, disp)
end
local function lshift(a, disp)
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2 ^ disp) % 2 ^ 32
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
    return t
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
UItheme = {
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
    W, H = mon.getSize()
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
    config.getDrawCommands = function()
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
                local rc = value.getDrawCommands()
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
    config.getDrawCommands = function()
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
local function Align(x, y, widgettoalign, alignment, w, h)
	local widget = widgettoalign
	widget.x = 0
	widget.y = 0
	local w = {}
	function updateXY(termar)
	  widget.x = 0
	  widget.y = 0
	  local tw, th = termar.getSize()
	  if w then tw = w end
	  if h then th = h end
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
    	  updateXY()
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
local function RenderWidgets(wdg, ox, oy, buf)
    local tw, th = #buf[1], #buf
    for i = 1, th, 1 do
        for ix = 1, tw, 1 do
            blitAtPos(ix + ox, i + oy, ui.UItheme.bg, ui.UItheme.fg, " ", buf)
        end
    end
    for index, value in ipairs(wdg) do
        ui.DirectRender(value, ox, oy, buf)
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
    RenderWidgets(widgets1, 0, 0, buf)
    RenderWidgets(widgets2, 0, 0, buf2)
    speed = speed + 1
    if ontop then
        while ox < tw - 0.5 do
            ox = math.max(((ox / tw) + (accel / 100)) * tw, 0)
            accel = accel / speed
            local sbuf = InitBuffer(terma)
            Cpy(buf, sbuf, 0, 0)
            Cpy(buf2, sbuf, (tw - ox) * (dir and -1 or 1), 0)
            Push(sbuf, terma)
            sbuf = nil
            sleep(1 / 20)
        end
    else
        accel = 1.5625
        while ox < tw - 0.5 do
            ox = math.max(((ox / tw) + (accel / 100)) * tw, 0)
            accel = accel * speed
            local sbuf = InitBuffer(terma)
            Cpy(buf2, sbuf, 0, 0)
            Cpy(buf, sbuf, (ox) * (dir and -1 or 1), 0)
            Push(sbuf, terma)
            sbuf = nil
            sleep(1 / 20)
        end
    end
end
local function RenderLoop(toRender, outTerm, f)
    local function reRender()
        local buf = ui.InitBuffer(outTerm)
        ui.RenderWidgets(toRender, 0, 0, buf)
        ui.Push(buf, outTerm)
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
return {create = create}By using arcos, you automatically agree to these
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
find the "telemetry" field and disable it