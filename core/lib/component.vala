namespace Devident {
  public abstract class Component : GLib.Object {
    public abstract string id { get; }

    public virtual bool is_root_component {
      get {
        return false;
      }
    }

    public virtual Component? parent_component {
      get {
        return null;
      }
    }

    public virtual Component? root_component {
      get {
        return null;
      }
    }

    construct {
      assert(is_valid_id(this.id));
    }

    public abstract bool has_component(string id);
    public abstract Component? get_component(string id);
    public abstract GLib.List<string> get_component_ids();

    public bool has_component_path(string path) {
      var spath = path.split("/");
      var component = this;
      foreach (var id in spath) {
        component = component.get_component(id);
        if (component == null) return false;
      }
      return true;
    }

    public Component? get_component_path(string path) {
      var spath = path.split("/");
      var component = this;
      foreach (var id in spath) {
        component = component.get_component(id);
        if (component == null) return null;
      }
      return component;
    }

    public static bool is_valid_id(string id) {
      string[] needles = {
        " ",
        "/"
      };

      foreach (var needle in needles) {
        if (id.contains(needle)) return false;
      }

      return true;
    }
  }
}
