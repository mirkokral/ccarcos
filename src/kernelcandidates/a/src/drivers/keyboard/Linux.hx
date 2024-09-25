package drivers.keyboard;

import haxe.Timer;
import sys.thread.Thread;
import drivers.keyboard.Global.KeyboardDriver;

class KeyboardDrv extends KeyboardDriver {
    public function getNextKeyPress(timeout: Int = -1): Float {
        var out: Null<Float> = null;
        #if(target.threaded)
        if(timeout > 0) {
            var t1 = Thread.create(() -> {
                var out2 = Sys.getChar(false);
                if(out == null) {
                    out = out2;
                }
            });
            
            
        } else {
            // Sys.println("No timeout");
            out = Sys.getChar(false);
        }
        
        #else
        out = Sys.getChar(false);
        #end
        var t1 = Sys.time();
        while (out == null) {
            Sys.sleep(0.05);
            var t2 = Sys.time();
            // Sys.println(t2 - t1);
            if(t2-t1 > timeout) {
                return -1;
            }
        }

        return out;
    }
}