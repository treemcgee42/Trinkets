package tracing

import "base:runtime"
import "core:fmt"
import "core:slice"
import "core:testing"
import "core:time"
import "core:os"

trace_explicit :: proc(fd: os.Handle,
                       handle: string, level: int,
                       location: runtime.Source_Code_Location,
                       format: string, args: ..any) {
    @(static) time_buf_mdy: [time.MIN_YY_DATE_LEN]u8
    @(static) time_buf_hms: [time.MIN_HMS_LEN]u8
    now := time.now()
    time.to_string_mm_dd_yy(now, time_buf_mdy[:])
    time.time_to_string_hms(now, time_buf_hms[:])

    fmt.fprintf(fd,
                "[%s %s] %s %d    %s ",
                time_buf_mdy, time_buf_hms, handle, level,
                location.procedure)
    fmt.fprintfln(fd, format, ..args)
}

TraceContext :: struct {
    fd: os.Handle,
    handle: string,
    enabled_levels: [dynamic]int,
}

init_tracing :: proc(handle: string,
                     default_enabled_levels := []int{0},
                     fd: os.Handle = os.stdout) -> TraceContext
{
    // TODO: check env vars
    enabled_levels := slice.clone_to_dynamic(default_enabled_levels)
    return TraceContext {
        fd = fd,
        handle = handle,
        enabled_levels = enabled_levels,
    }
}

deinit_tracing :: proc(tc: ^TraceContext) {
    delete(tc.enabled_levels)
}

trace_with_context :: proc(tc: ^TraceContext,
                           level: int,
                           location: runtime.Source_Code_Location,
                           format: string,
                           args: ..any) {
    emit := false
    for enabled_level in tc.enabled_levels {
        if level == enabled_level {
            emit = true
            break
        }
    }

    if emit {
        trace_explicit(tc.fd, tc.handle, level, location, format, ..args)
    }
}

t0 :: proc(tc: ^TraceContext, format: string, args: ..any,
           location := #caller_location) {
    trace_with_context(tc, 0, location, format, ..args)
}

t1 :: proc(tc: ^TraceContext, format: string, args: ..any,
           location := #caller_location) {
    trace_with_context(tc, 1, location, format, ..args)
}

// --- begin tests ------------------------------------------------------------------
// These aren't the most useful since the test runner doesn't play well with printing
// to stdout.

@(test)
test_trace_explicit :: proc(_: ^testing.T) {
    fd := os.stdout
    defer os.close(fd)
    trace_explicit(fd, "handle", 3, #location(),
                   "%s's favorite number is %d", "Susan", 2)
}

@(test)
test_trace_with_context :: proc(_: ^testing.T) {
    tc := init_tracing("TestTraceWithContext")
    defer deinit_tracing(&tc)

    t0(&tc, "Should be emitted")
    t1(&tc, "Should NOT be emitted")

    append(&tc.enabled_levels, 1)
    t1(&tc, "Should be emitted")
}

// --- end tests --------------------------------------------------------------------
