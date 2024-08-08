---@alias Color number

---White: Written as `0` in paint files and [`term.blit`], has a default
---@type Color
local white = 0x1

---Orange: Written as `1` in paint files and [`term.blit`], has a
---@type Color
local orange = 0x2

---Magenta: Written as `2` in paint files and [`term.blit`], has a
---@type Color
local magenta = 0x4

---Light blue: Written as `3` in paint files and [`term.blit`], has a
---@type Color
local lightBlue = 0x8

---Yellow: Written as `4` in paint files and [`term.blit`], has a
---@type Color
local yellow = 0x10

---Lime: Written as `5` in paint files and [`term.blit`], has a default
---@type Color
local lime = 0x20

---Pink: Written as `6` in paint files and [`term.blit`], has a default
---@type Color
local pink = 0x40

---Gray: Written as `7` in paint files and [`term.blit`], has a default
---@type Color
local gray = 0x80

---Light gray: Written as `8` in paint files and [`term.blit`], has a
---@type Color
local lightGray = 0x100

---Cyan: Written as `9` in paint files and [`term.blit`], has a default
---@type Color
local cyan = 0x200

---Purple: Written as `a` in paint files and [`term.blit`], has a
---@type Color
local purple = 0x400

---Blue: Written as `b` in paint files and [`term.blit`], has a default
---@type Color
local blue = 0x800

---Brown: Written as `c` in paint files and [`term.blit`], has a default
---@type Color
local brown = 0x1000

---Green: Written as `d` in paint files and [`term.blit`], has a default
---@type Color
local green = 0x2000

---Red: Written as `e` in paint files and [`term.blit`], has a default
---@type Color
local red = 0x4000

---Black: Written as `f` in paint files and [`term.blit`], has a default
---@type Color
local black = 0x8000

---comment
---@param hex string
---@return Color?
local function fromBlit(hex)
    assert(type(hex) == "string")

    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end

    return 2 ^ value
end

---Changes col to blit
---@param h Color
---@return string?
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