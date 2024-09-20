shell.setDir(environ.workDir)
term.setBackgroundColor(col.black)
term.setTextColor(col.white)
term.clear()
term.setCursorPos(1, 1)
parentShell = nil
shell.run("shell", ...) 