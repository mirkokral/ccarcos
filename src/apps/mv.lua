local s, t = ...
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end
local v, n = fs.resolve(s)[1], fs.resolve(t)[1]
if not s and t then
    print("Usage: mv [src] [target]")
    error()
end

fs.m(v, n)