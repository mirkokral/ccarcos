|/apps|-1|
|/config|-1|
|config/apps|-1|
|/index|0|
|apps/test.lua|94|
|config/apps/test.icon|510|
|config/apps/test.json|510|
--ENDTABLE
d>apps
f>apps/test.lua
d>config
d>config/apps
f>config/apps/test.icon
f>config/apps/test.json
local ui = require("ui")

local page = {
    ui.Label{
        label = "Hello, world!",
        x = 2,
        y = 2
    },
    ui.Label{
        label = ui.Wrap("This is a test of the UI wrapping, this should wrap around as it's quite long.", ({ term.getSize() })[2]-2),
        x = 2,
        y = 4
    }
}

local ls = true
while true do
    if term then
        ls = ui.RenderLoop(page, term, ls)
    end
    
end{
    "name": "Test Application",
    "execute": "/apps/test.lua",
    "icon": "+------+\n| \\  \/ |\n|  \\\/  |\n|  \/\\  |\n| \/  \\ |\n+------+"
}