namespace DevidentServer {
	[DBus(name = "com.devident.BaseComponent")]
	public abstract class BaseComponent : GLib.Object {
		private bool _is_inited = false;
		private uint _obj_id;
		private Device _device;
		private Context _context;

		[DBus(visible = false)]
		public Context? context {
			get {
				return this._context;
			}
			construct {
				this._context = value;
			}
		}

		[DBus(visible = false)]
		public Device device {
			get {
				return this._device;
			}
			construct {
				this._device = value;
			}
		}

		public string id {
			owned get {
				foreach (var comp in this.device.components) {
					var c = this.device.find_component(comp);
					if (c == null) continue;
					if (c == this) return comp;
				}
				return "unknown";
			}
		}

		[DBus(visible = false)]
		public string object_path {
			owned get {
				return this.device.object_path + "/components/%s".printf(dbusify_string(this.id));
			}
		}

		[DBus(visible = false)]
		public virtual void destroy() {
			if (this._obj_id > 0) {
				this.context.dbus_connection.unregister_object(this._obj_id);
				this._obj_id = 0;
				this.destroyed();
			}
		}

		[DBus(visible = false)]
		public virtual bool init(Device device) throws GLib.Error {
			if (this._is_inited) return false;

			this._is_inited = true;
			this._device = device;
			this._context = device.context;
			this._obj_id = this.context.dbus_connection.register_object(this.object_path, this);
			return true;
		}

		[DBus(visible = false)]
		public signal void destroyed();
	}
}