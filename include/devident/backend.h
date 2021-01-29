#pragma once

#include <stdlib.h>

/* Common */
#define DEVIDENT_KEY_NAME 0
#define DEVIDENT_KEY_REV 1
#define DEVIDENT_KEY_MANUFACTURER 2
#define DEVIDENT_KEY_TYPE 3

/* Phone */
#define DEVIDENT_KEY_PATH_LED 4
#define DEVIDENT_KEY_PATH_FRONT_CAM 5
#define DEVIDENT_KEY_PATH_REAR_CAM 6
#define DEVIDENT_KEY_SCREEN_NAME 7

int __devident_backend_init();
int __devident_backend_fini();
ssize_t __devident_backend_getprop(int key, void* data);
