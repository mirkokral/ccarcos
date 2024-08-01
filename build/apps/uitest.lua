local widgets = {
    ui.Label({
        label = "Testing 123",
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
    })
}
ui.RenderWidgets(widgets)
while true do
    local ev = { arcos.ev() }
    for i, v in ipairs(widgets) do
        v.onEvent(ev)
    end
    if ev[1] == "key" then
        widgets[5].label = "Latest key: " .. tostring(ev[2])
        ui.RenderWidgets(widgets)
    end
end