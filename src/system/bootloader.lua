--C:Exclude
local theme = {
    background = colours.blue,
    foreground = colors.lightBlue
}
--C:End

function main()
    
    term.setTextColor(theme.foreground)
    term.setBackgroundColor(theme.background)
    term.setCursorPos(1, 1)
    print("arcos2 bootloader")
end