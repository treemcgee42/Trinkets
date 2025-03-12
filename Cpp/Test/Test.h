#pragma once

#include <stdio.h>

struct Tm42_TestContext {
  int failures;
};

#define TM42_BEGIN_TEST( description ) \
  printf( "TEST_STARTED: %s\nTEST DESCRIPTION: %s\n", __func__, description )

#define TM42_END_TEST()                         \
  do {                                          \
  tm42_test_pass__:                             \
    printf( "TEST PASSED: %s\n", __func__ );    \
    goto tm42_test_teardown__;                  \
  tm42_test_fail__:                             \
    printf( "TEST FAILED: %s\n", __func__ );    \
    goto tm42_test_teardown__;                  \
  tm42_test_teardown__:                         \
    ;                                           \
  } while ( 0 )

#define TM42_TEST_ASSERT( ctx, cond )                           \
  do {                                                          \
    if ( !( cond ) ) {                                          \
      printf( "%s:%d: error in %s: assertion failed!\n",        \
              __FILE__, __LINE__, __func__ );                   \
      ctx->failures += 1;                                       \
      goto tm42_test_fail__;                                    \
    }                                                           \
  } while ( 0 )
