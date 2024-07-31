local pd = peripheral.find("playerDetector")
local player = ...

while true do
    term.setBackgroundColor(colors.blue)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
    local pl = pd.getPlayerPos(player)
    print("X: " .. pl.x)
    print("Y: " .. pl.y)
    print("Z: " .. pl.z)
    sleep(1)
end