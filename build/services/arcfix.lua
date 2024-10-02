local arcos = require("arcos")
if arcos.getCurrentTask().user ~= "root" then
    error("Not root! We are " .. require("tutils").sJSON(arcos.getCurrentTask()))
end
ackFinish()
