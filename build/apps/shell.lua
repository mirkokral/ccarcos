local col = require("col")
local files = require("files")
local tutils = require("tutils")
local arc = require("arc")
local arcos = require("arcos")
arcos.sleep(0.5) -- Avoid text race condition.
term.setTextColor(col.blue)
print("arcos " .. arcos.version())
print("\011f7" .. require("syscall").run("uname"))
local secRisks = {}
if arcos.validateUser("root", "toor") then
    table.insert(secRisks, "The root account password has not yet been changed.")
end
if arcos.validateUser("user", "user") then  
    table.insert(secRisks, "The user account password has not yet been changed.")
end
if #secRisks > 0 then
    print()
    term.setTextColor(col.red)
    print("Security risks")
    term.setTextColor(col.lightGray)
    print("- " .. table.concat(secRisks, "\n- "))
end
print()
print("\011f7This software comes with NO warranty, to the extent of the applicable law.")
print()
local confile = files.open("/config/arcshell", "r")
local conf = {}
if confile then
    conf = tutils.dJSON(confile.read())
    confile.close()
else
    return
end
local luaGlobal = setmetatable({}, {__index = _G})
if not environ.workDir then environ.workDir = "/" end
local function run(a1, ...) 
    local cmdr = nil
    if not a1 or a1 == "" then
        return true
    end
    if a1:sub(1, 1) == "/" then
        if files.exists(a1) then
            cmdr = a1
        else
            printError("File not found")
            return false
        end
    elseif a1:sub(1, 2) == "./" then
        if files.resolve(a1, false)[1] then
            cmdr = files.resolve(a1, false)[1]
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
                    cmdr = v .. "/" .. s
                end
            end
        end
    end
    if cmdr == nil then
        printError("Command not found!")
        return false, "Command not found!"
    end
    local args, ok, err = {...}, nil, nil
    local aok, aerr = pcall(function() 
        ok, err = arcos.r({}, cmdr, table.unpack(args))
        if not ok then
            printError(err)
        end
    end)
    if not aok then
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
    if environ.envType then
        term.setTextColor(col.yellow)   
        write("(" .. tostring(environ.envType) .. ") ")
    end
    term.setTextColor(col.gray) 
    write(environ.workDir)
    write(" ")
    write(arcos.getCurrentTask().user == "root" and "# " or "$ ")
    term.setTextColor(col.white)
    local ok, err = pcall(function (...)
        local cmd = read(nil, history) or ""
        if cmd ~= "" then table.insert(history, cmd) end
        local r, k = pcall(run, table.unpack(tutils.split(cmd, " ")))
        if not r then
            pcall(printError, k)
        end
    end)
    if not ok then write("\n") end
end