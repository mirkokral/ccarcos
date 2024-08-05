UItheme = {
    bg = col.black,
    fg = col.white,
    buttonBg = col.cyan,
    buttonFg = col.black,
    lighterBg = col.gray,
    lightBg = col.lightGray
}
local UIthemedefs = {
}
UIthemedefs[col.white] = {236, 239, 244}
UIthemedefs[col.orange] = {0, 0, 0}
UIthemedefs[col.magenta] = {180, 142, 173}
UIthemedefs[col.lightBlue] = {0, 0, 0}
UIthemedefs[col.yellow] = {235, 203, 139}
UIthemedefs[col.lime] = {163, 190, 140}
UIthemedefs[col.pink] = {0, 0, 0}
UIthemedefs[col.gray] = {76, 86, 106}
UIthemedefs[col.lightGray] = {216, 222, 233}
UIthemedefs[col.cyan] = {136, 192, 208}
UIthemedefs[col.purple] = {0, 0, 0}
UIthemedefs[col.blue] = {129, 161, 193}
UIthemedefs[col.brown] = {0, 0, 0}
UIthemedefs[col.green] = {163, 190, 140}
UIthemedefs[col.red] = {191, 97, 106}
UIthemedefs[col.black] = {59, 66, 82}
for index, value in pairs(UIthemedefs) do
    term.setPaletteColor(index, value[1]/255, value[2]/255, value[3]/255) 
end
W, H = term.getSize()


---Inits the buffer
---@param mon any
---@return table
function InitBuffer(mon)
    for index, value in pairs(UIthemedefs) do
        mon.setPaletteColor(index, value[1]/255, value[2]/255, value[3]/255)
        
    end
    local buf = {}
    W, H = mon.getSize()
    for i = 1, H, 1 do
        local tb = {}
        for i = 1, W, 1 do
            table.insert(tb, {col.white, col.black, " "})
        end
        table.insert(buf, tb)
    end
    return buf
end
---@param sx number The X position for the blit
---@param sy number The Y position for the blit
---@param bgCol Color The background color
---@param forCol Color The foreground color
---@param text string The text
---@param buf table Buffer
local function blitAtPos(sx, sy, bgCol, forCol, text, buf)
    local x = math.floor(sx+0.5)
    local y = math.floor(sy+0.5)
    if x <= #buf[1] and y <= #buf and y>0 and x>0 then
        buf[y][x] = {bgCol, forCol, text}
    end
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
---@field onEvent fun(e): boolean?
---@field renderFinish fun(ox, oy)?
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
---@field hideScrollbar boolean Wether to show the scroll bar
---@field showScrollbBtns boolean Wether to show the scroll bar
---@field scroll number How much scrolled
---@field getTotalHeight fun() : number Gets the total height of all the elements

---@class TextInput: Label
---@field curpos number
---@field width number
---@field focus boolean
---@field text string
---@field textScroll number

---Create a new scroll pane.
---@param b { width: number, height: number, x: number, y: number, col: Color?, children: Widget[], showScrollBtns: boolean?,  hideScrollbar: boolean? }
---@return ScrollPane
function ScrollPane(b)
    local config = {}
    for key, value in pairs(b) do
        config[key] = value
    end
    config.scroll = 0
    if not config.hideScrollbar then
        config.width = config.width - 1
    end
    config.getTotalHeight = function ()
        local h = 0
        for index, value in ipairs(config.children) do
            h = h + value.getWH()[2]
        end
        return h
    end
    local mbpressedatm = false
    local lastx, lasty = 0, 0
    config.getDrawCommands = function ()
        ---@type RenderCommand[]
        local dcBuf = {}
        local tw, th = config.width, config.height
        for i = 0, tw, 1 do
            for ix = 0, th, 1 do
                ---@type RenderCommand
                local rc = {
                    bgCol = config.col,
                    forCol = col.white,
                    text = " ",
                    x = config.x + i,
                    y = config.y + ix,
                }
                table.insert(dcBuf, rc)
            end
        end
        local yo = 0
        for index, value in ipairs(config.children) do
            if value.y + yo - config.scroll + value.getWH()[1] > 0 and value.y + yo - config.scroll <= config.height then
                ---@type RenderCommand[]
                local rc = value.getDrawCommands()
                for index, value in ipairs(rc) do
                    table.insert(dcBuf, {
                        x = config.x + value.x - 1,
                        y = config.y + value.y - 1 - config.scroll + yo,
                        text = value.text,
                        bgCol = value.bgCol,
                        forCol = value.forCol
                    })
                end
            end
            yo = yo + value.getWH()[2]
        end
        local rmIndexes = {}
        for index, value in ipairs(dcBuf) do
            if value.x - config.x < 0 or value.x - config.x >= config.width or value.y - config.y < 0 or value.y - config.y >= config.height then
                table.insert(rmIndexes, 1, index)
            end
        end
        for index, value in ipairs(rmIndexes) do
            table.remove(dcBuf, value)
        end
        if config.showScrollBtns then
            table.insert(dcBuf, {
                text = "^",
                forCol = config.col,
                bgCol = UItheme.bg,
                x = config.x + config.width,
                y = config.y
            })
            table.insert(dcBuf, {
                text = "v",
                forCol = config.col,
                bgCol = UItheme.bg,
                x = config.x + config.width,
                y = config.y + 1
            })
        end
        if not config.hideScrollbar then
            for i = (config.showScrollBtns and 2 or 0), config.height-1, 1 do
                table.insert(dcBuf, {
                    text = "|",
                    forCol = config.col,
                    bgCol = UItheme.bg,
                    x = config.x + config.width,
                    y = config.y + i
                }) 
            end
        end
        return dcBuf
    end
    config.renderFinish = function (ox, oy)
        local yo = 0
        for index, value in ipairs(config.children) do
            
            if value.y + yo - config.scroll + value.getWH()[1] > 0 and value.y + yo - config.scroll <= config.height then
                if value.renderFinish then
                    value.renderFinish(config.x+ox, config.y+oy-config.scroll)
                end
            end
            yo = yo + value.getWH()[2]
        end
    end
    config.onEvent = function (e)
        local ce = e
        if ce[1] == "click" then
            local ret = false
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[3] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    if value.onEvent({"click", ce[2], ce[3] - config.x+1, ce[4] - config.y + config.scroll - index+2}) then
                        ret = true
                    end
                end
            else
                for index, value in ipairs(config.children) do
                    if value.onEvent({"defocus"}) then ret = true end
                end
            end
            if config.showScrollBtns then
                if ce[3] == config.x+config.width and ce[4] == config.y then
                
                    config.scroll = math.max(config.scroll - 1, 0) 
                    return true
                end
                if ce[3] == config.x+config.width and ce[4] == config.y+1 then
                    
                    config.scroll = math.min(config.scroll + 1, config.getTotalHeight() - config.height) 
                    return true
                end
            end
            mbpressedatm = true
            lastx, lasty = ce[3], ce[4]
            return ret
        end
        if ce[1] == "drag" then
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[3] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    value.onEvent({"drag", ce[2], ce[3] - config.x, ce[4] - config.y + config.scroll - index+2})
                end
            end
            local ret = false
            if mbpressedatm and lastx == config.x + config.width and lasty >= config.y + (config.showScrollBtns and 2 or 0) and lasty <= config.y + config.width then
                config.scroll = math.min(math.max(config.scroll + (ce[4] - lasty)*-1, 0), config.getTotalHeight() - config.height)
                ret = true
            end
            lastx, lasty = ce[3], ce[4]
            return ret
        end
        if ce[1] == "up" then
            local ret = false
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[4] <= config.y + config.height then
                for index, value in ipairs(config.children) do
                    if value.onEvent({"up", ce[2], ce[3] - config.x, ce[4] - config.y + config.scroll - index+2}) then
                        ret = ture
                    end
                end
            end
            mbpressedatm = false
            return ret
        end
        if ce[1] == "scroll" then
            -- print(ce[2], ce[3], ce[4])
            -- sleep(1)
            if ce[3] >= config.x and ce[4] >= config.y and ce[3] <= config.x + config.width and ce[4] <= config.y + config.height then
                config.scroll = math.min(math.max(config.scroll + ce[2], 0), config.getTotalHeight() - config.height)
                return true
            end
            
        end
    end
    return config
end



---Wrap a string
---@param str any
---@param maxLength any
---@return string
function Wrap(str, maxLength)
    local ostr = ""
    local cstr = ""
    for index2, value2 in ipairs(tutils.split(str, "\n")) do
        for index, value in ipairs(tutils.split(value2, " ")) do
            if #cstr + #value > maxLength then
                ostr = ostr .. cstr .. "\n"
                cstr = ""
            end
            
            cstr = cstr .. value .. " "
        end
        if #cstr > 0 then
            ostr = ostr .. cstr .. "\n"
            cstr = ""
        end
    end
    if #cstr > 0 then
        ostr = ostr .. cstr .. "\n"
    end
    ostr = ostr:sub(1, #ostr-1)
    return ostr
end

---Creates a new text input
---@param b { label: string, x: number, y: number, width: number, col: Color?, textCol: Color?} The button configuration
---@return TextInput
function TextInput(b)
    local ca = b
    if not ca["col"] then ca["col"] = col.gray end
    
    local defaultText = ca.label
    ---@type TextInput
    ---@diagnostic disable-next-line: assign-type-mismatch
    local config = Label(ca)
    -- config.width = b.width
    config.text = defaultText or ""
    config.textScroll = math.max(#config.text - config.width, 1)
    config.label = config.label:sub(config.textScroll, config.width+config.textScroll-1)
    config.label = config.label .. string.rep(" ", math.max(config.width - #config.label, 0 ))
    local cursorPos = 1
    
    config.focus = false
    
    config.onEvent = function (e)
        local function reRender()
            -- print(cursorPos - config.textScroll)
            -- sleep(1)
            if config.focus then
                config.label = config.text:sub(0, cursorPos) .. "|" .. config.text:sub(cursorPos+1)
                config.textScroll = math.max(math.min(#config.text-config.width+2, cursorPos),1)
                -- print(config.textScroll)
                -- sleep(0.5)
                config.label = config.label:sub(config.textScroll, config.width+config.textScroll-1)
                config.label = config.label .. string.rep(" ", math.max(config.width - #config.label, 0 ))
                config.col = col.lightGray
                config.textCol = col.black

            else
                config.label = #config.text > 0 and config.text or " "
                config.textScroll = math.max(math.min(#config.text-config.width+1, cursorPos),1)
                config.label = config.label:sub(config.textScroll, config.width+config.textScroll-1)
                config.label = config.label .. string.rep(" ", math.max(config.width - #config.label, 0 ))
                config.col = col.gray
                config.textCol = col.white
            end
        end
        if e[1] == "defocus" then
            config.focus = false
            return true
        end
        if e[1] == "click" then
            -- print(e[3], e[4], config.getWH()[1], config.getWH()[2])
            if e[3] >= config.x and e[4] >= config.y and e[3] < config.x + config.getWH()[1] and e[4] < config.y + config.getWH()[2] then
                if config.focus then
                    cursorPos = config.textScroll + e[3] - config.x
                else
                    cursorPos = #config.text
                end
                config.focus = true
                reRender()
                return true
            else
                config.focus = false
                reRender()
                return true
            end
        end
        if e[1] == "char" and config.focus then
            
            config.text = config.text:sub(0, cursorPos) .. e[2] .. config.text:sub(cursorPos+1)
            cursorPos = cursorPos + 1
            reRender()
            return true
        end
        if e[1] == "key" and config.focus then
            if e[2] == __LEGACY.keys.enter then
                config.focus = false
                reRender()
            end
            if e[2] == __LEGACY.keys.backspace then
                if cursorPos > 0 then
                    config.text = config.text:sub(0, cursorPos-1) .. config.text:sub(cursorPos+1)
                    cursorPos = cursorPos - 1
                    reRender()
                end
            end
            if e[2] == __LEGACY.keys.left then
                cursorPos = math.max(cursorPos-1, 0)
                reRender()
            end
            if e[2] == __LEGACY.keys.right then
                cursorPos = math.min(cursorPos+1, #config.text)
                reRender()
            end
            
            return true
        end

    end

    return config
end
---Creates a new label
---@param b { label: string, x: number, y: number, col: Color?, textCol: Color?} The button configuration
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
---@param b { label: string, x: number, y: number, callBack: fun(): boolean, col: Color?, textCol: Color? } The button configuration
---@return Button
function Button(b)
    local config = {col = UItheme.buttonBg, textCol = UItheme.buttonFg}
    for i, v in pairs(b) do
        config[i] = v
    end
    local o = Label(config)
    o.onEvent = function (e)
        local rt = false
        if e[1] == "click" then
            local wh = o.getWH()
            if e[2] == 1 and e[3] >= o.x and e[4] >= o.y and e[3] < o.x + wh[1] and e[4] < o.y + wh[2] then
                if b.callBack() then rt = true end
            end
        end
        return rt
    end
---@diagnostic disable-next-line: return-type-mismatch
    return o
end
---Render Loop
---@param toRender Widget[] The actual widgets to render.
---@param outTerm table Output terminal
---@param f boolean? Force render
---@return boolean
---@return table
function RenderLoop(toRender, outTerm, f)
    local function rerender()
        local buf = ui.InitBuffer(outTerm)
        ui.RenderWidgets(toRender, 0, 0, buf)
        ui.Push(buf, outTerm)
        buf = nil
    end
    if f then rerender() end
    local ev = { arcos.ev() }
    local red = false
    local isMonitor, monSide = pcall(__LEGACY.peripheral.getName, outTerm)
    if not isMonitor then
        if ev[1] == "mouse_click" then
            for i, v in ipairs(toRender) do
                if v.onEvent({"click", ev[2], ev[3]-0, ev[4]-0}) then red = true end
            end
        elseif ev[1] == "mouse_drag" then
            for i, v in ipairs(toRender) do
                if v.onEvent({"drag", ev[2], ev[3]-0, ev[4]-0}) then red = true end
            end
        elseif ev[1] == "mouse_up" then
            for i, v in ipairs(toRender) do
                if v.onEvent({"up", ev[2], ev[3]-0, ev[4]-0}) then red = true end
            end
        elseif ev[1] == "mouse_scroll" then
            for i, v in ipairs(toRender) do
                if v.onEvent({"scroll", ev[2], ev[3]-0, ev[4]-0}) then red = true end
            end
        else

            for i, v in ipairs(toRender) do
                if v.onEvent(ev) then red = true end
            end
        end
    else
        if ev[1] == "monitor_touch" and ev[2] == monSide then
            for i, v in ipairs(toRender) do
                if v.onEvent({"click", 1, ev[3]-0, ev[4]-0}) then red = true end
                if v.onEvent({"up", 1, ev[3]-0, ev[4]-0}) then red = true end
            end
        else
            for i, v in ipairs(toRender) do
                if v.onEvent(ev) then red = true end
            end
        end
    end
    return red, ev
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
---@param terma table Terminal
function Push(buf, terma)
    for ix, vy in ipairs(buf) do
        local blitText = ""
        local blitColor = ""
        local blitBgColor = ""
        for iy, vx in ipairs(vy) do
            blitBgColor = blitBgColor .. col.toBlit(vx[1])
            blitColor = blitColor .. col.toBlit(vx[2])
            blitText = blitText .. vx[3]    
        end
        terma.setCursorPos(1, ix)
        terma.blit(blitText, blitColor, blitBgColor)
    end
    -- term.setCursorPos(1, 1)
    -- term.setTextColor(col.white)
    -- term.setBackgroundColor(col.black)
    -- term.write("VX"..tostring(#buf))
end

---Copies buf 1 to buf 2 with an offset
---@param buf1 table[][]
---@param buf2 table[][]
---@param ox number
---@param oy number
function Cpy(buf1, buf2, ox, oy)
    for iy, vy in ipairs(buf1) do
        for ix, vx in ipairs(vy) do
            blitAtPos(ix+ox, iy+oy, vx[1], vx[2], vx[3], buf2)
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
    local tw, th = #buf[1], #buf
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

---Lerps
---@param callback fun(n: number)
---@param speed number
---@param deAccelAtEnd boolean?
function Lerp(callback, speed, deAccelAtEnd)
    local accel = 50
    local ox = 0
    if deAccelAtEnd then
        while ox < 100 do
            ox = math.max(ox+accel, 0)
            accel = accel/speed
            callback(ox)
            
            sleep(1/20)
        end
    else
        accel = 1.5625
        while ox < 100 do
            ox = math.max(ox+accel, 0)
            accel = accel*speed
            callback(ox)
            sleep(1/20)
        end
    end
end

---Play a transition between widget sets 1 and 2
---@param widgets1 Widget[]
---@param widgets2 Widget[]
---@param dir boolean True if to the right, false if to the left
---@param speed number Speed
---@param ontop boolean True if new widget on top
---@param terma table Terminal
function PageTransition(widgets1, widgets2, dir, speed, ontop, terma)

    local tw, th = terma.getSize()
    local ox = 0
    local buf = InitBuffer(terma)
    local buf2 = InitBuffer(terma)
    local accel = 50
    RenderWidgets(widgets1, 0, 0, buf)
    RenderWidgets(widgets2, 0, 0, buf2)
    speed = speed + 1
    if ontop then
        while ox < tw-0.5 do
            ox = math.max(((ox/tw)+(accel/100))*tw, 0)
            accel = accel/speed
            local sbuf = InitBuffer(terma)
            Cpy(buf, sbuf, 0, 0)
            Cpy(buf2, sbuf, (tw - ox) * (dir and -1 or 1), 0)
            Push(sbuf, terma)
            -- print(math.floor(ox+0.1), math.floor(ox+0.1) < tw, accel, tw)
            sbuf = nil
            
            sleep(1/20)
        end
    else
        accel = 1.5625
        while ox < tw-0.5 do
            ox = math.max(((ox/tw)+(accel/100))*tw, 0)
            accel = accel*speed
            local sbuf = InitBuffer(terma)
            Cpy(buf2, sbuf, 0, 0)
            Cpy(buf, sbuf, (ox) * (dir and -1 or 1), 0)
            Push(sbuf, terma)
            sbuf = nil
            -- print(math.floor(ox+0.1), math.floor(ox+0.1) < tw, accel, tw)
            
            sleep(1/20)
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
    Cpy = Cpy,
    Wrap = Wrap,
    RenderLoop = RenderLoop,
    ScrollPane = ScrollPane,
    TextInput = TextInput
    
}
-- C:End
