local arcos = require("arcos")
local ok, err = arcos.r({}, "/apps/shell.lua")
if not ok then print(err) end