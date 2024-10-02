local arcos = require("arcos")
local tasking = require("tasking")

if arcos.getCurrentTask().user ~= "root" then
    write("[escalation] Enter root password: ")
    local pass = read("*")
    local f = tasking.changeUser("root", pass)
    if not f then
        error("Invalid password!")
    end
end
local args = { ... }
local username = args[1]
local password = ""
if #args == 1 then
    write("New Password: ")
    password = read("*") or ""

elseif #args == 2 then
    password = args[2]
else
    error("Too little or too many arguments")
end

arcos.createUser(username, password)