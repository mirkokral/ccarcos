local syscall = {
    run = function(syscall, ...)
        local f = { table.unpack(table.pack(coroutine.yield("syscall", syscall, ...)), 2) }
        if f[1] and type(f[1]) == "table" and f[1]["xType"] == "errorobject" and f[1]["xN"] == 0xfa115afe then
            error(debug.traceback(f[1]["xValue"]))
        else
            return table.unpack(f)
        end
    end
}
local function syscallmetatable(x, root)
    return setmetatable(x, {
        __index = function(t, k)
            return syscallmetatable({}, (#root > 0 and (root .. ".") or "") .. k)
        end,
        __call = function(t, ...)
            return syscall.run(root, ...)
        end
    })
end
syscall = syscallmetatable(syscall, "")
return syscall