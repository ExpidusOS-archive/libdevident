namespace DevidentXml {
  public interface Component : Devident.Component {
    public abstract GXml.DomElement element { get; }

    public Devident.Component? parent_component {
      get {
        return null; // TODO
      }
    }

    public bool has_component(string id) {
      var collection = this.element.get_elements_by_tag_name("component").to_array();
      foreach (var elem in collection) {
        if (elem.id == id) return true;
      }
      return false;
    }

    public Devident.Component? get_component(string id) {
      var collection = this.element.get_elements_by_tag_name("component").to_array();
      foreach (var elem in collection) {
        if (elem.id == id) {
          return null; // TODO
        }
      }
      return null;
    }

    public GLib.List<string> get_component_ids() {
      var list = new GLib.List<string>();
      foreach (var elem in this.element.get_elements_by_tag_name("component").to_array()) list.append(elem.id);
      return list;
    }
  }
}
