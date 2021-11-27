namespace DevidentClient {
	[DBus(name = "com.devident.component.Optimization")]
	public interface OptimizationComponentProxy : GLib.Object {
		public abstract DevidentCommon.OptimizationType opt_type { get; }
		public abstract GLib.Variant read() throws GLib.DBusError, GLib.IOError;
	}

	public class OptimizationComponent : BaseComponent {
		private OptimizationComponentProxy _proxy;

		public DevidentCommon.OptimizationType opt_type {
			get {
				return this._proxy.opt_type;
			}
		}

		public override bool init(GLib.Cancellable? cancellable = null) throws GLib.Error {
			if (base.init(cancellable)) {
				this._proxy = this.context.dbus_connection.get_proxy_sync("com.devident", this.object_path);
				return true;
			}
			return false;
		}


		public T? read<T>() throws GLib.DBusError, GLib.IOError {
			var r = this._proxy.read();
			if (typeof (T) == typeof (DevidentCommon.ProcessOptimizationData)) {
				return new DevidentCommon.ProcessOptimizationData.from_variant(r);
			}
			return null;
		}
	}
}