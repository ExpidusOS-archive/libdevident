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

  public abstract class Device : Component {
    public abstract DeviceKind kind { get; }

    public override bool is_root_component {
      get {
        return true;
      }
    }

    public static string? get_host_id() throws GLib.FileError {
#if TARGET_SYSTEM_DARWIN
      return get_darwin_model();
#elif TARGET_SYSTEM_LINUX
      if (GLib.FileTest.test("/sys/devices/virtual/dmi/id/board_vendor", GLib.FileTest.IS_REGULAR)) {
        string dev_name = read_file("/sys/devices/virtual/dmi/id/board_vendor");
        string value = try_read_file("/sys/devices/virtual/dmi/id/board_name");
        if (value.length > 0) dev_name += " " + value;
        return dev_name.replace(" ", ",");
      }

      if (GLib.FileTest.test("/sys/devices/virtual/dmi/id/product_name", GLib.FileTest.IS_REGULAR)) {
        string dev_name = read_file("/sys/devices/virtual/dmi/id/product_name");
        string value = try_read_file("/sys/devices/virtual/dmi/id/product_version");
        if (value.length > 0) dev_name += " " + value;
        return dev_name.replace(" ", ",");
      }

      if (GLib.FileTest.test("/sys/firmware/devicetree/base/model", GLib.FileTest.IS_REGULAR)) {
        return read_file("/sys/firmware/devicetree/base/model").replace(" ", ",");
      }
#else
      return null;
#endif
    }
  }
}
