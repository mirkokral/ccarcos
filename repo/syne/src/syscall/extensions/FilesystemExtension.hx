package syscall.extensions;

import lua.Table;

class FilesystemExtension extends SyscallExtension {
	var openFiles:Table<Int, filesystem.Filesystem.FileHandle> = Table.create();
	var sigma = 0;

	public function getSyscalls(kernel:Kernel):Array<Syscall> {
		function checkPipe(handle:Int) {
			if (openFiles[handle] == null || !openFiles[handle].getIfOpen()) {
				throw "Broken pipe";
			}
		}
		return [
			new Syscall("fs.getPermissions", function(...d:Dynamic) {
				return [kernel.rootFs.getPermissions(d[0], d[1])];
			}),
			new Syscall("fs.open", function(...d:Dynamic) {
				var file = d[0];
				var mode = d[1];
				if (mode == "r" || mode == "a" || mode == "r+" || mode == "w+" || mode == "rb") {
					if (!kernel.rootFs.getPermissions(d[0], d[1]).read) {
						throw "No permission for this action";
					}
				}
				if (mode == "w" || mode == "w+" || mode == "r+" || mode == "a" || mode == "wb") {
					if (!kernel.rootFs.getPermissions(d[0], d[1]).write) {
						throw "No permission for this action";
					}
				}
				var handle = kernel.rootFs.open(file, mode);
				sigma++;
				openFiles[sigma] = handle;
				return [sigma];
			}),
			new Syscall("fs.attributes", function(...d: Dynamic) {
				return [kernel.rootFs.attributes(d[0])];
			}),
			new Syscall("fs.fClose", function(...d:Dynamic) {
				var handle = d[0];
				checkPipe(handle);
				openFiles[handle].close();
				openFiles[handle] = null;
				return [];
			}),
			new Syscall("fs.fSeek", function(...d:Dynamic) {
				var handle = d[0];
				var offset = d[1];
				var whence = d[2];
				checkPipe(handle);
				openFiles[handle].seek(offset, whence);
				return [];
			}),
			new Syscall("fs.fRead", function(...d:Dynamic) {
				var handle = d[0];
				checkPipe(handle);
				return [openFiles[handle].read()];
			}),
			new Syscall("fs.fReadBytes", function(...d:Dynamic) {
				var handle = d[0];
				var length = d[1];
				checkPipe(handle);
				return [openFiles[handle].readBytes(length)];
			}),
			new Syscall("fs.fWrite", function(...d:Dynamic) {
				var handle = d[0];
				var data = d[1];
				checkPipe(handle);
				openFiles[handle].write(data);
				return [];
			}),
			new Syscall("fs.fWriteLine", function(...d:Dynamic) {
				var handle = d[0];
				var data = d[1];
				checkPipe(handle);
				openFiles[handle].writeLine(data);
				return [];
			}),
			new Syscall("fs.fReadLine", function(...d:Dynamic) {
				var handle = d[0];
				return [openFiles[handle].readLine()];
			}),
			new Syscall("fs.fSync", function(...d:Dynamic) {
				var handle = d[0];
				checkPipe(handle);
				openFiles[handle].flush();
				return [];
			}),
			new Syscall("fs.list", function(...d:Dynamic) {
				return [kernel.rootFs.list(d[0])];
			}),
			new Syscall("fs.exists", function(...d:Dynamic) {
				return [kernel.rootFs.exists(d[0])];
			}),

			new Syscall("fs.mkDir", function(...d:Dynamic) {
				if (!kernel.rootFs.getPermissions(cast(d[0], String)).write) {
					throw "No permission for this action";
				}
				kernel.rootFs.mkDir(d[0]);
				return [];
			}),
			new Syscall("fs.remove", function(...d:Dynamic) {
				if (!kernel.rootFs.getPermissions(d[0]).write) {
					throw "No permission for this action";
				}
				kernel.rootFs.remove(d[0]);
				return [];
			}),
			new Syscall("fs.copy", function(...d:Dynamic) {
				if (!kernel.rootFs.getPermissions(d[0]).read) {
					throw "No permission for this action";
				}
				if (!kernel.rootFs.getPermissions(d[1]).write) {
					throw "No permission for this action";
				}
				kernel.rootFs.copy(d[0], d[1]);
				return [];
			}),
			new Syscall("fs.move", function(...d:Dynamic) {
				if (!kernel.rootFs.getPermissions(d[0]).read) {
					throw "No permission for this action";
				}
				if (!kernel.rootFs.getPermissions(d[0]).write) {
					throw "No permission for this action";
				}
				if (!kernel.rootFs.getPermissions(d[1]).write) {
					throw "No permission for this action";
				}
				kernel.rootFs.move(d[0], d[1]);
				return [];
			}),
			new Syscall("fs.getMountRoot", function(...d:Dynamic) {
				return [kernel.rootFs.getMountRoot(d[0])];
			})

		];
	}
}
