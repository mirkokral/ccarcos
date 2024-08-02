local w, h = term.getSize()
local pages = {}
local page = 1
-- Page 1: Welcome
pages[1] = {}
table.insert(pages[1],
    ui.Label({
        label = "Welcome to ",
        x = 2,
        y = 2
    })
)
table.insert(pages[1],
    ui.Label({
        label = "cc",
        x = 13,
        y = 2,
        textCol = col.gray
    })
)
table.insert(pages[1],
    ui.Label({
        label = "arcos",
        x = 15,
        y = 2,
        textCol = col.cyan
    })
)
table.insert(pages[1],
    ui.Label({
        label = ui.Wrap("This wizard will guide you through the basic setup steps of arcos.", w-2),
        x = 2,
        y = 4,
        textCol = ui.UItheme.lighterBg
    })
)
table.insert(pages[1],
    ui.Button({
        callBack = function ()
            ui.PageTransition(pages[1], pages[2], false, 1, true, term)
            page = 2
            return true
        end,
        label = " Next ",
        x = w-1-6,
        y = h-1
    })
)
-- Page 2
pages[2] = {}

table.insert(pages[2], ui.Label({
    label = "Select an init",
    x = 2,
    y = 2
}))

table.insert(pages[2], ui.Label({
    label = ui.Wrap("An init is the program that gets started on machine boot.", w-2),
    x = 2,
    y = 2,
    textCol = ui.UItheme.lighterBg
}))
-- Rendering
local ls = true
while true do
    ls = ui.RenderLoop(pages[page], term, ls)
end