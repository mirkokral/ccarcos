package drivers.terminal;
import globals.Globals;
import Externs;
class TerminalBackend extends Output {
    public function write(s: String) {
        for (i in 0...s.length) {
            if (s.charAt(i) == "\n") {
                var o = Term.getCursorPos();
                Term.setCursorPos(1, o.y);
                this.setCursorPosRelative(0, 1);
            } else {
                Term.write(s.charAt(i));
            }
        }
    }
    public function clear() {
        Term.clear();
    }
    public function setFGColor(col: Color) {
        Term.setTextColor(col.bitASC);
    }
    public function setBGColor(col: Color) {
        Term.setBackgroundColor(col.bitASC);
    }
    public function setCursorPos(x: Int, y: Int) {
        Term.setCursorPos(x, y);
    }
    public function getCursorPos(): Vector2i {
        return Vector2i.fromCPos(Term.getCursorPos());
    }
    public function setCursorPosRelative(x: Int, y: Int) {
        var o = Term.getCursorPos();
        o.x += x;
        o.y += y;
        Term.setCursorPos(o.x, o.y);
        if(o.y > Term.getSize().y) {
            Term.scroll((o.y - Term.getSize().y-2)*-1);
            Term.setCursorPos(o.x, Term.getSize().y);
        }
    }
    public function get_size(): Vector2i {
        return Vector2i.fromCPos(Term.getSize());
    }
    public function set_palette(newc: Array<RGBColor>): Array<RGBColor> {
        var i = 0;
        for (color in newc) {
            this.apalette[i-1] = color;
            // Sys.println(Math.pow(2, i));
            Term.setPaletteColor(Std.int(Math.max(Math.pow(2, i), 1)), color.red/255.0, color.green/255.0, color.blue/255.0);
            i++;
        };
        return this.apalette;
    }

    public function new() {
        // super();
        set_palette(this.palette);
    }
}