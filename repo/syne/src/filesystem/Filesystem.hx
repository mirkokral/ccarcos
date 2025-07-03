package filesystem;

import haxe.ds.Either;

// Make sure to override all function
class FileHandle {
    public dynamic function close(): Void{};
    public dynamic function seek(?whence: String, ?offset: Int): Void{};
    public dynamic function read(): String{return"";};
    public dynamic function readBytes(count: Int): String{return"";};
    public dynamic function readLine(): String{return"";};
    public dynamic function write(data: String): Void{};
    public dynamic function writeLine(data: String): Void{};
    public dynamic function flush(): Void{};
    public dynamic function getIfOpen(): Bool{return false;};
    public function new() {}
}

abstract class Filesystem {

    abstract public function open(path: String, mode: String): FileHandle;
    abstract public function list(path: String): Array<String>;
    abstract public function exists(path: String): Bool;
    abstract public function attributes(path: String): Hal.FileAttributes;
    abstract public function mkDir(path: String): Void;
    abstract public function move(source: String, destination: String): Void;
    abstract public function copy(source: String, destination: String): Void;
    abstract public function remove(path: String): Void;
    abstract public function getMountRoot(path: String): String;
    abstract public function getPermissions(file: String, ?user: String): Hal.FilePermissions;
}