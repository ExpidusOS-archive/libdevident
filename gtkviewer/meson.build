conf_data_gtkviewer = configuration_data()
conf_data_gtkviewer.merge_from(conf_data)

build_conf_gtkviewer = configure_file(input: 'src/build.vala.in', output: 'build.vala',
  configuration: conf_data_gtkviewer)
gtkviewer_res = gnome.compile_resources('gtkviewer', 'data/gtkviewer.gresource.xml',
  source_dir: join_paths(meson.current_source_dir(), 'data'),
  c_name: 'devident_gtk_viewer')

gtkviewer_desktop = i18n.merge_file(
  input: 'data/gtkviewer.desktop.in',
  output: 'devident-gtkviewer.desktop',
  type: 'desktop',
  po_dir: join_paths(meson.project_source_root(), 'po'),
  install: true,
  install_dir: join_paths(datadir, 'applications'))

gtkviewer_rel_sources = ['src/application.vala', 'src/window.vala']
gtkviewer_sources = []

foreach src : gtkviewer_rel_sources
  gtkviewer_sources += [join_paths(meson.current_source_dir(), src)]
endforeach

if uncrustify.found()
  run_target('gtkviewer-prettier',
    command: [uncrustify, '--no-backup', gtkviewer_sources])
endif

gtkviewer = executable('devident-gtkviewer', build_conf_gtkviewer, gtkviewer_res, gtkviewer_rel_sources,
  c_args: ['-DG_LOG_DOMAIN="DevidentGtkViewer"', '-DGETTEXT_PACKAGE="libdevident"'],
  vala_args: ['--define=GETTEXT_PACKAGE="libdevident"'],
  dependencies: [libdevident_core, libtokyo_gtk4],
  install: true)
