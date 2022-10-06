namespace DevidentXml {
  public sealed class DeviceProvider : GLib.Object, Devident.DeviceProvider {
    public DeviceProvider() {
      Object();
    }

    public Devident.Device? get_device_from_path(string path) {
      try {
        var document = new GXml.Document.from_path(path);
        document.read_from_file(GLib.File.new_for_path(path), null);

        var device = new Device(document);
        var bname = GLib.Path.get_basename(path);
        var ix = bname.last_index_of_char('.', 0);
        device._id = bname.substring(0, ix);
        return device;
      } catch (GLib.Error e) {
        GLib.error(N_("Failed to get device \"%s\": %s:%d: %s"), path, e.domain.to_string(), e.code, e.message);
      }
    }

    public Devident.Device? get_device(string id) {
      return this.get_device_from_path(DATADIR + "/devident-xml/devices/%s.xml".printf(id));
    }

    public GLib.List<string> get_device_ids_in_path(string dirpath) {
      var list = new GLib.List<string>();
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

    public GLib.List<string> get_device_ids() {
      return this.get_device_ids_in_path(DATADIR + "/devident-xml/devices");
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
        if (this._element == null) {
          this._element = this.document.document_element;
        }
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

        if (Devident.DeviceKind.try_parse_nick(elem.text_content, out value)) return value;
        return Devident.DeviceKind.DESKTOP;
      }
    }

    public Device(GXml.Document document) throws GLib.Error {
      Object(document: document);
    }

    construct {
      assert_cmpstr(this.document.document_element.node_name, GLib.CompareOperator.EQ, "devident-device");
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
