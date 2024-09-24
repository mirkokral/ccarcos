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

import Button.Command;


@:expose class Color {
    public var palNumber: Int;
    public var bitASC: Int;
    public var blit = "f";
    public function new(blitText: String, palNumber: Int, bitASC: Int) {
        this.palNumber = palNumber;
        this.bitASC = bitASC;
        this.blit = blitText;
    }
}

@:expose class RGBColor {
    public var red: Int;
    public var green: Int;
    public var blue: Int;
    public function new(r: Int, g: Int, b: Int) {
        this.red = r;
        this.green = g;
        this.blue = b;
    }
}

@:expose class Colors {
    public static var white      = new Color("0", 0, 0x1);
    public static var orange     = new Color("1", 1, 0x2);
    public static var magenta    = new Color("2", 2, 0x4);
    public static var lightBlue  = new Color("3", 3, 0x8);
    public static var yellow     = new Color("4", 4, 0x10);
    public static var lime       = new Color("5", 5, 0x20);
    public static var pink       = new Color("6", 6, 0x40);    
    public static var gray       = new Color("7", 7, 0x80);
    public static var lightGray  = new Color("8", 8, 0x100);
    public static var cyan       = new Color("9", 9, 0x200);
    public static var purple     = new Color("a", 10, 0x400);
    public static var blue       = new Color("b", 11, 0x800);
    public static var brown      = new Color("c", 12, 0x1000);
    public static var green      = new Color("d", 13, 0x2000);
    public static var red        = new Color("e", 14, 0x4000);
    public static var black      = new Color("f", 15, 0x8000);
    public static function fromBlit(b: String): Color {
        switch(b) {
            case "0": return white;
            case "1": return orange;
            case "2": return magenta;
            case "3": return lightBlue;
            case "4": return yellow;
            case "5": return lime;
            case "6": return pink;
            case "7": return gray;
            case "8": return lightGray;
            case "9": return cyan;
            case "a": return purple;
            case "b": return blue;
            case "c": return brown;
            case "d": return green;
            case "e": return red;
            case "f": return black;
            default: return white;
        }
    }
}

@:expose enum MouseButton {
    NONE;
    LEFT;
    MIDDLE;
    RIGHT;
}

@:expose class Values {
    public static var typenames: Map<String, () -> Widget> = ["Label" => () -> {
        var o = new Label(0, 0, "");
        return o;
    }, "Container" => () -> new SimpleContainer([]), "Button" => () -> new Button([], new Command()), "TextArea" => () -> {
        return new TextArea(0, 0, "");
    }, "ScrollContainer" => () -> new ScrollContainer([])];
}