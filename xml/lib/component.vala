namespace DevidentXml {
  public struct ComponentInfo : Devident.ComponentInfo {
    public ComponentInfo(GXml.DomElement element) {
      var elem = element.get_elements_by_tag_name("name").item(0);
      assert(elem != null);
      this.name = elem.text_content;

      elem = element.get_elements_by_tag_name("vendor").item(0);
      assert(elem != null);
      this.vendor = elem.text_content;

      elem = element.get_elements_by_tag_name("product").item(0);
      assert(elem != null);
      this.product = elem.text_content;

      elem = element.get_elements_by_tag_name("kind").item(0);
      this.kind = Devident.ComponentInfoKind.UNKNOWN;
      if (elem != null) {
        Devident.ComponentInfoKind.try_parse_nick(elem.text_content, out this.kind);
      }
    }
  }

  public interface Component : Devident.Component {
    public abstract GXml.DomElement element { get; }

    public Devident.ComponentInfo info {
      owned get {
        var elem = this.element.get_elements_by_tag_name("component-info").item(0);
        assert(elem != null);
        return ComponentInfo(elem);
      }
    }

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
