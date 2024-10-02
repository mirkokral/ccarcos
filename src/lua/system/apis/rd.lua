local syscall = require("syscall")

---@alias Side "top" | "bottom" | "left" | "right" | "front" | "back"

---Sets the output of a side
---@param sd Side
---@param val number | boolean
local function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        syscall.rs.set(sd, val)
        -- print("numset")
    elseif type(val) == "boolean" then
        syscall.rs.set(sd, val and 15 or 0)
        -- print("boolset")
    end
end
---Gets the output of a side
---@param side Side
---@return number
local function getO(side)
    return syscall.rs.getO(side)
end
---Gets the input of a side
---@param side Side
---@return number
local function getI(side)
    return syscall.rs.getI(side)
end

---Sets the output bitmask of a side
---@param sd Side
---@param bitmask Color
local function setBO(sd, bitmask)
    return syscall.rs.setBO(sd, bitmask)
end

---Gets the output bitmask of a side
---@param sd Side
local function getBO(sd)
    return syscall.rs.getBO(sd)
end

---Gets the input bitmask of a side
---@param sd Side
local function getBI(sd)
    return syscall.rs.getBI(sd)
end

---Tests the input bitmask of a side
---@param sd Side
---@param test Color
local function testBI(sd, test)
    return syscall.rs.testBI(sd, test)
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
