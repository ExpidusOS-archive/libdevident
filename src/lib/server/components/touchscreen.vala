namespace DevidentServer {
	[DBus(name = "com.devident.component.Touchscreen")]
	public class TouchscreenComponent : BaseComponent {
		private uint _obj_id;

		public string display_id { owned get; construct; }
		public string input_path { owned get; construct; }
		public bool has_multitouch { get; construct; }

		public TouchscreenComponent(string display_id, string input_path, bool multitouch = false) {
			Object(display_id: display_id, input_path: input_path, has_multitouch: multitouch);
		}

		public override void destroy() {
			base.destroy();

			if (this._obj_id > 0) {
				this.context.dbus_connection.unregister_object(this._obj_id);
				this._obj_id = 0;
			}
		}

		public override bool init(Device device) throws GLib.Error {
			if (base.init(device)) {
				this._obj_id = this.context.dbus_connection.register_object(this.object_path, this);
				return true;
			}
			return false;
		}
	}
}