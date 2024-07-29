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
setmetatable(_G, {
    __index = function(_, i) do
        if debug.getinfo(2).source:sub(2) == "bios.lua" then
            return oldug[i]
        end
    end
})
dofile("/system/bootloader.lua")