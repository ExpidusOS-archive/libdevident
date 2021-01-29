#include <devident/backend.h>
#include <libdevident-config.h>
#ifdef FS_IDENT
#include <stdio.h>
#include <jsmn.h>
#endif

#if defined(HARD_IDENT) || defined(FS_IDENT)
#ifdef FS_IDENT
static FILE* __devident_fp = NULL;
static jsmn_parser __devident_parser;
#endif

int __devident_backend_init() {
#ifdef FS_IDENT
	__devident_fp = fopen(SYSCONFDIR"/devident.conf", "r");
	if (__devident_fp == NULL) return 0;
#endif
	return 1;
}

int __devident_backend_fini() {
#ifdef FS_IDENT
	if (__devident_fp == NULL) return 0;
	fclose(__devident_fp);
	__devident_fp = NULL;
#endif
	return 1;
}

ssize_t __devident_backend_getprop(int key, void* data) {
#ifdef HARD_IDENT
#endif
	return 0;
}
#endif
