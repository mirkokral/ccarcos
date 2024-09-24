/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2024 arcos Development Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package;

@:multiReturn extern class CPos {
    public var x: Float;
    public var y: Float;
}

class CCOS {
    public static function pullEvent(): Dynamic {
        untyped __lua__("
        if arcos then return arcos.ev() else return os.pullEvent() end
        ");
        return null;
    };
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
