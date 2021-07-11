namespace devident {
  [DBus(name = "com.devident.Component")]
  public class FileComponent : GLib.Object, Component {
    private string _id;
    private string _name;
    private ComponentCategory _category;
    private GLib.ObjectPath _obj_path;
    private FileDevice _dev;
    private uint _obj_id;

    public FileComponent(FileDevice dev, string id) throws GLib.Error {
      this._dev = dev;
      this._id = id;
      this._obj_path = new GLib.ObjectPath("/com/devident/device/%s/component/%s".printf(this._dev.get_id(), this._id));
      this._obj_id = this._dev.daemon.conn.register_object(this._obj_path, (this as Component));
    }

    ~FileComponent() {
      this._dev.daemon.conn.unregister_object(this._obj_id);
    }

    public string get_id() throws GLib.Error {
      return this._id;
    }

    public string get_name() throws GLib.Error {
      return this._name;
    }

    public ComponentCategory get_category() throws GLib.Error {
      return this._category;
    }

    public bool is_present() throws GLib.Error {
      return true; // TODO: how do I do this?
    }

    public GLib.ObjectPath get_object_path() throws GLib.Error {
      return this._obj_path;
    }
  }
}