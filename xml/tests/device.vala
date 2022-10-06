public const string devicedir_path = Devident.SOURCEDIR + "/xml/data/devident-xml";

public static int main(string[] args) {
  GLib.Test.init(ref args);

  GLib.Test.add_func("/xml/device-provider/get-device/all", () => {
    var provider = new DevidentXml.DeviceProvider();
    var list = provider.get_device_ids_in_path(devicedir_path);
    foreach (var id in list) {
      var device = provider.get_device_from_path(devicedir_path + "/" + id + ".xml");
      assert(device != null);
      GLib.info("%s - Info (%s)", id, device.info.to_string());
    }
  });

  GLib.Test.add_func("/xml/device-provider/get-device-ids", () => {
    var provider = new DevidentXml.DeviceProvider();
    var list = provider.get_device_ids_in_path(devicedir_path);
    foreach (var item in list) GLib.info("Found device \"%s\"", item);
  });
  return GLib.Test.run();
}
