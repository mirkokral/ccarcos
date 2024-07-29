local oldug = {}
for k, v in _G do
    oldug[k] = v
end
_G.__LEGACY = {
    colors = colors,
    colours = colours,
    commands = commands,
    disk = disk,
    fs = fs,
    gps = gps,
    help = help,
    http = http,
    io = io,
    keys = keys,
    os = os,
    paintutils = paintutils,
    parallel = parallel,
    peripheral = peripheral,
    pocket = pocket,
    rednet = rednet,
    redstone = redstone,
    settings = settings,
    shell = shell,
    term = term,
    textutils = textutils,
    turtle = turtle,
    vector = vector,
    window = window
}
_G["colors"] = nil
_G["colours"] = nil
_G["commands"] = nil
_G["disk"] = nil
_G["fs"] = nil
_G["gps"] = nil
_G["help"] = nil
_G["http"] = nil
_G["io"] = nil
_G["keys"] = nil
_G["os"] = nil
_G["paintutils"] = nil
_G["parallel"] = nil
_G["peripheral"] = nil
_G["pocket"] = nil
_G["rednet"] = nil
_G["redstone"] = nil
_G["settings"] = nil
_G["shell"] = nil
_G["term"] = nil
_G["textutils"] = nil
_G["turtle"] = nil
_G["vector"] = nil
_G["window"] = nil
setmetatable(_G, {
    __index = function(_, i)
        if debug.getinfo(2).source:sub(2) == "bios.lua" then
            return oldug[i]
        end
    end
})
dofile("/system/bootloader.lua")