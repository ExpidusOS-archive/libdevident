namespace DevidentCommon {
	public enum DeviceType {
		UNKNOWN = 0,
		DESKTOP,
		LAPTOP,
		TABLET,
		PHONE,
		CONSOLE,
		TV,
		CAR_RADIO
	}

	public static string? get_dmi(string key) throws GLib.FileError {
		var file = "/sys/devices/virtual/dmi/id/%s".printf(key);
		string? value = null;
		if (GLib.FileUtils.test(file, GLib.FileTest.IS_REGULAR)) {
			GLib.FileUtils.get_contents(file, out value);
			value = value.replace("\n", "");
		}
		return value;
	}

	public static string? get_device_string() throws GLib.FileError {
		string? dev_string = null;
		if (!GLib.FileUtils.test("/sys/firmware/devicetree/base/model", GLib.FileTest.IS_REGULAR)) {
			return get_dmi("product_name");
		} else {
			GLib.FileUtils.get_contents("/sys/firmware/devicetree/base/model", out dev_string);
			dev_string = dev_string.replace("\n", "");
		}
		return dev_string;
	}
}