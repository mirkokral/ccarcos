local theme = {
    background = colours.black,
    foreground = colors.white
}

function main()
    
    term.setTextColor(theme.foreground)
    term.setBackgroundColor(theme.background)
    term.clear()
    term.setCursorPos(1, 1)
    print("arcos2 bootloader")
    -- write("kargs: ")
    local args = ""
    _G.__LEGACY.shell.run("/system/krnl.lua " .. args)
end
main()