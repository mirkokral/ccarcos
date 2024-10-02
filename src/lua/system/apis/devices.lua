local syscall = require("syscall")

---@class DeviceND
---@field name string
---@field types string[]
---@field sendData fun(data: string): nil
---@field recvData fun(): string
---@field onEvent fun(...): nil
---@field onActivate fun(): nil
---@field onDeactivate fun(): nil

---@alias Device DeviceND | any

local devices = {}
devices = {
    ---Gets if a device with name exists
    ---@param name string
    ---@return boolean
    present = function(name)
        local names = devices.names()
        for _, v in ipairs(names) do
            if v == name then
                return true
            end
        end
        return false
    end,
    ---Gets the types of a device
    ---@param dev Device
    ---@return string ...
    type = function(dev)
        return table.unpack(dev.types)
    end,
    ---Gets if a deivce has a type
    ---@param dev Device
    ---@param type string
    ---@return boolean
    hasType = function(dev, type)
        for _, v in ipairs(dev.types) do
            if v == type then
                return true
            end
        end
        return false
    end,
    ---Gets all methods of a device
    ---@param name any
    methods = function(name)

    end,
    ---Gets the name of a device
    ---@param peripheral Device
    name = function(peripheral)
        return peripheral.name
    end,
    ---Calls a method on a device
    ---@param name string Device name
    ---@param method string Method name
    ---@param ... any
    ---@return any
    call = function(name, method, ...)
        return devices.get(name)[method](...)
    end,
    ---Gets a device from name
    ---@param what string? Device name
    ---@return Device
    get = function(what)
        return syscall.run("devices.get", what)
    end,
    ---Finds a device by type
    ---@param what string Device type
    ---@return Device
    find = function(what)
        return syscall.run("devices.find", what)
    end,
    ---Gets all device names
    ---@return string[]
    names = function()
        return syscall.run("devices.names")
    end,

}
return devices