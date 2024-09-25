local x = require("cellui")

local runner = x["Runner"].new(x["typedefs"].CCTerminal.new(term),x["ScrollContainer"].new({}),nil)
runner:run()