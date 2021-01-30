#pragma once

#include <glib.h>

/**
 * Device type
 */
typedef enum {
	DEVIDENT_TYPE_UNKNOWN = 0,
	DEVIDENT_TYPE_PHONE = 1,
	DEVIDENT_TYPE_DESKTOP = 2,
	DEVIDENT_TYPE_TABLET = 3,
	DEVIDENT_TYPE_WATCH = 4,
	DEVIDENT_TYPE_TV = 5,
	DEVIDENT_TYPE_IOT = 6
} devident_type_t;

typedef struct {
	devident_type_t type;
	gchar* model;
	gchar* rev;
	gchar* maker;
	gchar* screen_name;
	float screen_scale[2];
} devident_t;

devident_t* devident_new(GError** error);
void devident_destroy(devident_t* self);
