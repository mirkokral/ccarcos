-- This file is unused
-- TODO: Remove

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
-- tasking.createTask("Elevator step player detector handler", function()
--     local pd = devices.find("playerDetector")
--     while true do
--         local playersInRange = pd.getPlayersInRange(5)
--         for _, i in ipairs(whitelistedPlayers) do
--             print("Testing: " .. i)
--             print(table.unpack(playersInRange))
--             if contains(playersInRange, i) then
--                 print("sending")
--                 if currentFloor ~= 7 then mdm.transmit(476, 0, 7) end
--                 currentFloor = 7
--             end
--         end
--         sleep(1)
--     end
-- end, 1, "root", term)

while true do
    local _, side, channel, rc, msg, dist = arcos.ev("modem_message")
    if channel == 713 then
        print(msg)
        if msg == "TopDoorOpen" then
            rd.setO("back", true)
        elseif msg == "TopDoorClose" then
            rd.setO("back", false)
        end
    elseif channel == 711 then
        currentFloor = tonumber(msg)
    end
end
