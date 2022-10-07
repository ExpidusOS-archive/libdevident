namespace DevidentXml {
  public sealed class DeviceProvider : GLib.Object, Devident.DeviceProvider {
    public DeviceProvider() {
      Object();
    }

    public Devident.Device ?get_device_from_path(string path) {
      try {
        var document = new GXml.Document.from_path(path);
        document.read_from_file(GLib.File.new_for_path(path), null);

        var device = new Device(document.document_element);
        var bname  = GLib.Path.get_basename(path);
        var ix     = bname.last_index_of_char('.', 0);
        device._id = bname.substring(0, ix);
        return device;
      } catch (GLib.Error e) {
        GLib.error(N_("Failed to get device \"%s\": %s:%d: %s"), path, e.domain.to_string(), e.code, e.message);
      }
    }

    public Devident.Device ?get_device(string id) {
      return this.get_device_from_path(DATADIR + "/devident-xml/devices/%s.xml".printf(id));
    }

    public GLib.List <string> get_device_ids_in_path(string dirpath) {
      var list = new GLib.List <string>();
      try {
        var     dir  = GLib.Dir.open(dirpath, 0);
        string ?name = null;

        while ((name = dir.read_name()) != null) {
          if (!GLib.FileUtils.test(dirpath + "/" + name, GLib.FileTest.IS_REGULAR)) {
            continue;
          }

          var ix = name.last_index_of_char('.', 0);
          if (ix == -1) {
            continue;
          }
          if (name.substring(ix + 1) != "xml") {
            continue;
          }

          list.append(name.substring(0, ix));
        }
      } catch (GLib.Error e) {
        GLib.error("Failed to open directory \"%s\": %s:%d: %s", dirpath, e.domain.to_string(), e.code, e.message);
      }
      return list;
    }

    public GLib.List <string> get_device_ids() {
      return this.get_device_ids_in_path(DATADIR + "/devident-xml/devices");
    }
  }

  public sealed class Device : Devident.Device, Component {
    private GXml.DomElement _element;
    internal string ?_id;

    public GXml.DomElement element {
      get {
        return this._element;
      }
      construct {
        this._element = value;
      }
    }

    public override string id {
      get {
        if (this._id == null) {
          this._id = GLib.Path.get_basename(this.element.owner_document.url);
        }
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
        var col   = this.element.get_elements_by_tag_name("kind");
        if (col.length == 0) {
          return Devident.DeviceKind.DESKTOP;
        }

        if (Devident.DeviceKind.try_parse_nick(col.item(0).text_content, out value)) {
          return value;
        }
        return Devident.DeviceKind.DESKTOP;
      }
    }

    public Device(GXml.DomElement element) throws GLib.Error {
      Object(element: element);
    }

    construct {
      assert_cmpstr(this.element.node_name, GLib.CompareOperator.EQ, "devident-device");
    }

    public override bool has_component(string id) {
      return ((Component)this).has_component(id);
    }

    public override Devident.Component ?get_component(string id) {
      return ((Component)this).get_component(id);
    }

    public override GLib.List <string> get_component_ids() {
      return ((Component)this).get_component_ids();
    }
  }
}
