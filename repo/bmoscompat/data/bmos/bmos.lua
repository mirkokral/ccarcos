local bmos_compat_env = {}
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
