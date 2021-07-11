namespace devident {
  [DBus(name = "com.devident.Component")]
  public class FileComponent : GLib.Object, Component {
    private string _id;
    private GLib.ObjectPath _obj_path;
    private FileDevice _dev;
    private uint _obj_id;
    private GLib.Object? _obj = null;

    [DBus(visible = false)]
    public FileDevice dev {
      get {
        return this._dev;
      }
    }

    public FileComponent(FileDevice dev, string id) throws GLib.Error {
      this._dev = dev;
      this._id = id;
      this._obj_path = new GLib.ObjectPath("/com/devident/device/%s/component/%s".printf(this._dev.get_id(), this._id));
      this._obj_id = this._dev.daemon.conn.register_object(this._obj_path, (this as Component));

      switch (this.get_category()) {
        case ComponentCategory.NONE:
          break;
        case ComponentCategory.DISPLAY:
          this._obj = new FileDisplay(this);
          break;
        case ComponentCategory.TOUCH_DISPLAY:
          this._obj = new FileTouchDisplay(this);
          break;
        case ComponentCategory.GFX:
          this._obj = new FileGraphics(this);
          break;
        case ComponentCategory.HW_INPUT:
          this._obj = new FileHWInput(this);
          break;
        case ComponentCategory.CAMERA:
          this._obj = new FileCamera(this);
          break;
        case ComponentCategory.RGB:
          this._obj = new FileRGB(this);
          break;
      }
    }

    ~FileComponent() {
      if (this._obj != null) this._obj.unref();
      this._dev.daemon.conn.unregister_object(this._obj_id);
    }

    public string get_id() throws GLib.Error {
      return this._id;
    }

    public ComponentCategory get_category() throws GLib.Error {
      if (this._dev.kf.has_key(this._id, "category")) {
        var cat = this._dev.kf.get_string(this._id, "category");
        switch (cat) {
          case "none": return ComponentCategory.NONE;
          case "display": return ComponentCategory.DISPLAY;
          case "touch-display": return ComponentCategory.TOUCH_DISPLAY;
          case "hw-input": return ComponentCategory.HW_INPUT;
          case "gfx": return ComponentCategory.GFX;
          case "camera": return ComponentCategory.CAMERA;
          case "rgb": return ComponentCategory.RGB;
        }
      }
      return ComponentCategory.NONE;
    }

    public bool is_present() throws GLib.Error {
      return true; // TODO: how do I do this?
    }

    public GLib.ObjectPath get_object_path() throws GLib.Error {
      return this._obj_path;
    }
  }

  [DBus(name = "com.devident.Display")]
  public class FileDisplay : GLib.Object, Display {
    private FileComponent _comp;
    private uint _obj_id;

    public FileDisplay(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as Display));
    }

    ~FileDisplay() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    public string get_name() throws GLib.Error {
      return this._comp.dev.kf.get_string(this._comp.get_id(), "display-name");
    }

    public void get_resolution(out int x, out int y) throws GLib.Error {
      var r = this._comp.dev.kf.get_integer_list(this._comp.get_id(), "resolution");
      if (r.length == 2) {
        x = r[0];
        y = r[1];
      } else x = y = 0;
    }
  }

  [DBus(name = "com.devident.TouchDisplay")]
  public class FileTouchDisplay : GLib.Object, TouchDisplay {
    private FileComponent _comp;
    private uint _obj_id;

    public FileTouchDisplay(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as TouchDisplay));
    }

    ~FileTouchDisplay() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    public GLib.ObjectPath get_display_dbus() throws GLib.Error {
      return new GLib.ObjectPath("/com/devident/device/%s/component/%s".printf(this._comp.dev.get_id(), this._comp.dev.kf.get_string(this._comp.get_id(), "display-id")));
    }

    public string get_input() throws GLib.Error {
      return this._comp.dev.kf.get_string(this._comp.get_id(), "input");
    }

    public bool is_multitouch() throws GLib.Error {
      return this._comp.dev.kf.get_boolean(this._comp.get_id(), "multitouch");
    }
  }

  [DBus(name = "com.devident.Graphics")]
  public class FileGraphics : GLib.Object, Graphics {
    private FileComponent _comp;
    private uint _obj_id;

    public FileGraphics(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as Graphics));
    }

    ~FileGraphics() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    public bool supports_opengl() throws GLib.Error {
      var supports = this._comp.dev.kf.get_string_list(this._comp.get_id(), "supports");
      for (var i = 0; i < supports.length; i++) {
        if (supports[i] == "OpenGL") return true;
      }
      return false;
    }

    public void get_opengl_version(out int maj, out int min) throws GLib.Error {
      maj = min = 0;

      if (this.supports_opengl() && this._comp.dev.kf.has_key(this._comp.get_id(), "opengl-version")) {
        var ver = this._comp.dev.kf.get_integer_list(this._comp.get_id(), "opengl-version");
        maj = ver[0];
        min = ver[1];
      }
    }

    public bool supports_opengles() throws GLib.Error {
      var supports = this._comp.dev.kf.get_string_list(this._comp.get_id(), "supports");
      for (var i = 0; i < supports.length; i++) {
        if (supports[i] == "OpenGL ES") return true;
      }
      return false;
    }

    public void get_opengles_version(out int maj, out int min) throws GLib.Error {
      maj = min = 0;

      if (this.supports_opengles() && this._comp.dev.kf.has_key(this._comp.get_id(), "opengles-version")) {
        var ver = this._comp.dev.kf.get_integer_list(this._comp.get_id(), "opengles-version");
        maj = ver[0];
        min = ver[1];
      }
    }

    public bool supports_vulkan() throws GLib.Error {
      var supports = this._comp.dev.kf.get_string_list(this._comp.get_id(), "supports");
      for (var i = 0; i < supports.length; i++) {
        if (supports[i] == "Vulkan") return true;
      }
      return false;
    }

    public void get_vulkan_version(out int maj, out int min) throws GLib.Error {
      maj = min = 0;

      if (this.supports_opengles() && this._comp.dev.kf.has_key(this._comp.get_id(), "vulkan-version")) {
        var ver = this._comp.dev.kf.get_integer_list(this._comp.get_id(), "vulkan-version");
        maj = ver[0];
        min = ver[1];
      }
    }
  }

  [DBus(name = "com.devident.HWInput")]
  public class FileHWInput : GLib.Object, HWInput {
    private FileComponent _comp;
    private uint _obj_id;

    public FileHWInput(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as HWInput));
    }

    ~FileHWInput() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    private bool has(string name) throws GLib.Error {
      var buttons = this._comp.dev.kf.get_string_list(this._comp.get_id(), "buttons");
      for (var i = 0; i < buttons.length; i++) {
        if (buttons[i] == name) return true;
      }
      return false;
    }

    public bool has_home() throws GLib.Error {
      return this.has("home");
    }

    public bool has_back() throws GLib.Error {
      return this.has("home");
    }

    public bool has_context() throws GLib.Error {
      return this.has("home");
    }

    public bool has_volume() throws GLib.Error {
      return this.has("home");
    }

    public bool has_power() throws GLib.Error {
      return this.has("home");
    }
  }

  [DBus(name = "com.devident.Camera")]
  public class FileCamera : GLib.Object, Camera {
    private FileComponent _comp;
    private uint _obj_id;

    public FileCamera(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as Camera));
    }

    ~FileCamera() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    public string get_path() throws GLib.Error {
      return this._comp.dev.kf.get_string(this._comp.get_id(), "path");
    }

    public string[] get_names() throws GLib.Error {
      return this._comp.dev.kf.get_string_list(this._comp.get_id(), "names");
    }
    
    public string get_driver() throws GLib.Error {
      return this._comp.dev.kf.get_string(this._comp.get_id(), "driver");
    }
  }

  [DBus(name = "com.devident.RGB")]
  public class FileRGB : GLib.Object, RGB {
    private FileComponent _comp;
    private uint _obj_id;

    public FileRGB(FileComponent comp) throws GLib.Error {
      this._comp = comp;
      this._obj_id = this._comp.dev.daemon.conn.register_object(this._comp.get_object_path(), (this as RGB));
    }

    ~FileRGB() {
      this._comp.dev.daemon.conn.unregister_object(this._obj_id);
    }

    public RGBType get_rgb_type() throws GLib.Error {
      switch (this._comp.dev.kf.get_string(this._comp.get_id(), "type")) {
        case "sysfs": return RGBType.SYSFS;
        case "sysfs-seperate-rgb": return RGBType.SYSFS_SEPERATE_RGB;
        case "io-msi": return RGBType.IO_MSI;
      }
      return RGBType.SYSFS;
    }

    public string get_path() throws GLib.Error {
      if (this.get_rgb_type() != RGBType.SYSFS_SEPERATE_RGB) return this._comp.dev.kf.get_string(this._comp.get_id(), "path");
      return "";
    }

    public string get_red() throws GLib.Error {
      if (this.get_rgb_type() == RGBType.SYSFS_SEPERATE_RGB) {
        var s = this._comp.dev.kf.get_string_list(this._comp.get_id(), "path");
        if (s.length > 1) return s[0];
      }
      return "";
    }

    public string get_green() throws GLib.Error {
      if (this.get_rgb_type() == RGBType.SYSFS_SEPERATE_RGB) {
        var s = this._comp.dev.kf.get_string_list(this._comp.get_id(), "path");
        if (s.length > 2) return s[1];
      }
      return "";
    }

    public string get_blue() throws GLib.Error {
      if (this.get_rgb_type() == RGBType.SYSFS_SEPERATE_RGB) {
        var s = this._comp.dev.kf.get_string_list(this._comp.get_id(), "path");
        if (s.length == 3) return s[2];
      }
      return "";
    }
  }
}