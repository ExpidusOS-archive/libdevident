# libdevident

A versatile device identification library. `libdevident` is designed in mind for reporting information on the device being used so applications can tune themselves for different devices without much issue.

## Dependencies
* `libdaemon`
* `gio-2.0`
* `glib-2.0`
* `gobject-2.0`
* vala (host)

## Features
* DBus activatable service
* Per-device configuration files using regex
* Overridable applications
* Fallback virtual device