public static int main(string[] args) {
  GLib.Test.init(ref args);

  GLib.Test.add_func("/core/context/global", () => {
    var global = Devident.Context.get_global();
    assert_nonnull(global);
    assert_nonnull(global.device_id);
  });

#if HAS_LIBPEAS
  GLib.Test.add_func("/core/context/libpeas", () => {
    try {
      var context = new Devident.PeasContext();
      foreach (var id in context.plugins.get_keys()) {
        GLib.debug("Has plugin %s", id);
      }
    } catch (GLib.Error e) {
      assert_error(e, e.domain, e.code);
    }
  });
#endif
  return GLib.Test.run();
}
