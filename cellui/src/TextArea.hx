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

import Button.Transition;
import Button.Command;
import Render;
import haxe.DynamicAccess;
import Coloring;
import Vector;
import Coloring.Colors;
import Widget.Style;
import Externs;

@:expose class TextArea extends Widget {
	public var placeholder = "";
	public var value = "";
	public var isFocused = false;
	public var focused = false;
	public var cursorPos:Vector2f = new Vector2f(0, 0);
    public var scroll: Vector2f = new Vector2f(0, 0);
	public var ctrlPressed = false;

    public var onSubmit = new Command();
    public var onTab = new Command();

	public function new(x:Float, y:Float, placeholder:String) {
		this.x = x;
		this.y = y;
		this.placeholder = placeholder;
		this.style.bgColor = Colors.gray;
	}

	public override function onClick(pos:Vector2f, mb:MouseButton, wself:Bool) {
		if (focused && wself) {
			this.cursorPos.y = Math.min(pos.y, value.split("\n").length - 1);
			this.cursorPos.x = Math.min(pos.x, value.split("\n")[Std.int(this.cursorPos.y)].length);
		}
		focused = wself;
		requestRerender();
	}

	public override function onCustom(c:Array<Dynamic>) {
		if (!focused || (c[0] != "key" && c[0] != "char"))
			return;
		var cursorPosAsInt = 0;
		for (i in 0...Std.int(this.cursorPos.y)) {
			cursorPosAsInt += value.split("\n")[i].length + 1;
		}
		cursorPosAsInt += Std.int(this.cursorPos.x);
		if (c[0] == "key_up") {
			if (c[1] == Keys.control) {
				ctrlPressed = false;
			}
		}
		if (c[0] == "key") {
			if (c[1] == Keys.control) {
				ctrlPressed = true;
			}
            if(ctrlPressed && c[1] == Keys.u && focused) {
                value = "";
            }
			if (c[1] == Keys.backspace && !(this.cursorPos.y < 1 && this.cursorPos.x < 1)) {
				value = value.substring(0, cursorPosAsInt - 1) + value.substring(cursorPosAsInt);
				this.cursorPos.x--;
				if (this.cursorPos.x < 0) {
					this.cursorPos.y--;
					this.cursorPos.x = value.split("\n")[Std.int(this.cursorPos.y)].length;
				}
			}
            if (c[1] == Keys.navhome) {
                this.cursorPos.x = 0;
            }
            if (c[1] == Keys.navend) {
			    this.cursorPos.x = value.split("\n")[Std.int(this.cursorPos.y)].length;
            }
			if (c[1] == Keys.delete) {
				value = value.substring(0, cursorPosAsInt) + value.substring(cursorPosAsInt + 1);
			}
			if (c[1] == Keys.left) {
				this.cursorPos.x--;
				if (this.cursorPos.x < 0) {
					if (this.cursorPos.y > 0) {
						this.cursorPos.y--;
						this.cursorPos.x = value.split("\n")[Std.int(this.cursorPos.y)].length;
					} else {
						this.cursorPos.x++;
					}
				}
				this.cursorPos.y = Math.min(this.cursorPos.y, value.split("\n").length - 1);
				this.cursorPos.x = Math.min(this.cursorPos.x, value.split("\n")[Std.int(this.cursorPos.y)].length - 1);
			}
			if (c[1] == Keys.right) {
				this.cursorPos.x++;
				if (this.cursorPos.x > value.split("\n")[Std.int(this.cursorPos.y)].length) {
					this.cursorPos.x--;
					if (value.split("\n").length > this.cursorPos.y + 1) {
						this.cursorPos.y++;
						this.cursorPos.x = 0;
					};
				}
				this.cursorPos.y = Math.min(this.cursorPos.y, value.split("\n").length - 1);
				this.cursorPos.x = Math.min(this.cursorPos.x, value.split("\n")[Std.int(this.cursorPos.y)].length);
			}
			if (c[1] == Keys.up) {
				this.cursorPos.y--;
				this.cursorPos.y = Math.min(this.cursorPos.y, value.split("\n").length - 1);
				this.cursorPos.x = Math.min(this.cursorPos.x, value.split("\n")[Std.int(this.cursorPos.y)].length);
			}
			if (c[1] == Keys.down) {
				this.cursorPos.y++;
				this.cursorPos.y = Math.min(this.cursorPos.y, value.split("\n").length - 1);
				this.cursorPos.x = Math.min(this.cursorPos.x, value.split("\n")[Std.int(this.cursorPos.y)].length);
			}
			if (c[1] == Keys.enter && this.height > 1) {
				value = value.substring(0, cursorPosAsInt) + "\n" + value.substring(cursorPosAsInt);
				this.cursorPos.y++;
				this.cursorPos.x = 0;
			} else if (c[1] == Keys.enter && this.height <= 1) {
                this.onSubmit.execute(this, lsw, lsh);
            }
			requestRerender();
		} else if (c[0] == "char") {
			value = value.substring(0, cursorPosAsInt) + c[1] + value.substring(cursorPosAsInt);
			this.cursorPos.x++;
			requestRerender();
		}
	}

	public override function onRender() {
		if (this.focused && this.cursorPos.x+this.scroll.x < this.fixedWidth(lsw, lsh) && this.cursorPos.y+this.scroll.y < this.fixedHeight(lsw, lsh)) {
			var ts = this.getWman().term.getSize();
			this.getWman().term.setCursorPos(Std.int(this.fixedX(ts.x, ts.y, false) + this.cursorPos.x + this.scroll.x + 1), Std.int(this.fixedY(ts.x, ts.y, false) + this.cursorPos.y + this.scroll.y + 1));
			this.getWman().term.setCursorBlink(true);
		}
	};

	public function renderImpl(screenwidth:Float, screenheight:Float, width:Float, height:Float):Array<PositionedRenderCommand> {
		this.cursorPos.y = Math.min(this.cursorPos.y, value.split("\n").length - 1);
		this.cursorPos.x = Math.min(this.cursorPos.x, value.split("\n")[Std.int(this.cursorPos.y)].length);
		var text = value.length > 0 ? value : placeholder;
		var o:Array<PositionedRenderCommand> = [];
		var cposx = 0;
		var cposy = 0;
		for (i in 0...text.length) {
			var char = text.charAt(i);
			if (char == "\n") {
				cposx = 0;
				cposy++;
			} else {
				o.push(new PositionedRenderCommand(cposx+this.scroll.x, cposy+this.scroll.y, char, this.id, value.length > 0 ? this.style.fgColor : Colors.lightGray, this.style.bgColor));
				cposx++;
			}
		}
		return o;
	}

	public function getTypename():String {
		return "TextArea";
	}

	private function serializeAdditional():Map<String, Dynamic> {
		return ["placeholder" => this.placeholder];
	}

	private function deserializeAdditional(dt:Dynamic):Widget {
		var data:DynamicAccess<Dynamic> = dt;
		this.placeholder = data.get("placeholder");
		return this;
	}

	public function additionalEditorFields():Map<String, String> {
		return ["placeholder" => "Placeholder"];
	}
}
