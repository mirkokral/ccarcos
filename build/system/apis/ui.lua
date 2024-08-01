UItheme = {
    bg = col.blue,
    fg = col.white,
    buttonBg = col.lightBlue
}
local function blitAtPos(x, y, bgCol, forCol, text)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bgCol or UItheme.bg)
    term.setTextColor(forCol or UItheme.fg)
    term.write(text)
end
function Label(b)
    local config = {}
    for i, v in pairs(b) do
        config[i] = v
    end
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end
    config.getDrawCommands = function ()
        local rcbuffer = {}
        local rx = 0
        local ry = 0
        local i = 1
        while string.sub(config.label, i, i) do
            if string.sub(config.label, i, i) == "\n" then
                rx = 0
                ry = ry + 1
            else
                table.insert(rcbuffer, {
                    x = config.x + rx,
                    y = config.y + ry,
                    forCol = config.textCol,
                    bgCol = config.col,
                    text = string.sub(config.label, i, i)
                })
                rx = rx + 1
            end
            i = i + 1
        end
    end
    config.onEvent = function(ev)
    end
    return config
end
function DirectRender(wr)
    local rc
    if wr["getDrawCommands"] then
        rc = wr["getDrawCommands"]()
    else
        rc = wr
    end
    for i, v in ipairs(rc) do
        print(v.text)
        blitAtPos(v.x, v.y, v.bgCol, v.forCol, v.text)
    end
end
function RenderWidgets(wdg)
    term.setBackgroundColor(ui.UItheme.bg)
    term.clear()
    for index, value in ipairs(wdg) do
        ui.DirectRender(wdg)
    end
end
