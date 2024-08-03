local page = {
    ui.Label{
        label = "Hello, world!",
        x = 2,
        y = 2
    }
}

local ls = true
while true do
    ls = ui.RenderLoop(page, term, ls)
    
end