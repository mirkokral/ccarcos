local source = "enderstorage:ender_chest_1"
local pd = peripheral.find("playerDetector")
local src = peripheral.wrap(source)
local players = {
    {
        name = "ChanesawWhatever",
        chest =  "ironchest:copper_chest_25",
        im = peripheral.wrap("top")
    },
    {
        name = "StealthyCoder",
        chest = "ironchest:copper_chest_26",
        im = peripheral.wrap("left")
    },
    {
        name = "kkk8GJ",
        chest = "ironchest:copper_chest_27",
        im = peripheral.wrap("right")
    }
}
local logQueue = {"\xA7aStarted!"}
local function log(text)
    table.insert(logQueue, text)
    local i = 0
    while true do
        i = i + 1
        local ft = text:sub(i, i)
        if ft == "" then break end
        if ft == "\xA7" then
            i = i + 1
            local ftt = text:sub(i, i)
            if ftt == "0" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "1" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "2" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "3" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "4" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "5" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "6" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "7" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "8" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "9" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "a" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "b" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "c" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "d" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "e" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "f" then term.setTextColor(colors.fromBlit(ftt)) end
            if ftt == "r" then term.setTextColor(colors.white) end
        else
            write(ft)
        end
    end
    write("\n")
end
local function dispensePill(playerName)
    local items = src.list()
    local up = {}
    for _, player in ipairs(players) do
        if player.name == playerName then
            up = player
        end
    end
    if up == {} then return end
    for i, v in pairs(items) do
        if v.name == "estrogen:crystal_estrogen_pill" then
            src.pushItems(up.chest, i, 1, 1)
            break;
        end
    end
    local slot = 9

    --print(up.im.removeItemFromPlayer("north", {toSlot = 40, fromSlot = slot-1}))
    up.im.addItemToPlayer("north", {name = "estrogen:crystal_estrogen_pill", toSlot = slot-1, count = 1})

    return {
        items = items,
        up = up,
        slot = slot,
        itemInhand = itemInHand
    }
end
local function waitForPillFinish(playerName, old)

    local items = old.items
    local up = old.up
    local slot = old.slot
    local itemInHand = old.itemInHand
    local item
    item = nil
    for i, v in ipairs(up.im.getItems()) do
        if v.slot == slot-1 then
            item = v
            -- --print(v.slot)
            -- --print(v.name)
        end
    end

    -- --print(require("cc.pretty").pretty_--print(item))
    return function(vrs)
        item = nil
        for i, v in ipairs(up.im.getItems()) do
            if v.slot == slot-1 then
                item = v
                --print(v.slot)
                --print(v.name)
            end
        end
        if not item or item.name ~= "estrogen:crystal_estrogen_pill" then
            --print(up.im.removeItemFromPlayer("north", {toSlot = 1, fromSlot = slot-1}))
            up.im.addItemToPlayer("north", {fromSlot = 40, toSlot = slot-1})
            --print(item)
            return true
        end
        sleep(0.1)
        return false, vrs
    end
end
-- while true do
-- end
local olds = {}
local n = os.clock()
n = os.clock()
--print("Giving pills")
for _, player in ipairs(players) do
    for _, p in ipairs(pd.getOnlinePlayers()) do
        if p == player.name and not olds[p] then
            local op = dispensePill(p)
            olds[p] = waitForPillFinish(p, op)        
            log("\xA79" .. p .. "\xA7b got their pill!")           
        end
    end
end
while true do
    --print((os.clock() - n) % 5)
    if (os.clock() - n) > 4*60 then
        n = os.clock()
        --print("Giving pills")
        for _, player in ipairs(players) do
            for _, p in ipairs(pd.getOnlinePlayers()) do
                if p == player.name and not olds[p] then
                    local op = dispensePill(p)
                    olds[p] = waitForPillFinish(p, op)
                    --print(p .. " got their pill!")     
                    peripheral.find("chatBox").sendMessageToPlayer("\xA7bPill time!", p, "\xA7aEstrogen Dispenser")
                    log("\xA79" .. p .. "\xA7b got their pill!")           
                end
            end
        end
    end
    local tr = {}
    local vrs = {}
    for k, func in pairs(olds) do
        if k then
            local a
            a, vrs[k] = func(vrs[k])
            if a then
                table.insert(tr,k)
            end
        end
    end
    for _, v in ipairs(tr) do
        --print(v .. " ate their pill!")
        log("\xA79" .. v .. "\xA7b ate their pill!")           

        olds[v] = nil
    end
    local fru = table.remove(logQueue, 1)
    if fru then
        peripheral.find("chatBox").sendMessageToPlayer(fru, "kkk8GJ", "\xA7aEstrogen Dispenser")   
    end
    sleep(0.1)
end
