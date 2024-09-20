|/apps|-1|
|/data|-1|
|data/bmos|-1|
|data/bmosfs|-1|
|data/bmosfs/bin|-1|
|/index|0|
|apps/bmos.lua|506|
|data/bmos/bmos.lua|559|
|data/bmosfs/bin/cat.lua|5165|
|data/bmosfs/bin/cd.lua|5431|
|data/bmosfs/bin/clear.lua|5619|
|data/bmosfs/bin/copy.lua|5654|
|data/bmosfs/bin/echo.lua|5905|
|data/bmosfs/bin/login.lua|5942|
|data/bmosfs/bin/ls.lua|6391|
|data/bmosfs/bin/mkdir.lua|6779|
|data/bmosfs/bin/move.lua|7160|
|data/bmosfs/bin/package.lua|7411|
|data/bmosfs/bin/reboot.lua|13251|
|data/bmosfs/bin/rm.lua|13262|
|data/bmosfs/bin/sh.lua|13433|
|data/bmosfs/bin/shutdown.lua|18195|
|data/bmosfs/bin/useradd.lua|18284|
--ENDTABLE
d>apps
f>apps/bmos.lua
d>data
d>data/bmos
f>data/bmos/bmos.lua
d>data/bmosfs
d>data/bmosfs/bin
f>data/bmosfs/bin/cat.lua
f>data/bmosfs/bin/cd.lua
f>data/bmosfs/bin/clear.lua
f>data/bmosfs/bin/copy.lua
f>data/bmosfs/bin/echo.lua
f>data/bmosfs/bin/login.lua
f>data/bmosfs/bin/ls.lua
f>data/bmosfs/bin/mkdir.lua
f>data/bmosfs/bin/move.lua
f>data/bmosfs/bin/package.lua
f>data/bmosfs/bin/reboot.lua
f>data/bmosfs/bin/rm.lua
f>data/bmosfs/bin/sh.lua
f>data/bmosfs/bin/shutdown.lua
f>data/bmosfs/bin/useradd.lua
arcos.r({}, "/apps/craft.lua", "/data/bmos/bmos.lua")local bmos_compat_env = {}
for key, value in pairs(_G) do
    bmos_compat_env[key] = value
end
local directory = "/"
resolvePath = function(path)
	local matches = {}
	for i in path:gmatch("[^/]+") do
		table.insert(matches,i)
	end
	local result1 = {}
	local lastIndex = 1
	for i,v in pairs(matches) do
		if v ~= "." then
			if v== ".." then
				result1[lastIndex] = nil
				lastIndex = lastIndex-1
			else
				lastIndex = lastIndex + 1
				result1[lastIndex] = v
			end
		end
	end
	local result = {}
	for i,v in pairs(result1) do
		table.insert(result,v)
	end
	local final = "/"
	for i,v in pairs(result) do
		if i ~= 1 then
			final = final .. "/"
		end
		final = final..v
	end
	return final
end
local parentDir = "/data/bmosfs/bin"
bmos_compat_env._G = setmetatable({}, {__index = bmos_compat_env, __newindex = bmos_compat_env})
bmos_compat_env.rootColor = col.red
bmos_compat_env.userColor = col.green
bmos_compat_env.fs.resolvePath = resolvePath
bmos_compat_env.fs.setDir = function(dir)
	directory = dir
end
bmos_compat_env.fs.getDir = function()
	return directory
end
 bmos_compat_env.fs.getBootedDrive = function()
	local drive = resolvePath(parentDir.."..").."/"
	if drive == "//" then
		drive = "/"
	end
	return drive
end
bmos_compat_env.os.hostname = arcos.getName
bmos_compat_env.user = {
	login = tasking.changeUser,
	createUser = arcos.createUser,
	chkRoot = function() return arcos.getCurrentTask().user == "root" end,
	home = arcos.getHome,
	currentUser = function()
		return arcos.getCurrentTask().user
	end,
	currentUserColor = function()
		return (arcos.getCurrentTask().user == "root") and bmos_compat_env.rootColor or bmos_compat_env.userColor
	end,
}
bmos_compat_env.fs.updateFile = function(file,url)
	local result, reason = http.get({url = url, binary = true}) --make names better
	if not result then
		output.warn(("Failed to update %s from %s (%s)"):format(file, url, reason)) --include more detail
		return
	end
	local a1 = fs.open(file,"wb")
	a1.write(result.readAll())
	a1.close()
	result.close()
end
oldRun = os.run
bmos_compat_env.os.run = function(env,file,...)
	--resolving this here since its required for files to work
	local a = fs.open(file,"r")
	if a then
		local firstLine = a.readLine(false)
		a.close()
		if firstLine:sub(1,2) == "#!" then
			local interpreter = firstLine:sub(3)
			if fs.isProgramInPath("",interpreter) then
				interpreter = fs.isProgramInPath("",interpreter)
			end
			oldRun(env,interpreter,file,...)
		else
			oldRun(env,file,...)
		end
	else
		bmos_compat_env.output.info(file)
	end
end
bmos_compat_env.fs.isProgramInPath = function(path,progName)
	if fs.exists(path..progName) then
		return path..progName
	elseif fs.exists(path..progName..".lua") then
		return path..progName..".lua"
	elseif fs.exists(path..progName..".why") then
		return path..progName..".why"
	else
		return false
	end
end
bmos_compat_env.output = {
	debug = function(...)
		print("[DEBUG]",...)
	end,
	info = function(...)
		print("[INFO]",...)
	end,
	warn = function(...)
		local oldPrintColor
		if term.isColor() then
			oldPrintColor = term.getTextColor()
			term.setTextColor(col.yellow)
		end
		print("[WARNING]",...)
		if term.isColor() then
			term.setTextColor(oldPrintColor)
		end
	end,
	error = function(...)
		printError("[ERROR]",...)
	end,
}
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
UIthemedefs[colors.lightGray] = { 216, 222, 233 }
UIthemedefs[colors.cyan] = { 136, 192, 208 }
UIthemedefs[colors.purple] = { 0, 0, 0 }
UIthemedefs[colors.blue] = { 129, 161, 193 }
UIthemedefs[colors.brown] = { 0, 0, 0 }
UIthemedefs[colors.green] = { 163, 190, 140 }
UIthemedefs[colors.red] = { 191, 97, 106 }
UIthemedefs[colors.black] = { 59, 66, 82 }
function bmos_compat_env.term.fixColorScheme()
	for index, value in pairs(UIthemedefs) do
  		term.setPaletteColor(index, value[1] / 255, value[2] / 255, value[3] / 255)
	end
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
end
print("[INFO] BM-OS Compatiblity Enabled")
local lastEnvType = (environ.envType or "") .. ""
environ.envType = "BM-OS"
local ok, err = arcos.r(bmos_compat_env, "/data/bmosfs/bin/sh.lua", ...)
if not ok then bmos_compat_env.output.error(err) end
if lastEnvType == "" then
	environ.envType = nil
else
	environ.envType = lastEnvType
end
if not arg[1] then
    print("Usage: cat <file>")
    return
end
local file = fs.isProgramInPath(fs.getDir(),arg[1])
if file ~= false then
    local data = fs.open(file,"r")
    print(data.readAll())
    data.close()
    return
else
    print("File not found!")
end
if not arg[1] then
    print("Usage: cd <directory>")
    return
end
local newDir = fs.resolvePath(fs.getDir()..arg[1])
if newDir ~= "/" then
    newDir = newDir.."/"
end
fs.setDir(newDir)term.setCursorPos(1,1)
term.clear()if not arg[1] or not arg[2] then
    print("Usage: copy [file] [destination]")
end
local file = fs.getDir()..arg[1]
local destination = fs.getDir()..arg[2]
if fs.exists(file) then
    fs.copy(file,destination)
else
    print("File does not exist")
endarg[0] = nil
print(table.unpack(arg))local success = false

print("Login on device "..os.hostname())
local attempts = 0
while not success do
	if attempts > 0 then
		printError("Incorrect username or password")
		print("")
	end
	if attempts > 3 then
		printError("Too many login attempts")
		sleep(1)
		os.shutdown()
	end
	term.write("Username:")
	local user = read()
	term.write("Password:")
	local password = read("*")
	success = user.login(user, password)
	attempts = attempts + 1
endfor i,v in pairs(fs.list(fs.getDir())) do
    if string.sub(v, 1, 1) ~= "." then
        if fs.getDir() == "/" and  v == "startup.lua" or v == "rom" then
             --skip
         else
             if fs.isDir(fs.getDir()..v) then
                 term.setTextColor(colors.green)
            end
            print(v)
            term.setTextColor(colors.white)
         end
    end
endlocal newDir = arg[1]
if not newDir then
    print("Usage: mkdir <name>")
end
if fs.getDir() == "/" and string.sub(newDir,1,4) == "disk" and (string.len(newDir) == 5 or string.len(newDir) == 6) then
    print("Insufficient permissions")
end
if not fs.exists(fs.getDir()..newDir.."/") then
        fs.makeDir(fs.getDir()..newDir.."/")
else
    print("Direcotry already exists!")
endif not arg[1] or not arg[2] then
    print("Usage: copy [file] [destination]")
end
local file = fs.getDir()..arg[1]
local destination = fs.getDir()..arg[2]
if fs.exists(file) then
    fs.move(file,destination)
else
    print("File does not exist")
endlocal makeJson = textutils.serializeJSON
local makeTable = textutils.unserializeJSON
arg[0] = nil
if not arg[1] then
    print("Usage: package [update install remove]")
	return
end
--verify the files exist
if not fs.exists("/data/bmosfs/etc/packages.d/") then
    fs.makeDir("/data/bmosfs/etc/packages.d/")
end
if not fs.exists("/data/bmosfs/etc/packages.d/packages.json") then
    local file = fs.open("/data/bmosfs/etc/packages.d/packages.json","w")
    file.write(makeJson({
        provided = {},
        installed = {
            base = {
                packageId = "base",
                version = ""
            }
        }
    }))
    file.close()
end
if not fs.exists("/data/bmosfs/etc/packages.d/mirror.json") then
    local file = fs.open("/data/bmosfs/etc/packages.d/mirror.json","w")
    file.write(makeJson({
        lastupdated = "1970-01-01 12:00 AM",
        packages = {}
    }))
    file.close()
end
local file = fs.open("/data/bmosfs/etc/packages.d/mirror.json","r")
local packageList = makeTable(file.readAll())
file.close()
local file = fs.open("/data/bmosfs/etc/packages.d/packages.json","r")
local meta = makeTable(file.readAll())
file.close()
local updated = meta.updated
local installed = meta.installed
if not meta.provided then
	meta.provided = {}
	for i,v in pairs(installed) do
		meta.provided[v] = {v}
	end
end
local provided = meta.provided
if not meta.conflicts then
	meta.conflicts = {}
end
local conflicts = meta.conflicts
local metadata = 'https://windclan.neocities.org/blockmesa/meta.json'

local function isProvided(pack)
	for i,v in pairs(provided) do
		for i,v in pairs(v) do
			if v == pack then
				return true
			end
		end
	end
	return false
end
local function hasConflicts(pack)
	for i,v in pairs(conflicts) do
		for _,v in pairs(v) do
			if v == pack then
				return true,i
			end
		end
	end
	return false, ""
end

local function uninstallPackage(pack1)
	if installed[pack1] then
		local pack = installed[pack1]
		if pack.files then
			for i,v in pairs(pack.files) do
				fs.delete(v)
			end
		end
		meta.installed[pack1] = nil
		meta.provided[pack1] = nil
	end
end
local function handleConflict(pack,pack1)
	print(pack.." conflicts with "..pack1)
	print("remove "..pack1.."? y/n")
	local _, a = os.pullEvent("char")
	local doRemove = a == "y"
	if doRemove then
		uninstallPackage(pack1)
	else
		error("unable to create conflicts!",0)
	end
end
local function installPackage(pack)
    local info = installed[pack]
    if info then
        print("Package already installed!")
        print("Did you mean: package update?")
    else
        if packageList.packages[pack] then
			local conflicting = {}
			if hasConflicts(pack) then
				local _,conflicting1 = hasConflicts(pack)
				handleConflict(pack,conflicting1)
			end
			if packageList.packages[pack].conflicts then
				for i,v in pairs(packageList.packages[pack].conflicts) do
					table.insert(conflicting,v)
					if installed[v] then
						handleConflict(pack,v)
					end
				end
			end
            local baseUrl = packageList.packages[pack].assetBase
            print("Installing package "..pack)
			local files = {}
			provided[pack] = {
				pack,
			}
			conflicts[pack] = conflicting
			if packageList.packages[pack].files then
			    for i,v in pairs(packageList.packages[pack].files) do
					local url = v
					local file = ""
					if type(i) == "string" then
						file = i
					else
						file = v
					end
					table.insert(files,file)
					fs.updateFile(file,baseUrl..url)
				end
			end
			if packageList.packages[pack].requires then
				for i,v in pairs(packageList.packages[pack].requires) do
					if not installed[v] and not isProvided(v) then
						installPackage(v)
					end
				end
			end
			if packageList.packages[pack].provides then
				 for i,v in pairs(packageList.packages[pack].provides) do
					table.insert(provided[pack],v)
				 end
			end
            meta.installed[pack] = {
                packageId = pack,
                version = packageList.packages[pack].version,
				requires = packageList.packages[pack].requires,
				files = files,
            }
        else   
            print("Invalid package")
        end
    end
end
local function updatePackage(pack)
    local info = installed[pack]
    if info then
        if packageList.packages[pack].version ~= info.version then
            return true
        else
            return false
        end
    else
        printError("Package not installed")
        return false
    end
end
local function updateList()
	print("Updating package list...")
	local http, response = http.get(metadata)
	if not http then
		print(response)
		return
	end
	packageList = makeTable(http.readAll())
	http.close()
end
if arg[1] == "update" then
	updateList()
    local hasUpdated = false
	local updates = {}
    for i,v in pairs(installed) do
        local a = updatePackage(i)
        if a then
			table.insert(updates,i)
            hasUpdated = true
        end
    end
	for i,v in pairs(updates) do
		uninstallPackage(v)
	end
	for i,v in pairs(updates) do
		installPackage(v)
	end
    if not hasUpdated then
        print("No updates avaliable!")
    end
elseif arg[1] == "install" then
	updateList()
    if not arg[2] then
        print("Usage: package install [name]")
        return
    end
	table.remove(arg,1)
	for i,v in pairs(arg) do
		installPackage(v)
	end
elseif arg[1] == "remove" then
    if not arg[2] then
        print("Usage: package remove [name]")
        return
    end
	table.remove(arg,1)
	for i,v in pairs(arg) do
		print("Uninstalling "..v)
	    uninstallPackage(v)
	end
else
	print("no command specified!")
end
local file = fs.open("/data/bmosfs/etc/packages.d/mirror.json","w")
file.write(makeJson(packageList))
file.close()

local file = fs.open("/data/bmosfs/etc/packages.d/packages.json","w")
file.write(makeJson(meta))
file.close()
os.reboot()if not arg[1] then
    print("Usage: rm [file]")
end
local file = fs.getDir()..arg[1]
if fs.exists(file) then
    fs.delete(file)
else
    print("File does not exist")
endif shell then
	print("Nested shells detected!")
	print("Exiting...")
	return
end
term.clear()
term.setCursorPos(1,1)
--Not taken directly from BM-DOS
local function splitString(str,toMatch)
	if not toMatch then
		toMatch = "%S"
	end
	local words = {}
	for w in str:gmatch(toMatch.."+") do
		table.insert(words,w)
	end
	return words
end
local function removeFirstIndex(t)
	local newTable = {}
	for i,v in pairs(t) do
		if i ~= 1 then
			table.insert(newTable,v)
		end
	end
	return newTable
end
local romPrograms = {
	edit = "/rom/programs/edit.lua",
	pastebin = "/rom/programs/http/pastebin.lua",
	wget = "/rom/programs/http/wget.lua",
	import = "/rom/programs/import.lua",
	lua = "/rom/programs/lua.lua",
	ls = "/data/bmosfs/bin/ls.lua",
	dir = "/data/bmosfs/bin/ls.lua",
	mv = "/data/bmosfs/bin/move.lua",
	move = "/data/bmosfs/bin/move.lua",
	copy = "/data/bmosfs/bin/copy.lua",
	cp = "/data/bmosfs/bin/copy.lua",
	package = "/data/bmosfs/bin/package.lua",
}

local makeRequire = (compat and compat.isCapy64) and compat.makeRequire or dofile("rom/modules/main/cc/require.lua").make
local interpret
local runProgram
local parsePath
local runningProgram = ""
local shell = {
	run = function(...)
		local args = {...}
		local command = ""
		for i,v in pairs(args) do
			if type(v) == "string" then
				if i ~= 1 then
					command = command.." "
				end
				command = command..v
			end
		end
		interpret(command)
	end,
	execute = function(progName,...)
		local program = parsePath(progName)
		runProgram(progName,program,...)
		return
	 end,
	exit = function(...) return end, --no
	dir = fs.getDir,
	setDir = fs.setDir,
	path = function() return ".:/rom/programs:/rom/programs/http:/data/bsmosfs/bin:/data/bsmosfs/usr/bin" end,
	setPath = function(...) return end,
	resolve = function(progName)
		return parsePath(progName)
	end,
	getRunningProgram = function()
		return runningProgram
	end,
}
function parsePath(progName)
	local name = splitString(progName,"%P")
	local program = ""
	--removed /sbin from this as it isnt in a normal user's path
	if fs.isProgramInPath("/data/bsmosfs/bin/",progName) then
		program = fs.isProgramInPath("/data/bsmosfs/bin/",progName)
	elseif fs.isProgramInPath("/data/bsmosfs/usr/bin/",progName) then
		program = fs.isProgramInPath("/data/bsmosfs/usr/bin/",progName)
	elseif romPrograms[string.lower(progName)] then --move it down so we can add custom versions of ROM programs
		program = romPrograms[string.lower(progName)]
	elseif string.sub(progName,1,1) == "/" then -- if you are trying to use absolute paths you probably know exact filenames
		program = fs.resolvePath(progName)
	elseif name[2] or not fs.exists(fs.getDir()..progName..".lua") then
		program = fs.resolvePath(fs.getDir()..progName)
	else
		program = fs.resolvePath(fs.getDir()..progName..".lua")
	end
	return program
end
function runProgram(name,program,...)
	if name == nil then
		name = program
	end
	local args = {...}
	args[0] = name
	local fakeGlobals = {shell=shell, arg=args}
	fakeGlobals.require, fakeGlobals.package = makeRequire(fakeGlobals,fs.getDir(program))
	_G.os.pullEvent = os.pullEventOld
	runningProgram = program
	local success, response = pcall(os.run,fakeGlobals,program,table.unpack(args))
	runningProgram = ""
	term.fixColorScheme()
	_G.os.pullEvent = os.pullEventRaw
	if not success then
		print(response)
	end
end
function interpret(command)
	if command == "" then return end
	local splitcommand = splitString(command,"%S")
	local args = removeFirstIndex(splitcommand)
	local progName = splitcommand[1]
	local program = parsePath(progName)
	if fs.exists(program) then
		runProgram(progName,program,table.unpack(args))
	else
		print("File not found!")
	end
end
if not fs.exists("/home") then
	fs.makeDir("/home")
end
fs.setDir("/home/")
if fs.exists(user.home()) then
	fs.setDir(user.home())
end
--[[if not fs.exists(user.home()..".shrc") then
	--No .shrc found!
	local a = fs.open(user.home()..".shrc", "w")
	a.write('')
	a.close()
end]]
-- that drives me crazy
local a,b = pcall(function()
	for line in io.lines(user.home().."/.shrc") do
		local success, err = pcall(interpret,line)
		if not success then
			print(err)
		end
	end
end)

while true do
	term.setCursorBlink(true)
	term.setTextColor(user.currentUserColor())
 	term.write(user.currentUser())
	term.setTextColor(colors.white)
 	term.write("@"..os.hostname())
	term.setTextColour(colours.green)
	local path = fs.getDir()
	if string.sub(path,1,7+#user.currentUser()) == user.home() then
		path = "~"..string.sub(path,8+#user.currentUser(),string.len(path)-1)
	end
	term.write(" "..path.." >")
 	term.setTextColor(colors.white)
  	term.write("") -- beloved hack
	local command = read()
	local success, err = pcall(interpret,command)
	if not success then
		print(err)
	end
end
if arg[1] == "-r" or arg[1] == "--reboot" then
    os.reboot()
else
    os.shutdown()
endlocal function main()
  if not user.chkRoot() then print("This command requires root.") return 0 end
	local success = false
	print("")
	term.write("Username: ")
	local username = read()
	term.write("Password: ")
	local password = read("*")
	success = user.createUser(username,password)
	if success then print("User created.") else print("User creation failed.") end
end

main()
