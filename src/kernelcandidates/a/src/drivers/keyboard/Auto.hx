package drivers.keyboard;

#if CraftOS
import drivers.keyboard.CraftOS.KeyboardDrv;
#else
import drivers.keyboard.Linux.KeyboardDrv;
#end

class Keyboard extends KeyboardDrv {}