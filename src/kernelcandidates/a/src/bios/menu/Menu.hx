package bios.menu;

import drivers.keyboard.Global.KeyboardDriver;
import globals.Globals;

class Entry {
    public var selectable = false;
    public var name = "(empty)";
    public dynamic function callback(parent: Menu, index: Int): Bool {
        return false;
    }
    public dynamic function onKey(key: Float) {

    }
    public function new(name: String, callback: (parent: Menu, index: Int) -> Bool, selectable: Bool = false, onKey: Null<(key:Float) -> Void> = null) {
        this.name = name;
        this.callback = callback;
        this.selectable = selectable;
        this.onKey = onKey;
    }
}

class Menu {
    public var entries: Array<Entry> = [];
    public var name = "(empty)";
    public var selected = 0;
    public var scroll = 0;
    public var selectableEntriesCount = 0;
    public var actualSelectedPos = 0;

    public function redraw(out: Output) {
        out.setBGColor(Colors.gray);
        out.clear();
        out.setCursorPos(1, 1);
        out.setBGColor(Colors.blue);
        out.setFGColor(Colors.black);
        if(name.length > 40) {
            
            out.write(" " + name.substring(0, out.size.x-6) + "...");
        } else {
            out.write(" " + name);
        }
        out.write(StringTools.rpad("", " ", Std.int(out.size.x - Math.min(name.length+1, out.size.x-3))));
        var index = -1;
        for (acti => value in entries) {
            if(acti-scroll >= 0 && acti-scroll <= out.size.y) {
                if (value.selectable) {
                    index++;
                }
                if(selected == index && value.selectable) {
                    out.setBGColor(Colors.lightGray);
                    out.setFGColor(Colors.black);
                    this.actualSelectedPos = acti;
                } else {
                    out.setBGColor(Colors.gray);
                    out.setFGColor(Colors.white);
    
                }
                out.setCursorPos(1, acti+3-scroll);
                out.write(" " + value.name + StringTools.rpad("", " ", Std.int(out.size.x - Math.min(value.name.length+1, out.size.x))));
            }
        }
        selectableEntriesCount = index;
        
    }

    public function run(out: Output, keyboard: KeyboardDriver, stopOnSelect: Bool = true) {
        var running = true;
        this.redraw(out);
        while(running) {
            var key = keyboard.getNextKeyPress();
            if(key == 264) {
                this.selected = (this.selected + 1) % (this.selectableEntriesCount+1);
            }
            if(key == 265) {
                this.selected = (this.selected - 1);
                if(this.selected < 0) {
                    this.selected = this.selectableEntriesCount;
                }
            }
            if(key == 257) {
                var a = this.entries[this.actualSelectedPos];
                if(a.callback(this, this.actualSelectedPos)){
                    break;
                }
                if(stopOnSelect) {
                    break;
                }
            }
            if(this.entries[this.actualSelectedPos].onKey != null) {
                this.entries[this.actualSelectedPos].onKey(key);
            }
            this.redraw(out);
        }
        out.setFGColor(Colors.white);
        out.setBGColor(Colors.black);
        out.clear();
        out.setCursorPos(1, 1);
    }

    public function add(entry: Entry) {
        entries.insert(entries.length+1, entry);
    }

    public function new(name: String) {
        this.name = name;
    } 

}