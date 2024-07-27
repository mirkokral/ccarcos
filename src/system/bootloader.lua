local theme = {
    background = colours.blue,
    foreground = colors.lightBlue
}

function main()
    
    term.setTextColor(theme.foreground)
    term.setBackgroundColor(theme.background)
    term.setCursorPos(1, 1)
    print("arcos2 bootloader")
    write("")
end