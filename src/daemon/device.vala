namespace devident {
  [DBus(name = "com.devident.Device")]
  public class FileDevice : Device {
    private DBusDaemon _daemon;
    private string _path;
    private GLib.KeyFile _kf = new GLib.KeyFile();
    private GLib.List<FileComponent> _components;
    private uint _obj_id;
    
    [DBus(visible = false)]
    public DBusDaemon daemon {
      get {
        return this._daemon;
      }
    }

    public string path {
      get {
        return this._path;
      }
    }

    [DBus(visible = false)]
    public GLib.KeyFile kf {
      get {
        return this._kf;
      }
    }

    public FileDevice(DBusDaemon daemon, string path) throws GLib.Error {
      this._daemon = daemon;
      this._path = path;
      this._components = new GLib.List<FileComponent>();
      this._kf.load_from_file(this._path, GLib.KeyFileFlags.NONE);

      var groups = this._kf.get_groups();
      for (var i = 0; i < groups.length; i++) {
        if (groups[i] == "device") continue;
        this._components.append(new FileComponent(this, groups[i]));
      }

      this._obj_id = this.daemon.conn.register_object("/com/devident/device/%s".printf(this.get_id()), (this as Device));
    }

    ~FileDevice() {
      this._components.@foreach((comp) => comp.unref());
      this.daemon.conn.unregister_object(this._obj_id);
    }

    public override string get_id() {
      return GLib.Path.get_basename(this._path).replace(".cfg", "");
    }

    public override string get_name() throws GLib.Error {
      return this._kf.get_string("device", "name");
    }

    public override string get_manufacturer() throws GLib.Error {
      return this._kf.get_string("device", "manufacturer");
    }

    public override GLib.ObjectPath[] get_components_dbus() throws GLib.Error {
      var objs = new GLib.ObjectPath[this._components.length()];
      for (var i = 0; i < this._components.length(); i++) {
        objs[i] = this._components.nth_data(i).get_object_path();
      }
      return objs;
    }
  }

  [DBus(name = "com.devident.Device")]
  public class AutoDevice : Device {
    private DBusDaemon _daemon;
    private uint _obj_id;
    
    [DBus(visible = false)]
    public DBusDaemon daemon {
      get {
        return this._daemon;
      }
    }

    public AutoDevice(DBusDaemon daemon) throws GLib.Error {
      this._daemon = daemon;
      this._obj_id = this.daemon.conn.register_object("/com/devident/device/auto", (this as Device));
    }

    ~AutoDevice() {
      this.daemon.conn.unregister_object(this._obj_id);
    }

    public override string get_id() throws GLib.Error {
      return "auto";
    }

    public override string get_manufacturer() throws GLib.Error {
      var str = "";
      if (GLib.FileUtils.test("/sys/devices/virtual/dmi/id/board_vendor", GLib.FileTest.IS_REGULAR)) {
        GLib.FileUtils.get_contents("/sys/devices/virtual/dmi/id/board_vendor", out str);
        str = str.replace("\n", "");
      }
      return str;
    }

    public override string get_name() throws GLib.Error {
      string? dev_string = get_device_string(this.daemon, null);
      return dev_string == null ? "" : dev_string;
    }

    public override GLib.ObjectPath[] get_components_dbus() throws GLib.Error {
      return new GLib.ObjectPath[0];
    }
  }
}