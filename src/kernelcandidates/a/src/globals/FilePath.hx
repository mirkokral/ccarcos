package globals;

class FilePath {
    public var path: Array<String> = [];
    public function new(sPath: String) {
        this.path = sPath.split("/");
        var newp: Array<String> = [];
        for (s in this.path) {
            if(s == "..") {
                newp.pop();
            } else if (s == "." || s == "") {

            } else {
                newp.insert(newp.length, s);
            }
        }
        this.path = newp;
    }

    @:op(A / B)
    public function add(s: String) {
        var newPath = path;
        newPath.insert(newPath.length, s);
        return new FilePath(newPath.join("/"));
    }
}