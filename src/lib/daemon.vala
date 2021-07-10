namespace devident {
  [DBus(name = "com.devident.Daemon")]
  public interface BaseDaemon : GLib.Object {
    public abstract string get_version() throws GLib.Error;
    public abstract void quit() throws GLib.Error;
  }
}