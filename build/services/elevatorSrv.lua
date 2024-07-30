local currentFloor = -1
local doorWaitFloor = 8
local queue = {}
local enderModem = devices.get("top")
local wiredModem = devices.get("right")
wiredModem.open(712)
wiredModem.open(476)
enderModem.open(476)
local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
local function changeFloor(floor)
    enderModem.transmit(711, 712, floor-1)
    wiredModem.transmit(711, 712, floor-1)
    if floor == doorWaitFloor then
        wiredModem.transmit(713, 712, "TopDoorOpen")
    else
        wiredModem.transmit(713, 712, "TopDoorClose")
    end
    if floor == doorWaitFloor then
        repeat
            local e = {arcos.ev("modem_message")}
        until e[3] == 712
    end
    devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("top", true)
    sleep(0.05)
    devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("top", false)
    sleep(0.1)
    repeat
        local r = devices.get("redstoneIntegrator_" .. tostring(floor)).getInput("top")
        sleep(0.1)
    until r
end
tasking.createTask("Queue task", function()
    while true do
        local newFloor = table.remove(queue, 1)
        if newFloor then
            print("Moving to floor: " .. tostring(newFloor))
            changeFloor(newFloor)
            print("Finished moving")
            if #queue > 0 then sleep(5) end
        else
            sleep(1)
        end
    end
end, 1, "root", term)
while true do
    local event, side, channel, repChannel, msg, dist = arcos.ev("modem_message")
    if channel == 476 and not contains(queue, tonumber(msg+1)) then
        print("Queued floor " .. tonumber(msg + 1))
        table.insert(queue, tonumber(msg + 1))
    else
        print(channel)
    end
end
