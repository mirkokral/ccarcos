shell.setDir(environ.workDir)
shell.setAlias(     )
term.setBackgroundColor(col.black)
term.setTextColor(col.white)
term.clear()
term.setCursorPos(1, 1)
shell.run("/rom/startup.lua")
shell.run("shell", ...)