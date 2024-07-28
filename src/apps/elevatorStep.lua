local mdm = devices.find("modem")
local currentFloor = -1
if not mdm then
    error("Modem not found")
end

local whitelistedPlayers = {
    "ChanesawWhatever",
    "emireri1498",
    "kkk8GJ"
}

mdm.open(711)
mdm.open(713)
local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

tasking.createTask("Elevator step player detector handler", function()
    local pd = devices.find("playerDetector")
    while true do
        local playersInRange = pd.getPlayersInRange(5)
        for _, i in ipairs(whitelistedPlayers) do
            print("Testing: " .. i)
            print(table.unpack(playersInRange))
            if contains(playersInRange, i) then
                print("sending")
                if currentFloor ~= 7 then mdm.transmit(476, 0, 7) end
                currentFloor = 7
            end
        end
        sleep(1)
    end
end, 1, "root", term)

while true do
    local _, side, channel, rc, msg, dist = arcos.ev("modem_message")
    if channel == 713 then
        if msg == "TopDoorOpen" then
            __LEGACY.redstone.setOutput("back", false)
        elseif msg == "TopDoorClose" then
            __LEGACY.redstone.setO("back", true)
        end
    elseif channel == 711 then
        currentFloor = tonumber(msg)
    end
end
