package kernel.hooks;

import lua.Table.AnyTable;
import Externs;
import globals.Globals;
import kernel.Driver;


class MonitorTerminalBackend extends Output {
    @:native("peripheral") var peripheral: Dynamic;
    public function write(s: String) {
        for (i in 0...s.length) {
            if (s.charAt(i) == "\n") {
                untyped __lua__("local x, y = self.peripheral.getCursorPos() self.peripheral.setCursorPos(1, y);");
                this.setCursorPosRelative(0, 1);
            } else {
                untyped __lua__("self.peripheral.write(_G.string.sub(s, i + 1, i + 1));");
            }
        }
    }
    public function clear() {
        untyped __lua__("self.peripheral.clear()");
    }
    public function setFGColor(col: Color) {
        untyped __lua__("self.peripheral.setTextColor(col.bitASC)");
    }
    public function setBGColor(col: Color) {
        untyped __lua__("self.peripheral.setBackgroundColor(col.bitASC)");
    }
    public function setCursorPos(x: Int, y: Int) {
        untyped __lua__("self.peripheral.setCursorPos(x, y)");
    }
    public function getCursorPos(): Vector2i {
        untyped __lua__("local shmegmaels = self.peripheral.getCursorPos()");
        return Vector2i.fromCPos(untyped shmegmaels);
    }
    public function setCursorPosRelative(x: Int, y: Int) {
        var o = getCursorPos();
        o.x += x;
        o.y += y;
        untyped __lua__("
            self.peripheral.setCursorPos(o.x, o.y);
            if (o.y > self.peripheral.getSize().y) then 
                self.peripheral.scroll(((o.y - self.peripheral.getSize().y) - 2) * -1);
                self.peripheral.setCursorPos(o.x, self.peripheral.getSize().y);
            end;
        ");
    }
    public function get_size(): Vector2i {
        untyped __lua__("local shmegmaels = self.peripheral.getSize()");
        return Vector2i.fromCPos(untyped shmegmaels);
    }
    public function set_palette(newc: Array<RGBColor>): Array<RGBColor> {
        var i = 0;
        for (color in newc) {
            this.apalette[i-1] = color;
            // Sys.println(Math.pow(2, i));
            untyped __lua__("
                self.peripheral.setPaletteColor(Std.int(Math.max(_G.math.pow(2, i), 1)), color.red / 255.0, color.green / 255.0, color.blue / 255.0);
            ");
            i++;
        };
        return this.apalette;
    }

    public function new(monName: String) {
        // super();
        this.peripheral = Peripherals.wrap(monName);
        set_palette(this.palette);
        }
    }

class MonitorOutputDriver extends TerminalDriver {
    var output: Output;
    public function new(monName: String) {
        super();
        this.output = new MonitorTerminalBackend(monName);
        this.deviceName = monName;
    }
    public function write(s: String): Void {
        return output.write(s);
    };
    public function clear(): Void {
        return output.clear();
    };
    public function setFGColor(col: Color): Void {
        return output.setFGColor(col);
    };
    public function setBGColor(col: Color): Void {
        return output.setBGColor(col);
    };
    public function set_palette(newc: Array<RGBColor>): Array<RGBColor> {
        return output.set_palette(newc);
    }; 
    public function getCursorPos(): Vector2i {
        return output.getCursorPos();
    };
    public function setCursorPos(x: Int, y: Int): Void {
        return output.setCursorPos(x, y);
    };
    public function setCursorPosRelative(x: Int, y: Int): Void {
        return output.setCursorPosRelative(x, y);
    };
    public function get_size(): Vector2i {
        return output.get_size();
    };


    public function init() {}

    public function deinit() {}

    public function bg(ev: Array<Dynamic>) {}

    public function dataread():String {
        return "";
    }

	public function datawrite(s:String) {
        write(s);
    }
}

class CCMonitorDriverHook extends Hook {
    private var mons: Array<String> = [];    

    public function init() {
        for (s in AnyTable.toArray(Peripherals.getNames())) {
            if(Peripherals.getType(s) == "monitor") {
                addMonitior(cast(s, String));
            }
        }
    }

    public function deinit() {}

    public function bg(ev:Array<Dynamic>) {
        if(ev[0] == "peripheral") {
            if(Peripherals.getType(ev[1]) == "monitor") {
                addMonitior(cast(ev[1], String));
            }
        } else if(ev[0] == "peripheral_detach") {
            if(mons.contains(ev[1])) {
                remMonitior(cast(ev[1], String));
            }
        }
    }

    private function addMonitior(s:String) {
        mons.insert(mons.length, s);
        Drivers.add(new MonitorOutputDriver(s));
    }
    private function remMonitior(s:String) {
        mons.remove(s);
        Drivers.rem(s);
    }
}