
local methods = {
    GET = true, POST = true, HEAD = true,
    OPTIONS = true, PUT = true, DELETE = true,
    PATCH = true, TRACE = true,
}

local function check_key(options, key, ty, opt)
    local value = options[key]
    local valueTy = type(value)

    if (value ~= nil or not opt) and valueTy ~= ty then
        error(("bad field '%s' (%s expected, got %s"):format(key, ty, valueTy), 4)
    end
end

local function check_request_options(options, body)
    check_key(options, "url", "string")
    if body == false then
        check_key(options, "body", "nil")
    else
        check_key(options, "body", "string", not body)
    end
    check_key(options, "headers", "table", true)
    check_key(options, "method", "string", true)
    check_key(options, "redirect", "boolean", true)
    check_key(options, "timeout", "number", true)

    if options.method and not methods[options.method] then
        error("Unsupported HTTP method", 3)
    end
end

local function wrap_request(_url, ...)
    local ok, err = __LEGACY.http.request(...)
    if ok then
        while true do
            local event, param1, param2, param3 = os.pullEvent()
            if event == "http_success" and param1 == _url then
                return param2
            elseif event == "http_failure" and param1 == _url then
                return nil, param2, param3
            end
        end
    end
    return nil, err
end
local function get(_url, _headers, _binary)
    if type(_url) == "table" then
        check_request_options(_url, false)
        return wrap_request(_url.url, _url)
    end

    assert(type(_url) == "string")
    assert(type(_headers) == "table" or type(_headers) == "nil")
    assert(type(_binary) == "boolean" or type(_binary) == "nil")
    return wrap_request(_url, _url, nil, _headers, _binary)
end


local function getLatestCommit()
    local fr = get("https://api.github.com/repos/mirkokral/ccarcos/commits/main")
    local rp = __LEGACY.textutils.unserializeJSON(fr.readAll())["sha"]
    fr.close()
    return rp
end
local function checkForCD()
    if not __LEGACY.fs.exists("/config/arc") then
        __LEGACY.fs.makeDir("/config/arc")
    end
end
---Fetches arc repos
function fetch()
    checkForCD()
    local f = get("https://raw.githubusercontent.com/mirkokral/ccarcos/".. getLatestCommit() .."/repo/index.json")
    local fa = __LEGACY.fs.open("/config/arc/repo.json", "w")
    fa.write(f.readAll())
    fa.close()
    f.close()
end

-- C:Exc
_G.arc = {
    fetch = fetch
}
-- C:End