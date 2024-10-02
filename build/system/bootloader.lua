local term = KDriversImpl.terminal
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
    local cf = KDriversImpl.files.open("/config/aboot", "r")
    local config = json.decode(cf.readAll())
    cf.close()
    term.setTextColor(term.pMap[config["theme"]["fg"]])
    term.setBackgroundColor(term.pMap[config["theme"]["bg"]])
    term.clear()
    term.setCursorPos(1, 1)
    local args = config["defargs"] or ""
    if not config["skipPrompt"] then
      term.write("krnl: ")
        args = read() or ""
    end
    local f = KDriversImpl.files.open("/system/krnl.lua", "r")      
    local fn, e = load(f.readAll(), "/system/krnl.lua", nil, setmetatable({}, {__index = _G}))
    if not fn then error(e) end
    fn(table.unpack(mysplit(args, " ")))
end
main()
