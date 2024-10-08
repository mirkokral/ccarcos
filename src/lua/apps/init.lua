local tasking = require("tasking")
local files = require("files")
local arcos = require("arcos")
local sleep = arcos.sleep
local col = require("col")  
write("\011f8Welcome to \011f2arcos\011f8!\n")
local rt = -1
for index, value in ipairs(files.ls("/services/enabled")) do
    local servFile, err = files.open("/services/enabled/"..value, "r")
    if not servFile then
        error(err)
    end
    write("\011f2Group \011f0" .. value .. "\n")
    for i in servFile.readLine do
        if i:sub(1, 1) ~= "#" then 
                -- write("\011f7[\011fd Starting \011f7] \011f0" .. i:sub(3) .. "\n")
            local currentServiceDone = false
            local threadterm
            
            if i:sub(1,1) == "l" then
                local ttcp = {1, 1}
                threadterm = {
                    native = function()
                        return term
                    end,
                    current = function()
                        return term
                    end,
                    write = function(text)
                        arcos.log(i .. ": " .. text, 0)
                    end,
                    blit = function(text, ...)
                        arcos.log(i .. ": " .. text, 0)
                    end,
                    setTextColor = function(col) end,
                    setBackgroundColor = function(col) end,
                    setTextColour = function(col) end,
                    setBackgroundColour = function(col) end,
                    getTextColour = function() return col.white end,
                    getBackgroundColour = function() return col.black end,
                    getTextColor = function() return col.white end,
                    getBackgroundColor = function() return col.black end,
                    setCursorPos = function(cx, cy) ttcp = {cx, cy} end,
                    getCursorPos = function() return ttcp[1], ttcp[2] end,
                    scroll = function(sx) ttcp[2] = ttcp[2] - sx end,
                    clear = function() end,
                    isColor = function() return false end,
                    isColour = function() return false end,
                    getSize = function ()
                        return 51, 19
                    end
                }
            else
                threadterm = term
            end    
            local pid = tasking.createTask("Service: " .. i:sub(3), function()
                local ok, err = arcos.r({
                    ackFinish = function()
                        currentServiceDone = true
                    end
                }, "/services/" .. i:sub(3))
                currentServiceDone = true
                if ok then
                    write("\011f8| \011f7[\011f8 Ended \011f7] \011f0" .. i:sub(3) .. "\n")
                    
                else
                    write("\011f8| \011f7[\011fe Failed \011f7] \011f0" .. require("tutils").split(i:sub(3), "/")[1] .. "\n")
                    write("\011f8| \011f0" .. err)

                end
                sleep(1)
            end, 1, "root", threadterm)
            if i:sub(1,1) ~= "l" then
               rt = pid 
            end
            if i:sub(2,2) == "|" then
                repeat sleep(0.2)
                until currentServiceDone
            end
            write("\011f8| \011f7[\011fd OK \011f7] \011f0" .. require("tutils").split(i:sub(3), ".")[1] .. "\n")
        end
        -- ::ct::
    end
end
while true do
    local ev = {coroutine.yield()}
    if ev[1] == "terminate" and ev[2] == "root" then
        if rt == -1 then
            write("\011f8Init: No root task (last task which outputs to the console), terminate not happening.")
        else
            tasking.killTask(rt, "terminate")
        end

    end
end
