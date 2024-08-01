local counter = 0
local ox, oy = 0,0 
local tw, th = term.getSize()
local pages = {}
local page = 1

pages[1] = {
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
table.insert(
    pages[1],
    ui.Button(
        {
            callBack = function ()
                -- oy = oy + 1
                ui.PageTransition(pages[1], pages[2], true, 0.01)
                page = 2
            end,
            x = tw - 5,
            y = th - 1,
            label = "Next",
            
        }
    )
)
local btn = ui.Button({
    callBack = function ()
        pages[1][1].label = "Counter: " .. counter
        rerender()
    end,
    label = "Increase counter",
    x = 1,
    y = 7,
    col = ui.UItheme.buttonBg,
    textCol = ui.UItheme.buttonFg
})
table.insert(pages[1], btn)
table.insert(pages[1],
ui.Label({
    label = "Button width: " .. tostring(btn.getWH()[1]) .. ", height: " .. tostring(btn.getWH()[2]),
    x = 1,
    y = 8
})
)

pages[2] = {
    ui.Label({
        label = "Hello, world!",
        x = 3,
        y = 3,
    })
}
table.insert(
    pages[2],
    ui.Button(
        {
            callBack = function ()
                ui.PageTransition(pages[2], pages[1], false, 0.01)
                page = 1
                rerender()
            end,
            x = tw - 5,
            y = th - 1,
            label = "Back",
            col = col.gray,
            textCol = col.white
        }
    )
)
function rerender()
    ui.InitBuffer()
    ui.RenderWidgets(pages[page], ox, oy)
    ui.Push() 
end
rerender()
while true do
    local ev = { arcos.ev() }
    if ev[1] == "mouse_click" then
        for i, v in ipairs(pages[page]) do
            v.onEvent({"click", ev[2], ev[3]-ox, ev[4]-oy})
        end
    else

        for i, v in ipairs(pages[page]) do
            v.onEvent(ev)
        end
    end
    if ev[1] == "key" and page == 1 then
        pages[1][5].label = "Latest key: " .. tostring(ev[2])
        rerender()
        
    end
end