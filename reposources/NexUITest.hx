package;
import nexui.Terminal;
extern class _G {
    public static extern var term:nexui.Terminal;
}
class NexUITest {
    public static function main() {
        var terma: nexui.Terminal = new nexui.Terminal(Sys.print);
        terma.write("Hello, world!");
        terma.write(Sys.environment()["LINES"]);
    }
}