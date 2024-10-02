local syscall = require("syscall")
return {
    createTask = function(name, callback, nice, user, out, env)
        return syscall.tasking.createTask(name, callback, nice, user, out, env)
    end,
    getTasks = function()
        return syscall.tasking.getTasks()
    end,
    setTaskPaused = function(pid, paused)
        return syscall.tasking.setTaskPaused(pid, paused)
    end,
    changeUser = function(user, password)
        return syscall.tasking.changeUser(user, password)
    end
}
