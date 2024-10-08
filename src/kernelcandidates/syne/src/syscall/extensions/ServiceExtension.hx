package syscall.extensions;

import haxe.iterators.StringIterator;
import lua.TableTools;
import scheduler.Scheduler.TaskInfo;
import haxe.Constraints.Function;
import lua.Table;

class Service {
    public var name: String = "";
    public var callbacks: Map<String, (...d: Dynamic) -> Array<Dynamic>> = null;
    public var owner: TaskInfo;
    public function new(name: String, callbacks: Map<String, (...d: Dynamic) -> Array<Dynamic>>, owner: TaskInfo) {
        this.name = name;
        this.callbacks = callbacks;
    }
}

class ServiceExtension extends SyscallExtension {

    public var services: Array<Service> = [];

    public function getSyscalls(kernel:Kernel):Array<Syscall> {
        return [
            new Syscall("service.registerService", function(...d: Dynamic) {
                if(!Std.isOfType(d[0], String))
                    throw "Name must be string";
                if(!Std.isOfType(d[1], Table))
                    throw "Callbacks must be a table of {string: function}";

                var name = d[0];
                var callbacks = d[1];
                var service = new Service(cast(name, String), Table.toMap(cast(callbacks, Table<Dynamic, Dynamic>)), kernel.scheduler.getCurrentTask());
                services.push(service);
                return [];
            }),
            new Syscall("service.callService", function(...d: Dynamic) {
                if(!Std.isOfType(d[0], String))
                    throw "Name must be string";
                if(!Std.isOfType(d[1], String))
                    throw "Callback must be string";

                var name = d[0];
                var callback = d[1];

                var service = services[name];

                if(service == null) {
                    throw "Service not found";
                }

                if(service.callbacks[callback] == null) {
                    throw "Callback not found";
                }

                return Table.toArray(TableTools.pack(service.callbacks[callback](...d.toArray().slice(2))));
            }),
            new Syscall("service.getServices", function(...d: Dynamic) {
                return [services.map(e -> e.name)];
            }),
            new Syscall("service.getCallbacks", function(...d: Dynamic) {
                if(!Std.isOfType(d[0], String))
                    throw "Name must be string";

                var name = d[0];

                for (service in services) {
                    if(service.name == name) {
                        var n = [];
                        var o = service.callbacks.keys();
                        for (k in o) {
                            n.push(k);
                        }

                        return [n];
                    }
                }
                throw "No such service.";
            })
        ];
    }
}