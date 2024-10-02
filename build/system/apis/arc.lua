local files = require("files")
local tutils = require("tutils")
local arcos = require("arcos")
local devices = require("devices")
local methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    DELETE = true,
    PATCH = true,
    TRACE = true,
}
local function getChosenRepo(rootdir)
    if not rootdir then rootdir = "/" end
    local rf, x = files.open(rootdir .. "/config/arcrepo", "r")
    if not rf then
        return "mirkokral/ccarcos" -- Default to the main arcos repo
    end
    local fx = rf.read()
    rf.close()
    return fx
end
local function get(url, headers) 
    local d = devices.find("network_adapter")
    if not d then error("No network adapter found") end
    local s = {d.sendRequest("GET", url, headers)}
    if not s[1] then return table.unpack(s) end
    return {
        read = s[1].readAll,
        close = s[1].close
    }
end
local function getLatestCommit(rootdir)
    if not rootdir then rootdir = "/" end
    local f, e = require("files").open(rootdir .. "config/arc/latestCommit.hash", "r")
    if not f then 
        return ""
    else 
        local rp = f.read()
        f.close()
        return rp
    end
end
local function checkForCD(rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not require("files").exists(rootdir .. "config") then
        require("files").makeDir(rootdir .. "/config")
    end
    if not require("files").exists(rootdir .. "config/arc") then
        require("files").makeDir(rootdir .. "/config/arc")
    end
end
local function fetch(rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD()
    local f2, e = require("files").open(rootdir .. "/config/arc/latestCommit.hash", "w")    
    if not f2 then
        error(e)
    end
    local fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        ["Authorization"] = "Bearer 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"
    })
    if not fr then 
        fr, e = get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
        })
        if not fr then
            error(e)
        end
    end
    local rp = json.decode(fr.read())["sha"]
    f2.write(rp)
    fr.close()
    f2.close()
    local f, e = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" ..
    getLatestCommit() .. "/repo/index.json")
    if not f then
        return false
    end
    local fa, e = require("files").open(rootdir .. "/config/arc/repo.json", "w")
    if not fa then
        error(e)
    end
    fa.write(f.read())
    fa.close()
    f.close()
end
local function isInstalled(package, rootdir)
    if not rootdir then rootdir = "/" end
    return require("files").exists(rootdir .. "/config/arc/" .. package .. ".uninstallIndex")
end
local function getIdata(package, rootdir)
    if not rootdir then rootdir = "/" end
    if not require("files").exists(rootdir .. "/config/arc/" .. package .. ".meta.json") then
        return nil
    end
    local f, e = require("files").open(rootdir .. "/config/arc/" .. package .. ".meta.json", "r")
    if not f then
        return nil
    end
    return json.decode(f.read())
end
local function getRepo(rootdir)
    if not rootdir then rootdir = "/" end
    local f = require("files").open(rootdir .. "/config/arc/repo.json", "r")
    if not f then
        return {}
    end
    local uj = json.decode(f.read())
    f.close()
    return uj
end
local function uninstall(package, rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    if not require("files").exists(rootdir .. "/config/arc/" .. package .. ".uninstallIndex") then
        error("Package not installed.")
    end
    local toDelete = { }
    toDelete[rootdir .. "/config/arc/" .. package .. ".uninstallIndex"] = ""
    toDelete[rootdir .. "/config/arc/" .. package .. ".meta.json"] = ""
    local f, e = require("files").open(rootdir .. "/config/arc/" .. package .. ".uninstallIndex", "r")
    if not f then error(e) end
    for value in f.readLine do
        if value == nil then break end
        if tutils.split(value:sub(3), "/")[1] == "config" then goto continue end
        if value:sub(0, 1) == "f" then
            toDelete[rootdir .. "/" .. value:sub(3)] = "FILE"
        else
            toDelete[rootdir .. "/" .. value:sub(3)] = "DIRECTORY"
        end
        ::continue::
    end
    for value, hash in pairs(toDelete) do
        if hash == "DIRECTORY" and #require("files").list(value) > 0 then
            goto continue
        end
        require("files").delete(value)
        ::continue::
    end
    for value, hash in pairs(toDelete) do
        if hash == "DIRECTORY" then
            if require("files").isDir(value) then
                if #require("files").list(value) > 0 then
                    goto continue
                end
            end
            require("files").delete(value)
        end
        ::continue::
    end
end
local arkivelib = {
    unarchive = function(text)
        local linebuf = ""
        local isReaderHeadInTable = true
        local offsetheader = {}
        local bufend = 0
        for k = 0, #text, 1 do
            local v = text:sub(k, k)
            if v == "\n" then
                if linebuf == "--ENDTABLE" then
                    bufend = k + 1
                    isReaderHeadInTable = false
                    break
                else
                    table.insert(offsetheader, tutils.split(linebuf, "|"))
                end
                linebuf = ""
            else
                linebuf = linebuf .. v
            end
        end
        local outputfiles = {}
        for k, v in ipairs(offsetheader) do
            if v[2] == "-1" then
                table.insert(outputfiles, { v[1], nil })
            elseif offsetheader[k + 1] then
                table.insert(outputfiles,
                    { v[1], text:sub(bufend + tonumber(v[2]), bufend + tonumber(offsetheader[k + 1][2]) - 1) })
            else
                table.insert(outputfiles, { v[1], text:sub(bufend + tonumber(v[2]), #text) })
            end
        end
        return outputfiles
    end
}
local function install(package, rootdir)
    if not rootdir then rootdir = "/" end
    if arcos.getCurrentTask().user ~= "root" then
        error("This operation requires the user to be root.")
    end
    checkForCD(rootdir)
    local repo = getRepo(rootdir)
    local latestCommit = getLatestCommit(rootdir)
    local buildedpl = ""
    if not repo[package] then
        error("Package not found!")
    end
    if require("files").exists(rootdir .. "/config/arc/" .. package .. ".meta.json") then
        local f, e = require("files").open(rootdir .. "/config/arc/" .. package .. ".meta.json", "r")
        if not f then error(e) end
        local ver = json.decode(f.read())["vId"]
        if ver < repo[package]["vId"] then
            local updateFile, e = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/upd" .. repo[package]["vId"] .. ".lua")
            if updateFile then
                local r = updateFile.read()
                local fac, eac = load(r, "Update Module", "t", setmetatable({}, { __index = _G }))
                if fac then
                    local ok, err = pcall(fac);
                    if not ok then error(err) end
                else
                    error(eac)
                end
            end
            uninstall(package, rootdir)
        else
            error("Package already installed!")
        end
    end
    local pkg = repo[package]
    local indexFile, err = get("https://raw.githubusercontent.com/" .. getChosenRepo() .. "/" .. latestCommit .. "/archivedpkgs/" .. package .. ".arc")
    if not indexFile then
        error(err)
    end
    local ifx = arkivelib.unarchive(indexFile.read())
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not require("files").exists(rootdir .. "/" .. value[1]) then
                require("files").makeDir(rootdir .. "/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
        end
    end
    for index, value in ipairs(ifx) do
        if value[2] == nil then
            if not require("files").exists(rootdir .. "/" .. value[1]) then
                require("files").makeDir(rootdir .. "/" .. value[1])
                buildedpl = buildedpl .. "d " .. value[1] .. "\n"
            end
        else
            if not require("files").exists(rootdir .. "/" .. value[1]) then
                local file = value[2]
                local tfh, e = require("files").open(rootdir .. "/" .. value[1], "w")
                if not tfh then error(e) end
                tfh.write(file)
                tfh.close()
                buildedpl = buildedpl .. "f "  .. value[1] .. "\n"
            end
        end
    end
    if pkg["postInstScript"] then
        return function()
            local file, e = get("https://raw.githubusercontent.com/" ..
            getChosenRepo() .. "/" .. latestCommit .. "/repo/" .. package .. "/" .. "pi.lua")
            if not file then
                return;
            end
            local fd = file.read()
            file.close()
            local tf, espanol = require("files").open(rootdir .. "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua", "r")
            if not tf then error(espanol) end
            tf.write(fd)
            tf.close()
            arcos.r({}, rootdir .. "/temporary/arc." .. package .. "." .. latestCommit .. ".postInst.lua")
        end
    end
    indexFile.close()
    local insf = require("files").open(rootdir .. "/config/arc/" .. package .. ".meta.json", "w")
    if not insf then error("I") end
    insf.write(json.encode(pkg))
    insf.close()
    local uinsf = require("files").open(rootdir .. "/config/arc/" .. package .. ".uninstallIndex", "w")
    if not uinsf then error("I") end
    uinsf.write(buildedpl)
    uinsf.close()
    return function()
    end
end
local function getUpdatable(rootdir)
    if not rootdir then rootdir = "/" end
    local updatable = {}
    for index, value in ipairs(files.ls(rootdir .. "/config/arc/")) do
        if value:sub(#value - 14) == ".uninstallIndex" then
            local pk = value:sub(0, #value - 15)
            local pf, e = require("files").open(rootdir .. "/config/arc/" .. pk .. ".meta.json", "r")
            if not pf then print(e) return {} end
            local at = pf.read()
            local af = json.decode(at)
            pf.close()
            if af["vId"] < getRepo(rootdir)[pk]["vId"] then
                table.insert(updatable, pk)
            end
        end
    end
    return updatable
end
return {
    fetch = fetch,
    getRepo = getRepo,
    install = install,
    uninstall = uninstall,
    isInstalled = isInstalled,
    getIdata = getIdata,
    getUpdatable = getUpdatable,
    getChosenRepo = getChosenRepo,
    getLatestCommit = getLatestCommit,
    get = get,
}
