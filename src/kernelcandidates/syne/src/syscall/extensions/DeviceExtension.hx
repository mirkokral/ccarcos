package syscall.extensions;

import haxe.DynamicAccess;
import lua.Table;
import filesystem.Filesystem.FileHandle;
import Devices;

abstract class ExampleDevice extends Device {
    
    var data = "";  
    public function new() {
        this.name = "exampledevice";
        this.types = ["example", "virtual"];
    }

    public function getHandle(mode: FileMode):DeviceHandle {
        var fho = true;
        var pos = 0;
        return {
            read: (count:Int) -> {
                return data.substr(pos, count);
            },
            readAll: () -> {
                return data;
            },
            write: (data:String) -> {
                this.data = data;
            },
            seek: (?whence:String, ?offset:Int) -> {
                if(whence == "set") {
                    pos = offset;
                } else if(whence == "cur") {
                    pos += offset;
                } else if(whence == "end") {
                    pos = data.length - offset;
                }
            },
            isOpen: () -> {
                return fho;
            },
            close: () -> {
                fho = false;
            }
        };
    }
}
function craftifyDevice(d: Device): Dynamic {
    var n = {
        name: d.name,
        types: Table.fromArray(d.types),
        sendData: (data: String) -> {
            var h = d.getHandle(FileMode.Write);
            h.write(data);
            h.close();
        },
        recvData: () -> {
            var h = d.getHandle(FileMode.Read);
            var data = h.readAll();
            h.close();
            return data;
        },
        onEvent: () -> {},
        onActivate: () -> {},
        onDeactivate: () -> {},
    };
    for(k in Reflect.fields(d.dinterface)) {
        Reflect.setProperty(n, k, Reflect.getProperty(d.dinterface, k));
    }
    return n;
}

class DeviceExtension extends SyscallExtension {
    public function getSyscalls(kernel:Kernel):Array<Syscall> {
        // trace(device.)
        return [
            new Syscall("devices.names", function(...d:Dynamic) {
                return kernel.dm.devices.map(e -> e.name);
            }),
            new Syscall("devices.find", function(...d:Dynamic) {
                return kernel.dm.devices.filter(e -> e.types.contains(d[0])).map(e -> craftifyDevice(e));
            }),
            new Syscall("devices.get", function(...d:Dynamic) {
                return kernel.dm.devices.filter(n -> n.name == d[0]).map(e -> craftifyDevice(e));
            })
        ];
    }
}