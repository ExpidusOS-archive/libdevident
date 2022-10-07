# libdevident

A (nearly) universal device identification modular library written in Vala.

## Features

- GModule and `libpeas` plugin loaders
- Context based allowing for multiple instances in a single program
- Daemonless
- Loadable device identification files in `xml`
- Supports both macOS and Linux

## Dependencies

### Host

- `gettext` tools
- `gobject-introspection`
- `vala`

### Target

- `libpeas` (*optional* but recommended)
- `gmodule-2.0` (*optional* but recommended)
- `gxml` (*optional* but recommended)
- `gio-2.0`
- `vadi`
