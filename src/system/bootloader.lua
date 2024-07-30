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
    local cf = __LEGACY.fs.open("/config/aboot", "r")
    local config = __LEGACY.textutils.unserialiseJSON(cf.readAll())
    cf.close()
    -- print(__LEGACY.textutils.serialize(config))
    __LEGACY.term.setTextColor(__LEGACY.colors[config["theme"]["fg"]])
    __LEGACY.term.setBackgroundColor(__LEGACY.colors[config["theme"]["bg"]])
    __LEGACY.term.clear()
    __LEGACY.term.setCursorPos(1, 1)

    local args = ""
    if not config["skipPrompt"] then
        write("krnl: ")
        args = read()
    end
    local f = __LEGACY.fs.open("/system/krnl.lua", "r")
    load(f.readAll(), "/system/krnl.lua", nil, setmetatable({}, {__index = _G}))(table.unpack(mysplit(args, " ")))
end
main()