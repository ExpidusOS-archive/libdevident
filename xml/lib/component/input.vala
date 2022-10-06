namespace DevidentXml {
  public sealed class InputComponent : Devident.InputComponent, Component {
    private GXml.DomElement _element;
    private string? _id;

    public GXml.DomElement element {
      get {
        return this._element;
      }
      construct {
        this._element = value;
      }
    }

    public override Devident.Component? parent_component {
      owned get {
        return ((Component)this).parent_component;
      }
    }

    public override string id {
      get {
        if (this._id == null) this._id = this.element.get_attribute("id");
        return this._id;
      }
    }

    public override Devident.InputComponentKind kind {
      get {
        var value = Devident.InputComponentKind.UNKNOWN;
        var col = this.element.get_elements_by_tag_name("kind");
        if (col.length == 0) return Devident.InputComponentKind.UNKNOWN;

        if (Devident.InputComponentKind.try_parse_nick(col.item(0).text_content, out value)) return value;
        return Devident.InputComponentKind.UNKNOWN;
      }
    }

    public override Devident.ComponentInfo info {
      owned get {
        return ((Component)this).info;
      }
    }

    public InputComponent(GXml.DomElement element) {
      Object(element: element);
    }

    public override bool has_component(string id) {
      return ((Component)this).has_component(id);
    }

    public override Devident.Component? get_component(string id) {
      return ((Component)this).get_component(id);
    }

    public override GLib.List<string> get_component_ids() {
      return ((Component)this).get_component_ids();
    }
  }
}
