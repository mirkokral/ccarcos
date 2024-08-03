local function getLatestCommit()
    local fr = __LEGACY.http.get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    fr.close()
    return rp
end
local function checkForCD()
    if not __LEGACY.fs.exists("/config/arc") then
        __LEGACY.fs.makeDir("/config/arc")
    end
end
function fetch()
    checkForCD()
    local f = __LEGACY.http.get("https://raw.githubusercontent.com/mirkokral/ccarcos/".. getLatestCommit() .."/repo/index.json")
    local fa = __LEGACY.fs.open("/config/arc/repo.json", "w")
    fa.write(f.readAll())
    fa.close()
    f.close()
end
