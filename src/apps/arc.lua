local args = { ... }
local cmd = table.remove(args, 1)
if cmd == "fetch" then
    arc.fetch()
elseif cmd == "install" then
    local tobeinstalled = {}
    local repo = arc.getRepo()
    for index, value in ipairs(args) do
        if not repo[value] then
            error("Package not found: " .. value)
        end
        for index, value in ipairs(repo[value]["dependencies"]) do
            if not arc.isInstalled(value) then
                table.insert(tobeinstalled, value)
            end
        end
        if not arc.isInstalled(value) then
            table.insert(tobeinstalled, value)
        end
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
                arc.install(value)
            end
        else
            print("Installation Aborted.")
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