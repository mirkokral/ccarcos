package globals;

import Externs.CPos;

class Vector2i {
    public var x: Int;
    public var y: Int;
    public function new(x: Int, y: Int) {
        this.x = x;
        this.y = y;
    }
    #if CraftOS
    public static function fromCPos(a: CPos) {
        return new Vector2i(a.x, a.y);
        
    }
    #end
}
class Vector2f {
    public var x: Float;
    public var y: Float;

    public function new(x: Float, y: Float) {
        this.x = x;
        this.y = y;
    }
}

class Globals {
    public static var version = "0.01x";
    
}


class Color {
    public var palNumber: Int;
    public var bitASC: Int;
    public function new(palNumber: Int, bitASC: Int) {
        this.palNumber = palNumber;
        this.bitASC = bitASC;
    }
}

class RGBColor {
    public var red: Int;
    public var green: Int;
    public var blue: Int;
    public function new(r: Int, g: Int, b: Int) {
        this.red = r;
        this.green = g;
        this.blue = b;
    }
}

class Colors {
    public static var white = new Color(0, 0x1);
    public static var orange = new Color(1, 0x2);
    public static var magenta = new Color(2, 0x4);
    public static var lightBlue = new Color(3, 0x8);
    public static var yellow = new Color(4, 0x10);
    public static var lime = new Color(5, 0x20);
    public static var pink = new Color(6, 0x40);
    public static var gray = new Color(7, 0x80);
    public static var lightGray = new Color(8, 0x100);
    public static var cyan = new Color(9, 0x200);
    public static var purple = new Color(10, 0x400);
    public static var blue = new Color(11, 0x800);
    public static var brown = new Color(12, 0x1000);
    public static var green = new Color(13, 0x2000);
    public static var red = new Color(14, 0x4000);
    public static var black = new Color(15, 0x8000);
}

abstract class Output {
    abstract public function write(s: String): Void;
    public function print(s: String): Void {
        var words = s.split(" ");
        for (word in words) {
            if(this.getCursorPos().x + word.length > this.size.x) {
                this.write("\n");           
            }
            this.write(word + " ");
        }
    }
    abstract public function clear(): Void;
    abstract public function setFGColor(col: Color): Void;
    abstract public function setBGColor(col: Color): Void;
    private var apalette: Array<RGBColor> = [
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
    public var size(get, set): Vector2i;
    abstract public function set_palette(newc: Array<RGBColor>): Array<RGBColor>; 
    public function get_palette() {
        return this.apalette;
    }
    abstract public function getCursorPos(): Vector2i;
    abstract public function setCursorPos(x: Int, y: Int): Void;
    abstract public function setCursorPosRelative(x: Int, y: Int): Void;
    abstract public function get_size(): Vector2i;
    public function set_size(s: Vector2i): Vector2i {
        return get_size();        
    };
}


abstract class Input {
    abstract public function readInt(timeout: Float = -1): Int;
    abstract public function readChar(timeout: Float = -1): String;
    abstract public function readChars(num: Int, timeout: Float = -1, echo:String="/", ?echoOutput: Output, showCursor: Bool = false): String;
    abstract public function readLine(timeout: Float = -1, echo:String="/", ?echoOutput: Output, showCursor: Bool = false): String;
}