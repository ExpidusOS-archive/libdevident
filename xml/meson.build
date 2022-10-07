conf_data_xml = configuration_data()
conf_data_xml.merge_from(conf_data)

build_conf_xml = configure_file(input: 'lib/build.vala.in', output: 'build.vala',
 configuration: conf_data_xml)

libdevident_xml_rel_sources = ['lib/component.vala', 'lib/device.vala', 'lib/init.vala', 'lib/provider.vala',
  'lib/component/display.vala', 'lib/component/input.vala']
libdevident_xml_sources = []

foreach src : libdevident_xml_rel_sources
  libdevident_xml_sources += [join_paths(meson.current_source_dir(), src)]
endforeach

if uncrustify.found()
  run_target('xml-prettier',
    command: [uncrustify, '--no-backup', libdevident_xml_sources])
endif

libdevident_xml_sources += [build_conf_xml]
libdevident_xml_deps = [libdevident_core, gxml]
libdevident_xml_docs_args = ['--package-name=libdevident-xml', '--package-version=@0@'.format(shortver)]

libdevident_xml_shlib = shared_library('devident-xml', build_conf_xml, libdevident_xml_rel_sources,
  c_args: ['-DG_LOG_DOMAIN="DevidentXml"', '-DGETTEXT_PACKAGE="libdevident"'],
  vala_args: ['--define=GETTEXT_PACKAGE="libdevident"'],
  vala_gir: 'DevidentXml-@0@.gir'.format(shortver.split('-')[0]),
  dependencies: libdevident_xml_deps,
  version: shortver.split('-')[0],
  install: true,
  install_dir: [true, true, true, true])
libdevident_xml = declare_dependency(link_with: libdevident_xml_shlib, dependencies: libdevident_xml_deps,
  compile_args: ['-I' + join_paths(meson.project_build_root(), 'xml')])
pkg.generate(libdevident_xml_shlib,
  name: 'devident-xml',
  requires: ['devident', 'gxml'],
  description: 'XML loader for libdevident',
  url: 'https://github.com/ExpidusOS/libdevident',
  version: longver)

install_subdir(join_paths(meson.current_source_dir(), 'data', 'devident-xml'), install_dir: datadir)

subdir('docs', if_found: [valadoc])

if get_option('tests')
  subdir('tests')
endif
