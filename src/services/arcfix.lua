---@diagnostic disable: undefined-global
if arcos.getCurrentTask().user ~= "root" then
    error("Not root!")
end

-- local function recursiveMkdir(dir)
--     local f = tutils.split(dir, "/")
--     local rmdt = ""
--     for index, value in ipairs(f) do
--         rmdt = rmdt .. value
--         files.mkDir(value)
--     end
-- end
-- if files.exists("/config/arc") then
--     local packages = files.ls("/config/arc/")
--     for index, value in ipairs(packages) do
--         print(value:sub(#value-14) )
--         if value:sub(#value-14) == "uninstallIndex" then
--             local pkg = value:sub(0, #value-13)
--             local unif = files.open("/config/arc/" .. value, "r")
--             if not unif then goto continue end
--             local uni = tutils.split(unif.read(), "\n")
--             for index, value in ipairs(uni) do
--                 local mod = value:sub(1, 1)
--                 local fn = value:sub(3)
--                 if mod == "f" then
--                     recursiveMkdir(files.par(fn))
--                     local f = files.open(fn, "w")
--                     local h = arc.get("https://raw.githubusercontent.com/" .. arc.getChosenRepo() .. "/" .. arc.getLatestCommit() .. "/repo/" .. pkg .. "/" .. value)
--                     if f and h then
--                         f.write(h.readAll())
--                         f.close()
--                         h.close()
--                     end
--                 end
--                 if mod == "d" then
--                     recursiveMkdir(fn)
--                 end
--             end
--         end
--     end
--     ::continue::
-- end
ackFinish()
