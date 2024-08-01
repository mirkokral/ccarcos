UItheme = {
    bg = col.blue,
    fg = col.white,
    buttonBg = col.lightBlue
}
local function blitAtPos(x, y, bgCol, forCol, text)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bgCol)
    term.setTextColor(forCol)
    term.write(text)
end
function Label(b)
    local config = b
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end
    return {
        x = config.x,
        y = config.y,
        getDrawCommands = function ()
            local rcbuffer = {}
            local rx = 0
            local ry = 0
            local i = 1
            while config.label:sub(i, i) do
                if config.label:sub(i, i) == "\n" then
                    rx = 0
                    ry = ry + 1
                else
                    table.insert(rcbuffer, {
                        x = config.x + rx,
                        y = config.y + ry,
                        forCol = config.textCol,
                        bgCol = config.col,
                        text = config.label:sub(i, i)
                    })
                    rx = rx + 1
                end
                i = i + 1
            end
        end,
        onEvent = function(ev)
        end,
        label = config.label,
        col = config.col,
        textCol = config.textCol
    }
end
function DirectRender(wr)
    local rc
    if wr["getDrawCommands"] then
        rc = wr["getDrawCommands"]()
    else
        rc = wr
    end
    for i, v in ipairs(rc) do
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
