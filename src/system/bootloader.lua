local theme = {
    background = __LEGACY.colors.black,
    foreground = __LEGACY.colors.white
}
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
    
    term.setTextColor(theme.foreground)
    term.setBackgroundColor(theme.background)
    term.clear()
    term.setCursorPos(1, 1)
    local branch = __LEGACY.textutils.unserialiseJSON(__LEGACY.http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main").readAll())["sha"] 
    local cur = __LEGACY.fs.open("/system/rel", "r")
    if cur and cur.readAll() ~= branch then
        laodfile("/system/installer.lua")()
    end
    print("arcos2 bootloader")
    -- write("kargs: ")
    local args = ""
    loadfile("/system/krnl.lua", mysplit(args, " "))
end
main()