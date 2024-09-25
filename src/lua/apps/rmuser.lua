if arcos.getCurrentTask().user ~= "root" then
    write("[escalation] Enter root password: ")
    local pass = read("*")
    local f = tasking.changeUser("root", pass)
    if not f then
        error("Invalid password!")
    end
end

local args = { ... }
if #args ~= 1 then
    error("Too many or too few args.")
end

local u = arcos.deleteUser(args[1])

if not u then
    print("Failed removing user.")
end