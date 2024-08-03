local args = { ... }
if args[1] == "fetch" then
    arc.fetch()
else
    printError("No command.")
end