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
    WATCH;

    public static bool try_parse_name(string name, out DeviceKind result = null) {
      var enumc = (GLib.EnumClass)(typeof (DeviceKind).class_ref());
      unowned var eval = enumc.get_value_by_name(name);
      if (eval == null) {
        result = DeviceKind.DESKTOP;
        return false;
      }

      result = (DeviceKind)eval.value;
      return true;
    }

    public static bool try_parse_nick(string name, out DeviceKind result = null) {
      var enumc = (GLib.EnumClass)(typeof (DeviceKind).class_ref());
      unowned var eval = enumc.get_value_by_nick(name);
      return_val_if_fail(eval != null, false);

      if (eval == null) {
        result = DeviceKind.DESKTOP;
        return false;
      }

      result = (DeviceKind)eval.value;
      return true;
    }

    public string to_nick() {
      var enumc = (GLib.EnumClass)(typeof (DeviceKind).class_ref());
      var eval = enumc.get_value(this);
      return_val_if_fail(eval != null, null);
      return eval.value_nick;
    }
  }

  public interface DeviceProvider : GLib.Object {
    public abstract Device? get_device(string id);
    public abstract GLib.List<string> get_device_ids();
  }

  public abstract class Device : GLib.Object, Component {
    public abstract DeviceKind kind { get; }
    public abstract string id { get; }

    public override bool is_root_component {
      get {
        return true;
      }
    }

    construct {
      assert(Component.is_valid_id(this.id));
    }

    public abstract bool has_component(string id);
    public abstract Component? get_component(string id);
    public abstract GLib.List<string> get_component_ids();

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
