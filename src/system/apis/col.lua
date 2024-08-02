---@alias Color number

-- C:Exc
---@type {white: Color, orange: Color, magenta: Color, lightBlue: Color, yellow: Color, lime: Color, pink: Color, gray: Color, lightGray: Color, cyan: Color, purple: Color, blue: Color, brown: Color, green: Color, red: Color, black: Color, fromBlit: fun(hex: string): Color, toBlit: fun(c: Color): string}
_G.col = {}
-- C:End

---White: Written as `0` in paint files and [`term.blit`], has a default
---@type Color
white = 0x1

---Orange: Written as `1` in paint files and [`term.blit`], has a
---@type Color
orange = 0x2

---Magenta: Written as `2` in paint files and [`term.blit`], has a
---@type Color
magenta = 0x4

---Light blue: Written as `3` in paint files and [`term.blit`], has a
---@type Color
lightBlue = 0x8

---Yellow: Written as `4` in paint files and [`term.blit`], has a
---@type Color
yellow = 0x10

---Lime: Written as `5` in paint files and [`term.blit`], has a default
---@type Color
lime = 0x20

---Pink: Written as `6` in paint files and [`term.blit`], has a default
---@type Color
pink = 0x40

---Gray: Written as `7` in paint files and [`term.blit`], has a default
---@type Color
gray = 0x80

---Light gray: Written as `8` in paint files and [`term.blit`], has a
---@type Color
lightGray = 0x100

---Cyan: Written as `9` in paint files and [`term.blit`], has a default
---@type Color
cyan = 0x200

---Purple: Written as `a` in paint files and [`term.blit`], has a
---@type Color
purple = 0x400

---Blue: Written as `b` in paint files and [`term.blit`], has a default
---@type Color
blue = 0x800

---Brown: Written as `c` in paint files and [`term.blit`], has a default
---@type Color
brown = 0x1000

---Green: Written as `d` in paint files and [`term.blit`], has a default
---@type Color
green = 0x2000

---Red: Written as `e` in paint files and [`term.blit`], has a default
---@type Color
red = 0x4000

---Black: Written as `f` in paint files and [`term.blit`], has a default
---@type Color
black = 0x8000

---comment
---@param hex string
---@return Color?
function fromBlit(hex)
    assert(hex == "string")

    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end

    return 2 ^ value
end

---Changes col to blit
---@param h Color
---@return string?
function toBlit(h)
    return __LEGACY.colors.toBlit(h)
end