local user = ""
local we = fs.ls("/config/desktops")
local sq = {}

local running = true
local ls = true
local sel = ""
local ceRunning = false
local uiSelPage
local loginPage
local w, h = term.getSize()
for index, value in ipairs(we) do
    table.insert(sq, ui.Button{
        label = value,
        x = 1,
        y = 1,
        callBack = function ()
            sel = value
            ui.PageTransition(uiSelPage, loginPage, false, 1, false, term)
            ceRunning = false
            return true
        end
    })
end
uiSelPage = {
    ui.ScrollPane{
        children = sq,
        height = h,
        width  = w,
        col = col.gray,
        x = 1,
        y = 1
    }
}
loginPage = {
    ui.Label{
        label = "User",
        textCol = col.gray,
        x = 2,
        y = 2
    },
    ui.TextInput{
        label = "root",
        x = 2,
        y = 3
    },
    ui.Label{
        label = "Password",
        textCol = col.gray,
        x = 2,
        y = 5
    },
    ui.TextInput{
        label = "toor",
        x = 2,
        y = 6
    },
    ui.Button{
        label = "Login",
        x = 2,
        y = 8,
        callBack = function ()
            -- TODO: Add login validation
            if true then
                running = false
                return false
            end
        end
    },
    ui.Button{
        label = "\x04",
        x = 8,
        y = 8,
        callBack = function ()
            ui.PageTransition(loginPage, uiSelPage, false, 1, true, term)
            ceRunning = true
            return true
        end
    }
}
while running do
    if ceRunning then
        ls = ui.RenderLoop(uiSelPage, term, ls)
    else
        ls = ui.RenderLoop(loginPage, term, ls)
    end
end