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
    
end