local syscall = require("syscall")
return {
    -- createTask = syscall.tasking.createTask,
    -- killTask = syscall.tasking.killTask,
    -- getTasks = syscall.tasking.getTasks,
    -- setTaskPaused = syscall.tasking.setTaskPaused,
    -- changeUser = syscall.tasking.changeUser,


    ---Creates a task
    ---@param name string Task name
    ---@param callback function The actual code that the task runs
    ---@param nice number? Task niceness, how many times to execute coroutine.resume during the tasks round
    ---@param user string? Task user executor. Can only be current user and root if not root. changing to root asks for a password.
    ---@param out any? The output, exposed as term to the task
    ---@param env table? The task environment
    ---@return integer pid The task process id
    createTask = function(name, callback, nice, user, out, env)
        return syscall.tasking.createTask(name, callback, nice, user, out, env)
    end,
    ---Gets all tasks
    ---@return PublicTaskIdentifier[]
    getTasks = function()
        return syscall.tasking.getTasks()
    end,
    ---Sets the task paused status if not root can only be used on task of self
    ---@param pid number The pid of the task to set
    ---@param paused boolean New paused status
    setTaskPaused = function(pid, paused)
        return syscall.tasking.setTaskPaused(pid, paused)
    end,
    ---Changes the user of the current task
    ---@param user string New user username
    ---@param password string? New user password, ignored if root
    changeUser = function(user, password)
        return syscall.tasking.changeUser(user, password)
    end
}
