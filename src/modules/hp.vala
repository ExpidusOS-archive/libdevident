namespace HP {
	public class PavilionGamingLaptop : DevidentServer.Device {
		public override string manufacturer {
			owned get {
				return "HP";
			}
		}

		public override string model {
			owned get {
				return "Pavilion Gaming Laptop";
			}
		}

		public override string revision {
			owned get {
				return "";
			}
		}

		public override DevidentCommon.DeviceType device_type {
			get {
				return DevidentCommon.DeviceType.LAPTOP;
			}
		}

		construct {
			try {
				this.add_component("screen", new DevidentServer.DisplayComponent("eDP-1", DevidentCommon.DisplayType.INTEGRATED));
				this.add_component("backlight", new DevidentServer.BacklightComponent("intel_backlight"));
			} catch (GLib.Error e) {}
		}

		public override bool matches(string str) {
			return GLib.Regex.match_simple("HP Pavilion Gaming Laptop [0-9]+.*", str);
		}
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var obj_module = module as Peas.ObjectModule;
	obj_module.register_extension_type(typeof (DevidentServer.Device), typeof (HP.PavilionGamingLaptop));
}