arc.fetch()
local w, h = term.getSize()
local pages = {}
local page = 2
local tobeinstalled = {}
local atobeinstalled = {}
local ipchildren = {}
local init = "shell.lua"
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
        textCol = ui.UItheme.lightBg
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
pages[3] = {}
table.insert(pages[3], ui.Label({
    label = "Select a login screen.",
    x = 2,
    y = 2
}))
table.insert(pages[3], ui.Label({
    label = ui.Wrap("A login screen is the program you see right after the init system.", w-2),
    x = 2,
    y = 3,
    col = ui.UItheme.lightBg
}))
table.insert(pages[3], ui.ScrollPane({
    x = 2,
    y = 4+pages[3][2].getWH()[2],
    col = ui.UItheme.lighterBg,
    children = {
        ui.Button{
            label = "audm",
            callBack = function ()
                table.insert(tobeinstalled, "audm")
                init = "audm.lua"
                ui.PageTransition(pages[3], pages[4], false, 1, true, term)
                page = 4
                return true
            end,
            x = 1,
            y = 1
        },
        ui.Button{
            label = "Shell",
            callBack = function ()
                init = "shell.lua"
                ui.PageTransition(pages[3], pages[4], false, 1, true, term)
                page = 4
                return true
            end,
            x = 1,
            y = 1
        }
    },
    height = h - 4-pages[3][2].getWH()[2],
    width = w - 2,
    showScrollBtns = false
}))
local repo = arc.getRepo()
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
local function pushPackageWithDependencies(pkg)
    if repo[pkg] then
        for _, v in ipairs(repo[pkg].dependencies) do
            pushPackageWithDependencies(v)
        end
        if (not arc.isInstalled(pkg) or arc.getIdata(pkg)["vId"] < repo[pkg]["vId"]) and not has_value(atobeinstalled, pkg) then
            table.insert(atobeinstalled, pkg)
        end
    end
end
pages[4] = {
    ui.Label{
        label = "Set computer label",
        x = 2,
        y = 2
    },
    ui.Label{
        label = ui.Wrap("A computer label sets the computer's name in the inventory, and with mods like Jade also shows on the blockinfo.", w-2),
        x = 2,
        y = 3,
        textCol = ui.UItheme.lightBg
    },
    ui.TextInput{
        label = "arcos",
        x = 2,
        y = 3
    },
    ui.Button{
        label = "Done",
        callBack = function ()
            if pages[4][2].label ~= "" then
                arcos.setName(pages[4][2].text)
            end
            for index, value in ipairs(tobeinstalled) do
                pushPackageWithDependencies(value)
            end
            for index, value in ipairs(atobeinstalled) do
                table.insert(ipchildren, ui.Label{
                    label = value,
                    x = 1,
                    y = 1
                })
            end
            ui.PageTransition(pages[4], pages[5], false, 1, true, term)
            page = 5
            return true
        end,
        x = w-4,
        y = h-1
    }
}
pages[4][3].y = 4 + pages[4][2].getWH()[2]
pages[5] = {
    ui.Label{
        label = "Install packages",
        x = 2,
        y = 2
    },
    ui.ScrollPane{
        height = h - 6,
        width = w - 2,
        x = 2,
        y = 4,
        children = ipchildren,
        col = col.gray
    },
    ui.Button{
        label = " Install ",
        x = w-9,
        y = h-1,
        callBack = function ()
            term.setCursorPos(w-10, h-1)
            term.setBackgroundColor(col.gray)
            term.setTextColor(col.white)
            term.write("Installing")
            term.setBackgroundColor(col.black)
            term.setTextColor(col.white)
            for index, value in ipairs(atobeinstalled) do
                arc.install(value)
            end
            local f, e = fs.open("/services/enabled", "w")
            f.write("o " .. init)
            f.close()
            ui.PageTransition(pages[5], pages[6], false, 1, true, term)
            page = 6
            return true
        end
    }
}
pages[6] = {
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
local ls = true
while true do
    ls = ui.RenderLoop(pages[page], term, ls)
end