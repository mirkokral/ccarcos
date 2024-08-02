
if fs.exists("/.arcliveenv") then
    fs.delete("/.arcliveenv")
end
fs.makeDir("/.arcliveenv")
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
-- shell.run("rm /*")
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
    -- print(i)
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        fs.makeDir("/.arcliveenv/" .. filename)
    end
    if action == "f" then
        -- shell.run("rm /.arcliveenv/" .. filename)
        f = fs.open("/.arcliveenv/" .. filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not fs.exists("/.arcliveenv/" .. filename) then
        -- shell.run("rm /" .. filename)
        
        f = fs.open("/.arcliveenv/" .. filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
        
    end
end
f = fs.open("/.arcliveenv/system/rel", "w")
f.write(branch)
f.close()
if fs.exists("/startup.lua") then
    if fs.exists("/.startup.lua.albackup") then
        fs.delete("/.startup.lua.albackup")
    end
    fs.copy("/startup.lua", "/.startup.lua.albackup")
    fs.delete("/startup.lua")
end
local f = fs.open("/startup.lua", "w")
if f then
    f.write("fs.delete(\"/startup.lua\") if fs.exists(\"/.startup.lua.albackup\") then fs.move(\"/.startup.lua.albackup\", \"/startup.lua\") end shell.run(\"/.arcliveenv/startup.lua live\")")
    f.close()
else
    print("Error while making temporary installation")
end
os.reboot()