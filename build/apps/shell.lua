print("arcos shell")
local confile = fs.open("/config/arcshell", "r")
local conf = tutils.dJSON(confile.read())
confile.close()
local function run(a1, ...)
    local cmd = nil
    for i, v in ipairs(conf["path"]) do
        for i, v in ipairs(fs.ls(v)) do
            local t = v
            if t:sub(#t-3, #t) == ".lua" then
                t = t:sub(1, #t-4)
            end
            if t == a1 then
                cmd = t
            end
        end
    end
    if cmd == nil then
        printError("Command Not Found.")
        return false
    end
    local ok, err = arcos.r({}, cmd, ...)
    if not ok then
        printError(err)
    end
    return ok, err
end
while true
do
    local cTask = arcos.getCurrentTask()
    if cTask.user == "root" then
        term.setTextColor(col.red)
    else
        term.setTextColor(col.green)
    end
    write(cTask.user)
    term.setTextColor(col.gray)
    write("@")
    term.setTextColor(col.purple)
    write(arcos.getName())
    write(" ")
    term.setTextColor(col.gray)
    write("> ")
    term.setTextColor(col.white)
    local cmd = read()
    local r, k = pcall(run, table.unpack(tutils.split(cmd, " ")))
end