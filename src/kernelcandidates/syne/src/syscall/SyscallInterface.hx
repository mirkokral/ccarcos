package syscall;

import lua.TableTools;
import lua.Table;

function enluaify(d: Dynamic): Dynamic {
    if(Std.isOfType(d, Array)) {
        var c = cast(d, Array<Dynamic>);
        var o: Array<Dynamic> = [];
        for (index => value in c) {
            o[index] = enluaify(value);
        }
        return Table.fromArray(o);
    } else if (Std.isOfType(d, Table)) {
        var o: Table<Dynamic, Dynamic> = Table.create();
        for(k => v in Table.toMap(cast(d, Table<Dynamic, Dynamic>))) {
            o[k] = enluaify(v);
        }
        return o;
    } else {
        return d;
    }
}

class SyscallInterface {
    public var syscalls: Array<Syscall> = [];
    public var kernel: Kernel;
    public function new(k: Kernel) {
        this.kernel = k;
    }

    public function addSyscall(syscall: Syscall) {
        this.syscalls.push(syscall);
    }
    public function addSyscallInterface(syscallExt: SyscallExtension) {
        this.syscalls = this.syscalls.concat(syscallExt.getSyscalls(this.kernel));
    }
    public function executeSyscall(name: String, ...d: Dynamic): Table<Dynamic, Dynamic> {
        for(syscall in this.syscalls) {
            if(syscall.name == name) {
                var o: Array<Dynamic>; 
                try {
                    o = syscall.callback(...d);
                } catch(e: Dynamic) {
                    o = [{
                        "xType": "errorobject",
                        "xN": untyped __lua__("0xfa115afe"),
                        "xValue": e,
                    }];
                }
                return enluaify(o);
            }
        }
        return enluaify([{
            "xType": "errorobject",
            "xN": untyped __lua__("0xfa115afe"),
            "xValue": "No such syscall: " + name
        }]);
    }
}