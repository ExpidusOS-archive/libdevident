namespace Devident {
  public enum ComponentInfoKind {
    UNKNOWN = 0,
    MOTHERBOARD,
    SBC;

    public static bool try_parse_name(string name, out ComponentInfoKind result = null) {
      var enumc = (GLib.EnumClass)(typeof (ComponentInfoKind).class_ref());
      unowned var eval = enumc.get_value_by_name(name);
      if (eval == null) {
        result = ComponentInfoKind.UNKNOWN;
        return false;
      }

      result = (ComponentInfoKind)eval.value;
      return true;
    }

    public static bool try_parse_nick(string name, out ComponentInfoKind result = null) {
      var enumc = (GLib.EnumClass)(typeof (ComponentInfoKind).class_ref());
      unowned var eval = enumc.get_value_by_nick(name);
      return_val_if_fail(eval != null, false);

      if (eval == null) {
        result = ComponentInfoKind.UNKNOWN;
        return false;
      }

      result = (ComponentInfoKind)eval.value;
      return true;
    }

    public string to_nick() {
      var enumc = (GLib.EnumClass)(typeof (ComponentInfoKind).class_ref());
      var eval = enumc.get_value(this);
      return_val_if_fail(eval != null, null);
      return eval.value_nick;
    }
  }

  public struct ComponentInfo {
    public string name;
    public string vendor;
    public string product;
    public ComponentInfoKind kind;

    public ComponentInfo() {}

    public string to_string() {
      return "%s (Vendor: \"%s\", Product: \"%s\") - %s".printf(this.name, this.vendor, this.product, this.kind.to_nick());
    }
  }

  public interface Component : GLib.Object {
    public abstract string id { get; }
    public abstract ComponentInfo info { owned get; }

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
