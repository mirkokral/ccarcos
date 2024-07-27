local theme = {
    background = colours.blue,
    foreground = colors.lightBlue
}
function main()
    term.setTextColor(theme.foreground)
    term.setBackgroundColor(theme.background)
    term.clear()
    term.setCursorPos(1, 1)
    print("arcos2 bootloader")
    write("kargs: ")
    local args = read()
    _G.__LEGACY.shell.run("/system/krnl.lua " .. args)
end
main()