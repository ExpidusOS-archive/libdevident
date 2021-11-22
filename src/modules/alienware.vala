namespace Alienware {
	public class M15RyzenR5 : DevidentServer.Device {
		public override string manufacturer {
			owned get {
				return "Alienware";
			}
		}

		public override string model {
			owned get {
				return "M15 Ryzen Ed. R5";
			}
		}

		public override string revision {
			owned get {
				return "";
			}
		}

		construct {
			try {
				this.add_component("screen", new DevidentServer.DisplayComponent("eDP-1", DevidentCommon.DisplayType.INTEGRATED));
				this.add_component("backlight", new DevidentServer.BacklightComponent("amdgpu_bl0"));
			} catch (GLib.Error e) {}
		}

		public override bool matches(string str) {
			return GLib.Regex.match_simple("Alienware m15 Ryzen Ed. R5", str);
		}
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var obj_module = module as Peas.ObjectModule;
	obj_module.register_extension_type(typeof (DevidentServer.Device), typeof (Alienware.M15RyzenR5));
}