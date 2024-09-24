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

import Coloring.Colors;
import UI;
import typedefs.Terminal;

class Test {
	public static var candidates:Map<String, () -> Widget> = [
		"Alignment" => () -> {
			var w = new SimpleContainer([]);
            var i = 0;
            var v: Map<String, Array<Dynamic>> = [
                "Left" => [0.0, 0.0, "4"],
                "Right" => [1.0, 0.0, "9"],
                "Center" => [0.5, 0.0, "b"],
                "Left Middle" => [0.0, 0.5, "2"],
                "Right Middle" => [1.0, 0.5, "5"],
                "Middle" => [0.5, 0.5, "8"],
                "Left Down" => [0.0, 1.0, "e"],
                "Right Down" => [1.0, 1.0, "7"],
                "Center Down" => [0.5, 1.0, "a"],
            ];
			for (name => value in v) {
                var l = new Label(0, 0, name);
                l.xa = value[0];
                l.ya = value[1];
                l.style.bgColor = Colors.fromBlit(value[2]);
                w.addChild(l);
                i++;
                i %= 16;
            }
            w.height = 5;
            return w;
		},
        "Single-line text area" => () -> {
            var w = new TextArea(0, 0, "Placeholder");
            w.height = 1;
            return w;
        },
        "Multi-line text area" => () -> {
            var w = new TextArea(0, 0, "Placeholder\nMultiline support");
            w.height = 5;
            return w;
        }
	];

	public static function main() {
		var nxterm:CCTerminalD = null;
		untyped __lua__("nxterm = term");
		var term = new CCTerminal(nxterm);
		var screen = new ScrollContainer([]);
        var x = 0.0;
        for(name => func in candidates) {
            var w = func();
            var origin = screen.getMostWidgetHeight();
            var l = new Label(0, origin, '\n${name}');
            origin += 2;
            w.y = origin;
            w.x = 0;
            w.width = 0;
            w.hexpand = 1;
            w.vexpand = 0;
            screen.addChild(w);
            screen.addChild(l);
        }
		var r = new Runner(term, screen);
		r.run();
	}
}
