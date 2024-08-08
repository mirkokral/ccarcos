local user = ""
local we = files.ls("/config/desktops")
local sq = {}

local running = true
local ls = true
local sel = we[1]
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
        label = "",
        x = 2,
        y = 3,
        width = 10
    },
    ui.Label{
        label = "Password",
        textCol = col.gray,
        x = 2,
        y = 5,
    },
    ui.TextInput{
        label = "",
        x = 2,
        y = 6,
        width = 10
    },
    ui.Button{
        label = " Login ",
        x = 2,
        y = 8,
        callBack = function ()
            -- TODO: Add login validation
            if arcos.validateUser(loginPage[2].text, loginPage[4].text) then
                running = false
                return false
            else
                local frunnin = true
                local w = {
                    ui.Label{
                        label = "Incorrect Password!",
                        x = 2,
                        y = 2,
                        textCol = col.red
                    },
                    ui.Button{
                        label = " OK ",
                        x = w-1-4,
                        y = h-2,
                        callBack = function ()
                            frunnin = false
                            return true
                        end
                    }
                }
                ui.PageTransition(loginPage, w, false, 1, true, term)
                local frls = true
                while frunnin do
                    frls = ui.RenderLoop(w, term, frls)
                end
                ui.PageTransition(w, loginPage, false, 1, false, term)
                return true
            end
    end
    },
    ui.Button{
        label = " \x04 ",
        x = 10,
        y = 8,
        callBack = function ()
            ui.PageTransition(loginPage, uiSelPage, false, 1, true, term)
            ceRunning = true
            return true
        end
    }
}
loginPage[2].focus = true
while running do
    if ceRunning then
        ls = ui.RenderLoop(uiSelPage, term, ls)
    else
        local e
        ls, e = ui.RenderLoop(loginPage, term, ls)
        if e[1] == "key" and (e[2] == 258 or e[2] == 257) and loginPage[2].focus then
            loginPage[2].focus = false
            loginPage[4].focus = true
            ls = true
        end
        if e[1] == "key" and e[2] == 257 and loginPage[4].focus then
            loginPage[2].focus = false
            loginPage[4].focus = false
            if loginPage[5].callback() then
                ls = true
            end
        end
    end
end
local user = loginPage[2].text
tasking.createTask("s", function ()
    local f, e = files.open("/config/desktops/" .. sel, "r")
    if f then
        term.clear()
        term.setCursorPos(1, 1)
        term.setBackgroundColor(col.black)
        term.setTextColor(col.white)
        arcos.r({}, f.read())
    end
end, 1, user, term, environ)