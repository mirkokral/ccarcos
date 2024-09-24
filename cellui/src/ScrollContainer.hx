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

import Vector.Vector2f;

/**
 * A container with scrolling functionality. Fundementally the same as simplecontainer.
 */
@:expose class ScrollContainer extends SimpleContainer { // This one is the same as simplecontainer, but it has scroll functionality
    public override function getTypename():String {
        return "ScrollContainer";
    }
    public override function onScroll(pos:Vector2f, dir:Int, wself:Bool) {
        if(!wself) return;
        this.offset.y += -dir;
        this.offset.y = Math.min(Math.max(this.offset.y, -(this.getMostWidgetHeight()-this.fixedHeight(this.lsw, this.lsh))), 0);
        requestRerender();
    }
}