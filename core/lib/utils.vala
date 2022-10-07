namespace Devident {
  internal string read_file(string file) throws GLib.FileError {
    string value;
    GLib.FileUtils.get_contents(file, out value);
    return value.replace("\n", "");
  }

  internal string try_read_file(string file) {
    try {
      return read_file(file);
    } catch (GLib.Error e) {}
    return "";
  }
}
