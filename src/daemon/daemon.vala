namespace devident {
  private bool arg_kill = false;

  private const GLib.OptionEntry[] options = {
    { "kill", 'k', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref arg_kill, "Kills the current instance of the daemon", null },
    { null }
  };

  [DBus(name = "com.devident.Daemon")]
  public class DBusDaemon : GLib.Object, BaseDaemon {
    private GLib.MainLoop _loop;

    [DBus(visible = false)]
    public GLib.MainLoop loop {
      get {
        return this._loop;
      }
      construct {
        this._loop = value;
      }
    }

    public DBusDaemon(GLib.MainLoop loop) {
      Object(loop: loop);
    }

    public string get_version() throws GLib.Error {
      return "0.1.0";
    }

    public void quit() throws GLib.Error {
      this.loop.quit();
    }
  }

  private void finish() {
    Daemon.retval_send(255);
    Daemon.signal_done();
    Daemon.pid_file_remove();
  }

  public int main(string[] args) {
    try {
      GLib.OptionContext opt_ctx = new GLib.OptionContext("- Device identification daemon");
      opt_ctx.set_help_enabled(true);
      opt_ctx.add_main_entries(options, null);
      opt_ctx.parse(ref args);
    } catch (GLib.OptionError e) {
      stderr.printf("%s (%s): %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
      return 1;
    }

    Daemon.log_ident = Daemon.pid_file_ident = Daemon.ident_from_argv0(args[0]);

    if (arg_kill) {
      try {
        var conn = GLib.Bus.get_sync(GLib.BusType.SYSTEM);
        var daemon = conn.get_proxy_sync<BaseDaemon>("com.devident", "/com/devident");
        daemon.quit();
        return 0;
      } catch (GLib.Error e) {
        Daemon.log(Daemon.LogPriority.WARNING, "Failed to kill daemon using DBus, falling back to PID file: (%s) %s", e.domain.to_string(), e.message);
      }
      int ret = Daemon.pid_file_kill_wait(Daemon.Sig.TERM, 5);
      if (ret < 0) {
        Daemon.log(Daemon.LogPriority.WARNING, "Failed to kill daemon using PID file.");
      }
      return ret < 0 ? 1 : 0;
    }

    if (Daemon.reset_sigs(-1) < 0) {
      Daemon.log(Daemon.LogPriority.ERR, "Failed to reset signal handlers");
      return 1;
    }

    if (Daemon.unblock_sigs(-1) < 0) {
      Daemon.log(Daemon.LogPriority.ERR, "Failed to unblock signals");
      return 1;
    }

    var pid = Daemon.pid_file_is_running();
    if (pid >= 0) {
      Daemon.log(Daemon.LogPriority.ERR, "Device identification daemon is already running with PID file %u", pid);
      return 1;
    }

    if (Daemon.retval_init() < 0) {
      Daemon.log(Daemon.LogPriority.ERR, "Failed to create pipe");
      return 1;
    }

    if ((pid = Daemon.fork()) < 0) {
      Daemon.retval_done();
      return 0;
    } else if (pid > 0) {
      int ret = Daemon.retval_wait(20);
      if (ret < 0) {
        Daemon.log(Daemon.LogPriority.ERR, "Could not receive return value of daemon.");
        return 255;
      }
      
      Daemon.log(Daemon.LogPriority.ERR, "Received exit code %d", ret);
      return ret;
    } else {
      if (Daemon.close_all(-1) < 0) {
        Daemon.log(Daemon.LogPriority.ERR, "Failed to close all file descriptors");
        Daemon.retval_send(1);
        finish();
        return 1;
      }

      if (Daemon.pid_file_create() < 0) {
        Daemon.log(Daemon.LogPriority.ERR, "Failed to create PID file");
        Daemon.retval_send(2);
        finish();
        return 1;
      }

      if (Daemon.signal_init(Daemon.Sig.INT, Daemon.Sig.QUIT, 0) < 0) {
        Daemon.log(Daemon.LogPriority.ERR, "Could not register signal handlers");
        Daemon.retval_send(3);
        finish();
        return 1;
      }

      Daemon.retval_send(0);

      GLib.MainLoop loop = new GLib.MainLoop();
      Daemon.log(Daemon.LogPriority.INFO, "Daemon is online");

      GLib.Bus.own_name(GLib.BusType.SYSTEM, "com.devident", GLib.BusNameOwnerFlags.NONE, (conn, name) => {
        try {
          conn.register_object("/com/devident", new DBusDaemon(loop));
        } catch (GLib.IOError e) {
          Daemon.log(Daemon.LogPriority.ERR, "Failed to register object");
          loop.quit();
        }
      });

      loop.run();
      finish();
    }
    return 0;
  }
}