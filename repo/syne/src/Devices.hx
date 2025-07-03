import lua.Table;
import lua.TableTools;
import haxe.DynamicAccess;
import filesystem.Filesystem.FileHandle;

enum FileMode {
    Read;
    Write;
}

typedef DeviceHandle = {
    read: (count: Int) -> String,
    readAll: () -> String,
    write: (data: String) -> Void,
    seek: (?whence: String, ?offset: Int) -> Void,
    isOpen: () -> Bool,
    close: () -> Void,
}


class PeripheralDevice extends Device {
    
    var data = "";  
    public function new(peripheralName: String) {
        var per = Hal.devc.get(peripheralName);
        if (per == null) throw "Invalid device.";
        this.dinterface = per;
        this.types = Table.toArray(TableTools.pack(Hal.devc.type(peripheralName)));
        this.name = peripheralName;

    }

    public function getHandle(mode: FileMode):DeviceHandle {
        throw "This device does not support file handles";
    }
}

abstract class Device {
    public var name = "";
    public var types: Array<String> = [];
    public var dinterface: Dynamic;
    abstract public function getHandle(f: FileMode): DeviceHandle;
}

class Devices {
    public var devices: Array<Device> = [];
    public var kernel: Kernel;
    public function add(dev: Device) {
        for (device in devices) {
            if(device.name == dev.name) {
                throw "Device already exists";
            }
        }
        this.devices.push(dev);
        Logger.log("Device added: " + dev.name, 1);
        for (task in kernel.scheduler.tasks) {
            task.taskQueue.push(["device_connected", dev.name]);
        }
    }
    public function remove(name: String) {
        this.devices = this.devices.filter(e -> e.name != name);
        Logger.log("Device removed: " + name, 1);
        for (task in kernel.scheduler.tasks) {
            task.taskQueue.push(["device_disconnected", name]);
        }
    }

    public function new(k: Kernel) {
        kernel = k;
    }
}