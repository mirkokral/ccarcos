package drivers.terminal;

import haxe.ds.Vector;
import Externs.CPos;
import globals.Globals;

class TerminalBackend extends Output {
    public function write(s: String) {
        Sys.print(s);
    }
    public function clear() {
        Sys.print("\x1B[2J");
    }
    public function setFGColor(col: Color) {
        Sys.print("\x1B[38;2;" + this.apalette[col.palNumber].red +";" + this.apalette[col.palNumber].green + ";" + this.apalette[col.palNumber].blue + "m");
    }
    public function setBGColor(col: Color) {
        Sys.print("\x1B[48;2;" + this.apalette[col.palNumber].red +";" + this.apalette[col.palNumber].green + ";" + this.apalette[col.palNumber].blue + "m");
    }
    public function setCursorPos(x: Int, y: Int) {
        Sys.print("\x1B[" + y + ";" + x + "H");
    }
    public function getCursorPos(): Vector2i {
        return new Vector2i(-1, -1);
    }
    public function setCursorPosRelative(x: Int, y: Int) {
        if(x != 0) {
            Sys.print("\x1B[" + Math.abs(x) + (x >= 0 ? "B" : "A"));
        }
        if(y != 0) {
            Sys.print("\x1B[" + Math.abs(y) + (y >= 0 ? "C" : "D"));
        }
        // Sys.print("\x1B[" + y+"C");
    }
    public function get_size(): Vector2i {
        // Sys.print(Sys.environment()["LINES"]);
        // Sys.print(Sys.environment()["COLUMNS"]);
        if(Sys.environment()["LINES"] != null && Sys.environment() != null) {
            return new Vector2i(Std.parseInt(Sys.environment()["COLUMNS"]), Std.parseInt(Sys.environment()["LINES"]));
        }
        return new Vector2i(197, 10);
    }
    public function set_palette(newc: Array<RGBColor>): Array<RGBColor> {
        var i = 0;
        for (color in newc) {
            i++;
            this.apalette[i-1] = color;
            // term.setpaletteColor(i, color.red/255.0, color.green/255.0, color.blue/255.0);
        };
        return this.apalette;
    }
    public function new() {}
}