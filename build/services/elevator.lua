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
        bg = col.black,
        elFloor = col.blue,
        elFloorSel = col.magenta,
        buttonColor = col.white
    }
else
    theme = {
        bg = colors.black,
        elFloor = colors.brown,
        elFloorSel = colors.yellow,
        buttonColor = colors.white
    }
end
local floors = {
    {id=8, name="Outside"},
    {id=3, name="Living"},
    {id=4, name="Lab"},
    {id=9, name="Spatial"},
    {id=7, name="Bunker"}
}
local buttons = {
    {
        text = "[()]",
        pos = 1,
        callback = function()
            modem.transmit(4590, 0, "")
        end
    },
    {
        text = "[ ]",
        pos = 6,
        callback = function()
            modem.transmit(713, 0, "MatDoorOpen")
        end
    },
    {
        text = "[:]",
        pos = 10,
        callback = function()
            modem.transmit(713, 0, "MatDoorClose")
        end
    }
}
local function reDraw()
    term.setBackgroundColor(theme.bg)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(theme.buttonColor)
    for i, v in ipairs(buttons) do
        term.setCursorPos(v["pos"], 1)
        write(v["text"])
    end
    term.setCursorPos(1, 2)
    for i, v in ipairs(floors) do
        if selectedFloor == v["id"] then
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
    local seev
    if arcos then
        seev = table.pack(arcos.ev())
    else
        seev = table.pack(os.pullEvent())
    end
    if seev[1] == "modem_message" then
        selectedFloor = seev[5]+1
        reDraw()
    end
    if seev[1] == "mouse_click" then
        if seev[4] == 1 then
            for i, v in ipairs(buttons) do
                if seev[3] >= v["pos"] and seev[3] <= v["pos"]+#v["text"] then
                    v["callback"]()
                end
            end
        end
        if floors[seev[4]-1] then
            modem.transmit(476, 0, floors[seev[4]-1]["id"]-1)
            reDraw()
        end
    end
end