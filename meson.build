project('devident', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

pkg = import('pkgconfig')
dbus = dependency('dbus-1')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
libpeas = dependency('libpeas-1.0')

prefix = get_option('prefix')
libdir = prefix / get_option('libdir')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
sysconfdir = get_option('sysconfdir')

if not sysconfdir.startswith('/')
	sysconfdir = prefix / sysconfdir
endif

install_data('data/devident.cfg',
	install_dir: join_paths(sysconfdir, 'expidus'))

version = '"@0@"'.format(meson.project_version())
git = find_program('git', native: true, required: false)
if git.found()
	git_commit = run_command([git, 'rev-parse', '--short', 'HEAD'])
	git_branch = run_command([git, 'rev-parse', '--abbrev-ref', 'HEAD'])
	if git_commit.returncode() == 0 and git_branch.returncode() == 0
		version = '"@0@-@1@ (branch \'@2@\')"'.format(meson.project_version(), git_commit.stdout().strip(), git_branch.stdout().strip())
	endif
endif

conf_data = configuration_data()
conf_data.set('BINDIR', bindir)
conf_data.set('LIBDIR', libdir)
conf_data.set('DATADIR', datadir)
conf_data.set('SYSCONFDIR', sysconfdir)
conf_data.set('VERSION', version)

build_conf = configure_file(input: 'src/build.vala.in', output: 'build.vala',
	configuration: conf_data)

# Common library
libdevident_common = shared_library('devident-common', 'src/lib/common/component.vala', 'src/lib/common/context.vala', 'src/lib/common/device.vala', build_conf,
	vala_header: 'devident-common.h',
	vala_vapi: 'DevidentCommon-1.0.vapi',
	vala_gir: 'devident-common-1.0.gir',
	install_dir: [true, true, true, true],
	install: true,
	dependencies: [gobject, gio])
pkg.generate(libdevident_common, description: 'A device identification library. (Commons)',
	requires: [gobject.name(), gio.name()],
	name: 'devident-common-1.0')
libdevident_common_dep = declare_dependency(link_with: libdevident_common, dependencies: [gobject, gio])

# Client library
libdevident_client = shared_library('devident-client', 'src/lib/client/components/backlight.vala', 'src/lib/client/components/display.vala',
		'src/lib/client/components/touchscreen.vala', 'src/lib/client/component.vala', 'src/lib/client/context.vala', 'src/lib/client/device.vala',
	vala_header: 'devident-client.h',
	vala_vapi: 'DevidentClient-1.0.vapi',
	vala_gir: 'devident-client-1.0.gir',
	install_dir: [true, true, true, true],
	install: true,
	dependencies: [gobject, gio, libdevident_common_dep])
pkg.generate(libdevident_client, description: 'A device identification library. (Client)',
	requires: [gobject.name(), gio.name(), 'devident-common-1.0'],
	name: 'devident-client-1.0')
libdevident_client_dep = declare_dependency(link_with: libdevident_client, dependencies: [gobject, gio, libdevident_common_dep])

# Server library
libdevident_server = shared_library('devident-server', 'src/lib/server/components/backlight.vala', 'src/lib/server/components/display.vala',
		'src/lib/server/components/touchscreen.vala',	'src/lib/server/common.vala', 'src/lib/server/component.vala', 'src/lib/server/context.vala',
		'src/lib/server/device.vala',
	vala_header: 'devident-server.h',
	vala_vapi: 'DevidentServer-1.0.vapi',
	vala_gir: 'devident-server-1.0.gir',
	install_dir: [true, true, true, true],
	install: true,
	dependencies: [gobject, gio, libdevident_common_dep])
pkg.generate(libdevident_server, description: 'A device identification library. (Server)',
	requires: [gobject.name(), gio.name(), 'devident-common-1.0'],
	name: 'devident-server-1.0')
libdevident_server_dep = declare_dependency(link_with: libdevident_server, dependencies: [gobject, gio, libdevident_common_dep])

modules = ['alienware', 'fallback', 'hp', 'pine64']
foreach name : modules
	configure_file(input: 'data/modules/' + name + '.plugin.in', output: name + '.plugin',
		configuration: conf_data,
		install: true,
		install_dir: join_paths(libdir, 'devident', 'modules', name))

	shared_module(name, ['src/modules/' + name + '.vala'],
		dependencies: [libdevident_server_dep, libpeas],
		install: true,
		install_dir: join_paths(libdir, 'devident', 'modules', name))
endforeach

# Daemon
executable('devidentd', 'src/daemon/daemon.vala',
	install: true,
	dependencies: [libdevident_server_dep, libpeas])

install_data('data/com.devident.conf', install_dir: join_paths(dbus.get_pkgconfig_variable('sysconfdir'), 'dbus-1', 'system.d'))

configure_file(input: 'data/com.devident.service.in', output: 'com.devident.service',
	configuration: conf_data,
	install: true,
	install_dir: dbus.get_pkgconfig_variable('system_bus_services_dir'))
