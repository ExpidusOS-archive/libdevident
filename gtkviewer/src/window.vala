namespace DevidentGtkViewer {
  [GtkTemplate(ui = "/com/expidus/devident/gtkviewer/window.glade")]
  public class Window : TokyoGtk.ApplicationWindow {
    public Window(Application application) {
      Object(application: application);
    }
  }
}
