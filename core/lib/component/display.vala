namespace Devident {
  public abstract class DisplayComponent : GLib.Object, Component {
    public abstract string id { get; }
    public abstract ComponentInfo info { owned get; }

    public abstract bool has_component(string id);
    public abstract Component? get_component(string id);
    public abstract GLib.List<string> get_component_ids();
  }
}
