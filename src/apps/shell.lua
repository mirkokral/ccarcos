print("arcos shell")
local confile = fs.open("/config/arcshell", "r")
local conf = tutils.dJSON(confile.read())
confile.close()
if not environ.workDir then environ.workDir = "/" end
local function run(a1, ...)
    local cmd = nil
    for i, v in ipairs(conf["path"]) do
        for i, s in ipairs(fs.ls(v)) do
            local t = s
            if t:sub(#t-3, #t) == ".lua" then
                t = t:sub(1, #t-4)
            end
            if t == a1 then
                cmd = v .. "/" .. s
            end
        end

    end
    if cmd == nil then
        local cq = tutils.join({ a1, ... }, " ")
        local chunkl, err = load(cq, "eval", nil, _G)
        if not chunkl then
            printError(err)
            return false
        end
        local ok, err = pcall(chunkl)
        if not ok then
            printError(err)
        end
        
        return ok
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
    local a, err = pcall(arcos.getName)
    if a then
        term.setTextColor(col.gray)
        write("@")
        term.setTextColor(col.purple)
        if not pcall(write, tostring(err)) then
            write("(none)")
        end
    end
    write(" ")
    term.setTextColor(col.gray) 
    write(environ.workDir)
    write(" ")
    write(arcos.getCurrentTask().user == "root" and "# " or "$ ")
    term.setTextColor(col.white)
    local cmd = read()
    local r, k = pcall(run, table.unpack(tutils.split(cmd, " ")))
    if not r then
        pcall(printError, k)
    end
end