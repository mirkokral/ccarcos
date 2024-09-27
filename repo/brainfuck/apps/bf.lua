local bf = require("brainfuck")
local files = require("files")
local args = {...}

if #args ~= 1 then
    args = {"++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."}
end
local sigmaphone2488 = files.resolve(args[1])[1]
local torun = sigmaphone2488 and files.read(sigmaphone2488) or args[1]
bf.execute(torun)