namespace DevidentXml {
  public sealed class Provider : Devident.Provider {
    internal Provider() {
      Object();
    }

    construct {
      GLib.Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
      GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALDIR);
    }

    public override void init(Vdi.Container container) {
      container.bind_type(typeof (Devident.DeviceProvider), typeof (DeviceProvider));
    }
  }
}
