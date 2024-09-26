package kernel;

import kernel.Thread.XG;
import kernel.Driver.Since;
import kernel.Driver.ClockDriver;
import kernel.Driver.DriverProvides;
import haxe.PosInfos;

class Logger {
    public static var logBuf: String = "";
    public static function log(text: String, ?pos: PosInfos) {
        var d: Null<ClockDriver> = Drivers.getDriverByProvides(DriverProvides.Clock);
        
        var lString = "";
        if(d == null) {
            lString = '[${pos.fileName}:${pos.lineNumber}] ${text}';
        } else {
            lString = '[${d.getEpoch(Since.ComputerStart)}] [${pos.fileName}:${pos.lineNumber}] ${text}';
        }
        logBuf += lString + "\n";
        // Sys.println(lString);
    }
}