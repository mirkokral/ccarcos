local crApi
if __LEGACY then
    crApi = __LEGACY
else
    crApi = {
        shell = shell,
        fs = fs,
        http = http,
        textutils = textutils
    }
end
if not crApi.fs.exists("/system/krnl.lua") then
    crApi.shell.run("rm /*")
else
    crApi.shell.run("rm /system/*")
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
local fr = crApi.http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
local branch
if fr then
    branch = crApi.textutils.unserialiseJSON(fr.readAll())["sha"]
else
    write(">")
    branch = read()
end
file = crApi.http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/"..branch.."/build/objList.txt")
cont = file.readAll()
file.close()
for _,i in ipairs(strsplit(cont, "\n")) do
    print(i)
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        crApi.fs.makeDir("/" .. filename)
    end
    if action == "f" then
        crApi.shell.run("rm /" .. filename)
        f = crApi.fs.open(filename, "w")
        hf = crApi.http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not fs.exists("/" .. filename) then
        f = crApi.fs.open(filename, "w")
        hf = crApi.http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
end
f = fs.open("/system/rel", "w")
f.write(branch)
f.close()