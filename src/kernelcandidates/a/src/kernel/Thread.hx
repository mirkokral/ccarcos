package kernel;

import haxe.exceptions.ArgumentException;
import haxe.xml.Access;
import lua.Debug;
import lua.Table;
import lua.Table.AnyTable;
import lua.TableTools;
import kernel.Hook;
import globals.Globals.Output;
import kernel.Driver.KeyboardDriver;
import kernel.Driver.FileSystemDriver;
import lua.Coroutine;

class KThread {
    public var pInfo = new KThreadInfo("",0, new Map<String, String>(), "KTrunner");
    public var pCoroutine: Coroutine<Dynamic>;
    public var pDI: DebugInfo = null;

    public function new(name: String, callback: () -> Void, cId: Int, pEnv: Map<String, String>, user: String) {
        this.pInfo = new KThreadInfo(name, cId, pEnv, user);
        this.pCoroutine = Coroutine.create(callback);
        untyped __lua__("
        self.pDI = debug.getinfo(callback)
        ");

    }
}
class KThreadInfo {
    public var name = "(empty)";
    public var creatorID = 0;
    public var ID: Int = 0;
    public var user: String = "";
    public var env: Map<String, String> = [];
    public function new(name: String, creatorID: Int, env: Map<String, String>, user: String) { 
        this.name = name;
        this.creatorID = creatorID;
        this.env = env;
        // Debug.getinfo();
    }
    public function copy() {
        var kti = new KThreadInfo(this.name + "", this.creatorID+0, this.env, this.user+"");
        kti.ID = this.ID+0;
        return kti;
    }
}

class KThreadRunner {
    public var tasks: Array<KThread> = [];
    private var hooks: Array<Hook> = [];
    public var current: KThread = new KThread("krnl.lua", () -> {}, 0, [], "KrnlRunner");
    public var ongoingQueueEvents: Array<Array<Dynamic>> = [];
    public function run() {
        Debug.sethook(() -> {
            var i = 0;
            var b = Debug.getinfo(1);
            while(b != null) {
                i++;
                b = Debug.getinfo(i);
                if(b != null) {

                    if(tasks.filter(e -> e.pDI.name == b.name).length == 1 ) {
                        var x: KThread = tasks.filter(e -> e.pDI.name == b.name)[0];
                        // trace(x.pInfo.name);
                    }
                }

            }
            }, "l");
        for (thread in tasks) {
            this.current = thread;
            Coroutine.resume(this.current.pCoroutine, "startup");
        }
        for (driver in Drivers.drivers) {
            driver.bg(["startup"]);
        }
        for (hook in hooks) {
            hook.bg(["startup"]);
        }
        while(true) {
            var amogus = ongoingQueueEvents.pop();
            if(amogus != null) {

                for (thread in tasks) {
                    this.current = thread;
                    Coroutine.resume(this.current.pCoroutine, TableTools.unpack(AnyTable.fromArray(amogus)));
                }
                for (driver in Drivers.drivers) {
                    driver.bg(amogus);
                }
                for (hook in hooks) {
                    hook.bg(amogus);
                }
            }
            
            amogus = Table.toArray(TableTools.pack(Coroutine.yield()));
            for (thread in tasks) {
                this.current = thread;
                Coroutine.resume(this.current.pCoroutine, TableTools.unpack(AnyTable.fromArray(amogus)));
            }
            for (driver in Drivers.drivers) {
                driver.bg(amogus);
            }
            for (hook in hooks) {
                hook.bg(amogus);
            }
        }
    }
    public function addThread(th: KThread) {
        var cp = th;
        for (thread in this.tasks) {
            if(cp.pDI.name == thread.pDI.name || cp.pInfo.name == thread.pInfo.name) {
                throw new ArgumentException("th", "Task name or pDI name shouldn't be the same. Maybe check your task naming and make sure to provide an inline function to createtask.");
            }
        }
        cp.pInfo.ID = tasks.length;
        tasks.insert(tasks.length, cp);
    }

    public function new(hooks: Array<Hook>) {this.hooks = hooks;};
}

class KThreadAPI {
    private static var te: KThreadRunner;
    public static var current(get, set): KThreadInfo;
    public static function get_current() {
        return te.current.pInfo.copy();
    }
    public static function set_current(v: KThreadInfo) {
        return te.current.pInfo.copy();

    }
    public static function create(name: String, callback: () -> Void) {
        te.addThread(new KThread(name, callback, current.ID, current.env, current.user));
    }

    public static function queue(event: Array<Dynamic>) {
        te.ongoingQueueEvents.insert(te.ongoingQueueEvents.length, event);
    }
        

    public static function getTasks() {
        var f: Array<KThreadInfo> = [];
        for (thread in te.tasks) {
            f.insert(f.length, thread.pInfo.copy());
        }
        return f;
    }

}


@:native("xg") class XG {
    @:native("fs") public static var fs: FileSystemDriver;
    @:native("api") public static var api: KThreadAPI;
    @:native("inp") public static var inp: KeyboardDriver;
    @:native("out") public static var out: Output;
}