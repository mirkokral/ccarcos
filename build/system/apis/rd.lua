local function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        __LEGACY.redstone.setAnalogOutput(sd, val)
    elseif type(val) == "boolean" then
        __LEGACY.redstone.setOutput(sd, val)
    end
end
local function getO(side)
    return __LEGACY.redstone.getAnalogOutput(side)
end
local function getI(side)
    return __LEGACY.redstone.getAnalogInput(side)
end
local function setBO(sd, bitmask)
    return __LEGACY.redstone.setBundledOutput(sd, bitmask)
end
local function getBO(sd)
    return __LEGACY.redstone.getBundledOutput(sd)
end
local function getBI(sd)
    return __LEGACY.redstone.getBundledInput(sd)
end
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
