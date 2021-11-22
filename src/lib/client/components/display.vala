namespace DevidentClient {
	[DBus(name = "com.devident.component.Display")]
	public interface DisplayComponentProxy : GLib.Object {
		public abstract string name { owned get; }
		public abstract DevidentCommon.DisplayType display_type { get; }
	}

	public class DisplayComponent : BaseComponent {
		private DisplayComponentProxy _proxy;

		public string name {
			owned get {
				return this._proxy.name;
			}
		}

		public DevidentCommon.DisplayType display_type {
			get {
				return this._proxy.display_type;
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