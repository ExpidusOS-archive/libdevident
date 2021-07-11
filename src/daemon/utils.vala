namespace devident {
  public static string? get_device_string(DBusDaemon daemon, GLib.BusName? sender) throws GLib.Error {
    var dev_string = "";
    if (!GLib.FileUtils.test("/sys/firmware/devicetree/base/model", GLib.FileTest.IS_REGULAR)) {
      if (!GLib.FileUtils.test("/sys/devices/virtual/dmi/id/product_name", GLib.FileTest.IS_REGULAR)) {
        return null;
      } else {
        GLib.FileUtils.get_contents("/sys/devices/virtual/dmi/id/product_name", out dev_string);
        dev_string = dev_string.replace("\n", "");
      }
    } else {
      GLib.FileUtils.get_contents("/sys/firmware/devicetree/base/model", out dev_string);
      dev_string = dev_string.replace("\n", "");
    }

    if (sender == null) return dev_string;

    var pid = daemon.conn.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
      "GetConnectionUnixProcessID", new GLib.Variant("(s)", sender),
      null, GLib.DBusCallFlags.NONE, -1, null).get_child_value(0).get_uint32();

    var proc = "";
    size_t proc_len = 0;
    GLib.FileUtils.get_contents("/proc/%lu/cmdline".printf(pid), out proc, out proc_len);
    var cmdline = "";
    for (var i = 0; i < proc_len; i++) {
      if (proc[i] == '\0') cmdline += " ";
      else cmdline += proc[i].to_string();
    }
    cmdline = cmdline.replace("\n", "");

    string[] args = cmdline.split(" ");

    var argv0 = GLib.Path.get_basename(args[0]);
    if (argv0.contains("python")) {
      argv0 = args[1];
    }

    var overrides = daemon.kf.get_string_list("devices", "overrides");
    for (var i = 0; i < overrides.length; i++) {
      var a = overrides[i].split(":");
      if (a.length != 2) continue;
      if (GLib.Regex.match_simple(a[0], argv0)) {
        return a[1];
      }
    }

    return dev_string;
  }
}