#include "mylib.h"
#include <assert.h>
#include <string.h>

int main(void) {
  assert(strcmp(get_greeting(), "Hello world!") == 0);
  return 0;
}
