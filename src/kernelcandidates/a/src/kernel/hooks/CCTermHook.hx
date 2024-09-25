package kernel.hooks;

import kernel.Driver.DriverProvides;
import kernel.Driver.KeyboardDriver;
import lua.Coroutine;
import kernel.Driver.MouseEventType;
import kernel.Driver.MouseEvent;
import kernel.Driver.MouseDriver;
import drivers.terminal.Auto;
import globals.Globals;
import kernel.Driver.TerminalDriver;
import Externs;

// This hook exposes the internal computercraft terminal as an output driver

class OutputDriver extends TerminalDriver {
    var output: Output = new Terminal();
    public function new(output: Output, name: String) {
        super();
        this.output = output;
        this.deviceName = name;
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

@:multiReturn extern class MouseEventYReturn {
    var eventName: String;
    var mouseButton: Int;
    var x: Float;
    var y: Float;
}

class CCMouseDriver extends MouseDriver {
    
    public function init() {}

	public function deinit() {}

	public function bg(ev: Array<Dynamic>) {}

	public function getEvent(filter:Null<MouseEventType>):MouseEvent {
		while(true) {
            var e: MouseEventYReturn = Coroutine.yield();
            if(e.eventName.substring(0, 4) == "mouse") {
                var met = MouseEventType.Click;
                switch(e.eventName.substring(6)) {
                    case "click": met = MouseEventType.Click; break;
                    case "up": met = MouseEventType.ClickUp; break;
                    case "drag": met = MouseEventType.Drag; break;
                    case "scroll": met = MouseEventType.Scroll; break;
                }
                return new MouseEvent(met, e.x, e.y, e.mouseButton);
            }

        }
        return new MouseEvent(MouseEventType.Click, 1, 1, 1); // It won't compile without this, but it is useless.
	}

    public function new() {
        super();
        this.deviceName = "consolemouse";
    }   

    public function dataread():String {
        var e = getEvent(null);
        return '${e.x},${e.y},${e.button},${e.type}';
    }

	public function datawrite(s:String) {}
}
class CCKeyboardDriver extends KeyboardDriver {

    public function new() {
        super();
        this.deviceName = "consolekeyboard";
    }

    public function init() {}

	public function deinit() {}

	public function bg(ev: Array<Dynamic>) {}

	public function readInt(timeout: Float=-1):Int {
        var tId = -1;
        if(timeout > 0) {
            tId = OS.startTimer(timeout);
        }
        while(true) {
            var e: KeyEventReturn = Coroutine.yield();
            switch(e.name) {
                case "timer":
                    if(e.key == tId) return -1;
                    break;
                case "key":
                    return e.key;
                    break;
            }
        }
        return -1;
	}

	public function readChar(timeout:Float=-1):String {
        var tId = -1;
        if(timeout > 0) {
            tId = OS.startTimer(timeout);
        }
        while(true) {
            var e: KeyEventReturn = Coroutine.yield();
            switch(e.name) {
                case "timer":
                    if(e.key == tId) return "";
                    break;
                case "char":
                    return cast(e.key, String);
                    break;
            }
        }
        return "";
	}

	public function readChars(num:Int, timeout:Float=-1, echo:String="/", ?echoOutput: Output, showCursor: Bool = false):String {
        Sys.sleep(0.1);
        var ch = "";
        var tId = -1;
        var ocp = new Vector2i(1, 1);
        if(echoOutput != null) echoOutput.write(ch + (showCursor ? "_" : ""));
        if(echoOutput != null) {
            ocp = echoOutput.getCursorPos();
        }
        if(timeout > 0) {
            tId = OS.startTimer(timeout);
        }
        while(ch.length < num) {
            var e: KeyEventReturn = Coroutine.yield();
            switch(e.name) {
                case "timer":
                    if(e.key == tId) return "";
                    break;
                case "char":
                    ch += cast (e.key, String);
                    if(echoOutput != null) {
                        if(echo == "/") {
                            echoOutput.setCursorPos(ocp.x, ocp.y);
                            echoOutput.write(ch + (showCursor ? "_" : ""));
                        }
                    }
                    break;
                case "key":
                    if(e.key == 259) {
                        ch = ch.substr(0, ch.length-1);
                        if(echoOutput != null) echoOutput.setCursorPos(ocp.x, ocp.y);
                        if(echoOutput != null) echoOutput.write(ch + (showCursor ? "_" : "") + " ");
                    }
            }
        }
        return ch;
	}


    public function dataread():String {
        return readChar();
    }

	public function datawrite(s:String) {
    }
}

class CCTermHook extends Hook {
    public function init() {
        Drivers.add(new OutputDriver(new Terminal(), "console"));
        Drivers.add(new CCMouseDriver());
        Drivers.add(new CCKeyboardDriver());
    }
    public function deinit() {
        // Leave this empty, because this hook does not need deinitialization
    }

    public function bg(ev:Array<Dynamic>) {}
}