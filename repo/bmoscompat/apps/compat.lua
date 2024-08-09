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
print("[INFO] BM-OS Compatiblity Enabled")
environ.envType = "BM-OS"
local ok, err = arcos.r(bmos_compat_env, "/apps/bmshell.lua", ...)
if not ok then bmos_compat_env.output.error(err) end
