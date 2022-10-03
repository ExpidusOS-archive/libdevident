#include <sys/sysctl.h>
#include <stdlib.h>
#include <stdio.h>

char* devident_get_darwin_model() {
  int mib[2];
  mib[0] = CTL_HW;
  mib[1] = HW_MODEL;

  size_t len;
  if (sysctl(mib, 2, NULL, &len, NULL, 0) == -1) return NULL;

  char* name = malloc(sizeof (char) * len);
  if (name == NULL) return NULL;

  if (sysctl(mib, 2, name, &len, NULL, 0) == -1) {
    free(name);
    return NULL;
  }
  return name;
}
