package nexui;
class Terminal {
    private var cursorPos:Array<Int> = [0, 0];
    public dynamic function printFunction(toprint: String) {
        Sys.print(toprint);
    }
    public dynamic function write(text: String): Void {
        printFunction(text);
    }
    public dynamic function scroll(y: Int) {
        printFunction("Scrolling not implemented!");
    }
    public dynamic function redirect(target: Terminal) {
        if(target.printFunction != null) {
            this.printFunction = target.printFunction;
        } else {
            this.redirect = target.redirect;
            this.current = target.current;
        }
    }
    public dynamic function native() {
        return this;
    }
    public dynamic function current() {
        return this;
    }
    public function new(printFunction: (toprint: String) -> Void) {
        this.printFunction = printFunction;
    }
}

extern var term:Terminal;
