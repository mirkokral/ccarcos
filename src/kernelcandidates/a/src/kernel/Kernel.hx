package kernel;

import haxe.macro.Compiler;
import Externs.APS;
import kernel.Drivers;
import lua.Coroutine;
import kernel.hooks.CCMonitorDriverHook;
import haxe.extern.EitherType;
import haxe.Constraints.Function;
import lua.Table.AnyTable;
import haxe.PosInfos;
import lua.Lua;
import haxe.Exception;
import globals.FilePath;
import kernel.hooks.CCFSDriverHook;
import kernel.Driver;
import kernel.Thread;
import kernel.hooks.CCTermHook;

private class KFSMount {
	public var filePath: FilePath;
	public var fsd: FileSystemDriver;
	public function new(fp: FilePath, s: FileSystemDriver) {
		this.filePath = fp;
		this.fsd = s;
	}
}

private class MountNotFoundException extends Exception {}

private class KFSDriver extends FileSystemDriver {
	private var mounts: Array<KFSMount> = [];
	
	public function new(upfs:FileSystemDriver) {
		super();
		this.mounts.push(new KFSMount(new FilePath(""), upfs));
	}

	private function getFS(path: FilePath): FileSystemDriver {
		this.mounts.sort((a, b) -> {
			return a.filePath.path.length - b.filePath.path.length;	
		});
		this.mounts.reverse();
		for (mount in this.mounts) {
			
			if(path.path.slice(0, mount.filePath.path.length-1) == mount.filePath.path) {
				return mount.fsd;
			}	
		}
		for (mount in this.mounts) {
			if(mount.filePath.path.length == 0) {
				return mount.fsd;
			}
		}
		throw new MountNotFoundException("No mount at that path. This shouldn't happen if a filesystem is mounted at '/'.");
	}

	private function getFSS(path: String): FileSystemDriver {
		return getFS(new FilePath(path));
	}

	public function init() {}

	public function deinit() {}

	public function bg(ev:Array<Dynamic>) {}

	public function read(path:String):String {
		var fp = new FilePath(path);
		return getFS(fp).read(path);
		
	}

	public function readBytes(path:String, bytes:Int, fromPos:Int = 0):Array<Int> {
		return getFS(new FilePath(path)).readBytes(path, bytes, fromPos);
	}

	public function write(path:String, text:String) {
		var fp = new FilePath(path);
		return getFS(fp).write(path, text);
	}

	public function writeByte(path:String, byte:Int) {
		return getFSS(path).writeByte(path, byte);
	}

	public function append(path:String, text:String) {
		var fp = new FilePath(path);
		getFS(fp).append(path, text);
	}

	public function exists(path:String):Bool {
		var fp = new FilePath(path);
		return getFS(fp).exists(path);
	}

	public function isReadOnly(path:String, user:String = ""):Bool {
		var fp = new FilePath(path);
		return getFS(fp).isReadOnly(path, user);
	}

	public function list(dir:String):Array<String> {
		var fp = new FilePath(dir);
		var out = getFS(fp).list(dir);
		for (mount in mounts) {
			if(mount.filePath.path.slice(0, mount.filePath.path.length-2) == fp.path) {
				out.push(mount.filePath.path[mount.filePath.path.length-1]);
			}
		}
		return out;
	}

	public function type(path:String):FileType {
		var fp = new FilePath(path);
		return getFS(fp).type(path);
	}

	public function dataread():String {
		return "";
	}

	public function datawrite(s:String) {}
}

@:native("XGos") class OS {
	public static function run(env:Map<String, Dynamic>, path:String, ...args: Dynamic):Void {
		@:native("XPath") var XPath = path;
		@:native("MadeEnvironment") var MadeEnvironment:AnyTable = AnyTable.create();
		untyped __lua__('
            for i,v in pairs(_G) do
                MadeEnvironment[i] = v
            end
            MadeEnvironment["package"] = {loaded=setmetatable({}, {__index = function(s, f) return true end})};
            
        ');
		var m:Map<Dynamic, Dynamic> = AnyTable.toMap(MadeEnvironment);
		m["fs"] = null;
		m["xg"] = XG;
		m["drv"] = Drivers;
		m["k"] = Kernel;
		m["log"] = Logger;
		m["os"] = OS;
		m["setmetatable"] = Lua.setmetatable;
		var ajtr: AnyTable = null; // It WILL be created down below.
		untyped __lua__("
		if environ then ajtr = environ else ajtr = {} end
		");
		var xeenv = env;
		for(k => v in AnyTable.toMap(ajtr)) { 
			xeenv[k] = v;
		}
		m["environ"] =  AnyTable.fromMap(xeenv);
		
		m["print"] = function(p1:Dynamic):Int {
			var toprint:Array<String> = [];
			var vtoprint:Array<String> = [];
			var lout = 0;
			for (it in [p1]) {
				toprint = toprint.concat(Std.string(it).split(" "));
			}
			var vb = "";
			for (s in toprint) {
				for (i in 0...s.length) {
					var char = s.charAt(i);
					if (char == "\n") {
						vtoprint.insert(vtoprint.length, vb);
						vb = "";
					} else {
						vb += char;
					}
				}
				vb += " ";
			}
			vb = vb.substr(0, vb.length - 2);
			for (s in vtoprint) {
				for (sv in s.split(" ")) {
					if (s.length > (XG.out.size.x - XG.out.getCursorPos().x)) {
						XG.out.print("\n");
						lout++;
					}
					XG.out.print(s);
				}
				XG.out.print("\n");
				lout++;
			}
			return lout;
		}

		@:native("EnvTable") var EnvTable = AnyTable.create();
		for (key => value in m) {
			untyped __lua__('
            EnvTable[key] = value
            ');
		}
		@:native("Readed") var Readed = XG.fs.read(path);
		@:native("Loaded") var Loaded:(...args: Dynamic) -> Void = null;
		@:native("error") var error:String = "";
		untyped __lua__('
            EnvTable["_G"] = EnvTable
            Loaded, error = load(Readed, XPath, nil, EnvTable)
        ');
		if (Loaded == null) {
			XG.out.write(error);
			XG.out.write("\n");
		} else {
			try {
				Loaded(...args);
			} catch (e:String) {
				XG.out.write(e);
				XG.out.write("\n");
			}
		}
	}
}

class Kernel {
	private static var threadRunner:KThreadRunner;

	public static function panic(reason, ?posinfo:PosInfos) {
		var kp = "";
		kp += ("--- BEGIN XENOS KERNEL PANIC ---\n");
		kp += ('Reason: $reason\n');
		if(posinfo != null) {
			kp += ('Position: ${posinfo.fileName}:${posinfo.lineNumber}\n');
		} else {
			kp += ('No position information, probably from lua file.\n');
		}
		if(Drivers.getDriverByProvides(DriverProvides.Http) == null) {
			kp += ('No HTTP - Data not uploaded.\n');
		} else {
			kp += ('This version doesn\'t have telemetry.');
		}
		if (XG.api != null) {
			kp += ('---     TASK INFORMATION     ---\n');
			kp += ('Running task count: ' + XG.api.getTasks().length + "\n");
			kp += ('Current task name : ' + XG.api.current.name + "\n");
		}
		kp +=		 ("---  END XENOS KERNEL PANIC  ---");	
		try {
			if (XG.out != null) {
				XG.out.print(kp);
			} else {
				Sys.print(kp);
			}
		} catch(e) {
			Sys.print(kp);

		}
		if (Kernel.threadRunner != null) {
			Kernel.threadRunner.tasks = [];
		}
		while(true) {
			Coroutine.yield();
		}
	}

	public static function main() {
        Compiler.includeFile("includes/argp.lua");
		if(Kernel.threadRunner != null) Kernel.panic("Kernel ran in invalid state.");
		untyped __lua__("
		if k then
			k.panic(\"Kernel ran in invalid state\")
		end
		");
		var hooks = [
			// In case of additional hooks, add here
			new CCTermHook(),
			new CCFSDriverHook(),
			new CCMonitorDriverHook(),
		];
		for (hook in hooks) {
			Logger.log("Starting hook: " + Type.getClassName(Type.getClass(hook)));
			hook.init();
			Logger.log("Finished hook: " + Type.getClassName(Type.getClass(hook)));
		}
		var t:TerminalDriver = cast(Drivers.getDriverByProvides(DriverProvides.Terminal), TerminalDriver);
		var mouse:MouseDriver = cast(Drivers.getDriverByProvides(DriverProvides.Mouse), MouseDriver);
		var kb:KeyboardDriver = cast(Drivers.getDriverByProvides(DriverProvides.Keyboard), KeyboardDriver);
		var fs:FileSystemDriver = cast(Drivers.getDriverByName("hdd"), FileSystemDriver);
		if (t == null)
			Kernel.panic("No terminal found");
		if (kb == null)
			Kernel.panic("No keyboard found");
		if (fs == null)
			Kernel.panic("No filesystem found");
		Kernel.threadRunner = new KThreadRunner(hooks);
		t.clear();
		t.setCursorPos(1, 1);
		var kfs = new KFSDriver(fs);
		var kapi = new KThreadAPI(threadRunner);
		XG.fs = kfs;
		XG.api = kapi;
		XG.inp = kb;
		XG.out = t.asOutput();
		Logger.log("Stage 2...");
		OS.run([], "/system/s2.lua", ...AnyTable.toArray(APS.args));
		Logger.log("Starting task scheduler.");
		threadRunner.run();
	}
}
