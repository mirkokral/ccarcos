shell.setDir(environ.workDir)
-- parentShell = nil
shell.run("/rom/startup.lua")
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
shell.run("shell", ...)