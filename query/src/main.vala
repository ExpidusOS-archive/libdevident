private bool arg_list_devices = false;
private string? arg_device = null;

private const GLib.OptionEntry[] options = {
  { "list-devices", '\0', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref arg_list_devices, N_("List all devices"), null },
  { "device", 'd', GLib.OptionFlags.NONE, GLib.OptionArg.STRING, ref arg_device, N_("Use device for viewing information"), "DEV" },
  { null }
};

public static int main(string[] args) {
  var argv0 = GLib.Path.get_basename(args[0]);

  GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
  GLib.Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
  GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALDIR);
  GLib.Intl.textdomain(GETTEXT_PACKAGE);

  try {
    var opts_ctx = new GLib.OptionContext(_("- Device Identification Query Tool"));
    opts_ctx.set_help_enabled(true);
    opts_ctx.add_main_entries(options, null);
    opts_ctx.parse(ref args);
  } catch (GLib.Error e) {
    stderr.printf(_("%s: failed to handle arguments: (%s:%d) %s\n"), argv0, e.domain.to_string(), e.code, e.message);
    return 1;
  }

  var ctx = Devident.Context.get_global();
  if (ctx == null) {
    stderr.printf(_("%s: failed to get the global context\n"), argv0);
    return 1;
  }

  if (arg_list_devices) {
    foreach (var dev in ctx.get_device_ids()) {
      stdout.printf("%s\n", dev);
    }
    return 0;
  }

  if (arg_device == null) {
    try {
      arg_device = Devident.Device.get_host_id();
    } catch (GLib.Error e) {
      stderr.printf(_("%s: failed to find host device identification for lookup: (%s:%d): %s\n"), argv0, e.domain.to_string(), e.code, e.message);
      return 1;
    }
  }

  var dev = arg_device != null ? ctx.find_device(arg_device) : ctx.get_default();
  if (dev == null) {
    if (arg_device == null) {
      stderr.printf(_("%s: could not find an unknown device\n"), argv0);
    } else {
      stderr.printf(_("%s: could not find device \"%s\"\n"), argv0, arg_device);
    }
    return 1;
  }

  stdout.printf("%s\n", dev.to_string());
  return 0;
}
