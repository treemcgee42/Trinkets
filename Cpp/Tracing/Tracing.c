
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <time.h>
#include "Tracing.h"

static void
trace_explicit(FILE* output_fd,
               const char* handle, int level, const char* routine,
               const char* format, va_list args) {
  static char time_buf[20];
  time_t now = time(NULL);
  struct tm *tm_info = localtime(&now);
  // Could check if the above is non-NULL, but we don't really want to fail
  // the program or not emit anything at all.
  strftime(time_buf, sizeof(time_buf), "%Y-%m-%d %H:%M:%S", tm_info);

  fprintf(output_fd, "[%s] %s %d    %s ",
          time_buf, handle, level, routine);
  vfprintf(output_fd, format, args);
  fprintf(output_fd, "\n");
}


void
init_tracing(struct TraceContext* tc, FILE* output_fd, const char* handle) {
  tc->output_fd = output_fd;
  tc->handle = handle;
  // init_filter();
}

void
deinit_tracing(struct TraceContext* tc) {
  // deinit_filter();
}

static bool
should_trace(struct TraceContext* tc, int level) {
  return true;
}

void
trace_with_context(struct TraceContext* tc,
                   int level, const char* routine,
                   const char* format, ...) {
  if (should_trace(tc, level)) {
      va_list args;
      va_start(args, format);
      trace_explicit(tc->output_fd, tc->handle, level, routine, format, args);
      va_end(args);
  }
}

