#include "mylib.h"
#include <stdio.h>

int main(void) {
  const char *greeting = get_greeting();
  printf("%s\n", greeting);
  return 0;
}
