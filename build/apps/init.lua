if pocket then
    __LEGACY.shell.run("/apps/elevator.lua")
elseif devices.find("playerDetector") then
    __LEGACY.shell.run("/apps/elevatorStep.lua")
elseif devices.find("modem") then
    __LEGACY.shell.run("/apps/elevatorSrv.lua")
else
    __LEGACY.shell.run("shell")
end