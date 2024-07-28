if not fs.exists("/system/krnl.lua") then
    shell.run("rm /*")
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
-- shell.run("rm /*")

local branch = textutils.unserializeJson(http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main").readAll())["sha"]
file = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/"..branch.."/build/objList.txt")
cont = file.readAll()
file.close()
for _,i in ipairs(strsplit(cont, "\n")) do
    print(i)
    action = string.sub(i, 1, 1)
    filename = string.sub(i, 3)
    if action == "d" then
        fs.makeDir("/" .. filename)
    end
    if action == "f" then
        shell.run("rm /" .. filename)
        f = fs.open(filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
    end
    if action == "r" and not fs.exists("/" .. filename) then
        -- shell.run("rm /" .. filename)
        
        f = fs.open(filename, "w")
        hf = http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/" .. branch .. "/build/" .. filename)
        f.write(hf.readAll())
        hf.close()
        f.close()
        
    end
end
f = fs.open("/system/rel")
f.write(branch)
f.close()