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

import haxe.Rest;
import Render;
import Coloring;
import Widget;
import Label;
import Widget;
import Vector;
import SimpleContainer;
import typedefs.Simpleterminal;
import typedefs.Terminal;
import UI;
import Externs;

class Main2 {   
    public static function main() {
        //trace("Starting");
        var nxterm: CCTerminalD = null;
        var dtety = "";
        untyped __lua__("nxterm = term; dtety = _0x1EA5C8F8");
        var term = new CCTerminal(nxterm);
        var screen = new Label(1, 1, "No screens!");
        var r = new Runner(term, screen);
        r.root = ScreenManager.fromJSON(term, dtety);
        r.run();
        //trace("stopping");
    }
}