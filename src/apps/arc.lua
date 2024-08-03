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
    local outstr = table.concat(tobeinstalled, " ")
    term.setTextColor(col.white)
    write("Do you want to proceed? [y/n] ")
    local out = read(nil, {"n", "y"}, function (c)
        if c == "" then
            return {"y", "n"}
        end
        return {}
    end)
    if out == "y" or out == "" then
        for index, value in ipairs(tobeinstalled) do
            arc.install(value)
        end
    else
        print("Installation Aborted.")
    end
else
    printError("No command.")
end