local monitors = dev.monitor
local selecting = true
local terma = term
local selection = {
    ui.Button({
        label = "Local",
        x = 0,
        y = 0,
        callBack = function ()
            terma = term
            selecting = false
            return false
        end,
        col = col.lightGray,
        textCol = col.black
    }),
}
for _, i in ipairs(monitors) do
    table.insert(selection, 
        ui.Button({
            label = i.origName,
            callBack = function ()
                terma = i
                selecting = false
                return false
            end,
            x = 0,
            y = 0,
            col = col.lightGray,
            textCol = col.black
        })
    )
end
local ttw, tth = terma.getSize()
local monSelPage = {
    ui.Label({
        label = "Select an Output",
        x=2,
        y=2
    }),
    ui.ScrollPane({
        children = selection,
        height = tth-4,
        width = ttw-3,
        x = 2,
        y = 4,
        col = col.lightGray,
        showScrollBtns = false,
    })
}
ui.RenderLoop(monSelPage, term, true)
while selecting do
    if term then
        ui.RenderLoop(monSelPage, term)
    end
end
local counter = 0
local ox, oy = 0,0 
local tw, th = terma.getSize()
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
                ui.PageTransition(pages[1], pages[2], false, 1, true)
                page = 2
                return true
            end,
            x = tw - 5,
            y = th - 1,
            label = "Next",
        }
    )
)
local btn = ui.Button({
    callBack = function ()
        counter = counter + 1
        pages[1][1].label = "Counter: " .. counter
        return true
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
local lbls = {}
for i = 1, 40, 1 do
    table.insert(lbls, ui.Label({
        label = "Hello world: " .. tostring(i),
        x = 0,
        y = 0
    }))
end
pages[2] = {
    ui.Label({
        label = "Level!",
        x = 3,
        y = 7,
    }),
    ui.Label({
        label = "Level2!",
        x = 3,
        y = 17,
    }),
    ui.Label({
        label = "XLevel!",
        x = 20,
        y = 2,
    }),
    ui.Label({
        label = "XLevel2!",
        x = 40,
        y = 2,
    }),
    ui.ScrollPane({
        width= 20,
        height= 10,
        x = 20,
        y = 7,
        children = lbls,
        col = col.gray,
        showScrollBtns = true
    })
}
table.insert(
    pages[2],
    ui.Button(
        {
            callBack = function ()
                ui.PageTransition(pages[2], pages[1], false, 1, false)
                page = 1
                return true
            end,
            x = tw - 5,
            y = th - 1,
            label = "Back",
            col = col.gray,
            textCol = col.white
        }
    )
)
ui.RenderLoop(monSelPage, terma, true)
while selecting do
    if term then
        ui.RenderLoop(monSelPage, terma)
    end
end