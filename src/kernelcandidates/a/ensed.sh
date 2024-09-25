OPF=$1
E=$(cat $OPF)
X1="{
    sleep = function(n)
        n = n / 1000
        if _G.sleep ~= nil then
            sleep(n)
        else
            print(\"Sleeping for \" .. tonumber(n))
            os.execute(\"sleep \" .. tonumber(n))
        end

    end,
    run = function(mode) return false end,
    loop_alive = function() return false end,
    fs_unlink = function(path)
        x= fs.delete(path)
        if not x then return true end
    end,
    fs_mkdir = function(path)
        x=fs.makeDir(path)
        if not x then return true end

    end,
    fs_rmdir = function(path)
        x= fs.delete(path)
        if not x then return true end
    end,
    fs_readdir = function(path)
        return fs.list(path)
    end,
    fs_scandir = function(path)
        
        return {0, path}
    end,
    fs_scandir_next = function(dsci)
        dsci[1] = dsci[1] + 1
        
        return fs.list(dsci[2])[dsci[1]]
    end,
    fs_stat = function(path)
        if not fs.exists(path) then return nil end
        return fs.attributes(path)
    end,
    fs_rename = function(p, np)
        return fs.move(p, np)
    end,
    fs_sendfile = function(outfile, infile)
        return fs.copy(infile, outfile)
    end,
    fs_chmod = function(a,b) end,
    fs_chown = function(a,b,c) end,
    fs_utime = function(a,b,c) end,
    fs_lstat = function(path) error(\"Tried link operation\") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_link = function(p, a) error(\"Tried link operation\") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_symlink = function(p, a, m) error(\"Tried link operation\") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_readlink = function(p) error(\"Tried link operation\") end, -- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation 
    fs_cwd = function()
        if shell then return shell.dir() else return \"/\" end
    end,
    fs_chdir = function(path)
        if shell then return shell.setDir(path) end
    end,
    fs_exepath = function(path)
        if shell then
            return shell.getRunningProgram()
        else
            return debug.getinfo(1, \"S\").source
        end
    end,
    fs_open = function(path, mode, _)
        local f = fs.open(path, mode)
        return {
            read = function(len, offset)
                if offset then
                    f.seek(offset)
                end
                local actuallyread = f.read(len)
                return #actuallyread, actuallyread
            end,
            write = function(data, offset)
                if offset then
                    f.seek(offset)
                else
                    f.seek(1)
                end
                f.write(data)
            end,
            close = function()
                f.close()
            end,
            stat = function ()
                return fs.attributes(path)
            end,
            sync = function () end, -- There doesn't seem to be an imlpementation for this function in computercraft
            datasync = function () end, -- Same as above
            utime = function () end, -- Might be provided by os, but not in craftos or cc bioslevel.
            chmod = function () end, -- Might be provided by os, but not in craftos or cc bioslevel.
            chown = function () end, -- Might be provided by os, but not in craftos or cc bioslevel.
            truncate = function () end, -- Developer does not know what this means
        }

    end
}"
S1="${E/_G.require(\"luv\")/$X1}"
S1="${S1/_G.require(\"luv\")/$X1}"
S1="${S1/_G.require(\"luv\")/$X1}"
S1="${S1/_G.require(\"luv\")/$X1}"
S1="${S1/_G.require(\"luv\")/$X1}"
S1="${S1/package.loaded.luv/nil}"
A1="_gthis.k, cur"
A2="_gthis.h, cur"
# echo $S1
S1="${S1/$A1/$A2}"
# echo $S1
echo "${S1/_G.require(\"lua-utf8\")/string}" > ${OPF%.*}b.lua