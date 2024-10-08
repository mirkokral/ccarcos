if arcos or xnarcos then return end
local function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    if inputstr == nil then 
        return {""}
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
for k,v in pairs(_G) do
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
        local sEvent, param, param1, param2 = os.pullEvent()
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
_G.KDriversImpl = {
    files = {
        open = function(path, mode)
            return fs.open(path, mode)
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
            attr.capacity = fs.getCapacity(path)
            attr.driveRoot = fs.isDriveRoot(path)
            return attr
        end,
        getPermissions = function(file, user)
            if strsplit(file, "/") == {file} then
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
            if #fpn == 0 then fpn = {""} end
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
            return term.getCursorPos()
        end,
        setCursorPos = function(x, y)
            term.setCursorPos(x, y)
        end,
        getCursorBlink = function()
            return term.getCursorBlink()
        end,
        setCursorBlink = function(blink)
            term.setCursorBlink(blink)
        end,
        isColor = function()
            return term.isColor()
        end,
        getSize = function()
            return term.getSize()
        end,
        setTextColor = function(color)
            term.setTextColor(color)
        end,
        getTextColor = function()
            return term.getTextColor()
        end,
        setBackgroundColor = function(x)
            return term.setBackgroundColor(x)
        end,
        getBackgroundColor = function()
            return term.getBackgroundColor()
        end,
        setPaletteColor = function(color, r, g, b)
            term.setPaletteColor(color, r, g, b)
        end,
        setPaletteColour = function(color, r, g, b)
            term.setPaletteColor(color, r, g, b)
        end,
        getPaletteColor = function(color)
            return term.getPaletteColor(color)
        end,
        getPaletteColour = function(color)
            return term.getPaletteColor(color)
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
        pMap = colors,
        kMap = keys
    },
    computer = {
        id = os.getComputerID(),
        uptime = os.clock,
        label = os.getComputerLabel,
        setlabel = os.setComputerLabel,
        time = os.time,
        day = os.day,
        epoch = os.epoch,
        date = os.date,
        power = {
            shutdown = os.shutdown,
            reboot = os.reboot
        }
    },
    timers = {
        start = os.startTimer,
        cancel = os.cancelTimer,
        setalarm = os.setAlarm,
        cancelalarm = os.cancelAlarm
    },
    workarounds = {
        preventTooLongWithoutYielding = function(handleEvent)
            os.queueEvent("fakeEvent")
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
                            local event, param1, param2, param3 = os.pullEvent()
                            if event == "http_success" and param1 == url then
                                return param2
                            elseif event == "http_failure" and param1 == url then
                                return nil, param2, param3
                            end
                        end
                    end
                }
            end
            return peripheral.wrap(w)
        end,
        type = function(n)
            if n == "net" and http then
                return "network_adapter"
            end
            return peripheral.getType(n)
        end,
        list = function()
            local c = peripheral.getNames()
            if http then table.insert(c, "net") end
            return c
        end
    },
    pullEvent = coroutine.yield,
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
