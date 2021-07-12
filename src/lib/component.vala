namespace devident {
  /**
   * Base component interface
   */
  [DBus(name = "com.devident.Component")]
  public interface Component : GLib.Object {
    public abstract string get_id() throws GLib.Error;
    public abstract ComponentCategory get_category() throws GLib.Error;
    public abstract string get_driver() throws GLib.Error;

    public abstract bool is_present() throws GLib.Error;
  }

  [DBus(name = "com.devident.Display")]
  public interface Display : GLib.Object {
    public abstract string get_name() throws GLib.Error;
    public abstract void get_resolution(out int x, out int y) throws GLib.Error;
    public abstract string get_backlight() throws GLib.Error;
  }

  [DBus(name = "com.devident.TouchDisplay")]
  public interface TouchDisplay : GLib.Object {
    [DBus(name = "GetDisplay")]
    public abstract GLib.ObjectPath get_display_dbus() throws GLib.Error;
    public abstract string get_input() throws GLib.Error;
    public abstract bool is_multitouch() throws GLib.Error;

    [DBus(visible = false)]
    public Display get_display() throws GLib.Error {
      return GLib.Bus.get_proxy_sync<Display>(GLib.BusType.SYSTEM, "com.devident", this.get_display_dbus());
    }
  }

  [DBus(name = "com.devident.Graphics")]
  public interface Graphics : GLib.Object {
    [DBus(name = "SupportsOpenGL")]
    public abstract bool supports_opengl() throws GLib.Error;

    [DBus(name = "GetOpenGLVersion")]
    public abstract void get_opengl_version(out int maj, out int min) throws GLib.Error;

    [DBus(name = "SupportsOpenGLES")]
    public abstract bool supports_opengles() throws GLib.Error;

    [DBus(name = "GetOpenGLESVersion")]
    public abstract void get_opengles_version(out int maj, out int min) throws GLib.Error;

    public abstract bool supports_vulkan() throws GLib.Error;
    public abstract void get_vulkan_version(out int maj, out int min) throws GLib.Error;
  }

  [DBus(name = "com.devident.HWInput")]
  public interface HWInput : GLib.Object {
    public abstract bool has_home() throws GLib.Error;
    public abstract bool has_back() throws GLib.Error;
    public abstract bool has_context() throws GLib.Error;
    public abstract bool has_volume() throws GLib.Error;
    public abstract bool has_power() throws GLib.Error;
  }

  [DBus(name = "com.devident.Camera")]
  public interface Camera : GLib.Object {
    public abstract string get_path() throws GLib.Error;
    public abstract string[] get_names() throws GLib.Error;
    public abstract string get_selector_path() throws GLib.Error;
  }

  [DBus(name = "com.devident.RGB")]
  public interface RGB : GLib.Object {
    [DBus(name = "GetType")]
    public abstract RGBType get_rgb_type() throws GLib.Error;
    public abstract string get_path() throws GLib.Error;
    public abstract string get_red() throws GLib.Error;
    public abstract string get_green() throws GLib.Error;
    public abstract string get_blue() throws GLib.Error;
  }

  public enum RGBType {
    SYSFS_SEPERATE_RGB,
    SYSFS,
    IO_MSI
  }

  public enum ComponentCategory {
    NONE = 0,
    DISPLAY,
    TOUCH_DISPLAY,
    HW_INPUT,
    GFX,
    CAMERA,
    RGB
  }
}