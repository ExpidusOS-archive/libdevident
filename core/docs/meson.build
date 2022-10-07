libdevident_core_docs_devhelp = custom_target('core-docs-devhelp',
  input: libdevident_core_sources,
  output: 'devhelp',
  command: [valadoc, '-o', join_paths(meson.current_build_dir(), 'devhelp'),
      '--doclet', 'devhelp', '@INPUT@', '--force',
      '--pkg', 'vadi-0.0', '--pkg', 'gio-2.0',
      vala_defines,
      libdevident_core_docs_args],
  build_by_default: true)

install_subdir(join_paths(meson.current_build_dir(), 'devhelp', 'libdevident'), install_dir: join_paths(datadir, 'devhelp', 'books'))
