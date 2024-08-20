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
os.reboot()