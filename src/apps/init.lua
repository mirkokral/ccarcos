local servFile, err = fs.open("/services/enabled", "r")
if err then
    printError(err)
    error()
end
for i in servFile.readLine do
    if i:sub(1, 1) ~= "#" then 
        arcos.log("Starting service: " .. i)
        local currentServiceDone = false
        local threadterm        
        
        if i:sub(1,1) == "l" then
            threadterm = {
                native = function()
                    return term
                end,
                current = function()
                    return term
                end,
                write = function(text)
                    arcos.log(i .. ": " .. text)
                end,
                blit = function(text, ...)
                    arcos.log(i .. ": " .. text)
                end,
                setTextColor = function(col) end,
                setBackgroundColor = function(col) end,
                setTextColour = function(col) end,
                setBackgroundColour = function(col) end,
                getTextColour = function() return col.white end,
                getBackgroundColour = function() return col.black end,
                getTextColor = function() return col.white end,
                getBackgroundColor = function() return col.black end,
                setCursorPos = function(cx, cy) end,
                scroll = function(sx) end,
                clear = function() end,
                isColor = function() return false end,
                isColour = function() return false end,
                getSize = function ()
                    return 0, 0
                end
            }
        else
            threadterm = term
        end    
        tasking.createTask("Service: " .. i:sub(3), function()
            local ok, err = arcos.r({
                ackFinish = function()
                    currentServiceDone = true
                end
            }, "/services/" .. i:sub(3))
            if ok then
                arcos.log("Service " .. i:sub(3) .. " ended.")
            else
                arcos.log("Service " .. i:sub(3) .. " failed with error: " .. tostring(err))
            end
            sleep(1)
        end, 1, "root", threadterm)
        if i:sub(2,2) == "|" then
            repeat sleep(0.2)
            until currentServiceDone
        end
        arcos.log("Started")
    end
    -- ::ct::
end
tasking.setTaskPaused(arcos.getCurrentTask()["pid"], true)
coroutine.yield()
