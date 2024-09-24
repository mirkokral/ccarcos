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
#if cos
import lua.Table.AnyTable;
#end
import Coloring;
import Vector;
import Render;

@:expose class SimpleContainer extends Widget {
	var offset = new Vector2f(0, 0);

	public function new(widgets:Array<Widget>) {
	#if cos
	if(widgets.push == null) {
			widgets = AnyTable.toArray(cast(widgets));
		}
	#end
		this.children = widgets;
	}

	public function getMostWidgetHeight(): Float {
		var w = 0.0;
		for(widget in this.children) {
			w = Math.max(w, widget.fixedY(this.width, this.height, true)+widget.fixedHeight(this.width, this.height, true));
		}
		return w;
	}

	public function renderImpl(screenwidth:Float, screenheight:Float, width: Float, height: Float):Array<PositionedRenderCommand> {
		var rc:Array<PositionedRenderCommand> = [];
		for (widget in this.children) {
			rc = rc.concat(widget.getPRenderCommands(width, height).map(e -> {
				e.x += offset.x;				
				e.y += offset.y;
				// if(e.char != " ") {

				// }
				return e;
			}));
		}
		return rc;
	}

	/**
	 * Note: All positions are relative to widget origin
	 * @param pos 
	 * @param mb 
	 */
	override public function onClick(pos:Vector2f, mb:MouseButton, wself:Bool) {
        for(e in children) {
			var xp: Vector2f = Vector2f.add(pos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
			var termSize = new Vector2f(lsw, lsh);
			var wwself = xp.x >= 0 && xp.y >= 0 && xp.x < e.fixedWidth(lsw, lsh, true) && xp.y < e.fixedHeight(lsw, lsh, true);
			if(wwself) {
				// trace('X: ${e.x}, Y: ${e.y}, XP: ${xp}, Type: ${e.getTypename()}');
				// #if cos
				// untyped __lua__("sleep(2)");
				// #end
				
			}
			// trace('wwSelf: ${wwself}');
			e.onClick(xp, mb, wwself);
            if(e.requestsRerender) requestRerender();
        }
	};

	/**
	 * Note: All positions are relative to widget origin
	 * @param startpos 
	 * @param pos 
	 * @param mb 
	 */
	override public function onDrag(startpos:Vector2f, pos:Vector2f, mb:MouseButton, wself:Bool) {
        // for(widget in children) {
			for(e in children) {
				var sxp: Vector2f = Vector2f.add(startpos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
				var xp: Vector2f = Vector2f.add(pos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
				var termSize = new Vector2f(lsw, lsh);
				var wwself = xp.x >= 0 && xp.y >= 0 && xp.x < e.width && xp.y < e.height;
				e.onDrag(sxp, xp, mb, wwself);
				if(e.requestsRerender) requestRerender();
			}        
		// }
	};

	/**
	 * Note: All positions are relative to widget origin
	 * @param startpos 
	 * @param pos 
	 * @param mb 
	 */
	override public function onClickUp(startpos:Vector2f, pos:Vector2f, mb:MouseButton, wself:Bool) {
        // for(widget in children) {
			for(e in children) {
				var sxp: Vector2f = Vector2f.add(startpos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
				var xp: Vector2f = Vector2f.add(pos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
				var termSize = new Vector2f(lsw, lsh);
				var wwself = xp.x >= 0 && xp.y >= 0 && xp.x < e.width && xp.y < e.height;
				e.onClickUp(sxp, xp, mb, wwself);
				if(e.requestsRerender) requestRerender();
			}        
		// }
	};

	/**
	 * Note: All positions are relative to widget origin
	 * @param pos 
	 * @param dir 
	 */
	override public function onScroll(pos:Vector2f, dir:Int, wself:Bool) {
        for(e in children) {
			var xp: Vector2f = Vector2f.add(pos, offset).addInts(-e.fixedX(lsw, lsh, true), -e.fixedY(lsw, lsh, true)).addInts(-1,-1);
			var termSize = new Vector2f(lsw, lsh);
			var wwself = xp.x >= 0 && xp.y >= 0 && xp.x < e.width && xp.y < e.height;
			e.onScroll(xp, dir, wwself);
            if(e.requestsRerender) requestRerender();
        }
	};

	/**
	 * On system event
	 * @param c 
	 */
	override public function onCustom(c:Array<Dynamic>) {
        for (widget in children) {
            widget.onCustom(c);
            if(widget.requestsRerender) requestRerender();
        }
    };

	override public function onRender() {
		for (widget in children) {
			widget.onRender();
			widget.requestsRerender = false;
		}
	}

	function deserializeAdditional(data:Dynamic):Widget {
		return this;
	}
	function serializeAdditional(): Map<String, Dynamic> {
		return [];
	}
	function additionalEditorFields(): Map<String, String> {return [];}

	public function getTypename() {
		return "Container";
	}
}
