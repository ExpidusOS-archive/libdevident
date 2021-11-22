namespace DevidentClient {
	[DBus(name = "com.devident.Component")]
	public interface BaseComponentProxy : GLib.Object {
		public abstract string id { owned get; }
	}

	public class BaseComponent : GLib.Object, GLib.Initable {
		private BaseComponentProxy _proxy;

		public Context context { get; construct; }
		public string object_path { get; construct; }

		public string id {
			owned get {
				return this._proxy.id;
			}
		}

		public virtual bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			this._proxy = this.context.dbus_connection.get_proxy_sync("com.devident", this.object_path);
			return true;
		}
	}
}