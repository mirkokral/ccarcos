local syscall = require("syscall")
local function setO(sd, val)
    assert(type(val) == "number" or type(val) == "boolean", "Invalid argument: value")
    assert(type(sd) == "string", "Invalid argument: side")
    if type(val) == "number" then
        syscall.rs.set(sd, val)
    elseif type(val) == "boolean" then
        syscall.rs.set(sd, val and 15 or 0)
    end
end
local function getO(side)
    return syscall.rs.getO(side)
end
local function getI(side)
    return syscall.rs.getI(side)
end
local function setBO(sd, bitmask)
    return syscall.rs.setBO(sd, bitmask)
end
local function getBO(sd)
    return syscall.rs.getBO(sd)
end
local function getBI(sd)
    return syscall.rs.getBI(sd)
end
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
