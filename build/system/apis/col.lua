white = 0x1
orange = 0x2
magenta = 0x4
lightBlue = 0x8
yellow = 0x10
lime = 0x20
pink = 0x40
gray = 0x80
lightGray = 0x100
cyan = 0x200
purple = 0x400
blue = 0x800
brown = 0x1000
green = 0x2000
red = 0x4000
black = 0x8000
function fromBlit(hex)
    assert(hex == "string")
    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end
    return 2 ^ value
end