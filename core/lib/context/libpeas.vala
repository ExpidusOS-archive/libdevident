namespace Devident {
  public sealed class PeasContext : Context {
    private GLib.HashTable<string, Peas.Activatable> _plugins;
    private Peas.Engine _plugin_engine;
    private Peas.ExtensionSet _plugin_set;

    public GLib.HashTable<string, Peas.Activatable> plugins {
      get {
        return this._plugins;
      }
    }

    public Peas.Engine plugin_engine {
      get {
        return this._plugin_engine;
      }
    }

    public PeasContext() throws GLib.Error {
      Object();
    }

    construct {
      this._plugins = new GLib.HashTable<string, Peas.Activatable>(GLib.str_hash, GLib.str_equal);
      this._plugin_engine = new Peas.Engine();
      this._plugin_engine.add_search_path(LIBDIR + "/devident/plugins", DATADIR + "/devident/plugins");

#if TARGET_SYSTEM_WINDOWS
      var prefix = GLib.Win32.get_package_installation_directory_of_module(null);
      this._plugin_engine.add_search_path(GLib.Path.build_filename(prefix, "lib", "devident", "plugins"), GLib.Path.build_filename(prefix, "share", "devident", "plugins"));
#endif

      this._plugin_set = new Peas.ExtensionSet(this._plugin_engine, typeof (Peas.Activatable), "object", this);

      this._plugin_set.foreach((pset, info, extension) => {
        this.plugin_added(info, extension as Peas.Activatable);
      });

      this._plugin_set.extension_added.connect((info, obj) => {
        this.plugin_added(info, obj as Peas.Activatable);
      });

      this._plugin_set.extension_removed.connect((info, obj) => {
        var activatable = obj as Peas.Activatable;
        if (activatable != null) {
          GLib.debug(N_("Removing plugin \"%s\" %p"), info.get_name(), obj);
          activatable.deactivate();
          this._plugins.remove(info.get_module_name());
        }
      });
    }

    private void plugin_added(Peas.PluginInfo info, Peas.Activatable? activatable) {
      if (activatable != null && !this._plugins.contains(info.get_module_name())) {
        GLib.debug(N_("Adding plugin \"%s\" %p"), info.get_name(), activatable);
        this._plugins.set(info.get_module_name(), activatable);
        activatable.activate();
      }
    }
  }
}
