package kernel;

import kernel.Thread.XG;
import kernel.Driver;

@:native("drv") class Drivers {
	private static var sdrivers:Array<Driver> = [];
	public static var drivers(get, set):Array<Driver>;

	public static function getDriversByType(type:Dynamic):Array<Driver> {
		var out:Array<Driver> = [];
		for (driver in drivers) {
			if (Std.isOfType(driver, type)) {
				out.insert(out.length, driver);
			}
		}
		return out;
	}

	public static function getDriverByType(type:Dynamic):Null<Driver> {
		var gd = getDriversByType(type);
		if (gd.length > 0) {
			return gd[0];
		}
		return null;
	}

	public static function getDriversByProvides(p:DriverProvides):Array<Driver> {
		var out:Array<Driver> = [];
		for (driver in drivers) {
			if (driver.provides == p) {
				out.insert(out.length, driver);
			}
		}
		return out;
	}

	public static function getDriverByProvides(p:DriverProvides):Null<Dynamic> {
		var gd = getDriversByProvides(p);
		if (gd.length > 0) {
			return gd[0];
		}
		return null;
	}

	public static function getDriverByName(name:String):Null<Driver> {
		for (driver in drivers) {
			// Sys.println(driver.deviceName);
			if (driver.deviceName == name) {
				return driver;
			}
		}
		return null;
	}

	public static function add(d:Driver) {
		Logger.log("Device connected: " + d.deviceName + " of type " + Type.getClassName(Type.getClass(d)));
        if(XG.api != null) XG.api.queue(["device_connect", d.deviceName]);
		sdrivers.insert(drivers.length, d);
	}

	public static function rem(name:String) {
		Logger.log("Device disconnected: " + name);
        if(XG.api != null) XG.api.queue(["device_disconnect", name]);
		var d:Driver = null;
		for (index => value in sdrivers) {
			if (value.deviceName == name) {
				d = value;
				break;
			}
		}
		if (d != null) {
			sdrivers.remove(d);
			return true;
		} else
			return false;
	}

	static function set_drivers(value:Array<Driver>):Array<Driver> {
		return sdrivers;
	}

	static function get_drivers():Array<Driver> {
		return sdrivers;
	}
}
