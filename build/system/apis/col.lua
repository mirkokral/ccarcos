local white = 0x1
local orange = 0x2
local magenta = 0x4
local lightBlue = 0x8
local yellow = 0x10
local lime = 0x20
local pink = 0x40
local gray = 0x80
local lightGray = 0x100
local cyan = 0x200
local purple = 0x400
local blue = 0x800
local brown = 0x1000
local green = 0x2000
local red = 0x4000
local black = 0x8000
local function fromBlit(hex)
    assert(type(hex) == "string")
    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end
    return 2 ^ value
end
local function toBlit(h)
    return __LEGACY.colors.toBlit(h)
end
return {
    white = white,
    orange = orange,
    magenta = magenta,
    lightBlue = lightBlue,
    yellow = yellow,
    lime = lime,
    pink = pink,
    gray = gray,
    lightGray = lightGray,
    cyan = cyan,
    purple = purple,
    blue = blue,
    brown = brown,
    green = green,
    red = red,
    black = black,
    fromBlit = fromBlit,
    toBlit = toBlit,
}