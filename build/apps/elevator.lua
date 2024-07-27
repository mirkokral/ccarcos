local modem
local selectedFloor = -1
if arcos then
    modem = devices.find("modem")
else
    modem = peripheral.find("modem")
end
local theme
if arcos then
    theme = {
        bg = _G.__LEGACY.colors.black,
        elFloor = _G.__LEGACY.colors.blue,
        elFloorSel = _G.__LEGACY.colors.lightBlue,
    }
else
    theme = {
        bg = colors.black,
        elFloor = colors.brown,
        elFloorSel = colors.yellow
    }
end
local floors = {
    {id=8, name="Outside"},
    {id=3, name="Living"},
    {id=2, name="Lab"},
    {id=7, name="Bunker"}
}
local function reDraw()
    term.setBackgroundColor(theme.bg)
    term.clear()
    term.setCursorPos(1, 1)
    for i, v in ipairs(floors) do
        if selectedFloor == v["id"]-1 then
            term.setTextColor(theme.elFloorSel)
            print("> " .. v["name"])
        else
            term.setTextColor(theme.elFloor)
            print("| " .. v["name"])
        end
    end
end
modem.open(711)
reDraw()
while true do
    ev = { coroutine.yield() }
    if ev[1] == "modem_message" then
        selectedFloor = ev[5]
        reDraw()
    end
    if ev[1] == "terminate" then
        shell.run("shell")
    end
    if ev[1] == "mouse_click" then
        button, x, y = ev[1], ev[2], ev[3]
        if floors[y] then
            selectedFloor = floors[y]["id"]-1
            modem.transmit(476, 0, floors[y]["id"]-1)
            reDraw()
        end

    end
end