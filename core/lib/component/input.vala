namespace Devident {
  public enum InputComponentKind {
    UNKNOWN = 0,
    TOUCH,
    TRACKPAD,
    GYRO,
    MOUSE,
    KEYBOARD;

    public static bool try_parse_name(string name, out InputComponentKind result = null) {
      var enumc        = (GLib.EnumClass)(typeof(InputComponentKind).class_ref());
      unowned var eval = enumc.get_value_by_name(name);
      if (eval == null) {
        result = InputComponentKind.UNKNOWN;
        return false;
      }

      result = (InputComponentKind)eval.value;
      return true;
    }

    public static bool try_parse_nick(string name, out InputComponentKind result = null) {
      var enumc        = (GLib.EnumClass)(typeof(InputComponentKind).class_ref());
      unowned var eval = enumc.get_value_by_nick(name);
      return_val_if_fail(eval != null, false);

      if (eval == null) {
        result = InputComponentKind.UNKNOWN;
        return false;
      }

      result = (InputComponentKind)eval.value;
      return true;
    }

    public string to_nick() {
      var enumc = (GLib.EnumClass)(typeof(InputComponentKind).class_ref());
      var eval  = enumc.get_value(this);
      return_val_if_fail(eval != null, null);
      return eval.value_nick;
    }
  }

  public abstract class InputComponent : GLib.Object, Component {
    public abstract InputComponentKind kind { get; }
    public abstract string id { get; }
    public abstract ComponentInfo info { owned get; }

    public virtual bool is_root_component {
      get {
        return false;
      }
    }

    public virtual Component ?parent_component {
      owned get {
        return null;
      }
    }

    public virtual Component ?root_component {
      get {
        return null;
      }
    }

    public abstract bool has_component(string id);
    public abstract Component ? get_component(string id);

    public abstract GLib.List <string> get_component_ids();

    construct {
      if (this.kind == InputComponentKind.TOUCH) {
        assert(this.parent_component != null);
        assert(this.parent_component is DisplayComponent);
      }
    }

    public string to_string() {
      var s       = this.base_to_string().split("\n");
      var new_str = s[0] + N_("\nKind: %s").printf(this.kind.to_nick());
      for (var i = 1; i < s.length; i++) {
        new_str += "\n%s".printf(s[i]);
      }
      return new_str;
    }
  }
}
