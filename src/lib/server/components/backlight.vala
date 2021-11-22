namespace DevidentServer {
	[DBus(name = "com.devident.component.Backlight")]
	public class BacklightComponent : BaseComponent {
		private uint _obj_id;

		public string name { owned get; construct; }

		public BacklightComponent(string name) {
			Object(name: name);
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