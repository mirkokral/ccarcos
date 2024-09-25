package drivers.terminal;

#if CraftOS
import drivers.terminal.CraftOS.TerminalBackend in TERM;
#else
import drivers.terminal.Linux.TerminalBackend in TERM;
#end

class Terminal extends TERM {}