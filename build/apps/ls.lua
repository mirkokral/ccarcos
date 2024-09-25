local files = require("files")
local col = require("col")
local path = ... or environ.workDir
local f = files.resolve(path)
for _, fp in ipairs(f) do
    if files.exists(fp) then
        if files.dir(fp) then
            for _, i in ipairs(files.ls(fp)) do
                if files.dir(fp) then
                    term.setTextColor(col.green)
                else
                    term.setTextColor(col.white)
                end
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