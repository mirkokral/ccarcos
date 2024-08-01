UItheme = {
    bg = col.white,
    fg = col.black,
    buttonBg = col.blue,
    buttonFg = col.white
}
W, H = term.getSize()

---Inits the buffer
---@return table
function InitBuffer()
    local buf = {}
    W, H = term.getSize()
    for i = 1, W, 1 do
        local tb = {}
        for i = 1, H, 1 do
            table.insert(tb, {col.white, col.black, " "})
        end
        table.insert(buf, tb)
    end
    return buf
end
---@param x number The X position for the blit
---@param y number The Y position for the blit
---@param bgCol Color The background color
---@param forCol Color The foreground color
---@param text string The text
---@param buf table Buffer
local function blitAtPos(x, y, bgCol, forCol, text, buf)
    if x <= W and y <= H and y>0 and x>0 then
        buf[x][y] = {bgCol, forCol, text}
    end
end
---@param x number The X position for the blit
---@param y number The Y position for the blit
---@param bgCol Color The background color
---@param forCol Color The foreground color
---@param text string The text
local function oldBlitAtPos(x, y, bgCol, forCol, text)
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
---@field getWH fun(): [number, number] Gets the width and height of this element.

---@class Label: Widget
---@field label string The label
---@field col Color The label bg color
---@field textCol Color The text color for the label
---@class Button: Label
---@field callback fun()

---@class ScrollPane: Widget
---@field width number The width of the pane. Currently cuts off elements but maybe vertical scroll next time
---@field height number The height of the pane.
---@field col Color The background color of the scroll pane
---@field children Widget[] The children.
---@field showScrollbar boolean Wether to show the scroll bar
---@field scroll number How much scrolled
---@field getTotalHeight fun() : number Gets the total height of all the elements

---Create a new scroll pane.
---@param b { width: number, height: number, x: number, y: number, col: Color?, children: Widget[], showScrollbar: boolean?,  }
---@return ScrollPane
function ScrollPane(b)
    local config = {}
    for key, value in pairs(b) do
        config[key] = value
    end
    config.scroll = 0
    config.width = config.width - 1
    config.getTotalHeight = function ()
        local h = 0
        for index, value in ipairs(config.children) do
            h = h + value.getWH()[2]
        end
    end
    config.getDrawCommands = function ()
        ---@type RenderCommand[]
        local dcBuf = {}
        local tw, th = term.getSize()
        for i = 1, tw, 1 do
            for ix = 1, th, 1 do
                ---@type RenderCommand
                local rc = {
                    bgCol = config.col,
                    forCol = col.white,
                    text = " ",
                    x = tw,
                    y = th,
                }
                table.insert(dcBuf, rc)
            end
        end
        local yo = 0
        for index, value in ipairs(config.children) do
            ---@type RenderCommand[]
            local rc = value.getDrawCommands()
            for index, value in ipairs(rc) do
                table.insert(dcBuf, {
                    x = config.x + value.x,
                    y = config.y + value.y - config.scroll + yo,
                    text = value.text,
                    bgCol = value.bgCol,
                    forCol = value.forCol
                })
            end
            yo = yo + value.getWH()[2]
        end
        local rmIndexes = {}
        for index, value in ipairs(dcBuf) do
            if value.x < 1 or value.x > config.width or value.y < 1 or value.y > config.height then
                table.insert(rmIndexes, 1, index)
            end
        end
        for index, value in ipairs(rmIndexes) do
            table.remove(dcBuf, value)
        end
        table.insert(dcBuf, {
            text = "^",
            forCol = UItheme.bg,
            bgCol = UItheme.fg,
            x = config.x + config.width,
            y = config.y
        })
        table.insert(dcBuf, {
            text = "v",
            forCol = UItheme.bg,
            bgCol = UItheme.fg,
            x = config.x + config.width,
            y = config.y + 1
        })
        for i = 3, config.height, 1 do
            table.insert(dcBuf, {
                text = "|",
                forCol = UItheme.bg,
                bgCol = UItheme.fg,
                x = config.x + config.width,
                y = config.y + i
            }) 
        end
        return dcBuf
    end
    config.onEvent = function (e)
        local ce = e
        if ce[1] == "click" then
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[3] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    value.onEvent({"click", ce[2], ce[3] - config.x, ce[4] - config.y})
                end
            end
            if ce[3] == config.x+config.width and ce[4] == config.y then
                
                config.scroll = math.max(config.scroll - 1, 0) 
            end
            if ce[3] == config.x+config.width and ce[4] == config.y then
                
                config.scroll = math.min(config.scroll + 1, config.getTotalHeight()) 
            end
        end
    end
    return config
end

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
    local config = {col = UItheme.buttonBg, textCol = UItheme.buttonFg}
    for i, v in pairs(b) do
        config[i] = v
    end
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
---@param buf table Buffer
function DirectRender(wr, ox, oy, buf)
    local rc
    if wr["getDrawCommands"] then
        rc = wr["getDrawCommands"]()
    else
        rc = wr
    end
    for i, v in ipairs(rc) do
        blitAtPos(v.x+ox, v.y+oy, v.bgCol, v.forCol, v.text, buf)
    end
end

---Pushes the buffer to the screen, finnalizing rendering. NOTE: this does not reinit the buffer so make sure to reinit it after you're done with pushing.
---@param buf table Buffer
function Push(buf)
    for ix, vx in ipairs(buf) do
        for iy, vy in ipairs(vx) do
            oldBlitAtPos(ix, iy, vy[1], vy[2], vy[3])
        end
    end
end

---Render some widgets
---@param wdg Widget[]
---@param ox number Offset X
---@param oy number Offset Y
---@param buf table Offset Y
function RenderWidgets(wdg, ox, oy, buf)
    arcos.log("UI blitatpos")
    local tw, th = term.getSize()
    for i = 1, th, 1 do
        for ix = 1, tw, 1 do
            blitAtPos(ix+ox, i+oy, ui.UItheme.bg, ui.UItheme.fg, " ", buf)
        end
    end
    arcos.log("UI directrender")
    for index, value in ipairs(wdg) do
        ui.DirectRender(value, ox, oy, buf)
    end
end
---Play a transition between widget sets 1 and 2
---@param widgets1 Widget[]
---@param widgets2 Widget[]
---@param dir boolean True if to the right, false if to the left
---@param speed number Speed
---@param ontop boolean True if new widget on top
function PageTransition(widgets1, widgets2, dir, speed, ontop)
    local tw, th = term.getSize()
    local ox = 0
    local accel = 1
    if ontop then
        while ox < tw do
            ox = ox + accel
            accel = accel + speed
            
        end
        while ox > 0 do
            ox = math.max(ox - accel, 0)
            accel = accel - speed
            local buf = InitBuffer()
            RenderWidgets(widgets1, 0, 0, buf)
            RenderWidgets(widgets2, ox * (dir and -1 or 1), 0, buf)
            Push(buf)
            sleep(1/60)
        end        
    else
        while ox < tw do
            ox = math.min(ox + accel, tw)
            accel = accel + speed
            local buf = InitBuffer()
            RenderWidgets(widgets2, 0, 0, buf)
            RenderWidgets(widgets1, ox * (dir and -1 or 1), 0, buf)
            Push(buf)
            sleep(1/60)
        end
    end
end

-- C:Exc
_G.ui = {
    Label = Label,
    Button = Button,
    DirectRender = DirectRender,
    UItheme = UItheme,
    RenderWidgets = RenderWidgets,
    PageTransition = PageTransition,
    InitBuffer = InitBuffer,
    Push = Push,
    ScrollPane = ScrollPane
    
}
-- C:End
