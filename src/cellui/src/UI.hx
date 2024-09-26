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
import haxe.PosInfos;
import haxe.Json;
#if cos
import lua.Table;
import lua.TableTools;
#end
import Externs.CCOS;
import typedefs.Terminal;
import Render;
import Coloring;
import UI;
import Widget;
import Label;
import Widget;
import Vector;
import SimpleContainer;
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


@:expose class Runner {
    var term: Terminal = null;
    public var root = new ScreenManager(null);
    var peripheralName: String = null;
    var renderer = new Renderer(null);
    var cs = new Vector2f(0, 0);

    public function new(term: Terminal, root: Widget, ?peripheralName: String) {
        this.root.term = term;
        this.root.addScreen(root);
        this.term = term;
        this.peripheralName = peripheralName;
        this.renderer.term = this.term;
        
        Runner.log("Created runner");
    }

    public function run() {
        renderer.resize(term.getSize().x-1, term.getSize().y-1);
        renderer.render(root.current());
        #if cos
        while(true) {
            var ev = Table.toArray(TableTools.pack(CCOS.pullEvent()));
            event(ev);
        }
        #end
    }

    public function render() {
        renderer.render(root.current());
        root.current().onRender();
    }

    public function event(ev: Array<Dynamic>) { 
        if(peripheralName != null && ev[0] == "monitor_resize") {
            renderer.resize(term.getSize().x-1, term.getSize().y-1);
            render();
        }
        if(peripheralName == null && ev[0] == "term_resize") {
            renderer.resize(term.getSize().x-1, term.getSize().y-1);
            render();
        }
        if(peripheralName != null && ev[0] == "monitor_touch" && ev[1] == peripheralName) {
            root.current().onClick(new Vector2f(ev[2], ev[3]), MouseButton.LEFT, true);
            root.current().onClickUp(new Vector2f(ev[2], ev[3]), new Vector2f(ev[2], ev[3]), MouseButton.LEFT, true);
        }
        if(peripheralName == null) {
            switch(ev[0]) {
                case "mouse_click": cs = new Vector2f(ev[2], ev[3]); root.current().onClick(cs, ev[1], true);
                case "mouse_up": root.current().onClickUp(cs, new Vector2f(ev[2], ev[3]), ev[1], true);
                case "mouse_scroll": root.current().onScroll(new Vector2f(ev[2], ev[3]), ev[1], true);
                case "mouse_drag": root.current().onDrag(cs, new Vector2f(ev[2], ev[3]), ev[1], true);
            }
        }
        root.current().onCustom(ev);
        if(root.current().requestsRerender) {
            render();
            root.current().requestsRerender = false;
        }
    }
    public static function log(t: String, ?posInfos: PosInfos) {
        // #if !cos
        try {
            untyped __lua__("peripheral.wrap(\"back\").transmit(630, 630, t)");
        } catch (e) {
            // untyped __lua__('
            // local fear, err = fs.open("log.txt", "a")
            // if fear then fear.write(t .. "\\n") fear.close() end
            // ');
        }
        // #end
    }
    

}

@:expose class UILoader {
    var uiData: Dynamic;
    public function new(ui: String) {
        uiData = Json.parse(ui);
    }
}

@:expose class ScreenManager {
    public var screens: Array<Widget> = [];
    public var currentScreen: Int = 0;
    public var term: Terminal = null;
    public function addScreen(scr: Widget) {
        scr.x = 0;
        scr.y = 0;
        scr.width = Std.int(term.getSize().x);
        scr.height = Std.int(term.getSize().y);
        scr.wman = this;
        screens.push(scr);
    }
    public function rmScreen(scr: Widget) {
        screens.remove(scr);
    }
    public function current(): Widget {
        if(screens.length <= currentScreen) {
            return new Label(1, 1, "No screen created.");
        }
        screens[currentScreen].x = 0;
        screens[currentScreen].y = 0;
        screens[currentScreen].width = Std.int(term.getSize().x);
        screens[currentScreen].height = Std.int(term.getSize().y);
        screens[currentScreen].wman = this;
        return screens[currentScreen];
    }
    public function toJSON(): String {
        return Json.stringify(screens.map(e -> e.serialize()));
    }
    public static function fromJSON(term: Terminal, json: String): ScreenManager {
        var obj: Dynamic = Json.parse(json);
        var sm = new ScreenManager(term);
        if(Std.isOfType(obj, Array)) {
            sm.screens = obj.map(e -> Widget.deserialize(e));
        } else {
            sm.screens = [Widget.deserialize(obj)];
        }
        return sm;

    }
    public function new(terminal: Terminal){
        this.term = terminal;
    }
}