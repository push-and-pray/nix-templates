#include "greeting.h"
#include <stdio.h>
#include <string.h>

// Plain exit-code test: no assert(), so it also runs in NDEBUG builds.
int main(void) {
  const char *greeting = greeting_get();

  if (greeting == NULL || strcmp(greeting, "Hello world!") != 0) {
    fprintf(stderr, "unexpected greeting: %s\n",
            greeting ? greeting : "(null)");
    return 1;
  }

  return 0;
}
