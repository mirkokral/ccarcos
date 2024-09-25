package bios;

import haxe.macro.Compiler;
import lua.Lua;
import sys.FileSystem;
import globals.Globals;
import bios.menu.Menu;
import drivers.terminal.Auto;
import drivers.keyboard.Auto;


var term = new Terminal();
var kb = new Keyboard();

var lines = [
"X   X  XXX  XXXXX",
" X X  X   X     X",
"  X   XXXX     X ",   
" X X  X       X  ",
"X   X  XXXX  X  bios",
];

class Bios {
    public static function main() {
        Compiler.includeFile("includes/fsrunner.lua");
        term.setBGColor(Colors.black);
        term.clear();
        term.setCursorPos(2, 2);
        term.setFGColor(Colors.blue);
        for (line in lines) {
            for (i in 0...line.length) {
                if(line.charAt(i) != "X") {
                    term.setBGColor(Colors.black);
                } else {
                    term.setBGColor(Colors.lightBlue);
                }
                if(line.charAt(i) == "X") {
                    term.write(" ");
                } else {
                    term.write(line.charAt(i));
                }
            };
            term.write("\n");
            term.setCursorPosRelative(1, 0);
        }
        term.write("\n");
        term.setCursorPosRelative(1, 0);
        term.setBGColor(Colors.black);
        term.setFGColor(Colors.lightGray);
        term.write("version ");
        term.setFGColor(Colors.blue);
        term.write(Globals.version);
        term.write("\n");
        term.setFGColor(Colors.gray);
        if(!FileSystem.exists("/systems")) {
            term.setCursorPosRelative(1, 0);
            term.write("System-storing directory does not exist.");
            FileSystem.createDirectory("/systems");
        }
        
        term.setFGColor(Colors.blue);
        term.setCursorPosRelative(1, 0);
        term.write("Press any key to enter menu, or wait 2s to boot.");
        if(kb.getNextKeyPress(2) != -1) {
            var menu = new Menu("xe7bios Setup Utility");
            function buildPage1() {
                menu.entries = [];
                menu.add(new Entry("Architecture: " + Lua._VERSION, (parent, index) -> {
                    return false;
                    
                }, false));
                menu.add(new Entry("", (p, i) -> {return false;}, false));
                for(i in FileSystem.readDirectory("/systems")) {
                    menu.add(new Entry(i, (parent, index) -> {
                        untyped runfs("/systems/" + i);
                        
                        return true;
                    }, true, (key) -> {
                        if(key == 261) {
                            FileSystem.deleteDirectory("/systems/" + i);
                            buildPage1();
                        }
                    }));
        
                }
                menu.add(new Entry("", (p, i) -> {return false;}, false));
                menu.add(new Entry("Add new OS entry", (parent, index) -> {
                    var xi = 1;
                    while(FileSystem.exists("/systems/OS " + xi)) {
                        xi++;
                    }
                    FileSystem.createDirectory("/systems/OS " + xi);
                    buildPage1();
                    return false;
                }, true));
                menu.add(new Entry("CraftOS Shell", (parent, index) -> {
                    term.setBGColor(Colors.black);
                    term.setFGColor(Colors.white);
                    term.clear();
                    term.setCursorPos(1, 1);
                    term.write("To rename an OS, go to the systems/\n dir and rename sepcified directory.\n");
                    untyped __lua__("error()");
                    return false;
                }, true));
            }
            buildPage1();
            menu.run(term, kb, false);
        };
        while(true) {
            term.write(Std.string(kb.getNextKeyPress()) + "\n");
        }
        // term.write('\nTerm size: ${term.size.x}, ${term.size.y}');
        
    }
    
}
