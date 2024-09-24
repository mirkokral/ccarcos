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

import UI.ScreenManager;
import haxe.Json;
import haxe.DynamicAccess;
import haxe.Exception;
import haxe.macro.Expr.Error;
import Coloring;
import Vector;
import haxe.macro.Compiler;
import Render;




@:expose abstract class Widget {
    /**
     * The X value for the widget
     */
    public var x: Float = 0;
    /**
     * The Y value for the widget
     */
    public var y: Float = 0;
    /**
     * The X align value for the widget.
     * wx = x + xa * screenwidth - xa * widgetwidth
     * So, that means that
     * To align left: use 0
     * To align center: use 0.5
     * To align right: use 1
     */
    public var xa: Float = 0;
    /**
     * The Y align value for the widget.
     * wy = y + ya * screenheight - ya * widgetheight
     * So, that means that
     * To align up: use 0
     * To align middle: use 0.5
     * To align down: use 1
     */
    public var ya: Float = 0;
    /**
     * Wether to expand vertically.
     */
    public var vexpand: Float = 0;
    /**
     * Wether to expand horizontally.
     */
    public var hexpand: Float = 0;
    /**
     * The widget's width (in characters)
     */
    public var width: Int = 10;
    /**
     * The widget's height (in characters)
     */
    public var height: Int = 1;

    private var ow = 10;
    private var oh = 1;
    /** 
     * The widget's children
     */
    public var children: Array<Widget> = [];
    /**
     * The widget's visible status.
     */
    public var visible = true;
    public var parent: Widget = null;
    public var style = new Style();
    public var wman: ScreenManager = null;

    public var id = Std.string(Math.random()*1000000000);
    var lsw = 0.0;
    var lsh = 0.0;
    public var requestsRerender = false;

    public function requestRerender() {
        requestsRerender = true;
    }

    public function getWman(): ScreenManager {
        if(this.wman != null) {
            return this.wman;
        } else if(this.parent != null) {
            return this.parent.getWman();
        } else {
            return new ScreenManager(null);
        }
    }

    public function fixedWidth(screenwidth: Float, screenheight: Float, ?ignoreParent: Bool): Int {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;


            // + this.hexpand * (ignoreParent ? screenwidth : this.parent.fixedWidth(screenwidth, screenheight))) + ", Screen width: " + (ignoreParent ? screenwidth : this.parent.fixedWidth(screenwidth, screenheight)));
        // if(!ignoreParent) {

        // }

        //     + this.hexpand * (ignoreParent ? screenwidth : this.parent.fixedWidth(screenwidth, screenheight))));
        return Math.round(this.width
             + this.hexpand * (ignoreParent ? screenwidth : this.parent.fixedWidth(screenwidth, screenheight)));
    }

    public function fixedHeight(screenwidth: Float, screenheight: Float, ?ignoreParent: Bool): Int {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;
        
        return Math.round(this.height + (this.vexpand*(ignoreParent ? screenheight : this.parent.height)));
    }

    public function getPRenderCommands(screenwidth: Float, screenheight: Float, respectPosition: Bool = true): Array<PositionedRenderCommand> {
        lsw = screenwidth;
        lsh = screenheight;
        if(!visible) return[];
        var oldw = this.width + 1 - 1;
        var oldh = this.height + 1 - 1;
        ow = oldw;
        oh = oldh;
        var fwidth = fixedWidth(screenwidth, screenheight);
        var fheight = fixedHeight(screenwidth, screenheight);

        for(c in this.children) {
            c.parent = this;
        }   
        var rc: Array<PositionedRenderCommand> = [];
        for (i in 0...fwidth) {
			for (ix in 0...fheight) {
				rc.push(new PositionedRenderCommand(i, ix, " ", this.id, this.style.fgColor, style.bgColor));
			}
		}
        for(i in renderImpl(screenwidth, screenheight, fwidth, fheight)) {
            rc.push(i);
        };
                
        var nrc: Array<PositionedRenderCommand> = [];
        for (command in rc) {   
            if(command.x >= fwidth || command.y >= fheight || command.x < 0 || command.y < 0) {continue;};
            if(respectPosition) {  
                command.x = Math.floor(fixedXC((command.x), (screenwidth), (screenheight), true, true));
                command.y = Math.floor(fixedYC((command.y), (screenwidth), (screenheight), true, true));
            }   
            nrc.push(command);
        }
        this.width = oldw;
        this.height = oldh;
        return nrc;
    };
    public function fixedX(screenwidth: Float, screenheight: Float, ?ignoreParent: Bool) {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;
        // if(xa == 0) return  Math.floor((ignoreParent ? 0 : this.parent.width)+1+x + xa * (ignoreParent ? screenwidth : this.parent.width) - xa * fixedWidth(screenwidth, screenheight, ignoreParent));
        var x = fixedXC(0, screenwidth, screenheight, ignoreParent, true);

        return x;
    }
    public function fixedY(screenwidth: Float, screenheight: Float, ?ignoreParent: Bool) {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;
        var x = fixedYC(0, screenwidth, screenheight, ignoreParent, true);

        return x;

    }
    public function fixedXC(xc: Float, screenwidth: Float, screenheight: Float, ?ignoreParent: Bool, ?includeThis: Bool) {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;
        if(!ignoreParent) {
            screenwidth = this.parent.fixedWidth(screenwidth, screenheight);
            screenheight = this.parent.fixedHeight(screenwidth, screenheight);
        }
        return Math.floor(
            xc
            + (includeThis ? this.x : 0)  
            + (xa*screenwidth)
            + (ignoreParent ? 0 : this.parent.fixedX(screenwidth, screenheight))
            - xa*this.fixedWidth(screenwidth, screenheight));
    }
    public function fixedYC(yc: Float, screenwidth: Float, screenheight: Float, ?ignoreParent: Bool, ?includeThis: Bool) {
        if(ignoreParent == null) ignoreParent=false;
        if(this.parent == null) ignoreParent=true;
        if(!ignoreParent) {
            screenwidth = this.parent.fixedWidth(screenwidth, screenheight);
            screenheight = this.parent.fixedHeight(screenwidth, screenheight);
        }
        return Math.floor(
            yc
            + (includeThis ? this.y : 0)  
            + (ya*screenheight)
            + (ignoreParent ? 0 : this.parent.fixedY(screenwidth, screenheight))
            - ya*this.fixedHeight(screenwidth, screenheight));

    }
    public function addChild(child: Widget) {
        child.parent = this;
        children.push(child);
    }
    public function remChild(child: Widget) {
        child.parent = null;
        children.remove(child);
    }

    public function getChildByID(id: String): Null<Widget> {
        for (widget in recFilterChildren((w) -> w.id == id)) {
            return widget;
        }
        throw new Exception('Cannot find child with id ${id}');
    }
    public function recFilterChildren(filter: (c: Widget) -> Bool): Array<Widget> {
        var ch: Array<Widget> = [];
        for (widget in children) {
            if(filter(widget)) {
                ch.push(widget);
            }
            ch = ch.concat(widget.recFilterChildren(filter));
        }
        ch.reverse();
        return ch;
    }
    public function recFilterChildrenUF(filter: (c: Widget) -> Bool): Array<Widget> {
        var ch: Array<Widget> = [];
        for (widget in children) {
            var cha = (widget.recFilterChildrenUF(filter));
            var r = widget;
            r.children = cha;
            if(filter(widget)) {        
                ch.push(widget);

            }
        }
        ch.reverse();
        return ch;
    }

    abstract public function getTypename(): String;

    /**
     * Utility function to get the size of an object, but if object is not visible the function returns 0
     * @return Vector2i
     */
    public function getSize(): Vector2f {
        if(!visible) return new Vector2f(0, 0);
        return new Vector2f(width, height);
    }
    /**
     * This function should return positionedrendercommands.
     * They are supposed to be relative to 0,0 because getprendercommands automatically adds the offset
     * This function should not be used
     * @return Array<PositionedRenderCommand>
     */
    public abstract function renderImpl(screenwidth: Float, screenheight: Float, width: Float, height: Float): Array<PositionedRenderCommand>;
    /**
     * Note: All positions are relative to widget origin
     * @param pos 
     * @param mb 
     */
    public function onClick(pos: Vector2f, mb: MouseButton, wself:Bool) {};
    /**
     * Note: All positions are relative to widget origin
     * @param startpos 
     * @param pos 
     * @param mb 
     */
    public function onDrag(startpos: Vector2f, pos: Vector2f, mb: MouseButton, wself:Bool) {};
    /**
     * Note: All positions are relative to widget origin
     * @param startpos 
     * @param pos 
     * @param mb 
     */
    public function onClickUp(startpos: Vector2f, pos: Vector2f, mb: MouseButton, wself:Bool) {};
    /**
     * Note: All positions are relative to widget origin
     * @param pos 
     * @param dir 
     */
    public function onScroll(pos: Vector2f, dir: Int, wself:Bool) {};
    /**
     * On system event
     * @param c 
     */
    public function onCustom(c: Array<Dynamic>) {};
    /**
     * After rendering. The screen is already rendered so place your cursor mods here!
     */
    public function onRender() {};
    /**
     * Deserialize an object from it's object.
     * @param data 
     */
    private abstract function deserializeAdditional(data: Dynamic): Widget;

    private abstract function additionalEditorFields(): Map<String, String>;

    public function getEditorFields(): Map<String, String> {
        var a = this.additionalEditorFields();
        for (s => v in ["style" => "Style", "id" => "ID", "x" => "X", "y" => "Y", "width" => "Width", "height" => "Height", "xa" => "X align", "ya" => "Y align", "hexpand" => "Expand on X axis", "vexpand" => "Expand on Y axis"]) {
            a.set(s, v);
        }
        return a;
    }

    public static function deserialize(data: DynamicAccess<Dynamic>): Widget {

        if(Values.typenames.exists(data.get("typeName"))) {
            var ObjectType = Values.typenames.get(data.get("typeName"));

            var obj: Widget = ObjectType();
            obj.deserializeAdditional(data);
            var deserializeValues: Map<String, Dynamic> = ["x" => Float, "y" => Float, "xa" => Float, "ya" => Float, "vexpand" => Float, "hexpand" => Float, "width" => Float, "height" => Float, "id" => String, "style" => Dynamic, "children" => Dynamic];
            for (name => type in deserializeValues) {
                if(Std.isOfType(data.get(name), type)) {
                    
                    if(name == "children") {
                        obj.children = [];    
                        for(i in cast(data.get("children"), Array<Dynamic>)){
                            var w = (Widget.deserialize(i));
                            obj.addChild(w);
                        }
                    } else if(name == "style") {
                        var f: DynamicAccess<Dynamic> = data.get(name);

                        var nstyle = new Style();
                        nstyle.fgColor = Colors.fromBlit(f.get("fgColor"));
                        nstyle.bgColor = Colors.fromBlit(f.get("bgColor"));
                        obj.style = nstyle;
                    } else {
                        Reflect.setField(obj, name, data.get(name));
                    }
                }       
            }   
            return obj;
        } else {        
            return cast(data);
        }
    }
    /**
     * Deserialize an object from it's object.
     * @param data 
     */
    private abstract function serializeAdditional(): Map<String, Dynamic>;

    public function serialize(): Map<String, Dynamic> {
        var data: Map<String, Dynamic> = [];
        for(k => v in this.serializeAdditional()) {
            data[k] = v;
        }
        var serializeValues: Map<String, Dynamic> = ["x" => Float, "y" => Float, "xa" => Float, "ya" => Float,"vexpand" => Float, "hexpand" => Float, "width" => Float, "height" => Float, "id" => String, "children" => Array, "style" => Style];
        for (name => type in serializeValues) {
            var rp = name;
            if(rp == "width") rp = "ow";
            if(rp == "height") rp = "oh";
            data[name] = Reflect.getProperty(this, rp);
            if(Std.isOfType(data[name], Style)) {
                var newData: Map<String, String> = [
                    "fgColor" => this.style.fgColor.blit,
                    "bgColor" => this.style.bgColor.blit,
                ];
                data[name] = newData;
            }
            if(name == "children") {
                var ncmd: Array<Map<String, Dynamic>> = [];
                for (widget in this.children) {
                    ncmd.push(widget.serialize());
                }
                data[name] = ncmd;
            }
        }
        data["typeName"] = this.getTypename();
        return data;
    }
    public static function fromJSON(json: String): Widget {
        return Widget.deserialize(Json.parse(json));
    }
    public function toJSON(): String {
        return Json.stringify(this.serialize());
    }
}

@:expose class Style {
    public var bgColor = Colors.black;
    public var fgColor = Colors.white;

    public function new() {};

}