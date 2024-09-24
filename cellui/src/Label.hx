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
import Render.PositionedRenderCommand;
import Widget.Style;

function getTheoreticalWH(str: String) {
    var cposx = 0;
    var cposy = 0;
    var maxw = 0;
    var maxh = 1;
    for (i in 0...str.length) {
        var char = str.charAt(i);
        if(char == "\n") {
            cposx = 0;
            cposy++;
            maxh++;
        } else {
            cposx++;
            maxw = Std.int(Math.max(cposx, maxw));
        }
    }
    return [maxw, maxh];
}

@:expose class Label extends Widget {
    public var text = "<empty>";
    public function new(x: Float, y: Float, text: String) {
        this.x = x;
        this.y = y;
        this.text = text;
        var s = getTheoreticalWH(text);
        this.width = s[0];
        this.height = s[1];
        
    }

    public function renderImpl(screenwidth:Float, screenheight:Float, width: Float, height: Float):Array<PositionedRenderCommand> {
        var o: Array<PositionedRenderCommand> = [];
        var cposx = 0;
        var cposy = 0;
        for (i in 0...text.length) {
            var char = text.charAt(i);
            if(char == "\n") {
                cposx = 0;
                cposy++;
            } else {
                o.push(new PositionedRenderCommand(cposx, cposy, char, this.id, this.style.fgColor, this.style.bgColor));
                cposx++;
            }
        }
        return o;
    }

    private function deserializeAdditional(data:Dynamic): Widget {
        if(Std.isOfType(data.labelText, String)) {
            this.text = data.labelText;
        }
        return this;
    }

    private function serializeAdditional(): Map<String, Dynamic> {
        return ["labelText" => this.text];
    }

    function additionalEditorFields():Map<String, String> {
        return ["text" => "Label"];
    }
    

    public function getTypename():String {
        return "Label";
    }

}