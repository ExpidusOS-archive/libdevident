namespace Devident {
  public abstract class DisplayComponent : GLib.Object, Component {
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
  }
}
