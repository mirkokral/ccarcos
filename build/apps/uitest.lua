local counter = 0
local ox, oy = 0,0 
local tw, th = term.getSize()
local widgets = {
    ui.Label({
        label = "Counter: "..counter,
        x = 1,
        y = 1
    }),
    ui.Label({
        label = "I'm green!",
        x = 1,
        y = 2,
        textCol = col.green
    }),
    ui.Label({
        label = "I'm light blue on the background!",
        x = 1,
        y = 3,
        col = col.lightBlue
    }),
    ui.Label({
        label = "I'm multiline!\nSee?",
        x = 1,
        y = 4,
        col = col.red,
        textCol = col.white
    }),
    ui.Label({
        x=13,
        y=1,
        label = "No key yet pressed"
    }),
}
table.insert(widgets, ui.Button(
    {
        callBack = function ()
            ox = ox + 1
        end,
        x = tw - 2,
        y = tw - 3,
        label = ">"
    }
))
table.insert(widgets, ui.Button(
    {
        callBack = function ()
            ox = ox - 1
        end,
        x = tw - 4,
        y = tw - 3,
        label = "<"
    }
))
table.insert(
    widgets,
    ui.Button(
        {
            callBack = function ()
                oy = oy - 1
                ui.RenderWidgets(widgets, ox, oy)
            end,
            x = tw - 3,
            y = tw - 2,
            label = "^"
        }
    )
)
table.insert(
    widgets,
    ui.Button(
        {
            callBack = function ()
                oy = oy + 1
            end,
            x = tw - 3,
            y = tw - 2,
            label = "v"
        }
    )
)
local btn = ui.Button({
    callBack = function ()
        counter = counter + 1
        widgets[1].label = "Counter: " .. counter
        ui.RenderWidgets(widgets, ox, oy)
    end,
    label = "Increase counter",
    x = 1,
    y = 7,
    col = ui.UItheme.buttonBg,
    textCol = ui.UItheme.buttonFg
})
table.insert(widgets, btn)
table.insert(widgets,
ui.Label({
    label = "Button width: " .. tostring(btn.getWH()[1]) .. ", height: " .. tostring(btn.getWH()[2]),
    x = 1,
    y = 8
})
)
ui.RenderWidgets(widgets, ox, oy)
while true do
    local ev = { arcos.ev() }
    if ev[1] == "mouse_click" then
        for i, v in ipairs(widgets) do
            v.onEvent({"click", ev[2], ev[3], ev[4]})
        end
    else
        for i, v in ipairs(widgets) do
            v.onEvent(ev)
        end
    end
    if ev[1] == "key" then
        widgets[5].label = "Latest key: " .. tostring(ev[2])
        ui.RenderWidgets(widgets, ox, oy)
    end
end