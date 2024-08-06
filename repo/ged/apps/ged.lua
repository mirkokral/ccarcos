local file = ...
if not file then
    error("No file specified")
end
local qf = fs.resolve(file, true)[1]
local lx = {}
local w, h = term.getSize()
local siq = {
    ui.ScrollPane{
        children = lx,
        height = h,
        width = w,
        x = 1,
        y = 1,
        col = col.black,
        hideScrollbar = false,
        showScrollBtns = true
    }
}
local function genLX()
    lx = {}
    if fs.exists(qf) then
        local f = fs.open(qf, "r")
        for i in f.readLine do
            table.insert(lx, ui.TextInput{
                label = i,
                width = w-2,
                x = 1,
                y = 1
            })
        end
    else
        lx = {
            ui.TextInput{
                label = "",
                width = w-2,
                x = 1,
                y = 1
            }
        }
    end
    siq[1].children = lx
end
genLX()
local ls = true
while true do
    ls = ui.RenderLoop(siq, term, ls)
end