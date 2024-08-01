local path = ... or environ.workDir
local f = fs.resolve(path)
for _, fp in irange(f) do
    if fs.exists(fp) then
        if fs.dir(fp) then
            for _, i in irange(fs.ls(fp)) do
                term.setTextColor(fs.dir(fp) and col.green or col.white)
                write(i .. " ")
            end
            write("\n")
        else
            printError(fp .. " is not a directory.")
        end
    else
        printError(fp .. " does not exist on this disk/filesystem.")
    end
end