namespace devident {
	public class Fallback : DevidentServer.Device {
		public override string id {
			owned get {
				return "fallback";
			}
		}

		public override string manufacturer {
			owned get {
				try {
					var value = DevidentCommon.get_dmi("sys_vendor");
					if (value != null) return value;
					return "Unknown";
				} catch (GLib.FileError e) {
					return "Unknown";
				}
			}
		}

		public override string model {
			owned get {
				try {
					var value = DevidentCommon.get_dmi("product_name");
					if (value != null) return value;
					return "Unknown";
				} catch (GLib.FileError e) {
					return "Unknown";
				}
			}
		}

		public override string revision {
			owned get {
				try {
					var value = DevidentCommon.get_dmi("product_version");
					if (value != null) return value;
					return "Unknown";
				} catch (GLib.FileError e) {
					return "Unknown";
				}
			}
		}

		public override DevidentCommon.DeviceType device_type {
			get {
				try {
					var _value = DevidentCommon.get_dmi("chassis_type");
					if (_value == null) return DevidentCommon.DeviceType.UNKNOWN;
					switch (int.parse(_value)) {
						case 0x03:
						case 0x04:
						case 0x05:
						case 0x06:
						case 0x07:
						case 0x0D:
							return DevidentCommon.DeviceType.DESKTOP;
						case 0x08:
						case 0x09:
						case 0x0A:
						case 0x0E:
							return DevidentCommon.DeviceType.LAPTOP;
						case 0x0B: return DevidentCommon.DeviceType.PHONE;
						case 0x1E: return DevidentCommon.DeviceType.TABLET;
						default: return DevidentCommon.DeviceType.UNKNOWN;
					}
				} catch (GLib.FileError e) {
					return DevidentCommon.DeviceType.UNKNOWN;
				}
			}
		}

		public override bool matches(string str) {
			try {
				return str == DevidentCommon.get_device_string();
			} catch (GLib.Error e) {
				return false;
			}
		}
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var obj_module = module as Peas.ObjectModule;
	obj_module.register_extension_type(typeof (DevidentServer.Device), typeof (devident.Fallback));
}