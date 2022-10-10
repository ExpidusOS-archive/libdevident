libdevident_xml_docs_devhelp = custom_target('xml-docs-devhelp',
  input: libdevident_xml_sources,
  depends: [libdevident_xml_shlib],
  output: 'devhelp',
  command: [valadoc, '-o', join_paths(meson.current_build_dir(), 'devhelp'),
      '--doclet', 'devhelp', '@INPUT@', '--force',
      '--pkg', 'gxml-0.20', '--pkg', 'devident',
      '--pkg', 'vadi-0.0', '--pkg', 'gio-2.0',
      libdevident_core_docs_args,
      '--vapidir', join_paths(meson.project_build_root(), 'core'),
      '--vapidir', join_paths(meson.project_build_root(), 'subprojects', 'gxml', 'gxml'),
      '--vapidir', join_paths(meson.project_build_root(), 'subprojects', 'vadi', 'lib'),
      '--vapidir', join_paths(gee.get_variable('datadir'), 'vala', 'vapi'),
      vala_defines,
      libdevident_xml_docs_args],
  build_by_default: true)

install_subdir(join_paths(meson.current_build_dir(), 'devhelp', 'libdevident-xml'), install_dir: join_paths(datadir, 'devhelp', 'books'))
