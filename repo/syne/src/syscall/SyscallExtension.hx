package syscall;


abstract class SyscallExtension {
    public function new() {}
    abstract public function getSyscalls(kernel: Kernel): Array<Syscall>;
}