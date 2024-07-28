local mdm = devices.find("modem")
if not mdm then
    error("Modem not found")
end
local whitelistedPlayers = {
    "ChanesawWhatever",
    "emireri1498",
    "kkk8GJ"
}
mdm.open(711)
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
        local playersInRange = pd.getPlayersInRange(4)
        for _, i in ipairs(whitelistedPlayers) do
            print("Testing: " .. i)
            print(table.unpack(playersInRange))
            if contains(playersInRange, i) then
                mdm.transmit(476, 0, 7)
            end
        end
        sleep(5)
    end
end, 1, "root", term)
while true do
    local _, side, channel, rc, msg, dist = arcos.ev()
    red.setO("back", msg ~= "7")
end
