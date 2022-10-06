namespace DevidentXml {
  public struct ComponentInfo : Devident.ComponentInfo {
    public ComponentInfo(GXml.DomElement element) {
      var elem = element.get_elements_by_tag_name("name").item(0);
      assert(elem != null);
      this.name = elem.text_content;

      var col = element.get_elements_by_tag_name("vendor");
      if (col.length > 0) this.vendor = col.item(0).text_content;

      col = element.get_elements_by_tag_name("product");
      if (col.length > 0) this.product = col.item(0).text_content;

      col = element.get_elements_by_tag_name("description");
      if (col.length > 0) this.description = col.item(0).text_content;

      col = element.get_elements_by_tag_name("website");
      if (col.length > 0) this.website = col.item(0).text_content;

      col = element.get_elements_by_tag_name("kind");
      this.kind = Devident.ComponentInfoKind.UNKNOWN;
      if (col.length > 0) {
        Devident.ComponentInfoKind.try_parse_nick(col.item(0).text_content, out this.kind);
      }
    }
  }

  public interface Component : Devident.Component {
    public abstract GXml.DomElement element { get; construct; }

    public Devident.ComponentInfo info {
      owned get {
        var elem = this.element.get_elements_by_tag_name("component-info").item(0);
        assert(elem != null);
        return ComponentInfo(elem);
      }
    }

    public Devident.Component? parent_component {
      owned get {
        return Component.new(this.element.parent_element);
      }
    }

    public static Component? @new(GXml.DomElement element) {
      switch (element.get_attribute("type")) {
        case "display":
          return new DisplayComponent(element);
        case "input":
          return new InputComponent(element);
        case null:
          if (element.tag_name == "devident-device") {
            try {
              return new Device(element);
            } catch {
              return null;
            }
          }
          return null;
        default:
          return null;
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
          return Component.new(elem);
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
