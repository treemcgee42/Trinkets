Trinkets 0.1
************

This is a manual for the Trinkets library collection, version 0.1.

About
=====

Trinkets was born when I realized that I was writing the same sort of
library for multiple languages.  For example, I like to have tracing
facilities in nearly all of my programs.  Instead of scattering these
utility libraries across multiple repositories, I decided to collect
them in a single place: here.

   A nice side goal is to maintain a unified-ish API. That will allow
Trinket library code to be understood regardless of what language it
appears in.

1 Test
******

Unit testing frameworks.

1.1 C/C++
=========

Philosophy
==========

Simple and unsurprising are the primary design objectives.  This has
limited the feature scope.  Many robust C++ testing libraries exist
which provide rich features, such as Google test, catch2, and doctest.

   The following decisions demonstrate our design objectives:

   • _No execution framework._  There isn't a standard way to compile
     the tests into an executable and run them.  It is up to the user to
     define this abstraction for themselves.

   • _No automatic test function generation or registration._  Any user
     defined function can be a test.  To run the test, the user must
     call it manually.

Example
=======

     void testFoo( struct Tm42_TestContext * ctx ) {
         TM42_BEGIN_TEST( "a test about foo" );

         TM42_TEST_ASSERT( ctx, 1 + 1 == 2 );

         TM42_END_TEST();
     }

Integration
-----------

Here are some suggestions for integrating this into your codebase:

   • You can define tests next to the code it tests.

   • You can guard the inclusion of the test header and compilation of
     the test functions behind a compilation flag (e.g.  behind an
     ‘#ifdef COMPILE_TESTS’).

   • Taking the above a step further, if you are developing an
     executable you can define a "test main" function which is compiled
     when the compile flag is defined instead of the usual main
     function.

API
===

 -- Macro: TM42_BEGIN_TEST description
     Call this at the very beginning of the test function.  The
     expansion will print the test function and description when
     starting the test.

 -- Macro: TM42_END_TEST
     Call this at the end of the test, right before any teardown logic.
     A failed test assertion will jump to this point, so teardown logic
     can be included after this call, and will run whether the test
     passes or fails.

 -- Macro: TM42_TEST_ASSERT ctx cond
     If ‘cond’ is true, continue on.  Otherwise, mark the failure in the
     test context ‘ctx’ and jump to the failure handler generated via
     the ‘TM42_END_TEST’ macro.

2 Tracing
*********

Traces print formatted messages.  The idea is that they should remain in
the code, but have their behavior controllable via something like an
environment variable.  That way, you can control which traces are
emitted.

   To support this, we have two key concepts:
   • _Handle_.  This is a string which should be used to group together
     related traces.  You could have a handle per file, share a handle
     across multiple related files, or even have multiple handles in a
     single file.  When a handle is disabled, no traces associated with
     that handle will be emitted.

   • _Level_.  This is a number, 0-9, associated with each trace.  It
     provides even finer control than handles over which traces are
     emitted.  For a trace to be emitted, both its handle and level must
     be emitted.  For example, a user could trace frequently-called code
     at level 9 and less frequently-called code at level 0.

2.1 C/C++
=========

TODO

2.2 Odin
========

TODO

