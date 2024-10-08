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

	/**
	 * All the task's parents
	 * This is mainly used to let tasks with children that are another user be able to modify and kill their children.
	 * The last task in the array is the task's creator.
	 * This is an array of pids.
	 */
	public var parents: Array<Int> = [];

	public function new(name:String, id:Int, env:Map<String, String>, user:String, out:Dynamic, parents: Array<Int>) {
		this.name = name;
		this.id = id;
		this.env = env;
		this.user = user;
		this.paused = false;
		this.nice = 0;
		this.out = out;
		this.parents = parents;
	}

	public function copy() {
		var ti = new TaskInfo(this.name, this.id, this.env, this.user, this.out, this.parents);
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
			return new TaskInfo("Kernel", -1, [], "root", Hal.terminal, []);
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
					if (Hal.computer.uptime() - tasks[pid].lastPreempt > 0.1) { // Momentary jiffy value
						Coroutine.yield("preempt");
						tasks[pid].lastPreempt = Hal.computer.uptime();
					}
				}, "l");
			}
			try {
				callback();
			} catch(e) {
				trace(e);
				var id = Hal.timers.start(5);
				while(true) {
					var ev: Array<Dynamic> = Table.toArray(TableTools.pack(Coroutine.yield()));
					if(ev[0] == "timer" && ev[1] == id) {
						break;
					}
				}
			}
		});
		tasks[pid].taskQueue = [];
		tasks[pid].pInfo = new TaskInfo(name, pid, env, user, out, getCurrentTask().parents.concat([getCurrentTask().id]));
		tasks[pid].lastPreempt = Hal.computer.uptime();
		return pid;
	}

	public function killTask(pid:Int) {
		tasks.remove(tasks[pid]);
	}

	public function fixEvent(ev: Array<Dynamic>, termoffsetx: Int, termoffsety: Int, ?monitor: String): Array<Array<Dynamic>> {
		if(monitor != null) {
			if(ev[0] == "monitor_touch" && ev[1] == monitor) {
				return [
					[
						"mouse_click",
						1,
						ev[2] + termoffsetx,
						ev[3] + termoffsety,
					],
					[
						"mouse_up",
						1,
						ev[2] + termoffsetx,
						ev[3] + termoffsety,
					]
				];
			}
			if(ev[0] == "monitor_resize" && ev[1] == monitor) {
				return [[
					"term_resize"
				]];
			}
			if(["term_resize", "mouse_click", "mouse_up", "mouse_drag", "mouse_scroll"].contains(ev[0])) {
				Logger.log("Cancelling event: " + ev[0], 0);
				return [];
			}
		} else {
			if(ev[0] == "mouse_click") {
				return [[
					"mouse_click",
					ev[1],
					ev[2] + termoffsetx,
					ev[3] + termoffsety,
				]];
			}
			if(ev[0] == "mouse_drag") {
				return [[
					"mouse_drag",
					ev[1],
					ev[2] + termoffsetx,
					ev[3] + termoffsety,
				]];
			}
			if(ev[0] == "mouse_scroll") {
				return [[
					"mouse_scroll",
					ev[1],
					ev[2] + termoffsetx,
					ev[3] + termoffsety,
				]];
			}
			if(ev[0] == "mouse_up") {
				return [[
					"mouse_up",
					ev[1],
					ev[2] + termoffsetx,
					ev[3] + termoffsety,
				]];
			}
		}
		return [ev];
	}

	var ctrlPressed = false;

	private function handleEvent(ev: Array<Dynamic>) {
		if(ev[0] == "peripheral") {
			kernel.dm.add(new PeripheralDevice(ev[1]));
		}
		if(ev[0] == "key" && ev[1] == Hal.terminal.kMap.leftCtrl) {
			ctrlPressed = true;
		}
		if(ev[0] == "key" && ev[1] == Hal.terminal.kMap.rightCtrl) {
			ctrlPressed = true;
		}
		if(ev[0] == "key_up" && ev[1] == Hal.terminal.kMap.leftCtrl) {
			ctrlPressed = false;
		}
		if(ev[0] == "key_up" && ev[1] == Hal.terminal.kMap.rightCtrl) {
			ctrlPressed = false;
		}
		if(ev[0] == "peripheral_detach") {
			kernel.dm.remove(ev[1]);
		}	
		if((ctrlPressed && ev[0] == "key" && ev[1] == Hal.terminal.kMap.c) || ev[0] == "terminate") {
			tasks[0].taskQueue.push(["terminate", "root"]);
		} else {
			for (task in tasks) {
				task.taskQueue = task.taskQueue.concat(fixEvent(ev, task.pInfo.out.offsetx ?? 0, task.pInfo.out.offsety ?? 0, task.pInfo.out.name));
			}
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
		if (tasks[0] == null) {
			this.kernel.panic("Init died", "Scheduler", 0);
		}
		var n = false;
		for (task in tasks) {
			if (resumeTask(task)) {
				n = true;
			}
		}		
		var tasksToDelete: Array<Int> = [];
		
		for (task in tasks) {
			if(Coroutine.status(task.coroutine) == CoroutineState.Dead) {
				tasksToDelete.push(task.pInfo.id);
			}
		}

		for (id in tasksToDelete) {
			tasks.remove(tasks[id]);
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
