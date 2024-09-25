package kernel.hooks;

import lua.Table;
import kernel.Drivers;
import haxe.Exception;
import Externs.CCFileSystem;
import kernel.Driver;
import kernel.Driver.FileSystemDriver;
import kernel.Hook;

class CCFileSystemDriver extends FileSystemDriver {
    var rootpath = "/";
    public function new(path: String = "/") {
        super();
        this.rootpath = path;
        if(CCFileSystem.isDriveRoot(rootpath)) {
            this.deviceName = CCFileSystem.getDrive(rootpath);
        } else {
            this.deviceName = StringTools.replace(rootpath, "/", ".");
        }
    }

    public function init() {
    }

    public function deinit() {}


    public function bg(ev: Array<Dynamic>) {}

    public function read(path:String):String {
        var n = CCFileSystem.open(path, "r");
        if(n.out == null) throw new Exception(n.error);
        
        var rv: String = n.out.readAll();
        n.out.close();
        return rv;

    }

    public function readBytes(path:String, bytes:Int, fromPos:Int = 0):Array<Int> {
        var n = CCFileSystem.open(path, "rb");
        if(n.out == null) throw new Exception(n.error);
        n.out.seek(fromPos);
        var rv: Array<Int> = n.out.read(bytes);
        n.out.close();
        return rv;
    }

    public function write(path:String, text:String) {
        var n = CCFileSystem.open(path, "w");
        if(n.out == null) throw new Exception(n.error);
        n.out.write(text);
        n.out.close();
    }

    public function writeByte(path:String, byte: Int) {
        var n = CCFileSystem.open(path, "wb");
        if(n.out == null) throw new Exception(n.error);
        n.out.write(byte);
        n.out.close();
    }

    public function append(path:String, text:String) {
        var old = read(path);
        write(path, old+text);
    }

    public function exists(path:String):Bool {
        return CCFileSystem.exists(path);
    }

    public function isReadOnly(path: String, ?user:String):Bool {
        return CCFileSystem.isReadOnly(path); // Computercraft's fs has no permission system
    }

    public function list(dir:String):Array<String> {
        var n = CCFileSystem.list(dir);
        return Table.toArray(n);
    }

    public function type(path:String):FileType {
        return CCFileSystem.isDir(path) ? FileType.Directory : FileType.File;
    }

    public function dataread():String {
        return "";
    }


    public function datawrite(s:String) {

    }
}

class CCFSDriverHook extends Hook {

    public function init() {
        Drivers.add(new CCFileSystemDriver("/"));
    }

    public function deinit() {}

    public function bg(ev:Array<Dynamic>) {}
}