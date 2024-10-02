local arcos = require('arcos')
local sleep = arcos.sleep
local ui = require("ui")
local files = require("files")
local tutils = require("tutils")
local devices = require("devices")
local dev = require("dev")

local currentPowerUsage = 0
local f, e = files.open("/config/pmst", "r")
local titemcount = 0
local iup = 0
local monitor = devices.get("left")
local ed = dev.energyDetector[1]
local me = dev.meBridge[1]
local total = 0
local rd = true
if f then
    local l = tonumber(f.read())
    if l then
        total = l
    end
    f.close()
    
else
    total = 0
end
monitor.setTextScale(0.5)

local function formatNum(number)
    if not number then
        return 0, ""
    end
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
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total energy usage",
        x = 2,
        y = 6,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Total ME item count",
        x = 2,
        y = 8,
        textCol = ui.UItheme.lighterBg
    }),
    ui.Label({
        label = "Storage used",
        x = 2,
        y = 10,
        textCol = ui.UItheme.lighterBg
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
        return true
    end
})
local btn2 = ui.Button({
    label = " Lights off ",
    x = 14,
    y = 2,
    callBack = function ()
        dev.modem[1].transmit(713, 0, "MainLightsOff")
        return true
    end
})


local ls = false
local tid = arcos.startTimer(2.5)
while rd do
    local e
    ls, e = ui.RenderLoop({ screen[1], screen[2], screen[3], screen[4], time, teu, ceu, tic, uic, btn1, btn2}, monitor, ls)
    if e[1] == "timer" and e[2] == tid then

        local nf, err = files.open("/config/pmst", "w")
        if nf then
            nf.write(tostring(total))
            nf.close()
        end
        sleep(0.1)
        pcall(function (...)
            currentPowerUsage = ed.getTransferRate()
            total = total + ed.getTransferRate() * 10
            titemcount = me.getUsedItemStorage()
            iup = math.floor(me.getUsedItemStorage() / me.getTotalItemStorage()*100)
        end)
        local s = tutils.formatTime(arcos.time("ingame"))
        time.x = ({ monitor.getSize() })[1]-1-#s
        time.label = s
        local teufmt, teuext
        if total then
            teufmt, teuext = formatNum(total)
            teu.label = " " .. tostring(teufmt) .. teuext .. "fe "
            
        end
        if currentPowerUsage then
            teufmt, teuext = formatNum(currentPowerUsage)
            ceu.label = " " .. tostring(teufmt) .. teuext .. "fe/t "
        end
        if titemcount then
            teufmt, teuext = formatNum(titemcount)
            tic.label = " " .. tostring(teufmt) .. teuext .. " items "
        end
        uic.label = " " .. tostring(iup) .. "% "
        ls = true
        tid = arcos.startTimer(0.5)
    end
end