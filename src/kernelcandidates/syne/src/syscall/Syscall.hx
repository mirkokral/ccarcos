package syscall;

import haxe.Constraints.Function;

class Syscall {
    public var name = "";
    public var callback: (...d: Dynamic) -> Array<Dynamic> = null;
    public function new(name: String, callback: (...d: Dynamic) -> Array<Dynamic>) {
        this.name = name;
        this.callback = callback;
    }
}
