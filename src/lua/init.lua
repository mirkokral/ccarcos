_G.bit32 = package.preload.bi32
_G.bit = package.preload.bit
local term = require("term")
local fs = require("fs")
local mach = require("machine")
local timer = require("timer")
local http = require("http")
local event = require("event")
term.clear()
term.setPos(1, 1)
term.write("Hi")
if arcos or xnarcos then return end
local function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    if inputstr == nil then
        return { "" }
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    if t == {} then
        t = { inputstr }
    end
    local nt = {}
    for i, v in ipairs(t) do
        if v ~= "" then
            table.insert(nt, v)
        end
    end
    if nt == {} then
        nt = { "" }
    end
    return nt
end
local __LEGACY = {}
for k, v in pairs(_G) do
    __LEGACY[k] = v
end
__LEGACY["_G"] = __LEGACY
_G.read = function(_sReplaceChar, _tHistory, _fnComplete, _sDefault)
    term.setCursorBlink(true)
    local sLine
    if type(_sDefault) == "string" then
        sLine = _sDefault
    else
        sLine = ""
    end
    local nHistoryPos
    local nPos, nScroll = #sLine, 0
    if _sReplaceChar then
        _sReplaceChar = string.sub(_sReplaceChar, 1, 1)
    end
    local tCompletions
    local nCompletion
    local function recomplete()
        if _fnComplete and nPos == #sLine then
            tCompletions = _fnComplete(sLine)
            if tCompletions and #tCompletions > 0 then
                nCompletion = 1
            else
                nCompletion = nil
            end
        else
            tCompletions = nil
            nCompletion = nil
        end
    end
    local function uncomplete()
        tCompletions = nil
        nCompletion = nil
    end
    local w = term.getSize()
    local sx = term.getCursorPos()
    local function redraw(_bClear)
        local cursor_pos = nPos - nScroll
        if sx + cursor_pos >= w then
            nScroll = sx + nPos - w
        elseif cursor_pos < 0 then
            nScroll = nPos
        end
        local _, cy = term.getCursorPos()
        term.setCursorPos(sx, cy)
        local sReplace = _bClear and " " or _sReplaceChar
        if sReplace then
            term.write(string.rep(sReplace, math.max(#sLine - nScroll, 0)))
        else
            term.write(string.sub(sLine, nScroll + 1))
        end
        if nCompletion then
            local sCompletion = tCompletions[nCompletion]
            local oldText, oldBg
            if not _bClear then
                oldText = term.getTextColor()
                oldBg = term.getBackgroundColor()
                term.setTextColor(__LEGACY.colors.white)
                term.setBackgroundColor(__LEGACY.colors.gray)
            end
            if sReplace then
                term.write(string.rep(sReplace, #sCompletion))
            else
                term.write(sCompletion)
            end
            if not _bClear then
                term.setTextColor(oldText)
                term.setBackgroundColor(oldBg)
            end
        end
        term.setCursorPos(sx + nPos - nScroll, cy)
    end
    local function clear()
        redraw(true)
    end
    recomplete()
    redraw()
    local function acceptCompletion()
        if nCompletion then
            clear()
            local sCompletion = tCompletions[nCompletion]
            sLine = sLine .. sCompletion
            nPos = #sLine
            recomplete()
            redraw()
        end
    end
    while true do
        local sEvent, param, param1, param2 = coroutine.yield()
        if sEvent == "char" then
            clear()
            sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
            nPos = nPos + 1
            recomplete()
            redraw()
        elseif sEvent == "paste" then
            clear()
            sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
            nPos = nPos + #param
            recomplete()
            redraw()
        elseif sEvent == "key" then
            if param == __LEGACY.keys.enter or param == __LEGACY.keys.numPadEnter then
                if nCompletion then
                    clear()
                    uncomplete()
                    redraw()
                end
                break
            elseif param == __LEGACY.keys.left then
                if nPos > 0 then
                    clear()
                    nPos = nPos - 1
                    recomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys.right then
                if nPos < #sLine then
                    clear()
                    nPos = nPos + 1
                    recomplete()
                    redraw()
                else
                    acceptCompletion()
                end
            elseif param == __LEGACY.keys.up or param == __LEGACY.keys.down then
                if nCompletion then
                    clear()
                    if param == __LEGACY.keys.up then
                        nCompletion = nCompletion - 1
                        if nCompletion < 1 then
                            nCompletion = #tCompletions
                        end
                    elseif param == __LEGACY.keys.down then
                        nCompletion = nCompletion + 1
                        if nCompletion > #tCompletions then
                            nCompletion = 1
                        end
                    end
                    redraw()
                elseif _tHistory then
                    clear()
                    if param == __LEGACY.keys.up then
                        if nHistoryPos == nil then
                            if #_tHistory > 0 then
                                nHistoryPos = #_tHistory
                            end
                        elseif nHistoryPos > 1 then
                            nHistoryPos = nHistoryPos - 1
                        end
                    else
                        if nHistoryPos == #_tHistory then
                            nHistoryPos = nil
                        elseif nHistoryPos ~= nil then
                            nHistoryPos = nHistoryPos + 1
                        end
                    end
                    if nHistoryPos then
                        sLine = _tHistory[nHistoryPos]
                        nPos, nScroll = #sLine, 0
                    else
                        sLine = ""
                        nPos, nScroll = 0, 0
                    end
                    uncomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys.backspace then
                if nPos > 0 then
                    clear()
                    sLine = string.sub(sLine, 1, nPos - 1) .. string.sub(sLine, nPos + 1)
                    nPos = nPos - 1
                    if nScroll > 0 then nScroll = nScroll - 1 end
                    recomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys.home then
                if nPos > 0 then
                    clear()
                    nPos = 0
                    recomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys.delete then
                if nPos < #sLine then
                    clear()
                    sLine = string.sub(sLine, 1, nPos) .. string.sub(sLine, nPos + 2)
                    recomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys["end"] then
                if nPos < #sLine then
                    clear()
                    nPos = #sLine
                    recomplete()
                    redraw()
                end
            elseif param == __LEGACY.keys.tab then
                acceptCompletion()
            end
        elseif sEvent == "mouse_click" or sEvent == "mouse_drag" and param == 1 then
            local _, cy = term.getCursorPos()
            if param1 >= sx and param1 <= w and param2 == cy then
                nPos = math.min(math.max(nScroll + param1 - sx, 0), #sLine)
                redraw()
            end
        elseif sEvent == "term_resize" then
            w = term.getSize()
            redraw()
        end
    end
    local _, cy = term.getCursorPos()
    term.setCursorBlink(false)
    term.setCursorPos(0, cy)
    write("\n")
    return sLine
end
_G.json = (function()
    local json = { _version = "0.1.2" }
    local encode
    local escape_char_map = {
        ["\\"] = "\\",
        ["\""] = "\"",
        ["\b"] = "b",
        ["\f"] = "f",
        ["\n"] = "n",
        ["\r"] = "r",
        ["\t"] = "t",
    }
    local escape_char_map_inv = { ["/"] = "/" }
    for k, v in pairs(escape_char_map) do
        escape_char_map_inv[v] = k
    end
    local function escape_char(c)
        return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
    end
    local function encode_nil(val)
        return "null"
    end
    local function encode_table(val, stack)
        local res = {}
        stack = stack or {}
        if stack[val] then error("circular reference") end
        stack[val] = true
        if rawget(val, 1) ~= nil or next(val) == nil then
            local n = 0
            for k in pairs(val) do
                if type(k) ~= "number" then
                    error("invalid table: mixed or invalid key types")
                end
                n = n + 1
            end
            if n ~= #val then
                error("invalid table: sparse array")
            end
            for i, v in ipairs(val) do
                table.insert(res, encode(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        else
            for k, v in pairs(val) do
                if type(k) ~= "string" then
                    error("invalid table: mixed or invalid key types")
                end
                table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
            end
            stack[val] = nil
            return "{" .. table.concat(res, ",") .. "}"
        end
    end
    local function encode_string(val)
        return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
    end
    local function encode_number(val)
        if val ~= val or val <= -math.huge or val >= math.huge then
            error("unexpected number value '" .. tostring(val) .. "'")
        end
        return string.format("%.14g", val)
    end
    local type_func_map = {
        ["nil"] = encode_nil,
        ["table"] = encode_table,
        ["string"] = encode_string,
        ["number"] = encode_number,
        ["boolean"] = tostring,
    }
    encode = function(val, stack)
        local t = type(val)
        local f = type_func_map[t]
        if f then
            return f(val, stack)
        end
        error("unexpected type '" .. t .. "'")
    end
    function json.encode(val)
        return (encode(val))
    end

    local parse
    local function create_set(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[select(i, ...)] = true
        end
        return res
    end
    local space_chars  = create_set(" ", "\t", "\r", "\n")
    local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
    local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
    local literals     = create_set("true", "false", "null")
    local literal_map  = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil,
    }
    local function next_char(str, idx, set, negate)
        for i = idx, #str do
            if set[str:sub(i, i)] ~= negate then
                return i
            end
        end
        return #str + 1
    end
    local function decode_error(str, idx, msg)
        local line_count = 1
        local col_count = 1
        for i = 1, idx - 1 do
            col_count = col_count + 1
            if str:sub(i, i) == "\n" then
                line_count = line_count + 1
                col_count = 1
            end
        end
        error(string.format("%s at line %d col %d", msg, line_count, col_count))
    end
    local function codepoint_to_utf8(n)
        local f = math.floor
        if n <= 0x7f then
            return string.char(n)
        elseif n <= 0x7ff then
            return string.char(f(n / 64) + 192, n % 64 + 128)
        elseif n <= 0xffff then
            return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
        elseif n <= 0x10ffff then
            return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                f(n % 4096 / 64) + 128, n % 64 + 128)
        end
        error(string.format("invalid unicode codepoint '%x'", n))
    end
    local function parse_unicode_escape(s)
        local n1 = tonumber(s:sub(1, 4), 16)
        local n2 = tonumber(s:sub(7, 10), 16)
        if n2 then
            return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
        else
            return codepoint_to_utf8(n1)
        end
    end
    local function parse_string(str, i)
        local res = ""
        local j = i + 1
        local k = j
        while j <= #str do
            local x = str:byte(j)
            if x < 32 then
                decode_error(str, j, "control character in string")
            elseif x == 92 then -- `\`: Escape
                res = res .. str:sub(k, j - 1)
                j = j + 1
                local c = str:sub(j, j)
                if c == "u" then
                    local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                        or str:match("^%x%x%x%x", j + 1)
                        or decode_error(str, j - 1, "invalid unicode escape in string")
                    res = res .. parse_unicode_escape(hex)
                    j = j + #hex
                else
                    if not escape_chars[c] then
                        decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                    end
                    res = res .. escape_char_map_inv[c]
                end
                k = j + 1
            elseif x == 34 then -- `"`: End of string
                res = res .. str:sub(k, j - 1)
                return res, j + 1
            end
            j = j + 1
        end
        decode_error(str, i, "expected closing quote for string")
    end
    local function parse_number(str, i)
        local x = next_char(str, i, delim_chars)
        local s = str:sub(i, x - 1)
        local n = tonumber(s)
        if not n then
            decode_error(str, i, "invalid number '" .. s .. "'")
        end
        return n, x
    end
    local function parse_literal(str, i)
        local x = next_char(str, i, delim_chars)
        local word = str:sub(i, x - 1)
        if not literals[word] then
            decode_error(str, i, "invalid literal '" .. word .. "'")
        end
        return literal_map[word], x
    end
    local function parse_array(str, i)
        local res = {}
        local n = 1
        i = i + 1
        while 1 do
            local x
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) == "]" then
                i = i + 1
                break
            end
            x, i = parse(str, i)
            res[n] = x
            n = n + 1
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "]" then break end
            if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
        end
        return res, i
    end
    local function parse_object(str, i)
        local res = {}
        i = i + 1
        while 1 do
            local key, val
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) == "}" then
                i = i + 1
                break
            end
            if str:sub(i, i) ~= '"' then
                decode_error(str, i, "expected string for key")
            end
            key, i = parse(str, i)
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) ~= ":" then
                decode_error(str, i, "expected ':' after key")
            end
            i = next_char(str, i + 1, space_chars, true)
            val, i = parse(str, i)
            res[key] = val
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "}" then break end
            if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
        end
        return res, i
    end
    local char_func_map = {
        ['"'] = parse_string,
        ["0"] = parse_number,
        ["1"] = parse_number,
        ["2"] = parse_number,
        ["3"] = parse_number,
        ["4"] = parse_number,
        ["5"] = parse_number,
        ["6"] = parse_number,
        ["7"] = parse_number,
        ["8"] = parse_number,
        ["9"] = parse_number,
        ["-"] = parse_number,
        ["t"] = parse_literal,
        ["f"] = parse_literal,
        ["n"] = parse_literal,
        ["["] = parse_array,
        ["{"] = parse_object,
    }
    parse = function(str, idx)
        local chr = str:sub(idx, idx)
        local f = char_func_map[chr]
        if f then
            return f(str, idx)
        end
        decode_error(str, idx, "unexpected character '" .. chr .. "'")
    end
    function json.decode(str)
        if type(str) ~= "string" then
            error("expected argument of type string, got " .. type(str))
        end
        local res, idx = parse(str, next_char(str, 1, space_chars, true))
        idx = next_char(str, idx, space_chars, true)
        if idx <= #str then
            decode_error(str, idx, "trailing garbage")
        end
        return res
    end

    return json
end)()
local tPallete = {
    0xF0F0F0,
    0xF2B233,
    0xE57FD8,
    0x99B2F2,
    0xDEDE6C,
    0x7FCC19,
    0xF2B2CC,
    0x4C4C4C,
    0x999999,
    0x4C99B2,
    0xB266E5,
    0x3366CC,
    0x7F664C,
    0x57A64E,
    0xCC4C4C,
    0x111111,
}
_G.KDriversImpl = {
    platform = "Capy64",
    files = {
        open = function(path, mode)
            local link = fs.open(path, mode)
            return {
                close = function() link:close() end,
                write = function(w)
                    link:write(w)
                end,
                read = function(count)
                    return link:read(count)
                end,
                readAll = function()
                    return link:read("*all")
                end,
                readLine = function()
                    return link:read("*l")
                end,
                seek = function(whence, offset)
                    link:seek(whence, offset)
                end,
                flush = function()
                    link:flush()
                end
            }
        end,
        list = function(path)
            return fs.list(path)
        end,
        type = function(path)
            return fs.isDir(path) and "directory" or "file"
        end,
        exists = function(path)
            return fs.exists(path)
        end,
        copy = function(src, dest)
            return fs.copy(src, dest)
        end,
        unlink = function(path)
            return fs.delete(path)
        end,
        mkDir = function(path)
            return fs.makeDir(path)
        end,
        attributes = function(path)
            local attr = fs.attributes(path)
            attr.capacity = 1024 * 1024 * 1024 -- 1 GB
            attr.driveRoot = false
            return attr
        end,
        getPermissions = function(file, user)
            if strsplit(file, "/") == { file } then
                return {
                    read = true,
                    write = true,
                    listed = true
                }
            end
            local read = true
            local write = true
            local listed = true
            if fs.isReadOnly(file) then
                write = false
            end
            local fpn = strsplit(file, "/")
            if #fpn == 0 then fpn = { "" } end
            if fpn[#fpn]:sub(1, 1) == "$" then -- Metadata files
                return {
                    read = false,
                    write = false,
                    listed = false
                }
            end
            local disallowedfiles = { "startup.lua", "startup" }
            for index, value in ipairs(disallowedfiles) do
                if fpn[1] == value then -- Metadata files
                    return {
                        read = user == "root",
                        write = user == "root",
                        listed = false,
                    }
                end
            end
            if fpn[#fpn]:sub(1, 1) == "." then
                listed = false
            end
            return {
                read = read,
                write = write,
                listed = listed,
            }
        end
    },
    terminal = {
        write = function(str)
            term.write(str)
        end,
        clear = function()
            term.clear()
        end,
        getCursorPos = function()
            return term.getPos()
        end,
        setCursorPos = function(x, y)
            term.setPos(x, y)
        end,
        getCursorBlink = function()
            return term.getBlink()
        end,
        setCursorBlink = function(blink)
            term.setBlink(blink)
        end,
        isColor = function()
            return true
        end,
        getSize = function()
            return term.getSize()
        end,
        setTextColor = function(color)
            print(math.log(color,2)+1);
            print(color);
            term.setForeground(tPallete[math.log(color,2)+1])
        end,
        getTextColor = function()
            return term.getForeground()
        end,
        setBackgroundColor = function(color)
            print(math.log(color,2)+1);
            print(color);
            term.setBackground(tPallete[math.log(color,2)+1])
        end,
        getBackgroundColor = function()
            return term.getBackground()
        end,
        setPaletteColor = function(color, r, g, b)
            local ra = string.format("%x", r)
            local ga = string.format("%x", g)
            local ba = string.format("%x", b)
            if #ra == 1 then ra = "0" .. ra end
            if #ga == 1 then ga = "0" .. ga end
            if #ba == 1 then ba = "0" .. ba end
            tPallete[math.log(color,2)+1] = tonumber(ra .. ga .. ba, 16)
        end,
        setPaletteColour = function(color, r, g, b)
            local ra = string.format("%x", r)
            local ga = string.format("%x", g)
            local ba = string.format("%x", b)
            if #ra == 1 then ra = "0" .. ra end
            if #ga == 1 then ga = "0" .. ga end
            if #ba == 1 then ba = "0" .. ba end
            tPallete[math.log(color,2)+1] = tonumber(ra .. ga .. ba, 16)
        end,
        getPaletteColor = function(color)
            return tPallete[math.log(color,2)+1]
        end,
        getPaletteColour = function(color)
            return tPallete[math.log(color,2)+1]
        end,
        scroll = function(n)
            term.scroll(n)
        end,
        clearLine = function()
            term.clearLine()
        end,
        blit = function(c, v, s)
            term.blit(c, v, s)
        end,
        pMap = {
            white = 0x1,
            orange = 0x2,
            magenta = 0x4,
            lightBlue = 0x8,
            yellow = 0x10,
            lime = 0x20,
            pink = 0x40,
            gray = 0x80,
            lightGray = 0x100,
            cyan = 0x200,
            purple = 0x400,
            blue = 0x800,
            brown = 0x1000,
            green = 0x2000,
            red = 0x4000,
            black = 0x8000,
        },
        kMap = { -- Copied directly from capyos !
            none = 0,
            back = 8,
            tab = 9,
            enter = 13,
            pause = 19,
            caps_lock = 20,
            kana = 21,
            kanji = 25,
            escape = 27,
            ime_convert = 28,
            ime_no_convert = 29,
            space = 32,
            page_up = 33,
            page_down = 34,
            ["end"] = 35,
            home = 36,
            left = 37,
            up = 38,
            right = 39,
            down = 40,
            select = 41,
            print = 42,
            execute = 43,
            print_screen = 44,
            insert = 45,
            delete = 46,
            help = 47,
            zero = 48,
            one = 49,
            two = 50,
            three = 51,
            four = 52,
            five = 53,
            six = 54,
            seven = 55,
            eight = 56,
            nine = 57,
            a = 65,
            b = 66,
            c = 67,
            d = 68,
            e = 69,
            f = 70,
            g = 71,
            h = 72,
            i = 73,
            j = 74,
            k = 75,
            l = 76,
            m = 77,
            n = 78,
            o = 79,
            p = 80,
            q = 81,
            r = 82,
            s = 83,
            t = 84,
            u = 85,
            v = 86,
            w = 87,
            x = 88,
            y = 89,
            z = 90,
            left_windows = 91,
            right_windows = 92,
            apps = 93,
            sleep = 95,
            num_pad0 = 96,
            num_pad1 = 97,
            num_pad2 = 98,
            num_pad3 = 99,
            num_pad4 = 100,
            num_pad5 = 101,
            num_pad6 = 102,
            num_pad7 = 103,
            num_pad8 = 104,
            num_pad9 = 105,
            multiply = 106,
            add = 107,
            separator = 108,
            subtract = 109,
            decimal = 110,
            divide = 111,
            f1 = 112,
            f2 = 113,
            f3 = 114,
            f4 = 115,
            f5 = 116,
            f6 = 117,
            f7 = 118,
            f8 = 119,
            f9 = 120,
            f10 = 121,
            f11 = 122,
            f12 = 123,
            f13 = 124,
            f14 = 125,
            f15 = 126,
            f16 = 127,
            f17 = 128,
            f18 = 129,
            f19 = 130,
            f20 = 131,
            f21 = 132,
            f22 = 133,
            f23 = 134,
            f24 = 135,
            num_lock = 144,
            scroll = 145,
            left_shift = 160,
            right_shift = 161,
            left_control = 162,
            right_control = 163,
            left_alt = 164,
            right_alt = 165,
            browser_back = 166,
            browser_forward = 167,
            browser_refresh = 168,
            browser_stop = 169,
            browser_search = 170,
            browser_favorites = 171,
            browser_home = 172,
            volume_mute = 173,
            volume_down = 174,
            volume_up = 175,
            media_next_track = 176,
            media_previous_track = 177,
            media_stop = 178,
            media_play_pause = 179,
            launch_mail = 180,
            select_media = 181,
            launch_application1 = 182,
            launch_application2 = 183,
            semicolon = 186,
            plus = 187,
            comma = 188,
            minus = 189,
            period = 190,
            question = 191,
            tilde = 192,
            chat_pad_green = 202,
            chat_pad_orange = 203,
            open_brackets = 219,
            pipe = 220,
            close_brackets = 221,
            quotes = 222,
            oem8 = 223,
            backslash = 226,
            process_key = 229,
            copy = 242,
            auto = 243,
            enl_w = 244,
            attn = 246,
            crsel = 247,
            exsel = 248,
            erase_eof = 249,
            play = 250,
            zoom = 251,
            pa1 = 253,
            clear = 254,
        }
    },
    computer = {
        id = 0,
        uptime = os.clock,
        label = function()
            local l, e = KDriversImpl.files.open("/$ComputerLabel", "r")
            if not l then return "Capy64 Computer" end
            local label = l.readAll()
            l.close()
            return label
        end,
        setlabel = function(new)
            local l, e = KDriversImpl.files.open("/$ComputerLabel", "w")
            if not l then return end
            l.write(new)
            l.close()
        end,
        time = function(tz) return os.time() end,
        day = function(tz) return os.date("*t").day end,
        epoch = function() return os.time() / 1000 end,
        date = os.date,
        power = {
            shutdown = mach.shutdown,
            reboot = mach.reboot
        }
    },
    timers = {
        start = timer.start,
        cancel = function() end,
        setalarm = function(a) return -1 end,
        cancelalarm = function(a) end
    },
    workarounds = {
        preventTooLongWithoutYielding = function(handleEvent)
            event.push("fakeEvent")
            local f = true
            while f do
                local x = { coroutine.yield() }
                if x[1] == "fakeEvent" then
                    f = false
                    break
                else
                    handleEvent(x)
                end
            end
        end
    },
    devc = {
        get = function(w)
            if w == "net" and http then
                return {
                    sendRequest = function(reqType, url, headers, body)
                        local req = http.request {
                            url = url,
                            method = reqType,
                            headers = headers,
                            body = body
                        }
                        while true do
                            local event, param1, param2, param3 = KDriversImpl.pullEvent()
                            if event == "http_success" and param1 == url then
                                return param2
                            elseif event == "http_failure" and param1 == url then
                                return nil, param2, param3
                            end
                        end
                    end
                }
            end
            return nil
        end,
        type = function(n)
            if n == "net" and http then
                return "network_adapter"
            end
            return nil
        end,
        list = function()
            local c = {}
            if http then table.insert(c, "net") end
            return c
        end
    },
    branding = function(version)
        mach.setRPC("Running " .. version, "on Capy64")
    end,
    pullEvent = function()
        local co = { coroutine.yield() }
        if co[1] == "interrupt" then co[1] = "terminate" end
        if co[1] == "screen_resize" then co[1] = "term_resize" end
        if co[1] == "key_down" then co[1] = "key" end
        if co[1] == "audio_end" then co = { "speaker_audio_empty", "beeper" } end
        return co
    end,
}
local oldug = {}
local oldug2 = {}
for k, v in pairs(_G) do
    oldug2[k] = v
end
for k, v in pairs(_G) do
    oldug[k] = v
end
local keptAPIs = { utd = true, printError = true, KDriversImpl = true, json = true, require = true, print = true, write = true, read = true, bit32 = true, periphemu = true, bit = true, coroutine = true, debug = true, utf8 = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, __inext = true, load = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true }
local t = {}
for k in pairs(oldug) do if not keptAPIs[k] then table.insert(t, k) end end
for _, k in ipairs(t) do oldug[k] = nil end
oldug["_G"] = oldug
local f = KDriversImpl.files.open("/system/bootloader.lua", "r")
local ok, err = pcall(load(f.readAll(), "Bootloader", nil, oldug))
print(err)
while true do
    coroutine.yield()
end
coroutine.yield()
