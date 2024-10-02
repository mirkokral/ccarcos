

class Main {
    public static function main() {
        var k = new Kernel();
        try {
            k.run();
        } catch(e) {
            k.panic("Kernel error: " + e.toString(), "Kernel", 0, e.stack);
        }
    }
}