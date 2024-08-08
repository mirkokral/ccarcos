---@alias Side "top" | "bottom" | "left" | "right" | "front" | "back"

---Sets the output of a side
---@param sd Side
---@param val number | boolean
local function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        __LEGACY.redstone.setAnalogOutput(sd, val)
        -- print("numset")
    elseif type(val) == "boolean" then
        __LEGACY.redstone.setOutput(sd, val)
        -- print("boolset")
    end
end
---Gets the output of a side
---@param side Side
---@return number
local function getO(side)
    return __LEGACY.redstone.getAnalogOutput(side)
end
---Gets the input of a side
---@param side Side
---@return number
local function getI(side)
    return __LEGACY.redstone.getAnalogInput(side)
end

return {
    setO = setO,
    getO = getO,
    getI = getI
}
