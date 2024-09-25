package kernel;

import Externs.Keys;
import drivers.terminal.CraftOS.TerminalBackend;
import haxe.io.Bytes;
import globals.Globals;

enum MouseEventType {
	Click;
	ClickUp;
	Drag;
	Scroll;
}

enum MouseButton {
	None;
	Left;
	Right;
	Middle;
}

class MouseEvent {
	public var x:Float = 0;
	public var y:Float = 0;
	public var button = 0;
	public var type = MouseEventType.Click;

	public function new(type:MouseEventType, x:Float, y:Float, button:Int) {
		this.type = type;
		this.x = x;
		this.y = y;
		this.button = button;
	}
}

enum DriverProvides {
	Keyboard;
	Mouse;
	Terminal;
	Sound;
	Disk;
	Http;
	Network;
	Clock;
	Custom(name:String);
}

abstract class Driver {
	abstract public function init():Void;

	abstract public function deinit():Void;

	abstract public function bg(ev: Array<Dynamic>):Void;

	abstract public function dataread():String;

	abstract public function datawrite(s:String):Void;

	public var deviceName:String;
	public var provides:DriverProvides;
}

abstract class KeyboardDriver extends Driver {
	abstract public function readInt(timeout:Float = -1):Int;

	abstract public function readChar(timeout:Float = -1):String;

	abstract public function readChars(num:Int, timeout:Float = -1, echo:String = "/", ?echoOutput:Output, showCursor:Bool = true):String;

	public function readLine(timeout:Float = -1, echo:String = "/", ?echoOutput:Output, showCursor:Bool = false):String {
		Sys.sleep(0.1);
		var ch = "";
        var cursorPos = 0;
		var ocp = new Vector2i(1, 1);
		if (echoOutput != null) {
			ocp = echoOutput.getCursorPos();
		}
        function redraw() {

            if (echoOutput != null) {
                echoOutput.setCursorPos(ocp.x, ocp.y);
                var ech = ch + "";
                if(echo != "/") {
                    ech = StringTools.rpad("", echo, ech.length);
                }
                echoOutput.write(ech.substr(0, cursorPos) + (showCursor ? "_" : "") + ech.substr(cursorPos) + " ");

            }
        }
        redraw();
		while (true) {
			var e = readInt();
			trace(e);
            if(e >= Keys.q && e <= Keys.m) {
                var ea = readChar();
    
                ch = ch.substr(0, cursorPos) + ea + ch.substr(cursorPos);
                cursorPos++;

            }
			else if (e == Keys.backspace) {
				ch = ch.substr(0, cursorPos-1) + ch.substr(cursorPos);
                cursorPos--;
			}
			else if (e == Keys.enter) {
                showCursor = false;
                redraw();
				if (echoOutput != null)
					echoOutput.write("\n");
				return ch;
			}
            else if (e == Keys.left) {
                cursorPos = Std.int(Math.max(cursorPos-1, 0));
            }
            if (e == Keys.right) {
                cursorPos = Std.int(Math.min(cursorPos+1, ch.length));
            }
            redraw();
		}
	}

	public function new() {
		this.provides = DriverProvides.Keyboard;
	}
}

enum FileType {
	Directory;
	File;
	Link;
	Device;
}

abstract class FileSystemDriver extends Driver {
	abstract public function read(path:String):String;

	abstract public function readBytes(path:String, bytes:Int, fromPos:Int = 0):Array<Int>;

	abstract public function write(path:String, text:String):Void;

	abstract public function writeByte(path:String, byte:Int):Void;

	abstract public function append(path:String, text:String):Void;

	abstract public function exists(path:String):Bool;

	abstract public function isReadOnly(path:String, user:String = ""):Bool;

	abstract public function list(dir:String):Array<String>;

	abstract public function type(path:String):FileType;

	public function new() {
		this.provides = DriverProvides.Disk;
	}
}

abstract class MouseDriver extends Driver {
	abstract public function getEvent(filter:Null<MouseEventType>):MouseEvent;

	public function new() {
		this.provides = DriverProvides.Mouse;
	}
}

private class TDOutput extends Output {
	var td:TerminalDriver = null;

	public function new(td:TerminalDriver) {
		this.td = td;
	}

	public function write(s:String) {
		td.write(s);
	}

	public function clear() {
		td.clear();
	}

	public function setFGColor(col:Color) {
		return td.setFGColor(col);
	}

	public function setBGColor(col:Color) {
		return td.setBGColor(col);
	}

	public function set_palette(newc:Array<RGBColor>):Array<RGBColor> {
		return td.set_palette(newc);
	}

	public function getCursorPos():Vector2i {
		return td.getCursorPos();
	}

	public function setCursorPos(x:Int, y:Int) {
		return td.setCursorPos(x, y);
	}

	public function setCursorPosRelative(x:Int, y:Int) {
		return td.setCursorPosRelative(x, y);
	}

	public function get_size():Vector2i {
		return td.get_size();
	}
}

abstract class TerminalDriver extends Driver {
	abstract public function write(s:String):Void;

	public function print(s:String):Void {
		for (i in 0...s.length) {}
	}

	abstract public function clear():Void;

	abstract public function setFGColor(col:Color):Void;

	abstract public function setBGColor(col:Color):Void;

	private var apalette:Array<RGBColor> = [
        new RGBColor(236, 239, 244),
        new RGBColor(0, 0, 0),
        new RGBColor(180, 142, 173),
        new RGBColor(0, 0, 0),
        new RGBColor(235, 203, 139),
        new RGBColor(163,190,140),
        new RGBColor(0, 0, 0),
        new RGBColor(173, 179, 187),
        new RGBColor(216, 222, 187),
        new RGBColor(136,192,208),
        new RGBColor(0,0,0),
        new RGBColor(129,161,193),
        new RGBColor(0,0,0),
        new RGBColor(163,190,140),
        new RGBColor(191,97,106),
        new RGBColor(59, 66, 82),
    ];

	public var palette(get, set):Array<RGBColor>;
	public var size(get, set):Vector2i;

	abstract public function set_palette(newc:Array<RGBColor>):Array<RGBColor>;

	public function get_palette() {
		return this.apalette;
	}

	abstract public function getCursorPos():Vector2i;

	abstract public function setCursorPos(x:Int, y:Int):Void;

	abstract public function setCursorPosRelative(x:Int, y:Int):Void;

	abstract public function get_size():Vector2i;

	public function set_size(s:Vector2i):Vector2i {
		return get_size();
	};

	public function asOutput():Output {
		return new TDOutput(this);
	}

	public function new() {
		this.provides = DriverProvides.Terminal;
	}
}

abstract class SoundDriver extends Driver {
	abstract public function playNote(instrument:String, volume:Float = 2, pitch:Float = 1):Void;

	abstract public function playSound(name:String, volume:Float = 2, pitch:Float = 1):Void;

	abstract public function playAudio(audio:Array<Int>, volume:Float):Void;

	public function new() {
		this.provides = DriverProvides.Sound;
	}
}

enum RequestType {
	Post;
	Get;
}

enum Since {
	ComputerStart;
	UnixEpoch;
}

abstract class HttpDriver extends Driver {
	abstract public function sendRequest(url: String, requestType: RequestType = RequestType.Get, body: String, headers: Map<String, String>): Null<String>;
	public function new() {
		this.provides = DriverProvides.Http;
	}
}

abstract class ClockDriver extends Driver {
	/**
	 * Returns an epoch 
	 * @param since Since (x)
	 * @return The epoch
	 */
	abstract public function getEpoch(since: Since): Float;
	public function new() {
		this.provides = DriverProvides.Clock;
	}
}