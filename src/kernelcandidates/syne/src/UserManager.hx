import haxe.crypto.Sha256;
import haxe.Json;

class User {
	public var name = "";
	public var password = "";

	public function new(name:String, pass:String) {
		this.name = name;
		this.password = pass;
	}
}

class UserManager {
	public var users:Array<User> = [];
	public var kernel:Kernel;
	public var path:String = "/config/passwd";

	public function load(path:String = "/config/passwd") {
		var fH = kernel.rootFs.open(path, "r");
        this.path = path;
        this.users = Json.parse(fH.read());
        fH.close();
	}

	public function save(?path:String) {
		var p = path ?? this.path;
		var fH = kernel.rootFs.open(p, "w");
        fH.write(Json.stringify(this.users, null, " "));
        fH.close();
	}

	public function add(name:String, pass:String) {
		this.users.push(new User(name, pass));
		this.save();
	}

	public function remove(name:String) {
		this.users = this.users.filter((u) -> u.name != name);
		this.save();
	}

	public function validateUser(name:String, pass:String) {
		var hashedPassword = Sha256.encode(pass);
		return this.users.filter((u) -> u.name == name && u.password == hashedPassword).length > 0;
	}

	public function new(k:Kernel) {
		this.kernel = k;
	}
}
