project('devident', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

library('devident', 'src/devident.c',
	install: true,
	dependencies: [dependency('glib-2.0')],
	include_directories: [include_directories('include')])
install_headers('include/devident.h')
