local currentPowerUsage = 0
local f, e = fs.open("/config/pmst", "r")
local titemcount = 0
local iup = 0
local monitor = devices.get("left")
local ed = dev.energyDetector[1]
local me = dev.meBridge[1]
local total
local rd = true
if f then
    local total = tonumber(f.read())
    f.close()
    
else
    local total = 0
end
monitor.setTextScale(0.5)
local nf, err = fs.open("/config/pmst", "w")
if not nf then
    monitor.setBackgroundColor(ui.UItheme.bg)
    monitor.setTextColor(ui.UItheme.fg)
    monitor.clear()
    monitor.write(err)
    while true do
        sleep(5)
    end
end
tasking.createTask("Energy Detector", function ()
    while true do
        local ok, err = pcall(function (...)
        
            currentPowerUsage = ed.getTransferRate()
            total = total + ed.getTransferRate() * 20
            if nf then
                nf.write(tostring(total))
            end
            titemcount = me.getUsedItemStorage()
            iup = math.floor(me.getUsedItemStorage() / me.getTotalItemStorage()*100)
        end)
        if not ok then 
            rd = false
            monitor.setBackgroundColor(ui.UItheme.bg)
            monitor.setTextColor(ui.UItheme.fg)
            monitor.clear()
            monitor.write(err)

            while true do
                sleep(5)
            end
        end
        sleep(1)
    end    
end, 1, "root", term, {})

function formatNum(number)
    local on = number
    local unitprefix = ""
    if on > 1000 then
        unitprefix = "k"
        on = on / 1000
    end
    if on > 1000 then
        unitprefix = "M"
        on = on / 1000
    end
    if on > 1000 then
        unitprefix = "G"
        on = on / 1000
    end
    return math.floor(on), unitprefix
end

local screen = {
    ui.Label({
        label = "Current energy usage",
        x = 2,
        y = 2,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total energy usage",
        x = 2,
        y = 4,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total ME item count",
        x = 2,
        y = 6,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Storage used",
        x = 2,
        y = 8,
        textCol = ui.UItheme.lighterBg
    })
}
local ceu = ui.Label({
    label = " 0fe/t ",
    x = 23,
    y = 2,
    col = ui.UItheme.lighterBg,
})
local teu = ui.Label({
    label = " 0fe ",
    x = 23,
    y = 4,
    col = ui.UItheme.lighterBg,
})
local tic = ui.Label({
    label = " 0 items ",
    x = 23,
    y = 6,
    col = ui.UItheme.lighterBg,
})
local uic = ui.Label({
    label = " 0% ",
    x = 23,
    y = 8,
    col = ui.UItheme.lighterBg,
})

local ls = false
while rd do
    local e
    ls, e = ui.RenderLoop({ screen[1], screen[2], screen[3], screen[4], teu, ceu, tic, uic}, monitor, ls)
    if e[1] == "timer" then
        sleep(0.3)
        local teufmt, teuext = formatNum(total)
        teu.label = " " .. tostring(teufmt) .. teuext .. "fe "
        teufmt, teuext = formatNum(currentPowerUsage)
        ceu.label = " " .. tostring(teufmt) .. teuext .. "fe/t "
        teufmt, teuext = formatNum(titemcount)
        tic.label = " " .. tostring(teufmt) .. teuext .. " items "
        uic.label = " " .. tostring(iup) .. "% "
        ls = true
    end
end