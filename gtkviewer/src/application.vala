namespace DevidentGtkViewer {
  public class Application : TokyoGtk.Application {
    public Application() {
      Object(application_id: "com.expidus.devident.gtkviewer", flags: GLib.ApplicationFlags.FLAGS_NONE);
    }

    construct {
      GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
      GLib.Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
      GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALDIR);
      GLib.Intl.textdomain(GETTEXT_PACKAGE);
    }

    public override void activate() {
      if (this.get_windows().length() > 0) {
        this.get_windows().nth_data(0).show();
      } else {
        var win = new Window(this);
        this.add_window(win);
        win.show();
      }
    }
  }
}

public static int main(string[] args) {
  return new DevidentGtkViewer.Application().run(args);
}
