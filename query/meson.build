conf_data_query = configuration_data()
conf_data_query.merge_from(conf_data)

build_conf_query = configure_file(input: 'src/build.vala.in', output: 'build.vala',
  configuration: conf_data_query)

query_rel_sources = ['src/main.vala']
query_sources = []

foreach src : query_rel_sources
  query_sources += [join_paths(meson.current_source_dir(), src)]
endforeach

if uncrustify.found()
  run_target('query-prettier',
    command: [uncrustify, '--no-backup', query_sources])
endif

query = executable('devident-query', build_conf_query, query_rel_sources,
  c_args: ['-DG_LOG_DOMAIN="DevidentQuery"', '-DGETTEXT_PACKAGE="libdevident"'],
  vala_args: ['--define=GETTEXT_PACKAGE="libdevident"'],
  dependencies: [libdevident_core],
  install: true)
