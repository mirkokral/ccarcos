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

import typedefs.Terminal;
import Coloring;

@:expose class RenderCommand {
    public var char: String;
    public var belongsToID: String;
    public var fgColor: Color = Colors.white;
    public var bgColor: Color = Colors.black;
    public function new(char: String, belongsToID: String, ?fgColor: Color, ?bgColor: Color) {
        this.char = char;
        this.belongsToID = belongsToID;
        if(fgColor != null) this.fgColor = fgColor;
        if(bgColor != null) this.bgColor = bgColor;
    }
}
@:expose class PositionedRenderCommand extends RenderCommand {
    public var x: Float;
    public var y: Float;
    public function new(x: Float, y: Float, char: String, belongsToID: String, ?fgColor: Color, ?bgColor: Color) {
        this.x = x;
        this.y = y;
        super(char, belongsToID, fgColor, bgColor);
    }
}


@:expose class Buffer {
    /**
     * Buffer width
     */
    public var width: Int = 2;
    /**
     * Buffer height
     */
    public var height: Int = 2;
    /**
     * The 2-dimentional array containing buffer data
     */
    public var matrix: Array<Array<RenderCommand>> = [];
    /**
     * Reinitializes the buffer, clearing the screen
     */
    public function reinitBuffer(?bgcolor: Color) {
        if(bgcolor != null) bgcolor = Colors.black;
        matrix = [
                for(x in 0...height) [for(y in 0...width) new RenderCommand(" ", "Renderer")]
        ];  
    }

    /**
     * Adds a positioned render command.
     * @param rc The PRC to draw on the buffer
     */
    public function addPRC(rc: PositionedRenderCommand) {
        // Sys.println(rc.x);
        // Sys.println(rc.y);
        // rc.x--;
        if(matrix.length > Std.int(rc.y) && rc.y >=0 && rc.x >=0) {
            if(matrix[Std.int(rc.y)].length > Std.int(rc.x)) {
                matrix[Std.int(rc.y)][Std.int(rc.x)] = rc;
            }
        }
    }   

    public function draw(term: Terminal) {
        // Sys.println("drawin");
        // term.clear();
        term.setCursorBlink(false);
        for (index => array in matrix) {
            // Sys.println("smus");
            var t = "";
            var fg = "";
            var bg = "";
            for (command in array) {
                t += command.char;
                fg += command.fgColor.blit;
                bg += command.bgColor.blit;
            }
            term.setCursorPos(1, index+1);
            // term.write(t);
            term.blit(t, fg, bg);
            
        }
    }

    /**
     * Blits buffer onto this buffer
     * @param buffer The buffer to blit from
     * @param ox Offset X
     * @param oy Offset Y
     */
    public function blitBuffer(buffer: Buffer, ox: Float, oy: Float) {
        for (iy => line in buffer.matrix) {
            for (ix => command in line) {
                var fixedX = ix + ox;
                var fixedY = iy + oy;
                if(matrix.length > fixedY && matrix[Std.int(fixedY)].length > fixedX && fixedY >=0 && fixedX>=0) {
                    matrix[Std.int(fixedY)][Std.int(fixedX)] = command;
                } 
            }
        }
    }

    /** 
     * Creates the buffer
     * @param width buffer width
     * @param height buffer height 
     */
    public function new(width: Int, height: Int) {
        this.width = width;
        this.height = height;
        reinitBuffer();
    }   
}

@:expose class Renderer {
    /**
     * The buffer.
     */
    public var buffer1 = new Buffer(0, 0);

    /**
     * The current buffer, uses boolean for memory efficiency on some platforms
     * False = 1st buffer
     * True = 2nd buffer
     */
    public var currentBuffer = false;

    public var term: Terminal;

    public function new(terminal: Terminal) {
        this.term = terminal;
    }

    public function renderToBuffer(scr: Widget, ox: Int, oy: Int, buffer: Buffer) {

        scr.width = buffer.width;
        scr.height = buffer.height;
        scr.x = 0;
        scr.xa = 0;
        scr.y = 0;
        scr.ya = 0;
        scr.parent = null;
        for (rc in scr.getPRenderCommands(buffer.width, buffer.height, false)) {
            rc.x += ox;
            rc.y += oy;
            buffer.addPRC(rc);
        }
    }

    public function render(scr: Widget) {

        buffer1.reinitBuffer();
        renderToBuffer(scr, 0, 0, buffer1); 
        buffer1.draw(term);
    }

    public function resize(x: Float, y: Float) {
        this.buffer1.width = Std.int(x+1); 
        this.buffer1.height = Std.int(y+1);
        this.buffer1.reinitBuffer();

    }



}
