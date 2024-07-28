if pocket then
    __LEGACY.shell.run("/apps/elevator.lua")
elseif devices.find("playerDetector") then
    __LEGACY.shell.run("/apps/elevatorStep.lua")
else
    __LEGACY.shell.run("shell")
end