package syscall.extensions;

import UserManager;
import haxe.macro.Compiler;
import haxe.Json;

class ArcosExtension extends SyscallExtension {
	public function getSyscalls(kernel:Kernel):Array<Syscall> {
		return [
			new Syscall("panic", function(...d:Dynamic) {
				var error = d[0];
				var file = d[1];
				var line = d[2];
				kernel.panic(error, file, line);
				return [];
			}),
			new Syscall("log", function(...d:Dynamic) {
				var message = d[0];
				var level = d[1];
				Logger.log(message, level, true, true, null);
				return [];
			}),
			new Syscall("version", function(...d:Dynamic) {
				if (!kernel.rootFs.exists("/config/arc/base.meta.json")) {
					return [""];
				}
				var fH = kernel.rootFs.open("/config/arc/base.meta.json", "r");
				
				var meta = Json.parse(fH.read());
				fH.close();
				if (meta.version == null) {
					return [""];
				} else {
					return [meta.version];
				}
			}),
			new Syscall("uname", function(...d:Dynamic) {
				return [
					"Syne" + Compiler.getDefine("syneversion") + " built on Haxe " + Compiler.getDefine("haxe_ver")
				];
			}),
			new Syscall("getName", function(...d:Dynamic) {
				return [Hal.computer.label()];
			}),
			new Syscall("setName", function(...d:Dynamic) {
				if (kernel.scheduler.getCurrentTask().user != "root") {
					throw "No permission for this action";
				}
				Hal.computer.setlabel(d[0]);
				return [];
			}),
			new Syscall("getCurrentTask", function(...d:Dynamic) {
				var ct = kernel.scheduler.getCurrentTask();
				return [
					{
						name: ct.name,
						pid: ct.id,
						user: ct.user,
						nice: ct.nice,
						paused: ct.paused,
						env: ct.env
					}
				];
			}),
			new Syscall("getUsers", function(...d:Dynamic) {
				return [
					kernel.userManager.users.map(function(u:User) {
						return u.name;
					})
				];
			}),
			new Syscall("getKernelLogBuffer", function(...d:Dynamic) {
				if (kernel.scheduler.getCurrentTask().user != "root") {
					throw "No permission for this action";
				}
				return [Logger.kLog];
			}),
			new Syscall("time", function(...d: Dynamic) {
				return [Hal.computer.time(d[0])];
			}),
			new Syscall("day", function(...d: Dynamic) {
				return [Hal.computer.day(d[0])];
			}),
			new Syscall("epoch", function(...d: Dynamic) {
				return [Hal.computer.epoch(d[0])];
			}),
			new Syscall("date", function(...d: Dynamic) {
				return [Hal.computer.date(d[0])];
			}),
			new Syscall("queue", function(...d: Dynamic) {
				if (kernel.scheduler.getCurrentTask().user != "root") {
					throw "No permission for this action";
				}
				for (task in kernel.scheduler.tasks) {
					task.taskQueue.push(d.toArray());
				}
				return [];
				
			}),
			new Syscall("clock", function(...d: Dynamic) {
				return [Hal.computer.uptime()];
			}),
			new Syscall("startTimer", function(...d: Dynamic) {
				return [Hal.timers.start(d[0])];
			}),
			new Syscall("cancelTimer", function(...d: Dynamic) {
				Hal.timers.cancel(d[0]);
				return [];
			}),
			new Syscall("setAlarm", function(...d: Dynamic) {
				return [Hal.timers.setalarm(d[0])];
			}),
			new Syscall("cancelAlarm", function(...d: Dynamic) {
				Hal.timers.cancelalarm(d[0]);
				return [];
			}),
			new Syscall("getID", function(...d: Dynamic) {
				return [Hal.computer.id];
			}),
			new Syscall("getHome", function(...d: Dynamic) {
				if(!kernel.rootFs.exists("/user/" + kernel.scheduler.getCurrentTask().user + "/home")) {
					kernel.rootFs.mkDir("/user/" + kernel.scheduler.getCurrentTask().user + "/home");
				}
				return ["/user/" + kernel.scheduler.getCurrentTask().user];
			}),
			new Syscall("validateUser", function(...d: Dynamic) {
				return [kernel.userManager.validateUser(d[0], d[1])];
			}),
			new Syscall("createUser", function(...d: Dynamic) {
				if(kernel.scheduler.getCurrentTask().user != "root") {
					throw "No permission for this action";
				}
				kernel.userManager.add(d[0], d[1]);
				return [];
			}),
			new Syscall("deleteUser", function(...d: Dynamic) {
				if(kernel.scheduler.getCurrentTask().user != "root") {
					throw "No permission for this action";
				}
				kernel.userManager.remove(d[0]);
				return [];
			}),
			new Syscall("terminal.getKeymap", function(...d: Dynamic) {
				return [Hal.terminal.kMap];
			})
		];
	}
}
