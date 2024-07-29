local oldug = {}
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

for k, v in pairs(_G) do
    oldug[k] = v
end


oldug["colors"] = nil
oldug["colours"] = nil
oldug["commands"] = nil
oldug["disk"] = nil
oldug["fs"] = nil
oldug["gps"] = nil
oldug["help"] = nil
oldug["http"] = nil
oldug["io"] = nil
oldug["keys"] = nil
oldug["os"] = nil
oldug["paintutils"] = nil
oldug["parallel"] = nil
oldug["peripheral"] = nil
oldug["pocket"] = nil
oldug["rednet"] = nil
oldug["redstone"] = nil
oldug["settings"] = nil
oldug["shell"] = nil
oldug["term"] = nil
oldug["textutils"] = nil
oldug["turtle"] = nil
oldug["vector"] = nil
oldug["window"] = nil
loadfile("/system/bootloader.lua", nil, oldug)