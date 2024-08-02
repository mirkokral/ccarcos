local currentPowerUsage = 0
local f, e = fs.open("/config/pmst", "r")
local titemcount = 0
local iup = 0
local monitor = devices.get("left")
local ed = dev.energyDetector[1]
local me = dev.meBridge[1]
local total = 0
local rd = true
if f then
    total = tonumber(f.read())
    f.close()
else
    total = 0
end
monitor.setTextScale(0.5)
tasking.createTask("Energy Detector", function ()
    while true do
        currentPowerUsage = ed.getTransferRate()
        total = total + ed.getTransferRate() * 20
        titemcount = me.getUsedItemStorage()
        iup = math.floor(me.getUsedItemStorage() / me.getTotalItemStorage()*100)
        sleep(0.5)
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
        y = 4,
        textCol = ui.UItheme.lightBg
    }),
    ui.Label({
        label = "Total energy usage",
        x = 2,
        y = 6,
        textCol = ui.UItheme.lightBg
    }),
    ui.Label({
        label = "Total ME item count",
        x = 2,
        y = 8,
        textCol = ui.UItheme.lightBg
    }),
    ui.Label({
        label = "Storage used",
        x = 2,
        y = 10,
        textCol = ui.UItheme.lightBg
    })
}
local ceu = ui.Label({
    label = " 0fe/t ",
    x = 23,
    y = 4,
    col = ui.UItheme.lighterBg,
})
local teu = ui.Label({
    label = " 0fe ",
    x = 23,
    y = 6,
    col = ui.UItheme.lighterBg,
})
local tic = ui.Label({
    label = " 0 items ",
    x = 23,
    y = 8,
    col = ui.UItheme.lighterBg,
})
local uic = ui.Label({
    label = " 0% ",
    x = 23,
    y = 10,
    col = ui.UItheme.lighterBg,
})
local time = ui.Label({
    label = "00:00",
    x = ({ monitor.getSize() })[1]-1-5,
    y = 2,
})
local btn1 = ui.Button({
    label = " Lights on ",
    x = 2,
    y = 2,
    callBack = function ()
        dev.modem[1].transmit(713, 0, "MainLightsOn")
    end
})
local btn2 = ui.Button({
    label = " Lights off ",
    x = 14,
    y = 2,
    callBack = function ()
        dev.modem[1].transmit(713, 0, "MainLightsOff")
    end
})
local ls = false
while rd do
    local e
    ls, e = ui.RenderLoop({ screen[1], screen[2], screen[3], screen[4], time, teu, ceu, tic, uic, btn1, btn2}, monitor, ls)
    if e[1] == "timer" then
        local nf, err = fs.open("/config/pmst", "w")
        if nf then
            nf.write(tostring(total))
            nf.close()
        end
        sleep(0.1)
        local s = tutils.formatTime(arcos.time("ingame"))
        time.x = ({ monitor.getSize() })[1]-1-#s
        time.label = s
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