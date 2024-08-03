local s, t = ...
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
local v, n = fs.resolve(s)[1], fs.resolve(t, true)[1]
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end

fs.c(v, n)