namespace DevidentClient {
	[DBus(name = "com.devident.component.Touchscreen")]
	public interface TouchscreenComponentProxy : GLib.Object {
		public abstract string display_id { owned get; }
		public abstract string input_path { owned get; }
		public abstract bool has_multitouch { get; }
	}

	public class TouchscreenComponent : BaseComponent {
		private TouchscreenComponentProxy _proxy;

		public string display_id {
			owned get {
				return this._proxy.display_id;
			}
		}

		public string input_path {
			owned get {
				return this._proxy.input_path;
			}
		}

		public bool has_multitouch {
			get {
				return this._proxy.has_multitouch;
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