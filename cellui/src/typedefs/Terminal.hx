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
import Vector.Vector2f;
import Externs;

#if cos
@:luaDotMethod
@:expose extern class CCTerminalD {
    public function write(s: String): Void;
    public function clear(): Void;
    public function setCursorPos(x: Int, y: Int): Void;
    public function getSize(): CPos;
    public function setPaletteColor(paln: Int, r: Float, g: Float, b: Float): Void;
    public function blit(text: String, fgColors: String, bgColors: String): Void;
    public function setCursorBlink(b: Bool): Void;
}
#end

@:expose abstract class Terminal {
    abstract public function write(s: String): Void;
    abstract public function clear(): Void;
    abstract public function setCursorPos(x: Int, y: Int): Void;
    abstract public function getSize(): Vector2f;               
    abstract public function setPaletteColor(paln: Int, r: Float, g: Float, b: Float): Void;
    abstract public function blit(text: String, fgColors: String, bgColors: String): Void;
    abstract public function setCursorBlink(b: Bool): Void;

    public var size: Vector2f = new Vector2f(51, 19);
}

#if cos
@:expose class CCTerminal extends Terminal {
    
    var termxe: CCTerminalD;
    public function new(term: CCTerminalD) {
        this.termxe = term;
        for(i => v in Simpleterminal.apalettea) {
            this.setPaletteColor(Std.int(Math.pow(2, i)), v.red/255, v.green/255, v.blue/255);
        }
    }


    public function write(s:String) {
        this.termxe.write(s);
    }
    public function clear(): Void {
        this.termxe.clear();
    };
    public function setCursorPos(x: Int, y: Int): Void {
        this.termxe.setCursorPos(x, y);
    };
    public function getSize(): Vector2f {
        var s = this.termxe.getSize();
        return new Vector2f(s.x, s.y);
    };
    public function setPaletteColor(paln: Int, r: Float, g: Float, b: Float): Void {
        this.termxe.setPaletteColor(paln, r, g, b);
    };
    public function blit(text: String, fgColors: String, bgColors: String): Void {
        this.termxe.blit(text, fgColors, bgColors);
    };

    public function setCursorBlink(b:Bool) {
        this.termxe.setCursorBlink(b);
    }
}
#end