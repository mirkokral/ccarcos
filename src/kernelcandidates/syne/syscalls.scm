# arcos syscalls
# priv = Only root can run this syscall
# publ = Anyone can run this syscall
# depd = Syscall access depends on provided arguments or system configuration

# Thou shall not return functions or other callable objects in syscalls.

type TaskInfo {
    string name
    number pid
    string user
    number nice
    boolean paused
    table env
}
type PublicTaskInfo {
    string name
    number pid
    string user
    number nice
    boolean paused
    table env
}

type FileHandle = number

.power
publ void reboot()
publ void shutdown()

.arcos syne
priv void panic(err: string, file: string, line: int)
publ void log(txt: string, level: int)
publ string version() ; The package version of arcos 
publ string uname() ; An identification string for the kernel
publ string getName() ; Returns the computers name. Slimar to unix hostname
priv void setName(name: string) ; Sets the name for the computers
publ TaskInfo getCurrentTask() ; Returns the current task's TaskInfo
publ string[] getUsers() ; Gets all user names on the system. A non-root alternative to parsing the passwd file
priv string getKernelLogBuffer() ; Gets the kernel log buffer, used in dmesg.
publ number time(locale: "local"|"utc"|"ingame"?) ; Same as os.time in normal lua
publ number day(locale: "local"|"utc"|"ingame"?) ; Gets the current day in specified timezone
publ number epoch(locale: string?)
publ string|table date(format: string) ; Same as os.date in normal lua
priv void queue(...) ; Adds an event to all tasks eventQueue. 
publ number clock() ; Gets the computer uptime
publ number startTimer(durationSeconds: number) ; Starts a timer
publ void cancelTimer(id: number); cancels an timerID
publ number setAlarm(durationSeconds: number) ; Starts an alarm
publ void cancelAlarm(id: number) ; cancels an alarm
publ number getID() ; Gets the ID of the current task
publ string getHome() ; Gets the home directory of the current user
depd boolean validateUser(username: string, password: string) ; Validates an user
priv void createUser(username: string, password: string) ; Creates a new user
priv void deleteUser(username: string) ; Deletes a user

.devices
publ string[] devices.names() ; Gets all device names
publ Device devices.get(name: string) ; Gets one device
publ Rest<Device> devices.find(type: string) ; Gets one device of type

.tasking
depd number tasking.createTask(name: string, callback: function, nice: number, user: string, out: terminal, env: table?)
publ PublicTaskInfo[] tasking.getTasks()
depd string? setTaskPaused(pid: number, paused: boolean)
depd boolean changeuser(user: string, password: string)

.fs syne
depd FileHandle? fs.open(path: string, mode: string) ; Opens a file
| publ void fs.fClose(file: FileHandle) ; Closes a file
| publ void fs.fSeek(file: FileHandle, whence: string?, offset: number?)
| publ void fs.fSync(file: FileHandle)
| publ string fs.fRead(file: FileHandle)
| publ string fs.fReadBytes(file: FileHandle, count: number)
| publ string fs.fReadLine(file: FileHandle)
| publ void fs.fWrite(file: FileHandle, data: string)
| publ void fs.fWriteLine(file: FileHandle, line: string)

depd string[] fs.list(path: string) ; Gets a list of files in a directory
depd boolean fs.exists(path: string) ; Gets if a path exists on the filesystem
depd FileAttributes fs.attributes(path: string) ; Gets file attributes of path
depd void fs.mkDir(path: string) ; Makes a directory
depd void fs.move(source: string, destination: string) ; Moves source to destination
depd void fs.copy(source: string, destination: string) ; Copies source to destination
depd void fs.remove(path: string) ; Removes path
publ string fs.getMountRoot(path: string) ; Gets the mount on which a path resides
publ {read: boolean, write: boolean, listed: boolean} fs.getPermissions(file: string, user: string)
