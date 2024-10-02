import Devices.PeripheralDevice;
import lua.Lua;
import haxe.PosInfos;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import Hal;
import haxe.ds.Either;
import filesystem.Filesystem;
import scheduler.Scheduler;
import lua.Coroutine;
import lua.Debug;
import haxe.macro.Compiler;
import lua.TableTools;
import lua.Table;

class KernelConfig {
	public static var logLevel:Int = 0;
}

class Out {
	public static function write(...s:String) {
		var words = s.toArray().join(" ").split(" ");
		var comp = "";
		var terminal = (untyped __lua__("term")) ?? Hal.terminal;
		var cpos = {
			x: terminal.getCursorPos().x,
			y: terminal.getCursorPos().y
		}
		// Hal.terminal.write(s.toArray().join(" "));
		for (index => word in words) {
			if (cpos.x + word.length > terminal.getSize().x) {
				// var cursorPos = Hal.terminal.getCursorPos();
				// Hal.terminal.setCursorPos(1, cursorPos.y + 1);
				// if (Hal.terminal.getCursorPos().y > Hal.terminal.getSize().y) {
				// 	Hal.terminal.scroll(Hal.terminal.getCursorPos().y - Hal.terminal.getSize().y);
				// 	Hal.terminal.setCursorPos(1, Hal.terminal.getSize().y);
				// }
				comp += '\n';
				cpos.x = 1;
				cpos.y++;
			}
			for (char in word.split("")) {
				comp += char;
				cpos.x++;
			}
			if (index != words.length - 1) {
				comp += " ";
				cpos.x++;
			}
		}
		var pointer = 0;
		while (true) {
			var char = comp.charAt(pointer);
			if (char == "") {
				break;
			}
			if (char == "\n") {
				var cursorPos = terminal.getCursorPos();
				terminal.setCursorPos(1, cursorPos.y + 1);
				if (terminal.getCursorPos().y > terminal.getSize().y) {
					terminal.scroll(terminal.getCursorPos().y - terminal.getSize().y);
					terminal.setCursorPos(1, terminal.getSize().y);
				}
			} else if (char.charCodeAt(0) == 11) {
				pointer++;
				var command = comp.charAt(pointer);
				pointer++;
				var c2 = comp.charAt(pointer);
				var cn = switch (c2) {
					case "1": Hal.terminal.pMap.orange;
					case "2": Hal.terminal.pMap.magenta;
					case "3": Hal.terminal.pMap.lightBlue;
					case "4": Hal.terminal.pMap.yellow;
					case "5": Hal.terminal.pMap.lime;
					case "6": Hal.terminal.pMap.pink;
					case "8": Hal.terminal.pMap.lightGray;
					case "9": Hal.terminal.pMap.cyan;
					case "a": Hal.terminal.pMap.purple;
					case "b": Hal.terminal.pMap.blue;
					case "c": Hal.terminal.pMap.brown;
					case "d": Hal.terminal.pMap.green;
					case "f": Hal.terminal.pMap.black;
					case "e": Hal.terminal.pMap.red;
					case "0": Hal.terminal.pMap.white;
					case "7": Hal.terminal.pMap.gray;

					case _: Hal.terminal.pMap.white;
				}
				if (command == "b") {
					terminal.setBackgroundColor(cn);
				} else if(command == "f") {
					terminal.setTextColor(cn);
				}
			} else {
				terminal.write(char);
			}
			pointer++;
		}
	}

	public static function print(...s:String) {
		write(...s.append("\n"));
	}

	/**
	 * A drop-in rewrite for craftos's read function, but in haxe for the Syne kernel.
	 * @param sReplaceChar 
	 * @param tHistory 
	 * @param fnComplete 
	 * @param sDefault 
	 */
	public static function read(sReplaceChar:String, tHistory:Table<Int, String>, fnComplete:String->Table<Int, String>, sDefault:String = "") {
		var cursorPos = Hal.terminal.getCursorPos();
		var xCutoff = Hal.terminal.getSize().x - cursorPos.x - 1;
		var historyIndex = Table.toArray(tHistory).length;
		Hal.terminal.setCursorPos(cursorPos.x, cursorPos.y + 1);
		var s = sDefault;
		var scroll = 0;
		function redraw() {
			Hal.terminal.setCursorBlink(true);
			Hal.terminal.setCursorPos(cursorPos.x, cursorPos.y);
			Hal.terminal.write(s.substr(scroll, xCutoff));
		}
		while (true) {
			var event = TableTools.pack(Hal.pullEvent());
			if (event[0] == "key") {
				if (event[1] == Hal.terminal.kMap.up) {
					historyIndex--;
					if (historyIndex < 0) {
						historyIndex = 0;
					}
					s = Table.toArray(tHistory)[historyIndex];
					redraw();
				}
				if (event[1] == Hal.terminal.kMap.down) {
					historyIndex++;
					if (historyIndex >= Table.toArray(tHistory).length) {
						historyIndex = Table.toArray(tHistory).length - 1;
					}
					s = Table.toArray(tHistory)[historyIndex];
					redraw();
				}
			}
		}
	}
}

class WrappedFilesystem extends Filesystem {
	var cut = 0;
	var root:Filesystem;

	public function new(fsd:Filesystem, cut:Int) {
		this.cut = cut;
		this.root = fsd;
	}

	public function open(path:String, mode:String):FileHandle {
		return root.open(path.split("/").filter(x -> x != "").slice(cut).join("/"), mode);
	}

	public function list(path:String):Array<String> {
		return root.list(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function exists(path:String):Bool {
		return root.exists(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function attributes(path:String):Hal.FileAttributes {
		return root.attributes(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function mkDir(path:String):Void {
		return root.mkDir(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function move(source:String, destination:String):Void {
		return root.move(source.split("/").filter(x -> x != "").slice(cut).join("/"), destination.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function copy(source:String, destination:String):Void {
		return root.copy(source.split("/").filter(x -> x != "").slice(cut).join("/"), destination.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function remove(path:String):Void {
		return root.remove(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function getMountRoot(path:String):String {
		return root.getMountRoot(path.split("/").filter(x -> x != "").slice(cut).join("/"));
	}

	public function getPermissions(file:String, ?user:String):FilePermissions {
		return root.getPermissions(file.split("/").filter(x -> x != "").slice(cut).join("/"), user);
	}
}

class FSElem {
	public var path = "";
	public var fs:Filesystem;

	public function new(path:String, fs:Filesystem) {
		this.path = path;
		this.fs = fs;
	}
}

class KFSDriver extends Filesystem {
	public var mounts:Array<FSElem> = [];

	public function new() {}

	public function getDrive(dir:String) {
		var fp:Array<String> = dir.split("/").filter(x -> x != "");
		// Sort mounts by length of path, longest first
		mounts.sort((a, b) -> {
			return a.path.length - b.path.length;
		});
		for (mount in mounts) {
			var mountPath = mount.path.split("/").filter(x -> x != "");
			if (mountPath == fp.slice(0, mountPath.length)) {
				return new WrappedFilesystem(mount.fs, mountPath.length);
			}
		}
		for (mount in mounts) {
			var mountPath = mount.path.split("/").filter(x -> x != "");
			if (mountPath.length == 0) {
				return new WrappedFilesystem(mount.fs, 0);
			}
		}
		throw "No mount for path specified";
	}

	public function open(path:String, mode:String):FileHandle {
		return getDrive(path).open(path, mode);
	}

	public function list(path:String):Array<String> {
		return getDrive(path).list(path);
	}

	public function exists(path:String):Bool {
		return getDrive(path).exists(path);
	}

	public function attributes(path:String):Hal.FileAttributes {
		return getDrive(path).attributes(path);
	}

	public function mkDir(path:String):Void {
		return getDrive(path).mkDir(path);
	}

	public function move(source:String, destination:String):Void {
		return getDrive(source).move(source, destination);
	}

	public function copy(source:String, destination:String):Void {
		return getDrive(source).copy(source, destination);
	}

	public function remove(path:String):Void {
		return getDrive(path).remove(path);
	}

	public function getMountRoot(path:String):String {
		return getDrive(path).getMountRoot(path);
	}

	public function getPermissions(file:String, ?user:String):FilePermissions {
		return getDrive(file).getPermissions(file, user);
	}
}

class HalFSDriver extends Filesystem {
	public function new() {};

	public function open(path:String, mode:String):FileHandle {
		var fH = Hal.files.open(path, mode);
		var isopen = true;
		if (fH.fHandle == null) {
			throw fH.error;
		}
		var fileh = new FileHandle();
		fileh.close = () -> {
			isopen = false;
			fH.fHandle.close();
		}
		fileh.flush = () -> {
			fH.fHandle.flush();
		}
		fileh.read = () -> {
			return fH.fHandle.readAll();
		}
		fileh.write = (data) -> {
			fH.fHandle.write(data);
		}
		fileh.seek = (?whence, ?offset) -> {
			fH.fHandle.seek(whence, offset);
		}
		fileh.readLine = () -> {
			return fH.fHandle.readLine();
		}
		fileh.readBytes = (count) -> {
			return fH.fHandle.read(count);
		}
		fileh.writeLine = (data) -> {
			fH.fHandle.writeLine(data);
		}
		fileh.getIfOpen = () -> {
			return isopen;
		}
		return fileh;
	}

	public function list(path:String):Array<String> {
		return Table.toArray(Hal.files.list(path));
	}

	public function exists(path:String):Bool {
		return Hal.files.exists(path);
	}

	public function attributes(path:String):Hal.FileAttributes {
		return Hal.files.attributes(path);
	}

	public function mkDir(path:String) {
		Hal.files.mkDir(path);
	}

	public function move(source:String, destination:String) {
		Hal.files.copy(source, destination);
		Hal.files.unlink(source);
	}

	public function copy(source:String, destination:String) {
		Hal.files.copy(source, destination);
	}

	public function remove(path:String) {
		Hal.files.unlink(path);
	}

	public function getMountRoot(path:String):String {
		return "";
	}

	public function getPermissions(file:String, ?user:String):FilePermissions {
		return Hal.files.getPermissions(file, user);
	}
}

class Kernel {
	public var scheduler:Scheduler;
	public var userManager:UserManager;
	public var rootFs:KFSDriver;
	public var running:Bool = true;
	public var dm: Devices;

	public function panic(err:String, file:String, line:Int, ?stack:CallStack, ?pi:PosInfos) {
		Logger.log("... Kernel panic ...", 0, false, false);
		Logger.log("Error: " + err, 0, false, false);
		if (pi != null) {
			Logger.log("This happened inside the kernel.", 0, false, false);
			Logger.log("File: " + pi.fileName, 0, false, false);
			Logger.log("Line: " + pi.lineNumber, 0, false, false);
		} else {
			Logger.log("File: " + file, 0, false, false);
			if (stack != null) {
				Logger.log("Stack:", 0, false, false);
				for (item in stack.toString().split("\n")) {
					if (StringTools.replace(item, " ", "") != "") {
						Logger.log(item, 0, false, false);
					}
				}
			} else {
				Logger.log("Line: " + line, 0, false, false);
			}
		}
		Logger.log("", 0, false, false);
		Logger.log("... End kernel panic ...", 0, false, false);
		if (this.scheduler != null) {
			this.scheduler.tasks = [];
		}
		running = false;
	}

	public function run() {
		var usePreemption = true;
		Compiler.includeFile("package.lua");
		// untyped __lua__("debug.sethook = null");
		Hal.terminal.clear();
		Hal.terminal.setCursorPos(1, 1);
		Logger.log("Syne " + Compiler.getDefine("syneversion"), 1);
		if (Debug == null || Debug.sethook == null || false) {
			Logger.log("Platform doesn't support pre-emption, disabing.", 1);
			usePreemption = false;
		} else {
			Logger.log("Using preemption", 1);
			usePreemption = true;
		}
		Logger.log("Creating filesystem", 1);
		this.rootFs = new KFSDriver();
		this.rootFs.mounts.push(new FSElem("", new HalFSDriver()));
		Logger.log("Loading users", 1);
		this.userManager = new UserManager(this);
		this.userManager.load();
		Logger.log("Creating scheduler", 1);
		this.scheduler = new Scheduler(usePreemption, this);
		// scheduler.addTask("A", function() {
		// 	while(true) {
		// 		// Coroutine.yield("syscall", "log", "A", 0);
		// 	}
		// });
		Logger.log("Managing devices", 1);
		this.dm = new Devices(this);
		for (s in Table.toArray(Hal.devc.list())) {
			dm.add(new PeripheralDevice(s));
		}
		scheduler.tasks[scheduler.addTask("B", function() {
			try {
				untyped __lua__('
					local env = {}
					local path = "/apps/init.lua"
					local compEnv = {}
					for k, v in pairs(_G) do
						compEnv[k] = v
					end
					for k, v in pairs(env) do
						compEnv[k] = v
					end
					compEnv["apiUtils"] = nil
					compEnv["KDriversImpl"] = nil
					compEnv["xnarcos"] = nil
					compEnv["_G"] = nil
					compEnv["write"] = Out.write
					compEnv["print"] = Out.print
					compEnv.tasking = require("tasking")
					compEnv.arcos = require("arcos")
					compEnv.devices = require("devices")
					compEnv.sleep = compEnv.arcos.sleep

					setmetatable(compEnv, {
						__index = function(t, k)
							if k == "_G" then
								return compEnv
							end
						end,
					})
					local f, e = KDriversImpl.files.open(path, "r")
					if not f then print(e) return end
					local compFunc, err = load(f.readAll(), path, nil, compEnv)
					f.close()
					if compFunc == nil then
						error(err)
					else
						setfenv(compFunc, compEnv)
						local ok, err = pcall(compFunc)
						print(err)
					end');
			} catch (e) {
				trace(e);
			}
		})].pInfo.out = Hal.terminal;
		untyped __lua__(
			"
			_G.write = Out.write
			_G.print = Out.print
			"
		);
		while (running) {
			scheduler.tick();
		}
		while (true) {
			Coroutine.yield();
		}
	}

	public function new() {};
}
