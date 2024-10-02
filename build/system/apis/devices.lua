local syscall = require("syscall")
local devices = {}
devices = {
    present = function(name)
        local names = devices.names()
        for _, v in ipairs(names) do
            if v == name then
                return true
            end
        end
        return false
    end,
    type = function(dev)
        return table.unpack(dev.types)
    end,
    hasType = function(dev, type)
        for _, v in ipairs(dev.types) do
            if v == type then
                return true
            end
        end
        return false
    end,
    methods = function(name)
    end,
    name = function(peripheral)
        return peripheral.name
    end,
    call = function(name, method, ...)
        return devices.get(name)[method](...)
    end,
    get = function(what)
        return syscall.run("devices.get", what)
    end,
    find = function(what)
        return syscall.run("devices.find", what)
    end,
    names = function()
        return syscall.run("devices.names")
    end,
}
return devices