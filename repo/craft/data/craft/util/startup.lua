shell.setDir(environ.workDir)
-- parentShell = nil
shell.run("/rom/startup.lua")
term.setBackgroundColor(col.black)
term.setTextColor(col.white)
term.clear()
term.setCursorPos(1, 1)
shell.run("shell", ...)