local args = { ... }
local cmd = table.remove(args, 1)
local repo = arc.getRepo()
local function getTBI(a, b)
    if not repo[a] then
        error("Package not found: " .. a)
    end
    for index, value in ipairs(repo[a]["dependencies"]) do
        getTBI(a, b)
    end
    if (not arc.isInstalled(a)) or arc.getIdata(a)["vId"] < repo[a]["vId"] then
        table.insert(b, a)
    end
end
if cmd == "fetch" then
    arc.fetch()
elseif cmd == "install" then
    local tobeinstalled = {}
    local afterFunctions = {}
    for index, value in ipairs(args) do
        if not repo[value] then
            error("Package not found: " .. value)
        end
        getTBI(value, tobeinstalled)
    end
    if #tobeinstalled > 0 then
        term.setTextColor(col.lightGray)
        print("These packages will be installed:")
        print()
        term.setTextColor(col.green)
        print(table.concat(tobeinstalled, " "))
        term.setTextColor(col.white)
        print()
        print("Do you want to proceed? [y/n] ")
        local out = ({ arcos.ev("char") })[2]
        if out == "y" then
            for index, value in ipairs(tobeinstalled) do
                print("(" .. index .. "/" .. #tobeinstalled .. ") " .. value)
                table.insert(afterFunctions, arc.install(value))
            end
        else
            print("Installation Aborted.")
        end
        for index, value in ipairs(afterFunctions) do
            value()
        end
    end
    print("Done")
elseif cmd == "uninstall" then
    for index, value in ipairs(args) do
        if not arc.isInstalled(value) then
            error("Package not installed: " .. value)
        end
    end
    term.setTextColor(col.lightGray)
    print("These packages will be uninstalled:")
    print()
    term.setTextColor(col.red)
    print(table.concat(args, " "))
    print()
    term.setTextColor(col.white)
    print("Do you want to proceed? [y/n] ")
    local out = ({ arcos.ev("char") })[2]
    if out == "y" then
        for index, value in ipairs(args) do
            arc.uninstall(value)
        end
    else
        print("Unistallation Aborted.")
    end
else
    printError("No command.")
end