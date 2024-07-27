function setO(side, value)
    assert(type(value) == "number" or type(value) == "boolean", "Invalid argument: value")
    assert(type(side) == "string", "Invalid argument: side")
    if type(value) == "number" then
        __LEGACY.redstone.setAnalogOutput(side, value)
    elseif type(value) == "boolean" then
        __LEGACY.redstone.setOutput(side, value)
    end
end
function getO(side)
    return __LEGACY.redstone.getAnalogOutput(side)
end
function getI(side)
    return __LEGACY.redstone.getAnalogInput(side)
end