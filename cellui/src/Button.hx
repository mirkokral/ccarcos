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

import Coloring;
import Vector;
import Render;
import haxe.io.BufferInput;
import hxease.Linear.LinearEaseNone;
#if !cos
import haxe.Timer;
#end
import haxe.Exception;
import haxe.macro.Expr.Error;
import haxe.DynamicAccess;
import UI.Runner;
#if cos
import lua.Lua;
#end
import hxease.Back;

@:expose class Transition {
    public var direction: String= "left";
    public var anim: String = "over";
    public var curve: String = "easein";
    public var duration: Int = 1000;
    public function new(?direction: String, ?anim: String, ?curve: String, ?duration: Int) {
        if(direction != null) this.direction = direction;
        if(anim != null) this.anim = anim;
        if(curve != null) this.curve = curve;
        if(duration != null) this.duration = duration;
    }
    public function run(callback: (e: Float) -> Void, min: Float, max: Float) {
        var l = max - min;
        var divider = 2;
        var el = l/divider;
        var la = duration/el;
        //trace("asd2", Std.string(la));
        #if cos
        for (i in (0...Std.int(la))) {
            callback(this.getValue(i/l)*l+ min);
            //trace(Std.string(i*la));
            untyped __lua__("sleep((self.duration / 1000) / la)");
        }
        #else
        var i = 0;
        var t = new Timer(Std.int(la));
        t.run = () -> {
            //trace("asdf", Std.string(i/l), Std.string(la));
            callback(this.getValue(i/el)*l+ min);
            if(i == el) {t.stop(); return;}
            i++;
        }
        #end
    };

    public function copy(): Transition {
        return new Transition(this.direction, this.anim, this.curve, this.duration);
    }
    public function runForScreens(callback: (prevx: Int, prevy: Int, newx: Int, newy: Int, firstOnTop: Bool, progress: Float) -> Void, screenwidth: Int, screenheight: Int) {
        function cb(n: Float) {
            var e = Std.int(n);
            
            switch(anim) {
                case "slide":
                    switch(direction) {
                        case "left":
                            callback(e, 0, e-screenwidth, 0, false, n/screenwidth);
                        case "right":
                            callback(-e, 0, screenwidth - e, 0, false, n/screenwidth);
                            // xae -= e;
                        case "top":
                            callback(0, -e, 0, screenheight - e, false, n/screenheight);
                        case "bottom":
                            callback(0, e, 0, e-screenheight, false, n/screenheight);

                    }
                case "over":
                    switch(direction) {
                        case "left":
                            callback(0, 0, e-screenwidth, 0, false, n/screenwidth);
                        case "right":
                            callback(0, 0, screenwidth - e, 0, false, n/screenwidth);
                            // xae -= e;
                        case "top":
                            callback(0, 0, 0, screenheight - e, false, n/screenheight);
                        case "bottom":
                            callback(0, 0, 0, e-screenheight, false, n/screenheight);

                    }
                case "under":       
                    switch(direction) {
                        case "left":
                            callback(e, 0, 0, 0, true, n/screenwidth);
                        case "right":
                            callback(-e, 0, 0, 0, true, n/screenwidth);
                            // xae -= e;
                        case "top":
                            callback(0, -e, 0, 0, true, n/screenheight);
                        case "bottom":
                            callback(0, e, 0, 0, true, n/screenheight);

                    }
            }
        }
        switch(this.direction) {
            case "left" | "right":
                run(cb, 0, screenwidth);
            case "top" | "bottom":
                run(cb, 0, screenheight);

        }
    }
    public function getValue(ratioa: Float): Float {
        #if cos
        var ratio = ratioa*1.5;
        #else
        var ratio = ratioa;
        #end 
        switch(curve) {
            case "easein":
                return new BackEaseIn(0).calculate(ratio);
            case "easeout":
                return new BackEaseOut(0).calculate(ratio);
            case "ease":
                return new BackEaseInOut(0).calculate(ratio);
            default:
                return new LinearEaseNone().calculate(ratio);
        }
    }
}

@:expose class Command {
    public var type: String = "execLua";
    public var value: String = "-- Target is the widget which runs this command\nlocal target = { ... }";
    public var transition: Transition = new Transition("left", "over", "easein");  
    public function new(?type: String, ?value: String, ?transition: Transition) {
        if(type != null) this.type = type;
        if(value != null) this.value = value;
        if(transition != null) this.transition = transition;
    }
    public function serialize(): Dynamic {
        return {
            type: "Command",
            ctype: this.type,
            value: this.value,
            transition: {
                dir: this.transition.direction,
                anim: this.transition.anim,
                curve: this.transition.curve,
                duration: this.transition.duration
            }
        }
    }
    public static function deserialize(d: DynamicAccess<Dynamic>): Command {
        if(!d.exists("type") || d.get("type") != "Command") {
            throw new Exception("Not a command.");
        }
        var t: DynamicAccess<Dynamic> = d.get("transition");
        return new Command(d.get("ctype"), d.get("value"), new Transition(t.get("dir"), t.get("anim"), t.get("curve"), t.get("duration")));
    }

    public function execute(runner: Widget, screenwidth: Float, screenheight: Float) {
        switch(this.type) {
            case "goToScreen":
                var s1 = new Buffer(Std.int(screenwidth), Std.int(screenheight));
                var s2 = new Buffer(Std.int(screenwidth), Std.int(screenheight));
                for (command in runner.getWman().current().getPRenderCommands(screenwidth, screenheight, false)) {
                    s1.addPRC(command);
                }
                // trace(runner.getWman().screens[Std.parseInt(this.value)]);
                // #if cos
                // untyped __lua__("sleep(5)");
                // #end
                runner.getWman().screens[Std.parseInt(this.value)].x = 0;
                runner.getWman().screens[Std.parseInt(this.value)].y = 0;
                runner.getWman().screens[Std.parseInt(this.value)].width = Std.int(runner.getWman().term.getSize().x);
                runner.getWman().screens[Std.parseInt(this.value)].height = Std.int(runner.getWman().term.getSize().y);
                for (command in runner.getWman().screens[Std.parseInt(this.value)].getPRenderCommands(screenwidth, screenheight, false)) {
                    s2.addPRC(command);
                }

                this.transition.runForScreens((prevx, prevy, newx, newy, firstOnTop, progress) -> {
                    var b = new Buffer(Std.int(screenwidth), Std.int(screenheight));
                    if(firstOnTop) {
                        b.blitBuffer(s2, newx, newy);
                        b.blitBuffer(s1, prevx, prevy);
                    } else {
                        b.blitBuffer(s1, prevx, prevy);
                        b.blitBuffer(s2, newx, newy);
                    }
                    b.draw(runner.getWman().term);
                }, Std.int(screenwidth), Std.int(screenheight));
                runner.getWman().currentScreen = Std.parseInt(this.value);
                runner.requestRerender();
                runner.requestRerender();
            case "execLua":
                #if cos
                var l = Lua.load(this.value);
                if(l.func == null) {
                    //trace("Cannot load lua function because of " + l.message);
                }
                l.func(runner);
                #else
                //trace("No lua support");
                #end
        }
    }
}

@:expose class Button extends SimpleContainer {
    public var command: Command = null;
    public function new(widgets: Array<Widget>, command: Command) {
        super(widgets);
        this.command = command;
        // this.typeN
    }	
    override function getTypename(): String {
        return "Button";
    }
    override function deserializeAdditional(data:Dynamic):Widget {
        this.command = Command.deserialize(data.cmd);
        
		
        return this;
	}
	override function serializeAdditional(): Map<String, Dynamic> {
		// this.cmd = ;
        return ["cmd" => this.command.serialize()];
	}
	override function additionalEditorFields(): Map<String, String> {return ["command" => "On Click"];}

    override function onClick(pos: Vector2f, mb: MouseButton, wself:Bool) {
        Runner.log('Position: ${pos.x}, ${pos.y} Self: ${wself}');
        if(wself) {
            this.command.execute(this, this.lsw, this.lsh);
        }
    }

}