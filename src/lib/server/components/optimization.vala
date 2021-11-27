namespace DevidentServer {
	[DBus(name = "com.devident.component.Optimization")]
	public class OptimizationComponent : BaseComponent {
		private uint _obj_id;
		private GLib.Variant _data;

		public DevidentCommon.OptimizationType opt_type { get; construct; }

		public OptimizationComponent.process(bool should_pause) {
			Object(opt_type: DevidentCommon.OptimizationType.PROCESS);

			this._data = new DevidentCommon.ProcessOptimizationData(should_pause).to_variant();
		}

		public GLib.Variant read() throws GLib.DBusError, GLib.IOError {
			return this._data;
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