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

@:expose class Vector2f {
    public var x: Float = 0.0; 
    public var y: Float = 0.0; 
    public function new(x: Float, y: Float) {
        this.x = x;
        this.y = y;
    }

    public function addInts(x: Float, y: Float) {
        return new Vector2f(this.x+x, this.y+y);
    }

    @:op(A + B)
    public static function add(vec1: Vector2f, vec: Vector2f): Vector2f  {
        return new Vector2f(vec1.x+vec.x, vec1.y+vec.y);
    }
}