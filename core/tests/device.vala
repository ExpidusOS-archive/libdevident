public static int main(string[] args) {
  GLib.Test.init(ref args);

  GLib.Test.add_func("/core/device/host-name", () => {
    try {
      var device_name = Devident.Device.get_host_id();
      GLib.info("Devident.Device.get_host_id(): %s", device_name);
      assert_nonnull(device_name);
    } catch (GLib.Error e) {
      GLib.assert_error(e, e.domain, e.code);
    }
  });
  return GLib.Test.run();
}
