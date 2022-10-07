public static int main(string[] args) {
  GLib.Test.init(ref args);

  GLib.Test.add_func("/core/context/global", () => {
    var global = Devident.Context.get_global();
    assert_nonnull(global);
    assert_nonnull(global.device_id);
  });
  return GLib.Test.run();
}
