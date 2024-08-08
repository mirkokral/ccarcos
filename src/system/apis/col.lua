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

---Excepts
---@param n number Argument index
---@param v any Argument
---@param ... type type
local function expect(n, v, ...)
    r = false
    for index, value in ipairs({ ... }) do
        if type(v) == value then
            r = true
            break
        end
    end
    if not r then
        error("Argument " .. n .. " is not valid!")
    end
end


local function combine(...)
    local r = 0
    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i, c, "number")
        r = bit32.bor(r, c)
    end
    return r
end

local function subtract(colors, ...)
    expect(1, colors, "number")
    local r = colors
    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i + 1, c, "number")
        r = bit32.band(r, bit32.bnot(c))
    end
    return r
end

local function test(colors, color)
    expect(1, colors, "number")
    expect(2, color, "number")
    return bit32.band(colors, color) == color
end

local function packRGB(r, g, b)
    expect(1, r, "number")
    expect(2, g, "number")
    expect(3, b, "number")
    return
        bit32.band(r * 255, 0xFF) * 2 ^ 16 +
        bit32.band(g * 255, 0xFF) * 2 ^ 8 +
        bit32.band(b * 255, 0xFF)
end

local function unpackRGB(rgb)
    expect(1, rgb, "number")
    return
        bit32.band(bit32.rshift(rgb, 16), 0xFF) / 255,
        bit32.band(bit32.rshift(rgb, 8), 0xFF) / 255,
        bit32.band(rgb, 0xFF) / 255
end

local function rgb8(r, g, b)
    if g == nil and b == nil then
        return unpackRGB(r)
    else
        return packRGB(r, g, b)
    end
end

-- Colour to hex lookup table for toBlit
local color_hex_lookup = {}
for i = 0, 15 do
    color_hex_lookup[2 ^ i] = string.format("%x", i)
end
local function toBlit(color)
    expect(1, color, "number")
    local hex = color_hex_lookup[color]
    if hex then return hex end

    if color < 0 or color > 0xffff then error("Colour out of range", 2) end
    return string.format("%x", math.floor(math.log(color, 2)))
end
local function fromBlit(hex)
    expect(1, hex, "string")

    if #hex ~= 1 then return nil end
    local value = tonumber(hex, 16)
    if not value then return nil end

    return 2 ^ value
end
local function get_display_type(value, t)
    -- Lua is somewhat inconsistent in whether it obeys __name just for values which
    -- have a per-instance metatable (so tables/userdata) or for everything. We follow
    -- Cobalt and only read the metatable for tables/userdata.
    if t ~= "table" and t ~= "userdata" then return t end

    local metatable = debug.getmetatable(value)
    if not metatable then return t end

    local name = rawget(metatable, "__name")
    if type(name) == "string" then return name else return t end
end
local function get_type_names(...)
    local types = table.pack(...)
    for i = types.n, 1, -1 do
        if types[i] == "nil" then table.remove(types, i) end
    end

    if #types <= 1 then
        return tostring(...)
    else
        return table.concat(types, ", ", 1, #types - 1) .. " or " .. types[#types]
    end
end
local function field(tbl, index, ...)
    expect(1, tbl, "table")
    expect(2, index, "string")

    local value = tbl[index]
    local t = type(value)
    for i = 1, select("#", ...) do
        if t == select(i, ...) then return value end
    end

    t = get_display_type(value, t)

    if value == nil then
        error(("field '%s' missing from table"):format(index), 3)
    else
        error(("bad field '%s' (%s expected, got %s)"):format(index, get_type_names(...), t), 3)
    end
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
    grey = gray,
    lightGray = lightGray,
    lightGrey = lightGray,
    cyan = cyan,
    purple = purple,
    blue = blue,
    brown = brown,
    green = green,
    red = red,
    black = black,
    combine = combine,
    subtract = subtract,
    test = test,
    packRGB = packRGB,
    unpackRGB = unpackRGB,
    rgb8 = rgb8,
    toBlit = toBlit,
    fromBlit = fromBlit,
    expect = expect,
    field = field
}