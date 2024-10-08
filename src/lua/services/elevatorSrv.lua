local dev = require("dev")
local devices = require("devices")
local arcos = require("arcos")
local tasking = require("tasking")
local sleep = arcos.sleep

local currentFloor = -1
local doorWaitFloor = 8
local queue = {}
local enderModem = dev.wmodem[1]
local wiredModem = dev.modem[1]
print("Hello!")
print("EnderModem: " .. tostring(enderModem))
print("WiredModem: " .. tostring(wiredModem))
wiredModem.open(712)
wiredModem.open(476)
enderModem.open(476)
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function changeFloor(floor, fakeit)
    enderModem.transmit(711, 712, floor-1)
    wiredModem.transmit(711, 712, floor-1)
    print("Actual moving: " .. tostring(floor))
    if floor == doorWaitFloor then
        wiredModem.transmit(713, 712, "TopDoorOpen")
    else
        wiredModem.transmit(713, 712, "TopDoorClose")
    end
    local port = math.random(1, 65534)
    wiredModem.transmit(713, port, (floor == 3 and "CCDoorOpen" or "CCDoorClose"))
    print(floor == 3 and "CCDoorOpen" or "CCDoorClose")

    if floor == doorWaitFloor then
        print("Waiting for door")
        local e
        repeat
            e = {arcos.ev("modem_message")}
        until e[3] == 712 and e[5] == "TopDoorAck"
    end
    if not fakeit then
        devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("front", true)
        sleep(0.1)
        devices.get("redstoneIntegrator_" .. tostring(floor)).setOutput("front", false)
        sleep(0.1)
        repeat
            local r = devices.get("redstoneIntegrator_" .. tostring(floor)).getInput("front")
            sleep(0.1)
        until r
    end

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
tasking.createTask("PDtask", function ()
    local pd = dev.playerDetector[1]
    while true do
        if pd.isPlayerInCoords({-2740, 66, 9016}, {-2738, 67, 9014}, "ChanesawWhatever") or pd.isPlayerInCoords({-2740, 66, 9016}, {-2738, 67, 9014}, "kkk8GJ") and currentFloor ~= 8 and not has_value(queue, 8)  then
            table.insert(queue, 8)
            print("Sending")
        end
        sleep(1)
    end
end, 1, "root", term, {})
while true do
    local event, side, channel, repChannel, msg, dist = arcos.ev("modem_message")
    if channel == 476 and not contains(queue, tonumber(msg+1)) then
        print("Queued floor " .. tonumber(msg + 1))
        table.insert(queue, tonumber(msg + 1))
    elseif channel == 477 and not contains(queue, tonumber(msg+1)) then
        print("Faking floor " .. tonumber(msg + 1))
        changeFloor(tonumber(msg+1), true)
    else
        print(channel)
    end
end
