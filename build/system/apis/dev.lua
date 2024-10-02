local devices = require("devices")
return setmetatable({}, {
    __index = function(t, k)
        return devices.find(k)
    end
})