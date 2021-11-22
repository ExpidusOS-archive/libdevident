namespace DevidentServer {
	[DBus(name = "com.devident.Device")]
	public abstract class Device : GLib.Object, CommonObject {
		private bool _is_inited = false;
		private uint _obj_id;
		private GLib.HashTable<string, BaseComponent> _components;
		private Context? _context;

		[DBus(visible = false)]
		public Context? context {
			get {
				return this._context;
			}
			construct {
				this._context = value;
			}
		}

		public virtual string id {
			owned get {
				return (this.manufacturer + "-" + this.model + (this.revision.length > 0 ? "-" + this.revision : "")).down().replace(" ", "");
			}
		}

		public abstract string manufacturer { owned get; }
		public abstract string model { owned get; }
		public abstract string revision { owned get; }

		public virtual DevidentCommon.DeviceType device_type {
			get {
				return DevidentCommon.DeviceType.UNKNOWN;
			}
		}

		public string[] components {
			owned get {
				return this._components.get_keys_as_array();
			}
		}

		[DBus(visible = false)]
		public string object_path {
			owned get {
				return "/com/devident/devices/%s".printf(dbusify_string(this.id));
			}
		}

		construct {
			this._components = new GLib.HashTable<string, BaseComponent>(GLib.str_hash, GLib.str_equal);
		}

		[DBus(name = "GetComponentType")]
		public string get_component_type_dbus(string id) throws GLib.DBusError, GLib.IOError {
			var val = this.get_component_type(id);
			return val == null ? "" : val;
		}

		[DBus(name = "FindComponent")]
		public string find_component_dbus(string id) throws GLib.DBusError, GLib.IOError {
			var val = this.find_component(id);
			return val == null ? "" : val.object_path;
		}

		[DBus(visible = false)]
		public void destroy() {
			if (this._is_inited) {
				if (this._obj_id > 0) {
					this.context.dbus_connection.unregister_object(this._obj_id);
					this._obj_id = 0;
				}

				foreach (var comp in this._components.get_values()) comp.destroy();
				this._is_inited = false;
				this.destroyed();
			}
		}

		[DBus(visible = false)]
		public void add_component(string id, BaseComponent comp) throws GLib.Error {
			if (!this._components.contains(id)) {
				this._components.set(id, comp);
				if (this._is_inited) comp.init(this);
			}
		}

		[DBus(visible = false)]
		public string? get_component_type(string id) {
			if (this._components.contains(id)) {
				var comp = this._components.get(id);
				return comp.get_type().name().replace("DevidentServer", "").replace("Component", "");
			}
			return null;
		}

		[DBus(visible = false)]
		public BaseComponent? find_component(string id) {
			return this._components.get(id);
		}

		[DBus(visible = false)]
		public virtual bool init(Context context) throws GLib.Error {
			if (this._is_inited) return false;

			this._is_inited = true;
			this._context = context;
			this._obj_id = this.context.dbus_connection.register_object(this.object_path, this);

			foreach (var comp in this._components.get_values()) comp.init(this);
			return true;
		}

		[DBus(visible = false)]
		public virtual bool matches(string device) {
			return false;
		}

		public static GLib.ObjectPath get_component_path(string dev, string comp) {
			return new GLib.ObjectPath("/com/devident/device/%s/component/%s".printf(dev, comp));
		}
	}
}