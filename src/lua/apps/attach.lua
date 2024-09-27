local side, ptype = ...
if not periphemu then
    error("Not running inside of a compatible emulator.")
end
if type(side) ~= "string" or type(ptype) ~= "string" then
    error("Invalid arguments. Usage: attach <side> <ptype>")
end

periphemu.create(side, ptype)