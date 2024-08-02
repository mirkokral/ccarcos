---Serializes an object into JSON
---@param obj any
---@return string
function sJSON(obj)
    return __LEGACY.textutils.serializeJSON(obj)
end
---Deserializes a JSON string
---@param obj string
---@return any
function dJSON(obj)
    return __LEGACY.textutils.unserialiseJSON(obj)
end
---Serializes a lua object into lua coded
---@param obj any
---@return string
function s(obj)
    return __LEGACY.textutils.serialize(obj)
end
---Deserializes lua code
---@param obj string
---@return any
function d(obj)
    return __LEGACY.textutils.unserialize(obj)
end
---Splits string by seperator
---@param inputstr string
---@param sep string
---@return table
function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end
---Joins an table by seperators
---@param tab table
---@param sep string
---@return string
---@deprecated Use table.concat
function join(tab, sep )
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out-1)
end

---Formats time
---@param t number
---@param tfhour boolean
---@return string
function formatTime(t, tfhour)
    return __LEGACY.textutils.formatTime(t, tfhour)
end

-- C:Exc
_G.tutils = {
    dJSON = dJSON,
    sJSON = sJSON,
    d = d,
    s = s,
    split = split,
    join = join,
    formatTime = formatTime,
}
-- C:End