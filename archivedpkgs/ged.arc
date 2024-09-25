|/apps|-1|
|/index|0|
|apps/ged.lua|22|
--ENDTABLE
d>apps
f>apps/ged.lua
local files = require("files")
local ui = require("ui")
local col = require("col")
if not term then error("No term") end

local file = ...
if not file then
    error("No file specified")
end
local qf = files.resolve(file, true)[1]
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
        showScrollBtns = true
    }
}
local function genLX()
    lx = {}
    if files.exists(qf) then
        local f = files.open(qf, "r")
        if not f then error("Couldn't open file") end
        lx = {
            ui.TextInput{
                label = f.read(),
                width = w-1,
                x = 1,
                y = 1
            }
        }
    else
        lx = {
            ui.TextInput{
                label = "",
                width = w-1,
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