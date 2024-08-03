local w, h = term.getSize()
local pages = {}
local page = 2
-- Error page
pages[1] = {
    ui.Label({
        label = "An error happened during setup!",
        x = 2, y = 2,
        textCol = col.red
    }),
    ui.Label({
        label = "<insert error>",
        x = 2, y = 4,
        textCol = col.magenta
    })
}
-- Page 1: Welcome
pages[2] = {}
table.insert(pages[2],
    ui.Label({
        label = "Welcome to ",
        x = 2,
        y = 2
    })
)
table.insert(pages[2],
    ui.Label({
        label = "cc",
        x = 13,
        y = 2,
        textCol = col.gray
    })
)
table.insert(pages[2],
    ui.Label({
        label = "arcos",
        x = 15,
        y = 2,
        textCol = col.cyan
    })
)
table.insert(pages[2],
    ui.Label({
        label = ui.Wrap("This wizard will guide you through the basic setup steps of arcos.", w-2),
        x = 2,
        y = 4,
        textCol = ui.UItheme.lighterBg
    })
)
table.insert(pages[2],
    ui.Button({
        callBack = function ()
            ui.PageTransition(pages[2], pages[3], false, 1, true, term)
            page = 3
            return true
        end,
        label = " Next ",
        x = w-1-6,
        y = h-1
    })
)
-- Page 2
pages[3] = {}

table.insert(pages[3], ui.Label({
    label = "Select an init",
    x = 2,
    y = 2
}))
local is = {}
for index, value in ipairs(fs.ls("/services/")) do
    table.insert(is, ui.Button{
        callBack = function ()
            local f, e = fs.open("/services/enabled", "w")
            if not f then
                pages[1][2].label = tostring(e)
                ui.PageTransition(pages[3], pages[1], false, 1, true, term)
                page = 1
                return true
            end
            f.write("o " .. value)
            ui.PageTransition(pages[3], pages[4], false, 1, true, term)
            page = 4
            return true
        end,
        x = 1, y = 1,
        col = ui.UItheme.lighterBg,
        textCol = ui.UItheme.bg,
        label = value:sub(#value-3)
    })
end
table.insert(pages[3], ui.ScrollPane({
    x = 2,
    y = 4,
    col = ui.UItheme.lighterBg,
    children = is,
    height = h - 5,
    width = w - 2,
    showScrollBtns = false
}))
-- Page 3: Finish
pages[4] = {
    ui.Label{
        label = "All finished!",
        textCol = col.green,
        x = 2,
        y = 2
    },
    ui.Button{
        callBack = function ()
            arcos.reboot()
            return true
        end,
        label = " Reboot ",
        x = w-1-8,
        y = h-1
    }
}
-- Rendering
local ls = true
while true do
    ls = ui.RenderLoop(pages[page], term, ls)
end