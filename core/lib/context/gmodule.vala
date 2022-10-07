namespace Devident {
  public errordomain GModuleContextError {
    FAILED,
    MISSING_FUNCTION,
    UNEXPECTED_TYPE
  }

  public abstract class GModulePlugin : GLib.Object {
    private Context _context;
    private unowned GLib.Module _module;

    public Context context {
      get {
        return this._context;
      }
      construct {
        this._context = value;
      }
    }

    public unowned GLib.Module module {
      get {
        return this._module;
      }
      construct {
        this._module = value;
      }
    }

    public abstract void activate();
    public abstract void deactivate();

    public static new GModulePlugin ? @new(GLib.Type type, Context context, GLib.Module module) {
      return GLib.Object.new(type, "context", context, module) as GModulePlugin;
    }
  }

  public sealed class GModuleContext : Context {
    private GLib.HashTable <string, GModulePlugin> _plugins;

    public GLib.HashTable <string, GModulePlugin> plugins {
      get {
        return this._plugins;
      }
    }

    public GModuleContext() throws GLib.Error {
      Object();
    }

    construct {
      assert(GLib.Module.supported());
    }

    public GModulePlugin ? load(string path) throws GModuleContextError {
      if (this._plugins.contains(path)) {
        return this._plugins.get(path);
      }

      GLib.Module module = GLib.Module.open(path, GLib.ModuleFlags.LAZY);
      if (module == null) {
        throw new GModuleContextError.FAILED(GLib.Module.error());
      }

      void *ptr;
      module.symbol("register_devident_plugin", out ptr);
      if (ptr == null) {
        throw new GModuleContextError.MISSING_FUNCTION(N_("register_devident_plugin() not found"));
      }

      RegisterPluginFunction register_devident_plugin = (RegisterPluginFunction)ptr;
      var type = register_devident_plugin(module);
      if (!type.is_a(typeof(GModulePlugin))) {
        throw new GModuleContextError.UNEXPECTED_TYPE(N_("Unexpected type: got %s").printf(type.name()));
      }

      var plugin = GModulePlugin.new(type, this, module);
      if (plugin == null) {
        throw new GModuleContextError.UNEXPECTED_TYPE(N_("Unexpected type: got null"));
      }

      this._plugins.set(path, plugin);
      return plugin;
    }

    [CCode(has_target = false)]
    private delegate GLib.Type RegisterPluginFunction(GLib.Module module);
  }
}
