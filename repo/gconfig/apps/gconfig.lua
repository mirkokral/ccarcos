local w, h = term.getSize()
local currentScreen = "main"
local running = true
local blcf = files.open("/config/aboot", "r")
local blc = tutils.dJSON(blcf.read())

local function changeScreens(new, ot)
    ui.PageTransition(configs[currentScreen], configs[new], false, 1, ot, term)
    currentScreen = new
end
configs = {
    main = {
        ui.Label{
            label = "Select what to configure",
            x = 2,
            y = 2
        },
        ui.ScrollPane{
            x = 2,
            y = 4,
            width = w-1,
            height = h-4,
            col = col.black,
            children = {
                ui.Button {
                    label = "Bootloader",
                    x = 1,
                    y = 1,
                    callBack = function ()
                        changeScreens("bl", true)
                        return true
                    end
                }
            },
            showScrollBtns = true
        },
        ui.Button{
            label = "Quit",
            x = w-4,
            y = h-1,
            callBack = function ()
                running = false
                return false
            end,
            col = col.gray,
            textCol = col.white
        },
    },
    bl = {
        ui.Label{
            label = "Skip prompt: ",
            x = 2,
            y = 2
        },
        ui.Button{
            label = blc["skipPrompt"] and "Yes" or "No",
            x = 15,
            y = 2,
            callBack = function ()
                blc["skipPrompt"] = not blc["skipPrompt"]
                configs.bl[2].label = blc["skipPrompt"] and "Yes" or "No"
                return true
            end
        },
        ui.Label{
            label = "Default Args: ",
            x = 2,
            y = 4
        },
        ui.TextInput{
            label = blc["defargs"],
            x = 16,
            y = 4,
            width = w - 16
        },
        ui.Button{
            label = "Save & Back",
            x = w-11,
            y = h-1,
            callBack = function ()
                blc["defargs"] = configs.bl[4].text
                local f = files.open("/config/aboot", "w")
                f.write(tutils.sJSON(blc))
                f.close()
                changeScreens("main", false)
                return true
            end
        },
    }
}


local ls = true
while running do
    ls = ui.RenderLoop(configs[currentScreen], term, ls)
end