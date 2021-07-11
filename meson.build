project('devident', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

pkg = import('pkgconfig')
dbus = dependency('dbus-1')

install_subdir('data/devices',
	install_dir: join_paths(get_option('sysconfdir'), 'expidus', 'devices.d'),
	strip_directory: true)

conf_data = configuration_data()
conf_data.set('BINDIR', join_paths(get_option('prefix'), get_option('bindir')))
conf_data.set('SYSCONFDIR', get_option('sysconfdir'))
conf_data.set('VERSION', meson.project_version())

build_conf = configure_file(input: 'src/build.vala.in', output: 'build.vala',
	configuration: conf_data)

# Common/client library
libdevident = shared_library('devident', 'src/lib/component.vala', 'src/lib/daemon.vala', 'src/lib/device.vala',
	vala_header: 'devident.h',
	vala_vapi: 'devident-1.0.vapi',
	install_dir: [true, true, true],
	install: true,
	dependencies: [dependency('glib-2.0'), dependency('gobject-2.0'), dependency('gio-2.0')])
pkg.generate(libdevident, description: 'A device identification library.',
	name: 'libdevident')
libdevident_dep = declare_dependency(link_with: libdevident)

# Daemon
executable('devidentd', 'src/daemon/component.vala', 'src/daemon/daemon.vala', 'src/daemon/device.vala', build_conf,
	install: true,
	dependencies: [dependency('gobject-2.0'), dependency('gio-2.0'), dependency('libdaemon'), libdevident_dep])

install_data('data/com.devident.conf', install_dir: join_paths(dbus.get_pkgconfig_variable('sysconfdir'), 'dbus-1', 'system.d'))

configure_file(input: 'data/com.devident.service.in', output: 'com.devident.service',
	configuration: conf_data,
	install: true,
	install_dir: dbus.get_pkgconfig_variable('system_bus_services_dir'))