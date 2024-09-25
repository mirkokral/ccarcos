package kernel;

abstract class Hook {
    public function new() {};
    abstract public function init(): Void;
    abstract public function bg(ev: Array<Dynamic>): Void;
    abstract public function deinit(): Void;
}