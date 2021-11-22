namespace DevidentClient {
	[DBus(name = "com.devident.Device")]
	public interface DeviceProxy : GLib.Object {
		public abstract string manufacturer { owned get; }
		public abstract string model { owned get; }
		public abstract string revision { owned get; }
		public abstract DevidentCommon.DeviceType device_type { get; }
		public abstract string[] components { owned get; }

		public abstract string get_component_type(string id) throws GLib.DBusError, GLib.IOError;
		public abstract string find_component(string id) throws GLib.DBusError, GLib.IOError;
	}

	public class Device : GLib.Object, GLib.Initable {
		private DeviceProxy _proxy;

		public Context context { get; construct; }
		public string object_path { get; construct; }

		public string manufacturer {
			owned get {
				return this._proxy.manufacturer;
			}
		}

		public string model {
			owned get {
				return this._proxy.model;
			}
		}

		public string revision {
			owned get {
				return this._proxy.revision;
			}
		}

		public DevidentCommon.DeviceType device_type {
			get {
				return this._proxy.device_type;
			}
		}

		public string[] components {
			owned get {
				return this._proxy.components;
			}
		}

		public bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			this._proxy = this.context.dbus_connection.get_proxy_sync("com.devident", this.object_path);
			return true;
		}

		public string? get_component_type(string id) throws GLib.DBusError, GLib.IOError {
			var val = this._proxy.get_component_type(id);
			return val.length > 0 ? val : null;
		}

		public BaseComponent? find_component(string id) throws GLib.Error {
			var val = this._proxy.find_component(id);
			if (val.length == 0) return null;
			return this.load_component(id, val);
		}

		private BaseComponent? load_component(string id, string obj_path) throws GLib.Error {
			var type_name = this._proxy.get_component_type(id);
			GLib.Type? type_ret = null;
			
			switch (type_name) {
				case "Touchscreen":
					type_ret = typeof (TouchscreenComponent);
					break;
				default:
					type_ret = GLib.Type.from_name(type_name);
					break;
			}

			if (type_ret != null && type_ret != GLib.Type.NONE) {
				return (BaseComponent)GLib.Initable.@new(type_ret, null, "context", this.context, "object-path", obj_path, null);
			}
			return null;
		}
	}
}