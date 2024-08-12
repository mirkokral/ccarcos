package;
import nexui.*;
class NexUITest {
    public static function main() {
        var terma: nexui.Terminal = new nexui.Terminal(Sys.print);
        terma.write("Hello, world!");
    }
}