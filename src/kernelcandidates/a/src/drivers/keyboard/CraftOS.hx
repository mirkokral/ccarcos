package drivers.keyboard;

import lua.Coroutine;
import Externs.A;
import Externs.OS;
import drivers.keyboard.Global.KeyboardDriver;

class KeyboardDrv extends KeyboardDriver {
    public function getNextKeyPress(timeout: Int = -1): Float {
        var timerID: Int = -1;
        if(timeout > 0) {
            timerID = OS.startTimer(timeout);
        }
        while(true) {
            var event: A = Coroutine.yield();
            if(event.t1 == "timer" && event.t2 == timerID) {
                return -1;
            } else if(event.t1 == "key") {
                return event.t2;
            }
        }
        return 69;
    }
}