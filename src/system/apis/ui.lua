UItheme = {
    bg = col.white,
    fg = col.black,
    buttonBg = col.lightBlue,
    buttonFg = col.white
}

---@param x number The X position for the blit
---@param y number The Y position for the blit
---@param bgCol Color The background color
---@param forCol Color The foreground color
---@param text string The text
local function blitAtPos(x, y, bgCol, forCol, text)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bgCol or UItheme.bg)
    term.setTextColor(forCol or UItheme.fg)
    term.write(text)
end
---@class RenderCommand
---@field x number The X position for the render command
---@field y number The Y position for the render command
---@field bgCol Color The bg color for the render command
---@field forCol Color The foreground color for the render command
---@field text string The text for the render command

---@class Widget
---@field x number The x position of the widget
---@field y number The y position of the widget
---@field getDrawCommands fun(): RenderCommand[]
---@field onEvent fun(e)

---@class Label: Widget
---@field label string The label
---@field col Color The label bg color
---@field textCol Color The text color for the label 
---@field getWH fun(): [number, number]
---@class Button: Label
---@field callback fun()

---Creates a new label
---@param b { label: string, x: number, y: number, col: Color?, textCol: Color? } The button configuration
---@return Label
function Label(b)
    local config = {}
    for i, v in pairs(b) do
        config[i] = v
    end
    function config.getWH()
        local height = 1
        local width = 1
        local i = 1
        while string.sub(config.label, i, i) ~= "" do
            if string.sub(config.label, i, i) == "\n" then
                height = height + 1
            else
                width = width + 1
            end
            i = i + 1
        end
        width = width - 1
        return {width, height}
    end
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end
    config.getDrawCommands = function ()
        ---@type RenderCommand[]
        local rcbuffer = {}
        local rx = 0
        local ry = 0
        local i = 1
        while string.sub(config.label, i, i) ~= "" do
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
        return rcbuffer
    end
    config.onEvent = function(ev)
    end
    return config
end

---Creates a new button
---@param b { label: string, x: number, y: number, callBack: fun(), col: Color?, textCol: Color? } The button configuration
---@return Button
function Button(b)
    local config = {}
    for i, v in pairs(b) do
        config[i] = v
    end
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end

    local o = Label(config)
    o.onEvent = function (e)
        if e[1] == "click" then
            local wh = o.getWH()
            if e[2] == 1 and e[3] >= o.x and e[4] >= o.y and e[3] < o.x + wh[1] and e[4] < o.y + wh[2] then
                b.callBack()
            end
        end
    end
    return o
end

---Directly renders rendercommands.
---@param wr RenderCommand[] | Widget
---@param ox number Offset X
---@param oy number Offset Y
function DirectRender(wr, ox, oy)
    local rc
    if wr["getDrawCommands"] then
        rc = wr["getDrawCommands"]()
    else
        rc = wr
    end
    for i, v in ipairs(rc) do
        blitAtPos(v.x+ox, v.y+oy, v.bgCol, v.forCol, v.text)
    end
end

---Render some widgets
---@param wdg Widget[]
---@param ox number Offset X
---@param oy number Offset Y
function RenderWidgets(wdg, ox, oy)
    local tw, th = term.getSize()
    for i = 1, th, 1 do
        for ix = 1, tw, 1 do
            blitAtPos(ix+ox, i+oy, ui.UItheme.bg, ui.UItheme.fg, " ")
        end
    end
    for index, value in ipairs(wdg) do
        ui.DirectRender(value, ox, oy)
    end
end

-- C:Exc
_G.ui = {
    Label = Label,
    Button = Button,
    DirectRender = DirectRender,
    UItheme = UItheme,
    RenderWidgets = RenderWidgets,
    
}
-- C:End
