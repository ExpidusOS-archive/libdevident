namespace DevidentClient {
	[DBus(name = "com.devident.component.Backlight")]
	public interface BacklightComponentProxy : GLib.Object {
		public abstract string name { owned get; }
	}

	public class BacklightComponent : BaseComponent {
		private BacklightComponentProxy _proxy;

		public string name {
			owned get {
				return this._proxy.name;
			}
		}

		public override bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			if (base.init(cancellable)) {
				this._proxy = this.context.dbus_connection.get_proxy_sync("com.devident", this.object_path);
				return true;
			}
			return false;
		}
	}
}