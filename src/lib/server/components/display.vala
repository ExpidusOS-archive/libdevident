namespace DevidentServer {
	[DBus(name = "com.devident.component.Display")]
	public class DisplayComponent : BaseComponent {
		private uint _obj_id;

		public string name { owned get; construct; }
		public DevidentCommon.DisplayType display_type { get; construct; }

		public DisplayComponent(string name, DevidentCommon.DisplayType type) {
			Object(name: name, display_type: type);
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