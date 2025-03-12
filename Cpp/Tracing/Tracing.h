#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>

struct TraceContext {
  FILE* output_fd;
  const char* handle;
};

void
init_tracing(struct TraceContext* tc, FILE* output_fd, const char* handle);

void
deinit_tracing(struct TraceContext* tc);

void
trace_with_context(struct TraceContext* tc,
                   int level, const char* routine,
                   const char* format, ...);

#define t0(tc, format, ...) \
  do { \
    trace_with_context(tc, 0, __func__, format, ##__VA_ARGS__); \
  } while (0)

#define tassert(tc, cond, format, ...) \
  do { \
    if (!(cond)) {                                                \
      trace_with_context(tc, 0, __func__, format, ##__VA_ARGS__); \
      exit(1); \
    } \
  } while (0)

#ifdef __cplusplus
} // extern "C"
#endif
