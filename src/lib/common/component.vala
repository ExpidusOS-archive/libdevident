namespace DevidentCommon {
	[Flags]
	public enum DisplayType {
		NONE = 0,
		TOUCHSCREEN,
		INTEGRATED = (1 << 1),
		EXTERNAL = (2 << 1),
		TYPE_C = (1 << 3)
	}
}