package drivers.terminal;
import globals.Globals;
import Externs;
class TerminalBackend extends Output {
    public function write(s: String) {
        for (i in 0...s.length) {
            if (s.charAt(i) == "\n") {
                var o = term.getCursorPos();
                term.setCursorPos(1, o.y);
                this.setCursorPosRelative(0, 1);
            } else {
                term.write(s.charAt(i));
            }
        }
    }
    public function clear() {
        term.clear();
    }
    public function setFGColor(col: Color) {
        term.setTextColor(col.bitASC);
    }
    public function setBGColor(col: Color) {
        term.setBackgroundColor(col.bitASC);
    }
    public function setCursorPos(x: Int, y: Int) {
        term.setCursorPos(x, y);
    }
    public function getCursorPos(): Vector2i {
        return Vector2i.fromCPos(Term.getCursorPos());
    }
    public function setCursorPosRelative(x: Int, y: Int) {
        var o = term.getCursorPos();
        o.x += x;
        o.y += y;
        term.setCursorPos(o.x, o.y);
        if(o.y > term.getSize().y) {
            term.scroll((o.y - term.getSize().y-2)*-1);
            term.setCursorPos(o.x, term.getSize().y);
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
            term.setPaletteColor(Std.int(Math.max(Math.pow(2, i), 1)), color.red/255.0, color.green/255.0, color.blue/255.0);
            i++;
        };
        return this.apalette;
    }

    public function new() {
        // super();
        set_palette(this.palette);
    }
}