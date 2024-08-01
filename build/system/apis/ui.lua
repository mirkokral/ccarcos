UItheme = {
    bg = col.white,
    fg = col.black,
    buttonBg = col.lightBlue,
    buttonFg = col.white
}
local buf = {}
w, h = term.getSize()
function InitBuffer()
    buf = {}
    w, h = term.getSize()
    for i = 1, w, 1 do
        local tb = {}
        for i = 1, h, 1 do
            table.insert(tb, {col.white, col.black, " "})
        end
        table.insert(buf, tb)
    end
end
local function blitAtPos(x, y, bgCol, forCol, text)
    if x <= w and y <= h and y>0 and x>0 then
        buf[x][y] = {bgCol, forCol, text}
    end
end
local function oldBlitAtPos(x, y, bgCol, forCol, text)
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
function Push()
    for ix, vx in ipairs(buf) do
        for iy, vy in ipairs(vx) do
            oldBlitAtPos(ix, iy, vy[1], vy[2], vy[3])
        end
    end
end
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
function PageTransition(widgets1, widgets2, dir, speed)
    local tw, th = term.getSize()
    local ox = 0
    local accel = 1
    while ox < tw do
        ox = ox + 1
        accel = accel + 1
        InitBuffer()
        RenderWidgets(widgets2, 0, 0)
        RenderWidgets(widgets1, ox * (dir and -1 or 1), 0)
        Push()
        sleep(speed / accel)
    end
end
