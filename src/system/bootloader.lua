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
    __LEGACY.term.setTextColor(__LEGACY.colors[cf["theme"]["fg"]])
    __LEGACY.term.setBackgroundColor(__LEGACY.colors[cf["theme"]["bg"]])
    __LEGACY.term.clear()
    __LEGACY.term.setCursorPos(1, 1)
    local branch = __LEGACY.textutils.unserialiseJSON(__LEGACY.http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main").readAll())["sha"] 
    local cur = __LEGACY.fs.open("/system/rel", "r")
    if cur and cur.readAll() ~= branch then
        laodfile("/system/installer.lua")()
    end
    
    local args = ""
    if not config["skipPrompt"] then
        write("krnl: ")
        args = read()
    end
    loadfile("/system/krnl.lua", nil, setmetatable({}, {__index = _G}))(table.unpack(mysplit(args, " ")))
end
main()