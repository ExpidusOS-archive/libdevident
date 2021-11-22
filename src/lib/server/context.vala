namespace DevidentServer {
	public delegate Device? DeviceRegistryFactory(string? matches);

	[DBus(name = "com.devident.Context")]
	public abstract class Context : DevidentCommon.DBusInitable {
		private uint _obj_id;
		private uint _owns_id;

		public abstract string[] devices { owned get; }

		[DBus(visible = false)]
		public void destroy() {
			if (this._obj_id > 0) {
				this.dbus_connection.unregister_object(this._obj_id);
				this._obj_id = 0;
			}
		}

		[DBus(name = "GetDefaultDevice")]
		public virtual string? get_default_device_dbus(GLib.BusName sender) throws GLib.DBusError, GLib.IOError {
			var dev = this.get_default_device();
			if (dev == null) return "";
			return dev.object_path;
		}

		[DBus(name = "FindDeviceByID")]
		public string? find_device_by_id_dbus(string id, GLib.BusName sender) throws GLib.DBusError, GLib.IOError {
			var dev = this.find_device_by_id(id);
			if (dev == null) return "";
			return dev.object_path;
		}

		[DBus(name = "FindDevice")]
		public string? find_device_dbus(string device_name, GLib.BusName sender) throws GLib.DBusError, GLib.IOError {
			var dev = this.find_device(device_name);
			if (dev == null) return "";
			return dev.object_path;
		}

		public virtual void rescan() throws GLib.Error {}

		[DBus(visible = false)]
		public virtual Device? get_default_device() {
			try {
				var dev = this.find_device(DevidentCommon.get_device_string());
				if (dev == null) return this.find_device_by_id("fallback");
				return dev;
			} catch (GLib.Error e) {
				return this.find_device_by_id("fallback");
			}
		}

		[DBus(visible = false)]
		public virtual Device? find_device_by_id(string id) {
			return null;
		}

		[DBus(visible = false)]
		public virtual Device? find_device(string device) {
			return null;
		}

		[DBus(visible = false)]
		public virtual void add_device(Device device) throws DevidentCommon.ContextError {}

		[DBus(visible = false)]
		public virtual void remove_device(string id) throws DevidentCommon.ContextError {}

		[DBus(visible = false)]
		public virtual void register_with_factory(string id, DeviceRegistryFactory factory) throws DevidentCommon.ContextError {}

		[DBus(visible = false)]
		public override bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			if (base.init(cancellable)) {
				this._obj_id = this.dbus_connection.register_object("/com/devident", this);
				this._owns_id = GLib.Bus.own_name_on_connection(this.dbus_connection, "com.devident", GLib.BusNameOwnerFlags.DO_NOT_QUEUE);
				return true;
			}
			return false;
		}
	}
}