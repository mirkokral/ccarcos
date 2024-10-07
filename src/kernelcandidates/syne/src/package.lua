
---@type table
_G.package = {
    preload = {
        string = string,
        table = table,
        package = package,
        coroutine = coroutine,
        utf8 = utf8,

    },
    isarcos = true,
    loaded = {

    },
    ---@type table<function>
    loaders = {
        ---@param name string
        ---@return function
        function(name)
            if not package.preload[name] then
                error("no field package.preload['" .. name .. "']")
            end
            return function()
                return package.preload[name]
            end
        end,
        ---@param name string
        ---@return function
        function(name)
            if not package.loaded[name] then
                error("no field package.loaded['" .. name .. "']")
            end
            return function()
                return package.loaded[name]
            end
        end,
        ---@param name string
        ---@return function
        function(name)
            local searchPaths = { "/", "/system/apis", "/apis" }
            local searchSuffixes = { ".lua", "init.lua" }
            if environ and environ.workDir then
                table.insert(searchPaths, environ.workDir)
            end
            for _, path in ipairs(searchPaths) do
                for _, suffix in ipairs(searchSuffixes) do
                    local file = path .. "/" .. name:gsub("%.", "/") .. suffix
                    if KDriversImpl.files.exists(file) then
                        local compEnv = {}
                        for k, v in pairs(_G) do
                            compEnv[k] = v
                        end
                        compEnv["apiUtils"] = nil
                        compEnv["KDriversImpl"] = nil
                        compEnv["xnarcos"] = nil
                        compEnv["_G"] = nil
                        

                        compEnv["_G"] = nil
                        setmetatable(compEnv, {
                            __index = function(t, k)
                                if k == "_G" then
                                    return compEnv
                                end
                            end,
                        })

                        local f, err = KDriversImpl.files.open(file, "r")
                        if not f then
                            error(err)
                        end
                        local compFunc, err = load(f.readAll(), file, nil, compEnv)
                        f.close()
                        if compFunc == nil then
                            error(err)
                        end
                        return compFunc
                    end
                end
            end
            error("Package not found.")
        end
    }
}

_G.require = function(modname)
    local errors = {}
    for _, loader in ipairs(package.loaders) do
        local ok, func = pcall(loader, modname)
        if ok then
            local f = func()
            package.loaded[modname] = f
            return f
        end
        table.insert(errors, func)
    end
    error("module '" .. modname .. "' not found:\n  " .. table.concat(errors, "\n  "))
end
