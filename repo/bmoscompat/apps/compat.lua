local bmos_compat_env = {}
for key, value in pairs(_G) do
    bmos_compat_env[key] = value
end
bmos_compat_env._G = setmetatable({}, {__index = bmos_compat_env, __newindex = bmos_compat_env})
bmos_compat_env.rootColor = col.red
bmos_compat_env.userColor = col.green
bmos_compat_env.user = {
	login = tasking.changeUser,
	createUser = arcos.createUser,
	chkRoot = function() return arcos.getCurrentTask().user == "root" end,
	home = arcos.getHome,
	currentUser = function()
		return arcos.getCurrentTask().user
	end,
	currentUserColor = function()
		return chkRoot() and _G.rootColor or _G.userColor
	end,
}
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
local ok, err = arcos.r(bmos_compat_env, "/apps/shell.lua", ...)
if not ok then bmos_compat_env.output.error(err) end
