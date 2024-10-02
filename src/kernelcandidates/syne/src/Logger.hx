import lua.Debug;
import haxe.PosInfos;
import Kernel.Out;
import Kernel.KernelConfig;

class Logger {
    public static var kLog: String = "";
    public static function log(message: String, level: Int, useDebug: Bool = false, showPos: Bool = true, ?posInfos: PosInfos) {
        var posstr = "";
        if(showPos) {
            if(posInfos != null && !useDebug) {
                posstr = '${posInfos.fileName}:${posInfos.lineNumber} ';
            } else if(Debug != null) {
                var dInfo = Debug.getinfo(2);
                posstr = '${dInfo.source}:${dInfo.currentline}: ';
            }
        }
        
        var ut = Hal.computer.uptime();
        var logStr = "[" + StringTools.rpad(ut + "" + (Math.floor(ut) == ut ? ".0" : ""), "0", 4 + (""+Math.floor(ut)).length) + "] " + message + "\n";
        kLog += logStr;
        if(level >= KernelConfig.logLevel) {
            Out.write(logStr);
        }
        
    }
}