local s, t = ...
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end
local v, n = files.resolve(s)[1], files.resolve(t, true)[1]
if not s and t then
    print("Usage: cp [src] [target]")
    error()
end

files.c(v, n)