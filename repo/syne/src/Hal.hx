import lua.Lua.LoadResult;
import haxe.Rest;
import lua.Coroutine;
import lua.Table;
import haxe.ds.Either;

/**
 * File attributes
 */
class FileAttributes {
	/**
	 * File size
	 */
	public var size:Int;

	/**
	 * Is this a directory?
	 */
	public var isDir:Bool;

	/**
	 * Is this file read-only?
	 */
	public var isReadOnly:Bool;

	/**
	 * When was this file created?
	 */
	public var created:Date;

	/**
	 * When was this file last modified?
	 */
	public var modified:Date;

	/**
	 * Capacity of the drive the file is on
	 */
	public var capacity:Int;

	/**
	 * Is this the root of a drive?
	 */
	public var driveRoot:Bool;

	/**
	 * Permissions of the file
	 */
	public var permissions:Table<String, {read:Bool, write:Bool, listed:Bool}>;

	public function new() {}
}

extern class FilePermissions {
	public var read:Bool;
	public var write:Bool;
	public var listed:Bool;
}

@:luaDotMethod
extern class FileHandle {
	public dynamic function read(byteCount:Int):String;

	public dynamic function readAll():String;

	public dynamic function readLine():String;

	public function seek(?whence:String, ?offset:Int):Void;

	public dynamic function write(data:String):Int;
	public dynamic function writeLine(data:String):Int;

	public function flush():Void;

	public function close():Void;
}

@:multiReturn extern class Position {
	public var x:Int;
	public var y:Int;
}

@:multiReturn extern class OpenResult {
	public var fHandle:Null<FileHandle>;
	public var error:Null<String>;
}

class ColorMap {
	public var white:Int;
	public var orange:Int;
	public var magenta:Int;
	public var lightBlue:Int;
	public var yellow:Int;
	public var lime:Int;
	public var pink:Int;
	public var gray:Int;
	public var lightGray:Int;
	public var cyan:Int;
	public var purple:Int;
	public var blue:Int;
	public var brown:Int;
	public var green:Int;
	public var red:Int;
	public var black:Int;
}

@:multiReturn extern class ColorReturn {
	public var r:Float;
	public var g:Float;
	public var b:Float;
}

@:luaDotMethod extern class Terminal {
	public dynamic function write(text:String):Void;
	public dynamic function clear():Void;
	public dynamic function getCursorPos():Position;
	public dynamic function setCursorPos(x:Int, y:Int):Void;
	public dynamic function getCursorBlink():Bool;
	public dynamic function setCursorBlink(b:Bool):Void;
	public dynamic function isColor():Bool;
	public dynamic function getSize():Position;
	public dynamic function setTextColor(newColor:Int):Void;
	public dynamic function getTextColor():Int;
	public dynamic function setBackgroundColor(newColor:Int):Void;
	public dynamic function getBackgroundColor():Int;
	public dynamic function setPaletteColor(pIndex:Int, r:Float, g:Float, b:Float):Void;
	public dynamic function setPaletteColour(pIndex:Int, r:Int, g:Int, b:Int):Void;
	public dynamic function getPaletteColor(col:Int):ColorReturn;
	public dynamic function getPaletteColour(col:Int):ColorReturn;
	public dynamic function scroll(amount:Int):Void;
	public dynamic function clearLine():Void;
	public dynamic function blit(text:String, fgColors:String, bgColors:String):Void;
	public var pMap:ColorMap;
	public var kMap:Dynamic;
}

@:luaDotMethod extern class FileSystem {
	public dynamic function open(path:String, mode:String):OpenResult;
	public dynamic function list(path:String):Table<Int,String>;
	public dynamic function type(path:String):String;
	public dynamic function exists(path:String):Bool;
	public dynamic function copy(from:String, to:String):Void;
	public dynamic function unlink(what:String):Void;
	public dynamic function mkDir(path:String):Void;
	public dynamic function attributes(path:String):FileAttributes;
	public dynamic function getPermissions(path:String, ?user:String):FilePermissions;
}

@:luaDotMethod extern class ComputerPowerInterface {
	public dynamic function shutdown():Void;
	public dynamic function reboot():Void;
}

@:luaDotMethod extern class ComputerInterface {
	public var id:Int;
	public dynamic function uptime():Float;
	public dynamic function label():String;
	public dynamic function setlabel(newLabel:String):Void;
	public dynamic function time(locale:String):Float;
	public dynamic function day(locale:String):Int;
	public dynamic function epoch(locale:String):Int;
	public dynamic function date(format:String):String;
	public var power:ComputerPowerInterface;
}

@:luaDotMethod extern class TMI {
	public dynamic function start(duration:Float):Int;
	public dynamic function cancel(id:Int):Void;
	public dynamic function setalarm(duration:Float):Int;
	public dynamic function cancelalarm(id:Int):Void;
}

@:luaDotMethod extern class WorkaroundInterface {
	public dynamic function preventTooLongWithoutYielding(handleEvent: (ev: Table<Int, Dynamic>) -> Void):Void;
}

@:luaDotMethod extern class DeviceInterface {
	public dynamic function get(name:String):Dynamic;
	public dynamic function type(peripheral:String):String;
	public dynamic function list(): Table<Int, String>;
}

// Truly a @:luaDotMethod moment

@:native("KDriversImpl")
@:luaDotMethod
extern class Hal {
	public static var platform: String;
	public static var files:FileSystem;
	public static var terminal:Terminal;
	public static var computer:ComputerInterface;
	public static var timers:TMI;
	public static var workarounds:WorkaroundInterface;
	public static var devc:DeviceInterface;
	public static var pullEvent:Void->Dynamic;
	public static var branding:(version: String)->Void;
}

@:native("_G.coroutine")
extern class CG {
	static function resume<A, B>(c:Coroutine<Dynamic>, args:haxe.extern.Rest<A>):Dynamic;
}

@:native("_G")
extern class Global {
	static function load(code:haxe.extern.EitherType<String, Void->String>, ?chunkName: String, ?mode: String, ?env: Map<Dynamic, Dynamic>):LoadResult;
}