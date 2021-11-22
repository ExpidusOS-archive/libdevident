namespace devident {
	private static bool arg_version = false;

	private const GLib.OptionEntry[] options = {
		{ "version", 'v', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref arg_version, "Prints the version string", null },
		{ null }
	};

	private struct ContextFactoryEntry {
		public unowned DevidentServer.DeviceRegistryFactory factory;
	}

	public class Context : DevidentServer.Context {
		private GLib.HashTable<string, ContextFactoryEntry?> _factories;
		private GLib.HashTable<string, DevidentServer.Device> _devices;
		private GLib.HashTable<string, Peas.PluginInfo> _plugins;
		private Peas.Engine _engine;
		private Peas.ExtensionSet _extensions;

		public override string[] devices {
			owned get {
				return this._devices.get_keys_as_array();
			}
		}

		construct {
			this._factories = new GLib.HashTable<string, ContextFactoryEntry?>(GLib.str_hash, GLib.str_equal);
			this._devices = new GLib.HashTable<string, DevidentServer.Device>(GLib.str_hash, GLib.str_equal);
			this._plugins = new GLib.HashTable<string, Peas.PluginInfo>(GLib.str_hash, GLib.str_equal);

			this._engine = new Peas.Engine();
			this._engine.enable_loader("lua5.1");
			this._engine.enable_loader("python3");
			this._engine.add_search_path(DevidentCommon.LIBDIR + "/devident/modules/", DevidentCommon.DATADIR + "/devident/modules/");

			this._extensions = new Peas.ExtensionSet(this._engine, typeof (DevidentServer.Device), "context", this);
			this._extensions.extension_added.connect((info, obj) => {
				if (!this._plugins.contains(info.get_module_name())) {
					GLib.debug("Loading module \"%s\"", info.get_module_name());
					this._plugins.set(info.get_module_name(), info);

					try {
						this.add_device((DevidentServer.Device)obj);
					} catch (GLib.Error e) {
						GLib.error("Failed to add device from module \"%s\" (%s:%d): %s", info.get_module_name(), e.domain.to_string(), e.code, e.message);
					}
				}
			});

			this._extensions.extension_removed.connect((info, obj) => {
				if (this._plugins.contains(info.get_module_name())) {
					this._plugins.remove(info.get_module_name());
					try {
						this.remove_device(((DevidentServer.Device)obj).id);
					} catch (GLib.Error e) {
						GLib.error("Failed to add device from module \"%s\" (%s:%d): %s", info.get_module_name(), e.domain.to_string(), e.code, e.message);
					}
				}
			});
		}

		public override void rescan() throws GLib.Error {
			this._engine.rescan_plugins();
			foreach (var info in this._engine.get_plugin_list()) {
				GLib.debug("Found module \"%s\"", info.get_module_name());
				this._engine.try_load_plugin(info);
			}
		}

		public override DevidentServer.Device? find_device_by_id(string id) {
			if (this._devices.contains(id)) {
				return this._devices.get(id);
			}
			return null;
		}

		public override DevidentServer.Device? find_device(string device) {
			foreach (var dev in this._devices.get_values()) {
				if (dev.id == "fallback") continue;
				if (dev.matches(device)) return dev;
			}

			foreach (var entry in this._factories.get_values()) {
				var dev = entry.factory(device);
				if (dev == null) continue;

				try {
					dev.init(this);
				} catch (GLib.Error e) {
					return null;
				}

				this._devices.set(dev.id, dev);
				return dev;
			}
			return null;
		}

		public override void add_device(DevidentServer.Device device) throws DevidentCommon.ContextError {
			if (!this._devices.contains(device.id)) {
				try {
					device.init(this);
					this._devices.set(device.id, device);
				} catch (GLib.Error e) {}
			}
		}

		public override void remove_device(string id) throws DevidentCommon.ContextError {
			this._factories.remove(id);
			this._devices.remove(id);
		}

		public override void register_with_factory(string id, DevidentServer.DeviceRegistryFactory factory) throws DevidentCommon.ContextError {
			if (!this._factories.contains(id)) {
				ContextFactoryEntry entry = { factory };
				this._factories.set(id, entry);
			}
		}
	}

	public static int main(string[] args) {
		try {
			var opctx = new GLib.OptionContext("- Device Identification Daemon");
			opctx.set_help_enabled(true);
			opctx.add_main_entries(options, null);
			opctx.parse(ref args);
		} catch (GLib.Error e) {
			stderr.printf("%s: Failed to parse arguments (%s:%d): %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.code, e.message);
			return 1;
		}

		if (arg_version) {
			stdout.printf("%s\n", DevidentCommon.VERSION);
			return 0;
		}

		try {
			var ctx = (Context)GLib.Initable.@new(typeof (Context), null, null);
			ctx.rescan();
		} catch (GLib.Error e) {
			stderr.printf("%s: failed to initialize daemon (%s:%d): %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.code, e.message);
			return 1;
		}

		new GLib.MainLoop().run();
		return 0;
	}
}