namespace DevidentCommon {
	[Flags]
	public enum DisplayType {
		NONE = 0,
		TOUCHSCREEN,
		INTEGRATED = (1 << 1),
		EXTERNAL = (2 << 1),
		TYPE_C = (1 << 3)
	}

	public enum OptimizationType {
		NONE = 0,
		PROCESS
	}

	[Compact]
	public class ProcessOptimizationData {
		public ProcessOptimizationData(bool should_pause) {
			this.should_pause = should_pause;
		}

		public ProcessOptimizationData.from_variant(GLib.Variant v) {
			v.@get("(b)", out this.should_pause);
		}

		public bool should_pause;

		public GLib.Variant to_variant() {
			return new GLib.Variant("(b)", this.should_pause);
		}
	}
}