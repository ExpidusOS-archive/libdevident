conf_data_core = configuration_data()
conf_data_core.merge_from(conf_data)

libdevident_core_flags = []
libdevident_core_reqs = []

if libpeas.found()
  conf_data_core.set('HAS_LIBPEAS', 'true')
  libdevident_core_reqs += ['libpeas-1.0']
else
  conf_data_core.set('HAS_LIBPEAS', 'false')
endif

if gmodule.found()
  conf_data_core.set('HAS_GMODULE', 'true')
  libdevident_core_reqs += ['gmodule-2.0']
else
  conf_data_core.set('HAS_GMODULE', 'false')
endif

build_conf_core = configure_file(input: 'lib/build.vala.in', output: 'build.vala',
 configuration: conf_data_core)

libdevident_core_rel_sources = ['lib/component.vala', 'lib/context.vala', 'lib/device.vala', 'lib/provider.vala', 'lib/utils.vala',
  'lib/component/display.vala', 'lib/component/input.vala']
libdevident_core_sources = []

if target_machine.system() == 'darwin'
  libdevident_core_rel_sources += ['lib/device/darwin.c']
endif

if libpeas.found()
  libdevident_core_rel_sources += ['lib/context/libpeas.vala']
endif

if gmodule.found()
  libdevident_core_rel_sources += ['lib/context/gmodule.vala']
endif

foreach src : libdevident_core_rel_sources
  libdevident_core_sources += [join_paths(meson.current_source_dir(), src)]
endforeach

if uncrustify.found()
  run_target('core-prettier',
    command: [uncrustify, '--no-backup', libdevident_core_sources])
endif

libdevident_core_sources += [build_conf_core]
libdevident_core_deps = [vadi, gio, libintl]
libdevident_core_docs_args = ['--package-name=libdevident', '--package-version=@0@'.format(shortver)]

if libpeas.found()
  libdevident_core_deps += [libpeas]
  libdevident_core_docs_args += ['--pkg', 'libpeas-1.0']
endif

if gmodule.found()
  libdevident_core_deps += [gmodule]
  libdevident_core_docs_args += ['--pkg', 'gmodule-2.0']
endif

libdevident_core_shlib = shared_library('devident', build_conf_core, libdevident_core_rel_sources,
  c_args: ['-DG_LOG_DOMAIN="Devident"', '-DGETTEXT_PACKAGE="libdevident"'],
  vala_args: ['--define=GETTEXT_PACKAGE="libdevident"', '--define=TARGET_SYSTEM_@0@'.format(target_machine.system().to_upper()), libdevident_core_flags],
  vala_gir: 'Devident-@0@.gir'.format(shortver.split('-')[0]),
  dependencies: libdevident_core_deps,
  version: shortver.split('-')[0],
  install: true,
  install_dir: [true, true, true, true])
libdevident_core = declare_dependency(link_with: libdevident_core_shlib, dependencies: libdevident_core_deps,
  compile_args: ['-I' + join_paths(meson.project_build_root(), 'core')])
pkg.generate(libdevident_core_shlib,
  name: 'devident',
  requires: ['gio-2.0', 'vadi-0.0', libdevident_core_reqs],
  description: 'A device identification library',
  url: 'https://github.com/ExpidusOS/libdevident',
  version: longver)

subdir('docs', if_found: [valadoc])

if get_option('tests')
  subdir('tests')
endif
