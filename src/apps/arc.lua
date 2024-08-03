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
            table.insert(tobeinstalled, value)
        end
        table.insert(tobeinstalled, value)
    end
    term.setTextColor(col.lightGray)
    print("These packages will be installed:")
    print()
    term.setTextColor(col.green)
    print(table.concat(tobeinstalled, " "))
    term.setTextColor(col.white)
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
else
    printError("No command.")
end