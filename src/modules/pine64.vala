namespace PINE64 {
	public class PinePhone : DevidentServer.Device {
		public override string manufacturer {
			owned get {
				return "PINE64";
			}
		}

		public override string model {
			owned get {
				return "PinePhone";
			}
		}

		public override string revision {
			owned get {
				return "";
			}
		}

		public override DevidentCommon.DeviceType device_type {
			get {
				return DevidentCommon.DeviceType.PHONE;
			}
		}

		construct {
			try {
				this.add_component("screen", new DevidentServer.DisplayComponent("DSI-1", DevidentCommon.DisplayType.INTEGRATED | DevidentCommon.DisplayType.TOUCHSCREEN));
				this.add_component("touchscreen", new DevidentServer.TouchscreenComponent("screen", "/dev/input/event1", true));
			} catch (GLib.Error e) {}
		}

		public override bool matches(string device) {
			return GLib.Regex.match_simple(device, "Pine64 PinePhone Braveheart \\([0-9]\\.[0-9][a-z]?\\)");
		}
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var obj_module = module as Peas.ObjectModule;
	obj_module.register_extension_type(typeof (DevidentServer.Device), typeof (PINE64.PinePhone));
}