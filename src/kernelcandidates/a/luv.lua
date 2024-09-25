-- Fake libuv bindings for computercraft
-- These are not supposed to be used when developing apps, rather when porting or using other languages

-- Copyright 2024 TNC LTD.
-- 
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
-- 
-- 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
-- 
-- 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
-- 
-- 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


return {
    sleep = function(n)
        n = n / 1000
        if _G.sleep ~= nil then
            sleep(n)
        else
            print("Sleeping for " .. tonumber(n))
            os.execute("sleep " .. tonumber(n))
        end

    end,
    run = function(mode) return false end,
    loop_alive = function() return false end,
    fs_unlink = function(path)
        fs.delete(path)
    end,
    fs_mkdir = function(path)
        fs.makeDir(path)
    end,
    fs_rmdir = function(path)
        fs.delete(path)
    end,
    fs_readdir = function(path)
        return fs.list(path)
    end,
    fs_stat = function(path)
        return fs.attributes(path)
    end,
    fs_rename = function(p, np)
        return fs.move(p, np)
    end,
    fs_sendfile = function(outfile, infile)
        fs.copy(infile, outfile)
    end,
    fs_chmod = function(a,b) end,
    fs_chown = function(a,b,c) end,
    fs_utime = function(a,b,c) end,
    fs_lstat = function(path) error("Tried link operation") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_link = function(p, a) error("Tried link operation") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_symlink = function(p, a, m) error("Tried link operation") end,-- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation
    fs_readlink = function(p) error("Tried link operation") end, -- This may be provided by your current os, but CraftOS or computercraft bios-level executed code do not have this operation 
    fs_cwd = function()
        if shell then return shell.dir() else return "/" end
    end,
    fs_chdir = function(path)
        if shell then return shell.setDir(path) end
    end,
    fs_exepath = function(path)
        if shell then
            return shell.getRunningProgram()
        else
            return debug.getinfo(1, "S").source
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
}