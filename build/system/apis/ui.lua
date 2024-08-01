local function blitAtPos(x, y, bgCol, forCol, text)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bgCol)
    term.setTextColor(forCol)
    term.write(text)
end
function Button(config)
end
