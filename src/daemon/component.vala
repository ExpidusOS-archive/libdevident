namespace devident {
  public class DaemonComponent : GLib.Object, Component {
    private string _id;
    private string _name;
    private ComponentCategory _category;

    public string id {
      get {
        return this._id;
      }
      construct {
        this._id = value;
      }
    }

    public string name {
      get {
        return this._name;
      }
      construct {
        this._name = value;
      }
    }

    public ComponentCategory category {
      get {
        return this._category;
      }
      construct {
        this._category = value;
      }
    }

    public DaemonComponent() {}

    public string get_id() {
      return this.id;
    }

    public string get_name() {
      return this.name;
    }

    public ComponentCategory get_category() {
      return this.category;
    }

    public bool is_present() {
      return true; // TODO: how do I do this?
    }
  }
}