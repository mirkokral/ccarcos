function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        __LEGACY.redstone.setAnalogOutput(sd, val)
        print("numset")
    elseif type(val) == "boolean" then
        __LEGACY.redstone.setOutput(sd, val)
        print("boolset")
    end
end
function getO(side)
    return __LEGACY.redstone.getAnalogOutput(side)
end
function getI(side)
    return __LEGACY.redstone.getAnalogInput(side)
end