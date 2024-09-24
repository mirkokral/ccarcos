---Serializes an object into JSON
---@param obj any
---@return string
local function sJSON(obj)
    return __LEGACY.textutils.serializeJSON(obj)
end
---Deserializes a JSON string
---@param obj string
---@return any
local function dJSON(obj)
    return __LEGACY.textutils.unserialiseJSON(obj)
end
---Serializes a lua object into lua coded
---@param obj any
---@return string
local function s(obj)
    return __LEGACY.textutils.serialize(obj)
end
---Deserializes lua code
---@param obj string
---@return any
local function d(obj)
    return __LEGACY.textutils.unserialize(obj)
end
---Splits string by seperator
---@param inputstr string
---@param sep string
---@return table
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
    local nt = {}
    for i, v in ipairs(t) do
        if v ~= "" then
            table.insert(nt, v)
        end
    end
    if t == {} then
        t = { "" }
    end
    return nt
end
---Joins an table by seperators
---@param tab table
---@param sep string
---@return string
---@deprecated Use table.concat
local function join(tab, sep )
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out-1)
end

---Formats time
---@param t number
---@param tfhour boolean?
---@return string
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
