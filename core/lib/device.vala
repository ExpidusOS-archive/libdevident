namespace Devident {
#if TARGET_SYSTEM_DARWIN
  internal extern string? get_darwin_model();
#endif

  public enum DeviceKind {
    DESKTOP = 0,
    SERVER,
    PHONE,
    TV,
    CONSOLE,
    WATCH
  }

  public interface DeviceProvider : GLib.Object {
    public abstract string get_default_device_id();
    public abstract unowned Device? get_device(string id);
    public abstract GLib.List<string> get_device_ids();
  }

  public abstract class Device : GLib.Object {
    public abstract string id { get; }
    public abstract DeviceKind kind { get; }

    public static string? get_host_id() throws GLib.FileError {
      string? dev_name = null;

#if TARGET_SYSTEM_DARWIN
      dev_name = get_darwin_model();
#elif TARGET_SYSTEM_WINDOWS
#elif TARGET_SYSTEM_LINUX
      if (GLib.FileTest.test("/sys/devices/virtual/dmi/id/board_vendor", GLib.FileTest.IS_REGULAR)) {
        dev_name = read_file("/sys/devices/virtual/dmi/id/board_vendor");
        string value = try_read_file("/sys/devices/virtual/dmi/id/board_name");
        if (value.length > 0) dev_name += " " + value;
        return dev_name;
      }

      if (GLib.FileTest.test("/sys/devices/virtual/dmi/id/product_name", GLib.FileTest.IS_REGULAR)) {
        dev_name = read_file("/sys/devices/virtual/dmi/id/product_name");
        string value = try_read_file("/sys/devices/virtual/dmi/id/product_version");
        if (value.length > 0) dev_name += " " + value;
        return dev_name;
      }

      if (GLib.FileTest.test("/sys/firmware/devicetree/base/model", GLib.FileTest.IS_REGULAR)) {
        return read_file("/sys/firmware/devicetree/base/model");
      }
#endif
      return dev_name;
    }
  }
}
