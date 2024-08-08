term.setTextColor(col.blue)
print(arcos.version())
local confile = files.open("/config/arcshell", "r")
local conf = {}
if confile then
    conf = tutils.dJSON(confile.read())
    confile.close()
else
    return
end
if not environ.workDir then environ.workDir = "/" end
local function run(a1, ...)
    local cmd = nil
    if not a1 or a1 == "" then
        return true
    end
    if a1:sub(1, 1) == "/" then
        if files.exists(a1) then
            cmd = a1
        else
            printError("File not found")
            return false
        end
    elseif a1:sub(1, 2) == "./" then
        if files.resolve(a1, false)[1] then
            cmd = files.resolve(a1, false)[1]
        else
            printError("File not found")
            return false
        end
    else
        for i, v in ipairs(conf["path"]) do
            for i, s in ipairs(files.ls(v)) do
                local t = s
                if t:sub(#t-3, #t) == ".lua" then
                    t = t:sub(1, #t-4)
                end
                if t == a1 then
                    cmd = v .. "/" .. s
                end
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
        else
            print(tutils.s(err))
        end
        return ok
    end
    local ok, err = arcos.r({}, cmd, ...)
    if not ok then
        printError(err)
    end
    return ok, err
end
local history = {}
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
        term.setTextColor(col.magenta)
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
    local cmd = read(nil, history)
    table.insert(history, cmd)
    local r, k = pcall(run, table.unpack(tutils.split(cmd, " ")))
    if not r then
        pcall(printError, k)
    end
end