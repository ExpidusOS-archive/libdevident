namespace DevidentClient {
	[DBus(name = "com.devident.Context")]
	public interface ContextProxy : GLib.Object {
		public abstract string[] devices { owned get; }

		public abstract string get_default_device() throws GLib.DBusError, GLib.IOError;
		[DBus(name = "FindDeviceByID")]
		public abstract string find_device_by_id(string id) throws GLib.DBusError, GLib.IOError;
		public abstract string find_device(string dev) throws GLib.DBusError, GLib.IOError;

		public abstract void rescan() throws GLib.Error;
	}

	public class Context : DevidentCommon.DBusInitable {
		private ContextProxy _proxy;

		public Device? get_default_device() throws GLib.Error {
			var override_id = GLib.Environment.get_variable("DEVIDENT_OVERRIDE_DEFAULT_ID");
			var path = override_id != null ? this._proxy.find_device_by_id(override_id) : "";
			if (path.length == 0) path = this._proxy.get_default_device();
			if (path.length != 0) return (Device)GLib.Initable.@new(typeof (Device), null, "context", this, "object-path", path, null);
			return null;
		}

		public Device? find_device_by_id(string id) throws GLib.Error {
			var path = this._proxy.find_device_by_id(id);
			if (path.length > 0) return (Device)GLib.Initable.@new(typeof (Device), null, "context", this, "object-path", path, null);
			return null;
		}

		public Device? find_device(string dev) throws GLib.Error {
			var path = this._proxy.find_device(dev);
			if (path.length > 0) return (Device)GLib.Initable.@new(typeof (Device), null, "context", this, "object-path", path, null);
			return null;
		}

		public void rescan() throws GLib.Error {
			this._proxy.rescan();
		}

		public override bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			if (base.init(cancellable)) {
				this._proxy = this.dbus_connection.get_proxy_sync("com.devident", "/com/devident");
				return true;
			}
			return false;
		}
	}
}
