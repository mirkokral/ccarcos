|/apps|-1|
|/config|-1|
|config/apps|-1|
|/index|0|
|apps/gconfig.lua|76|
|config/apps/gconfig.json|3249|
--ENDTABLE
d>apps
f>apps/gconfig.lua
d>config
d>config/apps
f>config/apps/gconfig.json
local files = require("files")
local tutils = require("tutils")
local ui = require("ui")
local col = require("col")

local w, h = term.getSize()
local currentScreen = "main"
local running = true
local blcf = files.open("/config/aboot", "r")
if not blcf then error("Broken system") end
local blc = tutils.dJSON(blcf.read())
local configScreens
local function changeScreens(new, ot)
    ui.PageTransition(configScreens[currentScreen], configScreens[new], false, 1, ot, term)
    currentScreen = new
end
configScreens = {
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
                configScreens.bl[2].label = blc["skipPrompt"] and "Yes" or "No"
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
        ui.Label{
            label = "Auto Update: ",
            x = 2,
            y = 6
        },
        ui.Button{
            label = blc["autoUpdate"] and "Yes" or "No",
            x = 15,
            y = 6,
            callBack = function ()
                blc["autoUpdate"] = not blc["autoUpdate"]
                configScreens.bl[6].label = blc["autoUpdate"] and "Yes" or "No"
                return true
            end
        },
        ui.Button{
            label = "Save & Back",
            x = w-11,
            y = h-1,
            callBack = function ()
                blc["defargs"] = configScreens.bl[4].text
                local f = files.open("/config/aboot", "w")
                if not f then error("Broken system") end
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
    ls = ui.RenderLoop(configScreens[currentScreen], term, ls)
end{
    "name": "Tweaks",
    "execute": "/apps/gconfig.lua",
    "icon": "+------+\n| \\  \/ |\n|  \\\/  |\n|  \/\\  |\n| \/  \\ |\n+------+"
}