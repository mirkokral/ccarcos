|/apis|-1|
|/apps|-1|
|apis/brainfuck.lua|0|
|apps/bf.lua|864|
--ENDTABLE
local col = require("col")

return {
    ---Execute brainfuck code
    ---@param code string The brainfuck code to be executed
    execute = function(code)
        local instr = {
            [">"] = "pointer = pointer + 1\nmem[pointer] = mem[pointer] or 0",
            ["<"] = "pointer = pointer - 1\nmem[pointer] = mem[pointer] or 0",
            ["+"] = "mem[pointer] = (mem[pointer] or 0) + 1",
            ["-"] = "mem[pointer] = (mem[pointer] or 0) - 1",
            ["."] = "write(string.char(mem[pointer] or 63))",
            [","] = "mem[pointer] = ({arcos.ev(\"char\")})[2]",
            ["["] = "while mem[pointer] ~= 0 do",
            ["]"] = "end"
        }
        local compiled = "pointer, mem = 0, {}\n"
        for i = 1, #code do
            compiled = compiled .. instr[code:sub(i, i)] .. "\n"
        end
        load(compiled)()
    end
}
local bf = require("brainfuck")
local files = require("files")
local args = {...}

if #args ~= 1 then
    args = {"++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."}
end
local sigmaphone2488 = files.resolve(args[1])[1]
local torun = sigmaphone2488 and files.read(sigmaphone2488) or args[1]
bf.execute(torun)