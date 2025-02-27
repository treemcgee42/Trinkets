
#include <stdio.h>
#include "Tracing.h"

int
main() {
  /* trace_explicit(stdout, "Handle", 1, "main", */
  /*                "Hello %s!", "world"); */
  struct TraceContext tc;
  init_tracing(&tc, stdout, "BasicTest");

  t0(&tc, "Hello, %s!", "world");

  deinit_tracing(&tc);
  return 0;
}
