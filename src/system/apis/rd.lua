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

---Sets the output bitmask of a side
---@param sd Side
---@param bitmask Color
local function setBO(sd, bitmask)
    return __LEGACY.redstone.setBundledOutput(sd, bitmask)
end

---Gets the output bitmask of a side
---@param sd Side
local function getBO(sd)
    return __LEGACY.redstone.getBundledOutput(sd)
end

---Gets the input bitmask of a side
---@param sd Side
local function getBI(sd)
    return __LEGACY.redstone.getBundledInput(sd)
end

---Tests the input bitmask of a side
---@param sd Side
---@param test Color
local function testBI(sd, test)
    return __LEGACY.redstone.testtBundledInput(sd, test)
end

return {
    setO = setO,
    getO = getO,
    getI = getI,
    setBO = setBO,
    getBO = getBO,
    getBI = getBI,
    testBI = testBI,
}
