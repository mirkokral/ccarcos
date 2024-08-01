UItheme = {
    bg = col.blue,
    fg = col.white,
    buttonBg = col.lightBlue
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

---Creates a new label
---@param b { label: string, x: number, y: number, col: Color?, textCol: Color? } The button configuration
---@return Label
function Label(b)
    local config = {}
    for i, v in pairs(b) do
        config[i] = v
    end
    if not config.col then config.col = UItheme.bg end
    if not config.textCol then config.textCol = UItheme.fg end
    config.getDrawCommands = function ()
        ---@type RenderCommand[]
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

    end
    config.onEvent = function(ev)
    end
    return config
end
---Directly renders rendercommands.
---@param wr RenderCommand[] | Widget
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

---Render some widgets
---@param wdg Widget[]
function RenderWidgets(wdg)
    term.setBackgroundColor(ui.UItheme.bg)
    term.clear()
    for index, value in ipairs(wdg) do
        ui.DirectRender(wdg)
    end
end

-- C:Exc
_G.ui = {
    Label = Label,
    DirectRender = DirectRender,
    UItheme = UItheme,
    RenderWidgets = RenderWidgets,
    
}
-- C:End
