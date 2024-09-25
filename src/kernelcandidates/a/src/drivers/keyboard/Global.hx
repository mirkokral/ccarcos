package drivers.keyboard;

abstract class KeyboardDriver {
    abstract public function getNextKeyPress(timeout: Int = -1): Float;
    public function new() {}
}