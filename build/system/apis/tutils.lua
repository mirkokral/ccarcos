local function sJSON(obj)
    return __LEGACY.textutils.serializeJSON(obj)
end
local function dJSON(obj)
    return __LEGACY.textutils.unserialiseJSON(obj)
end
local function s(obj)
    return __LEGACY.textutils.serialize(obj)
end
local function d(obj)
    return __LEGACY.textutils.unserialize(obj)
end
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    return t
end
local function join(tab, sep )
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out-1)
end
local function formatTime(t, tfhour)
    return __LEGACY.textutils.formatTime(t, tfhour)
end
return {
    dJSON = dJSON,
    sJSON = sJSON,
    d = d,
    s = s,
    split = split,
    join = join,
    formatTime = formatTime,
}
