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
package typedefs;

import Coloring;
import Coloring.Colors;
import Vector.Vector2f;
import Coloring.RGBColor;


@:expose class Simpleterminal extends Terminal {
    private var apalette: Array<RGBColor> = [
        new RGBColor(236, 239, 244),
        new RGBColor(0, 0, 0),
        new RGBColor(180, 142, 173),
        new RGBColor(0, 0, 0),
        new RGBColor(235, 203, 139),
        new RGBColor(163, 190, 140),
        new RGBColor(0, 0, 0),
        new RGBColor(76, 86, 106),
        new RGBColor(216, 222, 233),
        new RGBColor(136, 192, 208),
        new RGBColor(0, 0, 0),
        new RGBColor(129, 161, 193),
        new RGBColor(0, 0, 0),
        new RGBColor(163, 190, 140),
        new RGBColor(191, 97, 106),
        new RGBColor(59, 66, 82),
    ];
    public static var apalettea: Array<RGBColor> = [
        new RGBColor(236, 239, 244),
        new RGBColor(0, 0, 0),
        new RGBColor(180, 142, 173),
        new RGBColor(0, 0, 0),
        new RGBColor(235, 203, 139),
        new RGBColor(163, 190, 140),
        new RGBColor(0, 0, 0),
        new RGBColor(76, 86, 106),
        new RGBColor(146, 154, 170),
        new RGBColor(136, 192, 208),
        new RGBColor(0, 0, 0),
        new RGBColor(129, 161, 193),
        new RGBColor(0, 0, 0),
        new RGBColor(163, 190, 140),
        new RGBColor(191, 97, 106),
        new RGBColor(59, 66, 82),
    ];
    public var palette(get, set):Array<RGBColor>;

    public function get_palette() {             
        return this.apalette;
    }
    
    var printFunction: (s: String) -> Void;

    public function write(s: String) {
        printFunction(s);
    }
    public function clear() {
        printFunction("\x1B[2J");
    }
    public function setTextColor(col: Color) {
        printFunction("\x1B[38;2;" + this.apalette[col.palNumber].red +";" + this.apalette[col.palNumber].green + ";" + this.apalette[col.palNumber].blue + "m");
    }
    public function setBackgroundColor(col: Color) {
        printFunction("\x1B[48;2;" + this.apalette[col.palNumber].red +";" + this.apalette[col.palNumber].green + ";" + this.apalette[col.palNumber].blue + "m");
    }
    public function setCursorPos(x: Int, y: Int): Void {
        printFunction("\x1B[" + y + ";" + x + "H");
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
    public function setPaletteColor(paln: Int, r: Float, g: Float, b: Float) {
        var apaln = Std.int(Math.log(paln));
        this.apalette[apaln] = new RGBColor(Std.int(r), Std.int(g), Std.int(b));
    }
    public function getSize(): Vector2f {
        return this.size;
    }

    public function blit(a: String, b: String, c: String) {
        for (i in 0...a.length) {
            var c = a.charAt(i);
            var fg = Colors.fromBlit(b.charAt(i));
            var bg = Colors.fromBlit(c.charAt(i));
            this.setTextColor(fg);
            this.setBackgroundColor(bg);
            this.write(c);
        }
    }
    public function setCursorBlink(b: Bool) {
        
    }
    public function new(pf: (s: String)->Void) {
        this.printFunction = pf;
        this.apalette = Simpleterminal.apalettea;
    }
}