function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

function main()
    local cf = __LEGACY.files.open("/config/aboot", "r")
    local config = __LEGACY.textutils.unserialiseJSON(cf.readAll())
    cf.close()
    -- print(__LEGACY.textutils.serialize(config))
    __LEGACY.term.setTextColor(__LEGACY.colors[config["theme"]["fg"]])
    __LEGACY.term.setBackgroundColor(__LEGACY.colors[config["theme"]["bg"]])
    __LEGACY.term.clear()
    __LEGACY.term.setCursorPos(1, 1)

    local args = config["defargs"] or ""
    if not config["skipPrompt"] then
        write("krnl: ")
        -- sleep(5)
        args = read()
    end
    local f = __LEGACY.files.open("/system/krnl.lua", "r")
    local fn, e = load(f.readAll(), "/system/krnl.lua", nil, setmetatable({}, {__index = _G}))
    if not fn then error(e) end
    fn(table.unpack(mysplit(args, " ")))
end
main()
