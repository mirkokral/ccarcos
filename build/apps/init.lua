if pocket then
    arcos.r({}, "/apps/elevator.lua")
elseif devices.find("playerDetector") then
    arcos.r({}, "/apps/elevatorStep.lua")
elseif devices.find("modem") then
    arcos.r({}, "/apps/elevatorSrv.lua")
else
    arcos.r({}, "shell")
end