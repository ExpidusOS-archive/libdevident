namespace DevidentCommon {
	public errordomain ContextError {
		INVALID_DEVICE
	}

	public abstract class DBusInitable : GLib.Object, GLib.Initable {
		private GLib.DBusConnection _dbus_conn;

		public GLib.DBusConnection dbus_connection {
			get {
				return this._dbus_conn;
			}
			construct {
				this._dbus_conn = value;
			}
		}

		public virtual bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			if (this._dbus_conn == null) {
				this._dbus_conn = GLib.Bus.get_sync(GLib.BusType.SYSTEM, cancellable);
			}
			return true;
		}
	}
}