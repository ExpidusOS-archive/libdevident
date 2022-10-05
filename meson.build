project('libdevident', 'vala', 'c', license: 'GPL-3.0-only', version: '0.2.0-prealpha')

vapi_dir = join_paths(meson.project_source_root(), 'vapi')
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

gnome = import('gnome')
i18n = import('i18n')
pkg = import('pkgconfig')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')
libexecdir = prefix / get_option('libexecdir')
localstatedir = get_option('localstatedir')

longver = '@0@'.format(meson.project_version())
shortver = longver
git = find_program('git', native: true, required: false)
conf_data = configuration_data()
i18n_args = ['--package-version=@0@'.format(longver), '--copyright-holder=Midstall Software']

if git.found()
	git_commit = run_command([git, 'rev-parse', '--short', 'HEAD'])
	git_branch = run_command([git, 'rev-parse', '--abbrev-ref', 'HEAD'])
  git_config_username = run_command([git, 'config', '--get', 'user.name'])

  if git_commit.returncode() == 0 and git_branch.returncode() == 0
    shortver = '@0@-@1@'.format(meson.project_version(), git_commit.stdout().strip())
    longver = '@0@ (branch \'@1@\')'.format(shortver, git_branch.stdout().strip())
  endif

  if git_config_username.returncode() == 0
    git_username = git_config_username.stdout().strip()
    conf_data.set('BUILD_USER', git_username)
  endif
endif

uncrustify = find_program('uncrustify', native: true, required: false)
valadoc = find_program('valadoc', required: get_option('docs'), native: true)

libpeas = dependency('libpeas-1.0', required: false)
gmodule = dependency('gmodule-2.0', required: false)
vadi = dependency('vadi-0.0', required: true)
gio = dependency('gio-2.0', required: true)

gxml = dependency('gxml-0.20', fallback: ['gxml', 'libgxml_dep'], required: false)

conf_data.set('PREFIX', prefix)
conf_data.set('BINDIR', bindir)
conf_data.set('DATADIR', datadir)
conf_data.set('LIBDIR', libdir)
conf_data.set('LIBEXECDIR', libexecdir)
conf_data.set('VERSION', longver)
conf_data.set('TARGET_SYSTEM', target_machine.system())
conf_data.set('LOCALDIR', join_paths(datadir, 'locale'))
conf_data.set('BUILDDIR', meson.current_build_dir())
conf_data.set('SOURCEDIR', meson.current_source_dir())

vala_defines = []

if libpeas.found()
  vala_defines += ['--define=HAS_LIBPEAS']
endif

if gmodule.found()
  vala_defines += ['--define=HAS_GMODULE']
endif

add_project_arguments(vala_defines, language: 'vala')

subdir('po')
subdir('core')

subdir('xml', if_found: [gxml])
