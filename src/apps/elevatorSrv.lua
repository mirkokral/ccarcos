local currentFloor = -1
local doorWaitFloor = 8
local queue = {}
local enderModem = devices.get("top")
local wiredModem = devices.get("right")
wiredModem.open(712)
wiredModem.open(476)
enderModem.open(476)
local function changeFloor(floor)
    enderModem.transmit(711, 712, floor)
    wiredModem.transmit(711, 712, floor)
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
    sleep()
    devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("top", false)
end
tasking.createTask("Queue task", function()
    while true do
        local newFloor = table.remove(queue, 1)
        if newFloor then
            print("Moving to floor: " .. tostring(newFloor))
            changeFloor(newFloor)
    
            sleep(5 + 5 * math.abs(newFloor - currentFloor))
            
        else
            sleep()
        end
    end
end, 1, "root", term)
while true do
    local event, side, channel, repChannel, msg, dist = arcos.ev("modem_message")
    if channel == 476 then
        print("Queued floor " .. tonumber(msg + 1))
        table.insert(queue, tonumber(msg + 1))
    else
        print(channel)
    end
end
