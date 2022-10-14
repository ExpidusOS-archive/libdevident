namespace DevidentXml {
#if HAS_LIBPEAS
  public sealed class PeasPlugin : GLib.Object, Peas.Activatable {
    private Devident.Context _context;
    private Provider _provider;

    public GLib.Object object {
      owned get {
        return this._context;
      }
      construct {
        this._context = value as Devident.Context;
      }
    }

    construct {
      this._provider = new Provider();
    }

    public void activate() {
      assert(this._context != null);
      this._context.add_provider(this._provider);
    }

    public void deactivate() {
      assert(this._context != null);
      this._context.remove_provider(this._provider);
    }

    public void update_state() {
    }
  }

  [CCode(cname = "peas_register_types")]
  internal void register_types(Peas.ObjectModule module) {
    module.register_extension_type(typeof (Peas.Activatable), typeof (PeasPlugin));
  }
#endif

#if HAS_GMODULE
  internal sealed class GModulePlugin : Devident.GModulePlugin {
    private Provider _provider;

    construct {
      this._provider = new Provider();
    }

    public override void activate() {
      this.context.add_provider(this._provider);
    }

    public override void deactivate() {
      this.context.remove_provider(this._provider);
    }
  }

  [CCode(cname = "register_devident_plugin")]
  internal GLib.Type register_plugin(GLib.Module module) {
    return typeof(GModulePlugin);
  }
#endif
}
