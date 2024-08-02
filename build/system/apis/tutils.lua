function sJSON(obj)
    return __LEGACY.textutils.serializeJSON(obj)
end
function dJSON(obj)
    return __LEGACY.textutils.unserialiseJSON(obj)
end
function s(obj)
    return __LEGACY.textutils.serialize(obj)
end
function d(obj)
    return __LEGACY.textutils.unserialize(obj)
end
function split(inputstr, sep)
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
function join(tab, sep )
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out-1)
end
function formatTime(t, tfhour)
    return __LEGACY.textutils.formatTime(t, tfhour)
end
