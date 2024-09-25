package;

import lua.Table;

@:native("argpstuff")
extern class APS {
	public static var args: Table<Int,Dynamic>;
}

@:multiReturn extern class CPos {
	public var x: Int;
	public var y: Int;
}

@:multiReturn extern class A {
    public var t1: String;
    public var t2: Float;
    public var t3: Bool;
}

@:native("term") extern class Term {
    public static function write(s: String): Void;
    public static function clear(): Void;
    public static function setTextColor(newColor: Int): Void;
    public static function setBackgroundColor(newColor: Int): Void;
    public static function setCursorPos(x: Int, y: Int): Void;
    public static function getCursorPos(): CPos;
    public static function getSize(): CPos;
    public static function setPaletteColor(paln: Int, r: Float, g: Float, b: Float): Void;
    public static function scroll(amount: Int): Void;

}

@:native("os") extern class OS {
    public static function startTimer(timeout: Float): Int;
    public static function pullEvent(): A;
    public static function queueEvent(): A;
}

@:multiReturn extern class KeyEventReturn {
    var name: String;
    var key: Int;
}
@:native("peripheral") extern class Peripherals {
    public static function getNames(): Table<Int, String>;
    public static function getType(peripheral: String): String;
    public static function wrap(name: String): Dynamic;
}

@:multiReturn extern class MRWithError {
    var out: Dynamic;
    var error: String;
}

@:native("fs") extern class CCFileSystem {
    public static function open(path: String, mode: String): MRWithError;
    public static function getDrive(path: String): String;
    public static function exists(path: String): Bool;
    public static function isDir(path: String): Bool;
    public static function isReadOnly(path: String): Bool;
    public static function list(dir: String): Table<Int, String>;
    public static function isDriveRoot(path: String): Bool;
}


@:native("keys") extern class Keys {
	public static var enter: Int;
	public static var backspace: Int;
	public static var left: Int;
	public static var right: Int;
	public static var up: Int;
	public static var down: Int;
	public static var delete: Int;
	@:native("end") public static var navend: Int;
	@:native("home") public static var navhome: Int;
	public static var control: Int;
	public static var space: Int;
	public static var a: Int;
	public static var b: Int;
	public static var c: Int;
	public static var d: Int;
	public static var e: Int;
	public static var f: Int;
	public static var g: Int;
	public static var h: Int;
	public static var i: Int;
	public static var j: Int;
	public static var k: Int;
	public static var l: Int;
	public static var m: Int;
	public static var n: Int;
	public static var o: Int;
	public static var p: Int;
	public static var q: Int;
	public static var r: Int;
	public static var s: Int;
	public static var t: Int;
	public static var u: Int;
	public static var v: Int;
	public static var w: Int;
	public static var x: Int;
	public static var y: Int;
	public static var z: Int;
    public static var tab: Int;
}
