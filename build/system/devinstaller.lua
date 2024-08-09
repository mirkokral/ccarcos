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
f = fs.open("/config/aboot", "w+")
local a = textutils.unserialiseJSON(f.readAll())
a["autoUpdate"] = false
f.write(textutils.serializeJSON(a))
f.close()
os.reboot()