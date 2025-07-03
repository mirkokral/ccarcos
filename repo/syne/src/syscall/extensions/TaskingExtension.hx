package syscall.extensions;

import lua.Table;
import lua.Lua;

class TaskingExtension extends SyscallExtension {
	public function getSyscalls(kernel:Kernel):Array<Syscall> {
		return [
			new Syscall("tasking.createTask", function(...d:Dynamic) {
				var name = d[0];
				var callback = d[1];
				var nice = d[2] ?? 0;
				var user = d[3] ?? kernel.scheduler.getCurrentTask().user;
				var out = d[4] ?? (untyped __lua__("term"));
				var env = d[5] ?? (untyped __lua__("environ"));
				if (!Std.isOfType(name, String))
					throw "Name must be string";
				if (!Std.isOfType(nice, Int))       
					throw "Nice must be integer";
				if (!Std.isOfType(user, String))
					throw "User must be string";
				if (env != null && !Std.isOfType(env, Table))
					throw "Env must be table";
				if (kernel.scheduler.getCurrentTask().user != "root" && user != kernel.scheduler.getCurrentTask().user) {
					throw "No permission for this action (note: you can use tasking.changeuser to change the current user)";
				}
				var v = kernel.scheduler.addTask(name, cast callback, user, out);
				kernel.scheduler.tasks[v].pInfo.nice = nice;
				kernel.scheduler.tasks[v].pInfo.out = out;

				return [v];
			}),
			new Syscall("tasking.killTask", function(...d:Dynamic) {
				var pid = d[0];
				var signal = d[1] ?? "terminate";
				if (!Std.isOfType(pid, Int))
					throw "Pid must be integer";
				if (!Std.isOfType(signal, String))
					throw "Signal must be string";

				if (kernel.scheduler.getCurrentTask().user != "root" && kernel.scheduler.tasks[pid].pInfo.user != kernel.scheduler.getCurrentTask().user && !kernel.scheduler.tasks[pid].pInfo.parents.contains(kernel.scheduler.getCurrentTask().id)) {
					throw "No permission for this action (note: you can use tasking.changeuser to change the current user)";
				}


				if(signal == "annihalate") {
					kernel.scheduler.tasks.remove(kernel.scheduler.tasks[pid]);
				} else {
					kernel.scheduler.tasks[pid].taskQueue.push(["terminate", signal]);
				}
				return [];
			}),
			new Syscall("tasking.getTasks", function(..._:Dynamic) {
				return [kernel.scheduler.tasks.map(e -> {
					return {
						name: e.pInfo.name,
                        pid: e.pInfo.id,
                        user: e.pInfo.user,
                        nice: e.pInfo.nice,
                        paused: e.pInfo.paused,
                        env: e.pInfo.env
					};
				})];
			}),
            new Syscall("tasking.setTaskPaused", function(...d:Dynamic) {
                var pid = d[0];
                var paused = d[1];
                if (!Std.isOfType(pid, Int))
                    throw "Pid must be integer";
                if (!Std.isOfType(paused, Bool))
                    throw "Paused must be boolean";
                if (kernel.scheduler.getCurrentTask().user != "root" && kernel.scheduler.tasks[pid].pInfo.user != kernel.scheduler.getCurrentTask().user && !kernel.scheduler.tasks[pid].pInfo.parents.contains(kernel.scheduler.getCurrentTask().id)) {
                    throw "No permission for this action (note: you can use tasking.changeuser to change the current user)";
                }
                kernel.scheduler.tasks[pid].pInfo.paused = paused;
                return [];
            }),
            new Syscall("tasking.changeUser", function(...d:Dynamic) {
                var user = d[0];
                var password = d[1];
                if (!Std.isOfType(user, String))
                    throw "User must be string";
                if (kernel.scheduler.getCurrentTask().user != "root" && !Std.isOfType(password, String))
                    throw "Password must be string";
                if (kernel.scheduler.getCurrentTask().user == "root" || kernel.userManager.validateUser(user, password)) {
                    kernel.scheduler.getCurrentTask().user = user;
                    return [true];
                } else {
                    return [false];
                }
            })
		];
	}
}
