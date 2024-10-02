local side = ...
if not periphemu then
    error("Not running inside of a compatible emulator.")
end
if type(side) ~= "string" then
    error("Invalid arguments. Usage: detach <side>")
end
periphemu.remove(side)