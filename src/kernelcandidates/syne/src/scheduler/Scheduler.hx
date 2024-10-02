package scheduler;

import Kernel.Out;
import syscall.extensions.TaskingExtension;
import Devices.PeripheralDevice;
import syscall.extensions.DeviceExtension;
import syscall.extensions.FilesystemExtension;
import Hal;
import haxe.Rest;
import syscall.extensions.ArcosExtension;
import lua.Debug;
import lua.Table;
import lua.TableTools;
import syscall.SyscallInterface;
import Hal.Terminal;
import haxe.Constraints.Function;
import lua.Coroutine;

class TaskInfo {
	/**
	 * The task's name
	 * This identifies the tasks. In the system, it is used in the following:
	 * Log and kernel panic display this.
	 */
	public var name:String;

	/**
	 * The task's id
	 * This value is the same as its position in the tasks array in the scheduler
	 */
	public var id:Int;

	/**
	 * The task's environment
	 * _G.environ gets set to this value when its the task's turn.
	 */
	public var env:Map<String, String>;

	/**
	 * The task's user value.
	 * Affects the task's permissions.
	 */
	public var user:String;

	/**
	 * The paused value of the task
	 * If true, the task will not be assigned any events and the task will not run.
	 */
	public var paused:Bool;

	/**
	 * The tasks niceness value
	 * More means the task runs for longer.
	 * This only applies when the platform supports pre-emption (currently only computercraft because opencomputers doesn't have debug hooks and liko-12 doesn't even have the debug library)
	 */
	public var nice:Int;

	/**
	 * The variable to be assigned to term while running the task.
	 * This is used to pass the output of the task to the terminal
	 */
	public var out:Dynamic;

	public function new(name:String, id:Int, env:Map<String, String>, user:String, out:Dynamic) {
		this.name = name;
		this.id = id;
		this.env = env;
		this.user = user;
		this.paused = false;
		this.nice = 0;
		this.out = out;
	}

	public function copy() {
		var ti = new TaskInfo(this.name, this.id, this.env, this.user, this.out);
		ti.paused = this.paused;
		ti.nice = this.nice;
		return ti;
	}
}

class Task {
	public var coroutine:Coroutine<() -> Void>;
	public var taskQueue:Array<Array<Dynamic>>;
	public var pInfo:TaskInfo;
	public var lastPreempt:Float;
	public var isWaitingForEvent = false;

	public function new() {}
}

class Scheduler {
	public var tasks:Array<Task> = [];
	public var currentTaskPid:Int;
	public var usePreemption:Bool = false;

	private var kernel:Kernel;

	public var syscallInterface:SyscallInterface;

	public function getCurrentTask() {
		if (tasks[currentTaskPid] != null) {
			return tasks[currentTaskPid].pInfo.copy();
		} else {
			return new TaskInfo("Kernel", -1, [], "root", Hal.terminal);
		}
	}

	public function addTask(name:String, callback:() -> Void, ?user:String, ?out:Dynamic) {
		if (user == null) {
			user = getCurrentTask().user;
		}
		if (out == null) {
			out = getCurrentTask().out;
		}
		var pid = tasks.length;
		var env = getCurrentTask().env;
		tasks[pid] = new Task();
		tasks[pid].coroutine = Coroutine.create(() -> {
			if (usePreemption) {
				Debug.sethook(() -> {
					if (Hal.computer.uptime() - tasks[pid].lastPreempt > 0.01) { // Momentary jiffy value
						Coroutine.yield("preempt");
						tasks[pid].lastPreempt = Hal.computer.uptime();
					}
				}, "l");
			}
			try {
				callback();
			} catch(e) {
				trace(e);
			}
		});
		tasks[pid].taskQueue = [];
		tasks[pid].pInfo = new TaskInfo(name, pid, env, user, out);
		tasks[pid].lastPreempt = Hal.computer.uptime();
		return pid;
	}

	public function killTask(pid:Int) {
		tasks.remove(tasks[pid]);
	}

	private function handleEvent(ev: Array<Dynamic>) {
		if(ev[0] == "peripheral") {
			kernel.dm.add(new PeripheralDevice(ev[1]));
		}
		if(ev[0] == "peripheral_detach") {
			kernel.dm.remove(ev[1]);
		}	
		for (task in tasks) {
			task.taskQueue.push(ev);
		}
	}

	public function resumeTask(task:Task, ?fev:Array<Dynamic>):Bool {
		Hal.workarounds.preventTooLongWithoutYielding((ev) -> {
			this.handleEvent(Table.toArray(ev));
		});
		if (!task.isWaitingForEvent || fev != null) {
			untyped __lua__("_G.term = task.pInfo.out");
			untyped __lua__("_G.environ = task.pInfo.env");
			currentTaskPid = task.pInfo.id;
			var n = fev ?? [];
			var tra:Array<Dynamic> = Table.toArray(TableTools.pack(CG.resume(task.coroutine, ...n)));
			var tr = {
				success: tra[0],
				result: tra.slice(1)
			}
			if (false) {
				tasks.remove(task);
			} else {
				var n = tr.result;
				if (n[0] == "syscall") {
					var o = syscallInterface.executeSyscall(n[1], ...n.slice(2));
					resumeTask(task, ["syscall_result"].concat(Table.toArray(cast o)));
				} else if (n[0] == "preempt" && usePreemption) {
					task.isWaitingForEvent = false;
				} else {
					task.isWaitingForEvent = true;
				}
			}
			currentTaskPid = -1;
			return true;
		} else if (task.isWaitingForEvent && task.taskQueue.length > 0) {
			untyped __lua__("_G.term = task.pInfo.out");
			untyped __lua__("_G.environ = task.pInfo.env");
			currentTaskPid = task.pInfo.id;
			var ev = task.taskQueue.shift();
			var tra:Array<Dynamic> = Table.toArray(TableTools.pack(CG.resume(task.coroutine, ...ev)));
			var tr = {
				success: tra[0],
				result: tra.slice(1)
			}
			if (false) {
				tasks.remove(task);
			} else {
				var n = tr.result;
				if (n[0] == "syscall") {
					var o = syscallInterface.executeSyscall(n[1], ...n.slice(2));
					resumeTask(task, ["syscall_result"].concat(Table.toArray(cast o)));
				} else if (n[0] == "preempt" && usePreemption) {
					task.isWaitingForEvent = false;
				} else {
					task.isWaitingForEvent = true;
				}
			}
			currentTaskPid = -1;
			return true;
		} else {
			return false;
		}
	}

	public function tick() {
		if (tasks.length == 0) {
			this.kernel.panic("All tasks died", "Scheduler", 0);
		}
		var n = false;
		for (task in tasks) {
			if (resumeTask(task)) {
				n = true;
			}
		}			
		if (!n) {
			var ev = Table.toArray(TableTools.pack(Coroutine.yield()));
			this.handleEvent(ev);
		}
	}

	public function new(usePreemption:Bool, kernel:Kernel) {
		this.kernel = kernel;

		this.syscallInterface = new SyscallInterface(kernel);
		this.syscallInterface.addSyscallInterface(new ArcosExtension());
		this.syscallInterface.addSyscallInterface(new FilesystemExtension());
		this.syscallInterface.addSyscallInterface(new DeviceExtension());
		this.syscallInterface.addSyscallInterface(new TaskingExtension());
		this.usePreemption = usePreemption;
	}
}
