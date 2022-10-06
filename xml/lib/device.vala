namespace DevidentXml {
  public sealed class DeviceProvider : GLib.Object, Devident.DeviceProvider {
    public Devident.Device? get_device(string id) {
      try {
        var device = new Device(new GXml.Document.from_path(DATADIR + "/devident-xml/devices/%s.xml".printf(id)));
        device._id = id;
        return device;
      } catch (GLib.Error e) {
        return null;
      }
    }

    public GLib.List<string> get_device_ids() {
      var list = new GLib.List<string>();
      var dirpath = DATADIR + "/devident-xml/devices";
      try {
        var dir = GLib.Dir.open(dirpath, 0);
        string? name = null;

        while ((name = dir.read_name()) != null) {
          if (!GLib.FileUtils.test(dirpath + "/" + name, GLib.FileTest.IS_REGULAR)) continue;

          var ix = name.last_index_of_char('.', 0);
          if (ix == -1) continue;
          if (name.substring(ix + 1) != "xml") continue;

          list.append(name.substring(0, ix));
        }
      } catch (GLib.Error e) {
        GLib.error("Failed to open directory \"%s\": %s:%d: %s", dirpath, e.domain.to_string(), e.code, e.message);
      }
      return list;
    }
  }

  public sealed class Device : Devident.Device, Component {
    private GXml.Document _document;
    private GXml.DomElement _element;
    internal string? _id;

    public GXml.Document document {
      get {
        return this._document;
      }
      construct {
        this._document = value;
      }
    }

    public GXml.DomElement element {
      get {
        if (this._element == null) this._element = this.document.search_root_element_property();
        return this._element;
      }
    }

    public override string id {
      get {
        if (this._id == null) this._id = GLib.Path.get_basename(this.document.url);
        return this._id;
      }
    }

    public override Devident.ComponentInfo info {
      owned get {
        return ((Component)this).info;
      }
    }

    public override Devident.DeviceKind kind {
      get {
        var value = Devident.DeviceKind.DESKTOP;
        var elem = this.document.get_elements_by_tag_name("kind").item(0);
        if (elem == null) return Devident.DeviceKind.DESKTOP;

        if (Devident.DeviceKind.try_parse_name(elem.text_content, out value)) return value;
        return Devident.DeviceKind.DESKTOP;
      }
    }

    public Device(GXml.Document document) throws GLib.Error {
      Object(document: document);
    }

    construct {
      var root_elem = this.document.search_root_element_property();
      assert_cmpstr(root_elem.tag_name, GLib.CompareOperator.EQ, "devident-device");
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
