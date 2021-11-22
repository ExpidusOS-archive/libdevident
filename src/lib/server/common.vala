namespace DevidentServer {
	public interface CommonObject : GLib.Object {
		public abstract string object_path { owned get; }

		[DBus(visible = false)]
		public virtual bool init(Context context) throws GLib.Error {
			return true;
		}

		public signal void destroyed();
	}

	public static string dbusify_string(string input) {
		return input.replace(" ", "_").replace("-", "_");
	}
}