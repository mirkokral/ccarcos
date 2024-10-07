local expect = require("col").expect

local function getArgs(fun)
    local args = {}
    local hook, mask, count = debug.gethook()

    local argHook = function(...)
        local info = debug.getinfo(3)
        if 'pcall' ~= info.name then return end

        for i = 1, math.huge do
            local name, value = debug.getlocal(2, i)
            if '(*temporary)' == name then
                debug.sethook(hook, mask, count)
                error('')
                return
            end
            table.insert(args, name)
        end
    end

    debug.sethook(argHook, "c")
    pcall(fun)

    return args
end
local function serializeTable(val, name, skipnewlines, depth, doColors)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. (doColors and "\011f7" or "") .. "[" .. (doColors and "\011fd" or "") .. serializeTable(name, nil, true, 0, false) .. (doColors and "\011f7" or "") .. "]" .. (doColors and "\011f8" or "") .. " = " end

    if type(val) == "table" then
        tmp = tmp .. (doColors and "\011f8" or "") .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1, doColors) .. (doColors and "\011f7" or "") .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. (doColors and "\011f8" or "") .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. (doColors and "\011f9" or "") .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. (doColors and "\011f4" or "") .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (doColors and "\011f2" or "") .. (val and "true" or "false")
    elseif type(val) == "nil" then
        tmp = tmp .. (doColors and "\011fe" or "") .. "nil"
    elseif type(val) == "function" then
        tmp = tmp .. (doColors and "\011fb" or "") .. "function(" .. table.concat(getArgs(val), ", ") .. ") end"
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end
---Serializes an object into JSON
---@param obj any
---@return string
local function sJSON(obj)
    return json.encode(obj)
end
---Deserializes a JSON string
---@param obj string
---@return any
local function dJSON(obj)
    return json.decode(obj)
end
---Serializes a lua object into lua coded
---@param obj any
---@return string
local function s(obj, dc)
    return serializeTable(obj, nil, false, 0, dc)
end
---Deserializes lua code
---@param obj string
---@return any
local function d(obj)
    return load("return " .. d)()
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
local function join(tab, sep)
    local out = ""
    for _, i in ipairs(tab) do
        out = out .. tostring(i) .. sep
    end
    return out:sub(1, #out - 1)
end

---Formats time
---@param t number
---@param tfhour boolean?
---@return string
local function formatTime(t, tfhour)
    expect(1, t, "number")
    expect(2, tfhour, "boolean", "nil")
    local sTOD = nil
    if not tfhour then
        if t >= 12 then
            sTOD = "PM"
        else
            sTOD = "AM"
        end
        if t >= 13 then
            t = t - 12
        end
    end

    local nHour = math.floor(t)
    local nMinute = math.floor((t - nHour) * 60)
    if sTOD then
        return string.format("%d:%02d %s", nHour == 0 and 12 or nHour, nMinute, sTOD)
    else
        return string.format("%d:%02d", nHour, nMinute)
    end
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
