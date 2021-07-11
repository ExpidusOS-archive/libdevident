namespace devident {
  [DBus(name = "com.devident.Daemon")]
  public interface BaseDaemon : GLib.Object {
    public abstract string get_version() throws GLib.Error;
    public abstract void quit() throws GLib.Error;

    [DBus(name = "GetDevice")]
    public abstract GLib.ObjectPath get_device_dbus(GLib.BusName sender) throws GLib.Error;

    public abstract void reload() throws GLib.Error;

    [DBus(visible = false)]
    public Device get_device() throws GLib.Error {
      var conn = GLib.Bus.get_sync(GLib.BusType.SYSTEM);
      var obj_path = this.get_device_dbus(new GLib.BusName(conn.unique_name));
      return conn.get_proxy_sync<Device>("com.devident", obj_path);
    }
  }
}