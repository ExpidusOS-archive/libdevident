namespace devident {
  /**
   * Base component interface
   */
  [DBus(name = "com.devident.Component")]
  public interface Component : GLib.Object {
    public abstract string get_id() throws GLib.Error;
    public abstract string get_name() throws GLib.Error;
    public abstract ComponentCategory get_category() throws GLib.Error;

    public abstract bool is_present() throws GLib.Error;
  }

  public enum ComponentCategory {
    NONE = 0,
    DISPLAY,
    TOUCH_DISPLAY,
    HW_INPUT,
    GFX,
    AUDIO
  }
}