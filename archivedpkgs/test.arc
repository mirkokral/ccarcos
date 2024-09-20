|/apps|-1|
|/config|-1|
|config/apps|-1|
|/index|0|
|apps/test.lua|94|
|config/apps/test.icon|455|
|config/apps/test.json|455|
--ENDTABLE
d>apps
f>apps/test.lua
d>config
d>config/apps
f>config/apps/test.icon
f>config/apps/test.json
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
    ls = ui.RenderLoop(page, term, ls)
    
end{
    "name": "Test Application",
    "execute": "/apps/test.lua",
    "icon": "+------+\n| \\  \/ |\n|  \\\/  |\n|  \/\\  |\n| \/  \\ |\n+------+"
}