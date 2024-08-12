import sys.Http;
import haxe.Int32;
import haxe.io.Output;

abstract class Attachment {
    public function attach(gss: GalvanizedSquareSteel) {
        gss.attachments.push(this);
    }

}

class EcoFriendlyWoodVeneir extends Attachment {
    var EcoFriendlyness:Int32 = 10;
    public function new() {

    }
}

class GalvanizedSquareSteel {
    public var attachments: Array<Attachment> = [];
    public function new() {
        
    }
}
class Test {
    static public function main() {
        var steel = new GalvanizedSquareSteel();
        var wood = new EcoFriendlyWoodVeneir();
        wood.attach(steel);

        Sys.println(steel.attachments);

        Sys.println(Http.requestUrl("https://raw.githubusercontent.com/luvit/luv/master/LICENSE.txt"));
    }
}