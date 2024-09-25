xg.out:write("Hello, world!\n");
while true do
    local l = xg.inp:readLine(-1, "/", xg.out, true);
    log.log(l);
end