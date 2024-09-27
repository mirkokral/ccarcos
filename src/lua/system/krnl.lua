---@diagnostic disable: duplicate-set-field


-- C:Exc
_G.__CPOSINFOFILE__ = "" -- Defined by the builder
_G.__CPOSINFOLINE__ = 0  --  Defined by the builder
_G.__CCOMPILECOUNT__ = 0 -- Defined by the builder
-- C:End

---@alias decodeFunction fun(f: string): any
---@alias encodeFunction fun(f: any): string
---@type { encode: encodeFunction, decode: decodeFunction }

local json = (function()
    --
    -- json.lua
    --
    -- Copyright (c) 2020 rxi
    --
    -- Permission is hereby granted, free of charge, to any person obtaining a copy of
    -- this software and associated documentation files (the "Software"), to deal in
    -- the Software without restriction, including without limitation the rights to
    -- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
    -- of the Software, and to permit persons to whom the Software is furnished to do
    -- so, subject to the following conditions:
    --
    -- The above copyright notice and this permission notice shall be included in all
    -- copies or substantial portions of the Software.
    --
    -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    -- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    -- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    -- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    -- SOFTWARE.
    --

    local json = { _version = "0.1.2" }

    -------------------------------------------------------------------------------
    -- Encode
    -------------------------------------------------------------------------------

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

        -- Circular reference?
        if stack[val] then error("circular reference") end

        stack[val] = true

        if rawget(val, 1) ~= nil or next(val) == nil then
            -- Treat as array -- check keys are valid and it is not sparse
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
            -- Encode
            for i, v in ipairs(val) do
                table.insert(res, encode(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        else
            -- Treat as an object
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
        -- Check for NaN, -inf and inf
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

    -------------------------------------------------------------------------------
    -- Decode
    -------------------------------------------------------------------------------

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
        -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
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
        -- Surrogate pair?
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
            -- Empty / end of array?
            if str:sub(i, i) == "]" then
                i = i + 1
                break
            end
            -- Read token
            x, i = parse(str, i)
            res[n] = x
            n = n + 1
            -- Next token
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
            -- Empty / end of object?
            if str:sub(i, i) == "}" then
                i = i + 1
                break
            end
            -- Read key
            if str:sub(i, i) ~= '"' then
                decode_error(str, i, "expected string for key")
            end
            key, i = parse(str, i)
            -- Read ':' delimiter
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) ~= ":" then
                decode_error(str, i, "expected ':' after key")
            end
            i = next_char(str, i + 1, space_chars, true)
            -- Read value
            val, i = parse(str, i)
            -- Set
            res[key] = val
            -- Next token
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

local args = { ... }
local kpError = nil
local currentTask
local cPid
local kernelLogBuffer = "Start\n"
local tasks = {}
local permmatrix
local config = {
    forceNice = nil,
    init = "/apps/init.lua",
    printLogToConsole = false,
    printLogToFile = false,
    telemetry = true,
    quiet = false
}
local function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
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
    if t == {} then
        t = { "" }
    end
    return nt
end

--- BEGIN DRIVERS ---
---@type {open: function, list: function, type: function, exists: function, copy: function, unlink: function, mkDir: function, getPermissions: function}
local KDriversImpl = {
    files = {
        open = function(path, mode)
            return __LEGACY.files.open(path, mode)
        end,
        list = function(path)
            return __LEGACY.files.list(path)
        end,
        type = function(path)
            return __LEGACY.files.isDir(path) and "directory" or "file"
        end,
        exists = function(path)
            return __LEGACY.files.exists(path)
        end,
        copy = function(src, dest)
            return __LEGACY.files.copy(src, dest)
        end,
        unlink = function(path)
            return __LEGACY.files.delete(path)
        end,
        mkDir = function(path)
            return __LEGACY.files.makeDir(path)
        end,
        getPermissions = function(path, user)
            local read = true
            local write = true
            local listed = true
            if user == nil then user = xnarcos.getCurrentTask().user end
            if __LEGACY.files.isReadOnly(file) then
                write = false
            end
            if strsplit(file, "/")[#strsplit(file, "/")]:sub(1, 1) == "$" then -- Metadata files
                return {
                    read = false,
                    write = false,
                    listed = false
                }
            end
            local disallowedfiles = { "startup.lua", "startup" }
            for index, value in ipairs(disallowedfiles) do
                if strsplit(file, "/")[1] == value then -- Metadata files
                    return {
                        read = false,
                        write = false,
                        listed = false,
                    }
                end
            end
            if strsplit(file, "/")[#strsplit(file, "/")]:sub(1, 1) == "." then
                listed = false
            end

            return {
                read = read,
                write = write,
                listed = listed,
            }
        end
    }
}

---  END DRIVERS  ---


_G.syscall = {
    run = function(syscall, ...)
        return table.unpack(table.pack(coroutine.yield("syscall", syscall, ...)), 2)
    end
}



local logfile = nil
if config.printLogToFile then
    logfile, error = KDriversImpl.files.open("/system/log.txt", "w")
    if not logfile then
        print(error)
        while true do coroutine.yield() end
    end
end
term.redirect(term.native())
local oldw = _G.write
_G.write = function(...)
    local isNextSetC = false
    local nextCommand = ""
    local args = { ... }
    for i, vn in ipairs(args) do
        if i > 1 then term.write(" ") end
        local v = tostring(vn)
        for xi = 0, #v do
            local char = v:sub(xi, xi)
            if isNextSetC then
                nextCommand = char
                isNextSetC = false
            elseif #nextCommand > 0 then
                if nextCommand == "b" then
                    isNextSetC = false
                    local value = tonumber(char, 16)
                    if not value then return nil end

                    term.setBackgroundColor(2 ^ value)
                elseif nextCommand == "f" then
                    isNextSetC = false
                    local value = tonumber(char, 16)
                    if not value then return nil end

                    term.setTextColor(2 ^ value)
                end
                nextCommand = ""
            elseif char == "\011" then
                isNextSetC = true
            else
                oldw(char)
            end
        end
    end
end
_G.print = function(...)
    write(...)
    write("\n")
end
local function recursiveRemove(r)
    for _, i in ipairs(KDriversImpl.files.list(r)) do
        if KDriversImpl.files.type(i) == "directory" then
            recursiveRemove(i)
        else
            KDriversImpl.files.unlink(i)
        end
    end
end
for _, i in ipairs(KDriversImpl.files.list("/temporary/")) do
    recursiveRemove("/temporary/" .. i)
end
local users = {}


_G.apiUtils = {
    ---Executes a kernel panic
    ---@param err string Error to display
    ---@param file string File kernel panic source
    ---@param line number File line
    kernelPanic = function(err, file, line)
        kpError = "Suspected location: " .. file .. ":" .. line .. "\n" .. "Error: " .. err
        tasks = {}
    end

}



_G.xnarcos = {
    ---Reboots the system
    reboot = function()
        syscallxe("reboot")
    end,
    ---Shuts the system down
    shutdown = function()
        syscallxe("shutdown")
    end,
    ---Logs a string
    ---@param txt string String to log
    ---@param level number The log level. 0 = Print to console only if printlog flag, 1 = Print to console unless quiet flag is set, 2 = Always print to console
    log = function(txt, level)
        kernelLogBuffer = kernelLogBuffer ..
            "[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt .. "\n"
        if (level == 0 and config["printLogToConsole"]) or (level == 1 and not config["quiet"]) or (level == 2) then
            print("[" .. __LEGACY.os.clock() .. "] " .. debug.getinfo(2).source:sub(2) .. ": " .. txt)
        end
        if config.printLogToFile and logfile then
            logfile.write(kernelLogBuffer)
        end
    end,
    ---Returns the arcos version
    ---@return string
    version = function()
        -- parse it from the package "base"
        if KDriversImpl.files.exists("/config/arc/devenv.lock") then
            return "arcos development environment"
        end
        local f, e = KDriversImpl.files.open("/config/arc/base.meta.json", "r")
        if not f then
            return "invalid package metadata"
        else
            xnarcos.log("Loading package metadata", 1)
            local meta = json.decode(f.readAll())
            f.close()
            return "arcos " .. meta.version
        end
    end,
    ---Gets the computer name
    ---@return string
    getName = function()
        return __LEGACY.os.getComputerLabel()
    end,
    ---Sets the computer name
    ---@param new string New computer name
    setName = function(new)
        if xnarcos.getCurrentTask().user == "root" then
            __LEGACY.os.setComputerLabel(new)
        end
    end,
    ---@class PublicTaskIdentifier
    ---@field public pid number The process id
    ---@field public name string The process name
    ---@field public user string The process user
    ---@field public nice number The process niceness value
    ---@field public paused boolean The paused boolean
    ---@field public env table The environment of the process, exposed as environ
    ---Gets the currrent task
    ---@return PublicTaskIdentifier
    getCurrentTask = function()
        if currentTask then
            return {
                pid = cPid,
                name = currentTask["name"],
                user = currentTask["user"],
                nice = currentTask["nice"],
                paused = currentTask["paused"],
                env = currentTask["env"]
            }
        end
        return {
            pid = -1,
            name = "kernelspace",
            user = "root",
            nice = 1,
            paused = false,
            env = {}
        }
    end,

    ---Gets all user names in the system
    ---@return table<number,string>
    getUsers = function()
        local f = {}
        for index, value in ipairs(users) do
            table.insert(f, value.name)
        end
        return f
    end,

    ---Gets the kernel log buffer
    ---@return string?
    getKernelLogBuffer = function()
        if not currentTask or currentTask["user"] == "root" then
            return kernelLogBuffer
        else
            return nil
        end
    end,
    ---Pulls an event with respect for the arcos thread executor.
    ---@param filter string?
    ---@return table
    ev = function(filter)
        r = table.pack(coroutine.yield())
        if r[1] == "terminate" then
            error("Terminated")
        end
        if not filter or r[1] == filter then
            return table.unpack(r)
        else
            return xnarcos.ev(filter)
        end
    end,
    ---Pulls an event with respect for the arcos thread executor. Ignores terminte
    ---@param filter string?
    ---@return table
    rev = function(filter)
        r = table.pack(coroutine.yield())
        if not filter or r[1] == filter then
            return table.unpack(r)
        else
            return xnarcos.ev(filter)
        end
    end,
    ---Gets the time
    ---@param t string? Timezone
    ---@return integer
    time = function(t)
        return __LEGACY.os.time(t)
    end,
    ---Gets the day
    ---@param t string? Timezone
    ---@return integer
    day = function(t)
        return __LEGACY.os.day(t)
    end,
    ---Gets the epoch
    ---@param t string? Timezone
    ---@return integer
    epoch = function(t)
        return __LEGACY.os.epoch(t)
    end,
    ---Returns a date string (or table) using a specified format.
    ---@param format string?
    ---@param time number?
    ---@return string|osdate
    date = function(format, time)
        return __LEGACY.os.date(format, time)
    end,
    ---Runs a program
    ---@param env table Environment
    ---@param path string Path to the executable
    ---@param ... any
    ---@return boolean success
    ---@return any out
    r = function(env, path, ...)
        assert(type(env) == "table", "Invalid argument: env")
        assert(type(path) == "string", "Invalid argument: path")
        local compEnv = {}
        for k, v in pairs(_G) do
            compEnv[k] = v
        end
        for k, v in pairs(env) do
            compEnv[k] = v
        end
        compEnv["apiUtils"] = nil
        compEnv["__LEGACY"] = nil
        compEnv["_G"] = nil
        setmetatable(compEnv, {
            __index = function(t, k)
                if k == "_G" then
                    return compEnv
                end
            end,
        })
        local f = KDriversImpl.files.open(path, "r")
        local compFunc, err = load(f.readAll(), path, nil, compEnv)
        f.close()
        if compFunc == nil then
            return false, "Failed to load function: " .. err
        else
            setfenv(compFunc, compEnv)
            local ok, err = pcall(compFunc, ...)
            return ok, err
        end
    end,
    ---Queues an event
    ---@param ev any
    ---@param ... any
    queue = function(ev, ...)
        __LEGACY.os.queueEvent(ev, ...)
    end,
    ---Returns the clock
    ---@return number
    clock = function() return __LEGACY.os.clock() end,

    ---Loads an API. This shouldn't be used outside of the kernel, but there are cases where it's needed.
    ---@param api string
    loadAPI = function(api)
        error("Use require instead of loadAPI.")
    end,
    ---Starts a timer
    ---@param d number Timer duration in seconds
    ---@return number id Timer id
    startTimer = function(d)
        return __LEGACY.os.startTimer(d)
    end,
    ---Cancels a timer
    ---@param d number Timer ID
    cancelTimer = function(d)
        return __LEGACY.os.cancelTimer(d)
    end,
    ---Sets an alarm
    ---@param d number Alarm time
    ---@return number id Alarm id
    setAlarm = function(d)
        return __LEGACY.os.setAlarm(d)
    end,
    ---Cancels an alarm
    ---@param d number Alarm ID
    cancelAlarm = function(d)
        return __LEGACY.os.cancelAlarm(d)
    end,

    id = __LEGACY.os.getComputerID()
}

_G.arcos = {
    ---Reboots the system
    reboot = function()
        coroutine.yield("syscall", "reboot")
    end,
    ---Shuts the system down
    shutdown = function()
        coroutine.yield("syscall", "shutdown")
    end,
    ---Logs a string
    ---@param txt string String to log
    ---@param level number The log level. 0 = Print to console only if printlog flag, 1 = Print to console unless quiet flag is set, 2 = Always print to console
    log = function(txt, level)
        coroutine.yield("syscall", "log", txt, level)
    end,
    ---Returns the arcos version
    ---@return string
    version = function()
        return coroutine.yield("syscall", "version")
    end,
    ---Gets the computer name
    ---@return string
    getName = function()
        return coroutine.yield("syscall", "getName")
    end,
    ---Sets the computer name
    ---@param new string New computer name
    setName = function(new)
        coroutine.yield("syscall", "setName", new)
    end,
    ---@class PublicTaskIdentifier
    ---@field public pid number The process id
    ---@field public name string The process name
    ---@field public user string The process user
    ---@field public nice number The process niceness value
    ---@field public paused boolean The paused boolean
    ---@field public env table The environment of the process, exposed as environ
    ---Gets the currrent task
    ---@return PublicTaskIdentifier
    getCurrentTask = function()
        return coroutine.yield("syscall", "getCurrentTask")
    end,

    ---Gets all user names in the system
    ---@return table<number,string>
    getUsers = function()
        return coroutine.yield("syscall", "getUsers")
    end,

    ---Gets the kernel log buffer
    ---@return string?
    getKernelLogBuffer = function()
        return coroutine.yield("syscall", "getKernelLogBuffer")
    end,
    ---Pulls an event with respect for the arcos thread executor.
    ---@param filter string?
    ---@return table
    ev = function(filter)
        r = table.pack(coroutine.yield())
        if r[1] == "terminate" then
            error("Terminated")
        end
        if not filter or r[1] == filter then
            return table.unpack(r)
        else
            return xnarcos.ev(filter)
        end
    end,
    ---Pulls an event with respect for the arcos thread executor. Ignores terminte
    ---@param filter string?
    ---@return table
    rev = function(filter)
        r = table.pack(coroutine.yield())
        if not filter or r[1] == filter then
            return table.unpack(r)
        else
            return xnarcos.ev(filter)
        end
    end,
    ---Gets the time
    ---@param t string? Timezone
    ---@return integer
    time = function(t)
        return coroutine.yield("syscall", "time", t)
    end,
    ---Gets the day
    ---@param t string? Timezone
    ---@return integer
    day = function(t)
        return coroutine.yield("syscall", "day", t)
    end,
    ---Gets the epoch
    ---@param t string? Timezone
    ---@return integer
    epoch = function(t)
        return coroutine.yield("syscall", "epoch", t)
    end,
    ---Returns a date string (or table) using a specified format.
    ---@param format string?
    ---@param time number?
    ---@return string|osdate
    date = function(format, time)
        return coroutine.yield("syscall", "date", format, time)
    end,
    ---Runs a program
    ---@param env table Environment
    ---@param path string Path to the executable
    ---@param ... any
    ---@return boolean success
    ---@return any out
    r = function(env, path, ...)
        assert(type(env) == "table", "Invalid argument: env")
        assert(type(path) == "string", "Invalid argument: path")
        local compEnv = {}
        for k, v in pairs(_G) do
            compEnv[k] = v
        end
        for k, v in pairs(env) do
            compEnv[k] = v
        end
        compEnv["apiUtils"] = nil
        compEnv["__LEGACY"] = nil
        compEnv["_G"] = nil
        setmetatable(compEnv, {
            __index = function(t, k)
                if k == "_G" then
                    return compEnv
                end
            end,
        })
        local f = KDriversImpl.files.open(path, "r")
        local compFunc, err = load(f.readAll(), path, nil, compEnv)
        f.close()
        if compFunc == nil then
            return false, "Failed to load function: " .. err
        else
            setfenv(compFunc, compEnv)
            local ok, err = pcall(compFunc, ...)
            return ok, err
        end
    end,
    ---Queues an event
    ---@param ev any
    ---@param ... any
    queue = function(ev, ...)
        coroutine.yield("syscall", "queue", ev, ...)
    end,
    ---Returns the clock
    ---@return number
    clock = function()
        return coroutine.yield("syscall", "clock")
    end,

    ---Loads an API. This shouldn't be used outside of the kernel, but there are cases where it's needed.
    ---@param api string
    loadAPI = function(api)
        error("Use require instead of loadAPI.")
    end,
    ---Starts a timer
    ---@param d number Timer duration in seconds
    ---@return number id Timer id
    startTimer = function(d)
        return coroutine.yield("syscall", "startTimer", d)
    end,
    ---Cancels a timer
    ---@param d number Timer ID
    cancelTimer = function(d)
        return coroutine.yield("syscall", "cancelTimer", d)
    end,
    ---Sets an alarm
    ---@param d number Alarm time
    ---@return number id Alarm id
    setAlarm = function(d)
        return coroutine.yield("syscall", "setAlarm", d)
    end,
    ---Cancels an alarm
    ---@param d number Alarm ID
    cancelAlarm = function(d)
        return coroutine.yield("syscall", "cancelAlarm", d)
    end,
    id = __LEGACY.os.getComputerID(),

    getHome = function()
        return coroutine.yield("syscall", "getHome")
    end,

    validateUser = function(user, pass)
        return coroutine.yield("syscall", "validateUser", user, pass)
    end,

    createUser = function (user, pass)
        return coroutine.yield("syscall", "createUser", user, pass)
    end,

    deleteUser = function (user)
        return coroutine.yield("syscall", "deleteUser", user)
    end


}
-- C:Exc

_G.term = {
    native = function()
        return term
    end,
    current = function()
        return term
    end,
    write = function(text)
        xnarcos.log(i .. ": " .. text, 0)
    end,
    blit = function(text, ...)
        xnarcos.log(i .. ": " .. text, 0)
    end,
    setTextColor = function(col) end,
    setBackgroundColor = function(col) end,
    setTextColour = function(col) end,
    setBackgroundColour = function(col) end,
    getTextColour = function() return require("col").white end,
    getBackgroundColour = function() return require("col").black end,
    getTextColor = function() return require("col").white end,
    getBackgroundColor = function() return require("col").black end,
    setCursorPos = function(cx, cy) end,
    scroll = function(sx) end,
    clear = function() end,
    isColor = function() return false end,
    isColour = function() return false end,
    getSize = function()
        return 0, 0
    end
}

-- C:End

---Sleeps for a time, respects arcos thread executor
---@param time number Sleep time
function _G.sleep(time)
    if not time then time = 0.05 end
    local tId = xnarcos.startTimer(time)
    repeat
        _, i = xnarcos.ev("timer")
    until i == tId
end

---Prints an error
---@param ... string toprint
function _G.printError(...)
    local oldtc = term.getTextColor()
    term.setTextColor(require("col").red)
    print(...)
    term.setTextColor(oldtc)
end

_G.tasking = {

    ---Creates a task
    ---@param name string Task name
    ---@param callback function The actual code that the task runs
    ---@param nice number Task niceness, how many times to execute coroutine.resume during the tasks round
    ---@param user string Task user executor. Can only be current user and root if not root. changing to root asks for a password.
    ---@param out any The output, exposed as term to the task
    ---@param env table? The task environment
    ---@return integer pid The task process id
    createTask = function(name, callback, nice, user, out, env)
        if not env then env = xnarcos.getCurrentTask().env or { workDir = "/" } end
        if not user then
            if currentTask then
                user = currentTask["user"]
            else
                user = ""
            end
        end
        if currentTask and user ~= "root" then
            if user ~= currentTask["user"] and not currentTask["user"] == "root" then
                return 1
            end
        end
        if currentTask and user == "root" and currentTask["user"] ~= "root" then
            write("\nEnter root password")
            local password = read()
            if not xnarcos.validateUser("root", password) then
                write("Sorry")
                xnarcos.log(
                    currentTask["user"] ..
                    " tried to create a task with user " .. user .. " but failed the password check.",
                    1)
                error("Invalid password")
            end
        end
        
        table.insert(tasks, {
            name = name,
            crt = coroutine.create(callback),
            nice = nice,
            user = user,
            out = out,
            env = env,
            paused = false,
            tQueue = {}
        })

        return #tasks
    end,
    ---Kills task. Can only be current user task if not root
    ---@param pid number The actual pid
    killTask = function(pid)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
                user = "root"
            })["user"] then
            table.remove(tasks, pid)
        end
    end,
    ---Gets all tasks
    ---@return PublicTaskIdentifier[]
    getTasks = function()
        local returnstuff = {}
        for i, v in ipairs(tasks) do
            table.insert(returnstuff, {
                pid = i,
                name = v["name"],
                user = v["user"],
                nice = v["nice"],
                paused = v["paused"]
            })
        end
        return returnstuff
    end,
    ---Sets the task paused status if not root can only be used on task of self
    ---@param pid number The pid of the task to set
    ---@param paused boolean New paused status
    setTaskPaused = function(pid, paused)
        if not currentTask or currentTask["user"] == "root" or tasks[pid]["user"] == (currentTask or {
                user = "root"
            })["user"] then
            tasks[pid]["paused"] = paused
        end
    end,
    ---Changes the user of the current task
    ---@param user string New user username
    ---@param password string? New user password, ignored if root
    changeUser = function(user, password)
        if xnarcos.getCurrentTask().user == user then return true end
        if xnarcos.getCurrentTask().user ~= "root" then
            if not password then return "Invalid credentials" end
            if not xnarcos.validateUser(user, password) then return "Invalid credentials" end
        end
        if not currentTask then return "No current task" end
        for index, value in ipairs(users) do
            if value.name == user then
                currentTask["user"] = user
                return true
            end
        end
        return "User non-existent"
    end
}

local i = 0

while true do
    i = i + 1
    if args[i] == nil then
        break
    end
    if args[i]:sub(1, 2) ~= "--" then
        apiUtils.kernelPanic("Invalid argument: " .. args[i], "__CPOSINFOFILE__", __CPOSINFOLINE__)
    end
    local arg = string.sub(args[i], 3)
    if arg == "forceNice" then
        i = i + 1
        config["forceNice"] = tonumber(args[i])
    end
    if arg == "init" then
        i = i + 1
        config["init"] = args[i]
    end
    if arg == "noTel" then
        config.telemetry = false
    end
    if arg == "printLog" then
        config["printLogToConsole"] = true
    end
    if arg == "fileLog" then
        config["printLogToFile"] = true
    end
    if arg == "quiet" then
        config["quiet"] = true
    end
end
if config.printLogToFile then
    logfile, error = KDriversImpl.files.open("/system/log.txt", "w")
    if not logfile then
        print(error)
        while true do coroutine.yield() end
    end
end

---@type table
_G.package = {
    preload = {
        string = string,
        table = table,
        package = package,
        arcos = arcos,
        bit32 = __LEGACY.bit32,
        bit = __LEGACY.bit,
        coroutine = coroutine,
        os = arcos,
        tasking = tasking,
        utf8 = utf8,

    },
    loaded = {

    },
    ---@type table<function>
    loaders = {
        ---@param name string
        ---@return function
        function(name)
            if not package.preload[name] then
                error("no field package.preload['" .. name .. "']")
            end
            return function()
                return package.preload[name]
            end
        end,
        ---@param name string
        ---@return function
        function(name)
            if not package.loaded[name] then
                error("no field package.loaded['" .. name .. "']")
            end
            return function()
                return package.loaded[name]
            end
        end,
        ---@param name string
        ---@return function
        function(name)
            local searchPaths = { "/", "/system/apis", "/apis" }
            local searchSuffixes = { ".lua", "init.lua" }
            if environ and environ.workDir then
                table.insert(searchPaths, environ.workDir)
            end
            for _, path in ipairs(searchPaths) do
                for _, suffix in ipairs(searchSuffixes) do
                    local file = path .. "/" .. name:gsub("%.", "/") .. suffix
                    if KDriversImpl.files.exists(file) then
                        local compEnv = {}
                        for k, v in pairs(_G) do
                            compEnv[k] = v
                        end
                        if path ~= "/apis" and path ~= "/system/apis" then
                            compEnv["apiUtils"] = nil
                            compEnv["__LEGACY"] = nil
                        end

                        compEnv["_G"] = nil
                        setmetatable(compEnv, {
                            __index = function(t, k)
                                if k == "_G" then
                                    return compEnv
                                end
                            end,
                        })

                        local f, err = KDriversImpl.files.open(file, "r")
                        if not f then
                            error(err)
                        end
                        local compFunc, err = load(f.readAll(), file, nil, compEnv)
                        f.close()
                        if compFunc == nil then
                            error(err)
                        end
                        return compFunc
                    end
                end
            end
            error("Package not found.")
        end
    }
}

_G.require = function(modname)
    local errors = {}
    for _, loader in ipairs(package.loaders) do
        local ok, func = pcall(loader, modname)
        if ok then
            local f = func()
            package.loaded[modname] = f
            return f
        end
        table.insert(errors, func)
    end
    error("module '" .. modname .. "' not found:\n  " .. table.concat(errors, "\n  "))
end
local tutils = require("tutils")

xnarcos.log("Hello, world!", 1)
local col = require("col")
local hashing = require("hashing")
debug.setfenv(read, setmetatable({ colors = col, colours = col }, { __index = _G }))

local passwdFile, e = KDriversImpl.files.open("/config/passwd", "r")
if not passwdFile then
    apiUtils.kernelPanic("Password file not found", "__CPOSINFOFILE__", __CPOSINFOLINE__)
else
    xnarcos.log("Decoding passwd file", 1)
    local fx = passwdFile.readAll()
    users = json.decode(fx)
end
---Gets the current home dir for the user
---@return string
_G.xnarcos.getHome = function()
    if not KDriversImpl.files.exists("/user/" .. xnarcos.getCurrentTask().user) then
        KDriversImpl.files.mkDir("/user/" .. xnarcos.getCurrentTask().user)
    end
    return "/user/" .. xnarcos.getCurrentTask().user
end
---Validates user credentials
---@param user string
---@param password string
---@return boolean
_G.xnarcos.validateUser = function(user, password)
    for index, value in ipairs(users) do
        if value.name == user and value.password == hashing.sha256(password) then
            if not KDriversImpl.files.exists("/user/" .. user) then
                KDriversImpl.files.mkDir("/user/" .. user)
            end
        end
    end

    for index, value in ipairs(users) do
        if value.name == user and value.password == hashing.sha256(password) then
            return true
        end
    end
    return false
end
---Creates an user
---@param user string User name
---@param password string Password
---@return boolean
_G.xnarcos.createUser = function(user, password)
    if xnarcos.getCurrentTask().user ~= "root" then
        return false
    end
    for index, value in ipairs(users) do
        if value.name == user then
            return false
        end
    end
    table.insert(users, {
        name = user,
        password = hashing.sha256(password)
    })
    local ufx, e = KDriversImpl.files.open("/config/passwd", "w")
    if not ufx then
        error(e)
    end
    ufx.write(json.decode(users))
    ufx.close()
    return true
end
_G.xnarcos.deleteUser = function(user)
    if xnarcos.getCurrentTask().user ~= "root" then
        return false
    end
    if user == "root" then
        return false
    end
    local todel = nil
    for index, value in ipairs(users) do
        if value.name == user then
            todel = index
        end
    end
    if todel then
        table.remove(users, todel)
        return true
    end
    return false
end


---@class Device: table
---@field name string
---@field types string[]
---@field sendData fun(data: string): nil
---@field recvData fun(): string
---@field onEvent fun(...): nil
---@field onActivate fun(): nil
---@field onDeactivate fun(): nil

---@type Device[]
local regDevices = {}


_G.devices = {
    ---Gets if a device with name exists
    ---@param name string
    ---@return boolean
    present = function(name)
        local names = devices.names()
        for _, v in ipairs(names) do
            if v == name then
                return true
            end
        end
        return false
    end,
    ---Gets the types of a device
    ---@param dev Device
    ---@return string ...
    type = function(dev)
        return table.unpack(dev.types)
    end,
    ---Gets if a deivce has a type
    ---@param dev Device
    ---@param type string
    ---@return boolean
    hasType = function(dev, type)
        for _, v in ipairs(dev.types) do
            if v == type then
                return true
            end
        end
        return false
    end,
    ---Gets all methods of a device
    ---@param name any
    methods = function(name)

    end,
    ---Gets the name of a device
    ---@param peripheral Device
    name = function(peripheral)
        return peripheral.name
    end,
    ---Calls a method on a device
    ---@param name string Device name
    ---@param method string Method name
    ---@param ... any
    ---@return any
    call = function(name, method, ...)
        return devices.get(name)[method](...)
    end,
    ---Gets a device from name
    ---@param what string Device name
    ---@return Device
    get = function(what)
        return syscall.run("devices.get", what)
    end,
    ---Finds a device by type
    ---@param what string Device type
    ---@return Device
    find = function(what)
        return syscall.run("devices.find", what)
    end,
    ---Gets all device names
    ---@return string[]
    names = function()
        return syscall.run("devices.names")
    end,
    ---Add a device (requires root)
    ---@param device Device
    ---@return boolean
    add = function(device)
        if xnarcos.getCurrentTask().user ~= "root" then
            xnarcos.log("User " .. xnarcos.getCurrentTask().user .. " does not have root access", 1)
            return false
        end
        for k, v in ipairs(regDevices) do
            if v.name == device.name then
                xnarcos.log("Device already exists: " .. device.name, 1)
                return false
            end
        end
        xnarcos.log("Device connected: " .. device.name, 1)
        for _, v in ipairs(tasks) do
            table.insert(v.tQueue, {
                [1] = "device_connected",
                [2] = device.name
            })
        end
        table.insert(regDevices, device)
        device.onActivate()
        return true
    end,
    ---Remove a device (requires root)
    ---@param deviceName string
    ---@return boolean
    remove = function(deviceName)
        if xnarcos.getCurrentTask().user ~= "root" then
            return false
        end
        for index, value in ipairs(regDevices) do
            if value.name == deviceName then
                xnarcos.log("Device disconnected: " .. deviceName, 1)
                for _, v in ipairs(tasks) do
                    table.insert(v.tQueue, {
                        [1] = "device_disconnected",
                        [2] = deviceName
                    })
                end
                table.remove(regDevices, index)
                return true
            end
        end
        return false
    end

}
---Execute a syscall
---@param ev any[]
---@return any
local function syscallxe(ev)
    if ev[1] == "panic" and #ev == 4 and type(ev[2]) == "string" and type(ev[3]) == "string" and type(ev[4]) == "number" then
        if xnarcos.getCurrentTask()["user"] == "root" then
            apiUtils.kernelPanic(ev[2], ev[3], ev[4])
            return true
        else
            return false
        end
    elseif ev[1] == "devices.get" and #ev == 2 and type(ev[2]) == "string" then
        for _, v in ipairs(regDevices) do
            if v.name == ev[2] then
                return v
            end
        end
        return nil
    elseif ev[1] == "devices.find" and #ev == 2 and type(ev[2]) == "string" then
        local out = {}
        for _, v in ipairs(regDevices) do
            for index, value in ipairs(v.types) do
                if value == ev[2] then
                    table.insert(out, v)
                end
            end
        end
        return table.unpack(out)
    elseif ev[1] == "devices.names" and #ev == 1 then
        local out = {}
        for _, v in ipairs(regDevices) do
            table.insert(out, v.name)
        end
        return table.unpack(out)
    elseif ev[1] == "shutdown" then
        if __LEGACY and __LEGACY.os and __LEGACY.os.shutdown then
            xnarcos.log("Shutting down...", 2)
            sleep(1)
            __LEGACY.os.shutdown()
        else
            error("Shutting down")
        end
        return true
    elseif ev[1] == "reboot" then
        if __LEGACY and __LEGACY.os and __LEGACY.os.reboot then
            __LEGACY.os.reboot()
        else
            xnarcos.log("Rebooting...", 2)
            sleep(1)
            error("Rebooting")
        end
        return true
    elseif xnarcos[ev[1]] then
        return xnarcos[ev[1]](table.unpack(ev, 2))
    else
        xnarcos.log("Invalid syscall or syscall usage: " .. ev[1], 0)
        return nil
    end
end

--- A table where indexing it is the same as devices.find
_G.dev = {

}



setmetatable(_G.dev, {
    __index = function(t, k)
        return devices.find(k)
    end
})


-- C:Exc
---Prints something
---@param ... string
_G.print = function(...) end
---Just like print but doesn't write a newline
---@param ... string
_G.write = function(...) end
---Reads a line
---@param r any?
---@param v any?
---@param a any?
---@return string userInput
_G.read = function(r, v, a) return "" end
-- C:End

_G.kernel = {
    uname = function()
        return "arckernel __CCOMPILECOUNT__"
    end
}
local f, err = KDriversImpl.files.open("/config/passwd", "r")
local tab
if f then
    xnarcos.log("Reading passwd file", 1)
    local fx = f.readAll()
    tab = json.decode(fx)
else
    apiUtils.kernelPanic("Could not read passwd file: " .. tostring(err), "__CPOSINFOFILE__", __CPOSINFOLINE__)
end

for index, value in ipairs(xnarcos.getUsers()) do
    if not KDriversImpl.files.exists("/user/" .. value) then
        KDriversImpl.files.mkDir("/user/" .. value)
    end
end

tasking.createTask("Init", function()
    xnarcos.log("Starting Init", 0)
    local ok, err = pcall(function()
        local ok, err = xnarcos.r({}, config["init"])
        if err then
            apiUtils.kernelPanic("Init Died: " .. err, "__CPOSINFOFILE__", __CPOSINFOLINE__)
        else
            apiUtils.kernelPanic("Init Died with no errors.", "__CPOSINFOFILE__", __CPOSINFOLINE__)
        end
    end)
    apiUtils.kernelPanic("Init Died: " .. err, "__CPOSINFOFILE__", __CPOSINFOLINE__)
end, 1, "root", term, { workDir = "/user/root" })
xnarcos.startTimer(0.2)

local function resumeTask(index, value, sus)
    if __LEGACY.os and __LEGACY.os.queueEvent then
        __LEGACY.os.queueEvent("fakeEvent") 
        local f = true
        while f do
            local x = { xnarcos.rev() }
            if x[1] == "fakeEvent" then
                f = false
                break
            else
                for _, v in ipairs(tasks) do
                    table.insert(v.tQueue, x)
                end
            end
        end
    end
    -- print("Task has queue: " .. value.name)
    currentTask = value
    cPid = index
    local event = sus or table.remove(value.tQueue, 1)
    _G.environ = value["env"]
    local sca = table.pack(coroutine.resume(value["crt"], table.unpack(event)))
    local sc = { table.unpack(sca, 2, #sca) }
    if not sca[1] then
        -- Delete task
        table.remove(tasks, index)
    end
    -- print(require("tutils").s(sc[1]))
    if sc[1] == "syscall" then
        if __LEGACY.os and __LEGACY.os.queueEvent then
            __LEGACY.os.queueEvent("fakeEvent")
            xnarcos.rev("fakeEvent")
        end
        resumeTask(index, value, table.pack(syscallxe({ table.unpack(sc, 2, #sc) })))
    end
    value["env"] = _G.environ
end

while kpError == nil do
    local f = 0
    for index, value in ipairs(tasks) do
        if not value.paused then
            f = f + #value.tQueue
        end
    end
    if f > 0 then
        --[[
        For some reason the following coded has these side-effects:
        - Literally makes the fucking server crash
        - Uses 100% cpu
        - What the fuck
        ]]

        -- __LEGACY.os.queueEvent("fakeevent")
        -- local f = {}
        -- repeat
        --     table.insert(f, table.pack(coroutine.yield()))
        -- until f[#f][1] == "fakeevent"
        -- for index, value in ipairs(tasks) do
        --     for i, v in ipairs(f) do
        --         table.insert(value.tQueue, v)
        --     end
        -- end

        for index, value in ipairs(tasks) do
            if not value.paused then
                -- print("Not Paused task: " .. value.name)
                if #value.tQueue > 0 then
                    resumeTask(index, value)
                    if kpError then break end
                end
            else
                -- print("Paused task: " .. value.name)
            end
        end
    else
        -- print("Pulling")
        local ev = table.pack(coroutine.yield())
        -- print(ev[1])
        if ev[1] == "key" and ev[2] == require("keys").scrollLock then
            local ks = require("keys")
            local _, cmd = xnarcos.rev("key")
            if cmd == ks.k then
                xnarcos.log("Killing all tasks because of sysrq sequence", 1)
                tasks = {}
            elseif cmd == ks.s then
                -- Run emergency shell
                xnarcos.log("Starting emergency shell because of sysrq sequence", 1)
                tasking.createTask("Emergency shell", function()
                    write("Enter root password: ")
                    local pw = read()
                    if not xnarcos.validateUser("root", pw) then
                        write("Invalid password")
                    else
                        xnarcos.r({}, "/apps/shell.lua")
                    end
                end, 1, "root", term, { workDir = "/" })
            elseif cmd == ks.h then
                xnarcos.log("-- SYSRQ Help --", 2)
                xnarcos.log("S: Run emergency shell", 2)
                xnarcos.log("H: Show this help", 2)
            else
                xnarcos.log("Invalid sysrq command", 1)
            end
        elseif ev[1] == "terminate" then
            syscall { "shutdown" }
        elseif ev[1] == "peripheral" then
            ---@type Device
            local ap = __LEGACY.peripheral.wrap(ev[2])
            ap.name = ev[2]
            ap.types = table.pack(__LEGACY.peripheral.getType(ev[2]))
            ap.onActivate = function()

            end
            ap.onDeactivate = function()

            end
            ap.onEvent = function()
            end
            ap.sendData = function(data)

            end
            ap.recvData = function()
                return "NODATA"
            end
            devices.add(ap)
        elseif ev[1] == "peripheral_detach" then
            devices.remove(ev[2])
        else
            for index, value in ipairs(tasks) do
                table.insert(value.tQueue, ev)
            end
        end
    end
    -- print("Fake")
end

do
    -- Error
    term.setBackgroundColor(0x4000)
    term.setTextColor(0x8000)
    term.setCursorPos(1, 1)
    term.clear()
    print("arcos has forcefully shut off, due to an error.")
    print("If this is the first time you've seen these errors, try restarting your computer.")
    print("If this problem continues:")
    print(
        "- If this started happening after an update, open an issue at github.com/mirkokral/ccarcos, and wait for an update")
    print("- Try removing or disconnecting any newly installed hardware or software.")
    print(
        "- If using a multiboot/bios solution, check if your multiboot/bios solution supports TLCO and open an issue there")
    print("- On boot, try pressing the scroll lock key and s. That should put you into an emergency shell.")
    print()
    print(kpError)
    print()
    print("If needed, contact @mirko56 on discord for further assistance.")
end

while true do
    coroutine.yield()
end
