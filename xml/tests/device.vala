public const string devicedir_path = Devident.SOURCEDIR + "/xml/data/devident-xml";

public static int main(string[] args) {
  GLib.Test.init(ref args);

  GLib.Test.add_func("/xml/device-provider/get-device/all", () => {
    var provider = new DevidentXml.DeviceProvider();
    var list = provider.get_device_ids_in_path(devicedir_path);
    foreach (var id in list) {
      var device = provider.get_device_from_path(devicedir_path + "/" + id + ".xml");
      assert(device != null);
      GLib.info("%s", device.to_string());
    }
  });

  GLib.Test.add_func("/xml/device-provider/get-device/host", () => {
    try {
      var provider = new DevidentXml.DeviceProvider();
      var device = provider.get_device_from_path(devicedir_path + "/%s.xml".printf(Devident.Device.get_host_id()));
      GLib.info("%s", device.to_string());
    } catch (GLib.Error e) {
      GLib.error("Failed to get host device: %s:%d: %s", e.domain.to_string(), e.code, e.message);
    }
  });

  GLib.Test.add_func("/xml/device-provider/get-device-ids", () => {
    var provider = new DevidentXml.DeviceProvider();
    var list = provider.get_device_ids_in_path(devicedir_path);
    foreach (var item in list) GLib.info("Found device \"%s\"", item);
  });
  return GLib.Test.run();
}
