package tracing

import "base:runtime"
import "core:fmt"
import "core:slice"
import "core:testing"
import "core:time"
import "core:os"
import "core:strconv"
import "core:strings"

FILTER_ACTIVE := false
FILTER: TraceFilter

parse_trace_env_var :: proc(
    value: string
) -> (handleToLevels: map[string][dynamic]int) {
    handleToLevels = make(map[string][dynamic]int)
    if (len(value) == 0) {
        return
    }

    components := strings.split(value, ",")
    defer delete(components)
    for component in components {
        sp := strings.split(component, "/")
        defer delete(sp)
        assert(len(sp) == 2)
        handle := sp[0]
        levels := make([dynamic]int)
        handleToLevels[handle] = levels

        sp_levels := strings.split(sp[1], "")
        defer delete(sp_levels)
        for level_st in sp_levels {
            level, ok := strconv.parse_int(level_st)
            assert(ok)
            append(&handleToLevels[handle], level)
        }
    }

    return
}

TraceFilter :: struct {
    handleToLevels: map[string][dynamic]int,
}

init_filter :: proc() {
    if FILTER_ACTIVE {
        return
    }
    trace_env_var := os.get_env("TRACE")
    defer delete(trace_env_var)
    handleToLevels := parse_trace_env_var(trace_env_var)
    FILTER = TraceFilter {
        handleToLevels = handleToLevels,
    }
    FILTER_ACTIVE = true
}

deinit_filter :: proc() {
    if !FILTER_ACTIVE {
        return
    }
    for key, value in FILTER.handleToLevels {
        delete(value)
        delete_key(&FILTER.handleToLevels, key)
    }
    delete(FILTER.handleToLevels)
    FILTER_ACTIVE = false
}

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
}

init_tracing :: proc(handle: string,
                     fd: os.Handle = os.stdout) -> TraceContext
{
    init_filter()
    return TraceContext {
        fd = fd,
        handle = handle,
    }
}

deinit_tracing :: proc(tc: ^TraceContext) {
    deinit_filter()
}

should_trace :: proc(ctx: ^TraceContext, level: int) -> bool {
    enabledLevels, ok := FILTER.handleToLevels[ctx.handle]
    if !ok {
        return false
    }

    for enabledLevel in enabledLevels {
        if level == enabledLevel {
            return true
        }
    }
    return false
}

trace_with_context :: proc(tc: ^TraceContext,
                           level: int,
                           location: runtime.Source_Code_Location,
                           format: string,
                           args: ..any) {
    if should_trace(tc, level) {
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

tassert :: proc(tc: ^TraceContext, val: bool, format: string, args: ..any,
                location := #caller_location) {
    if !val {
        trace_explicit(tc.fd, tc.handle, 0, location, format, ..args)
        assert(false, loc=location)
    }
}

// --- begin tests ------------------------------------------------------------------

@(test)
test_parse_trace_env_var :: proc(_: ^testing.T) {
    handleToLevels := parse_trace_env_var("Foo/12,Bar/0,Baz/928")
    defer {
        for key, value in handleToLevels {
            delete(value)
            delete_key(&handleToLevels, key)
        }
        delete(handleToLevels)
    }

    assert(len(handleToLevels) == 3)

    assert("Baz" in handleToLevels)

    assert("Foo" in handleToLevels)
    assert(len(handleToLevels["Foo"]) == 2)
    assert(handleToLevels["Foo"][0] == 1)
    assert(handleToLevels["Foo"][1] == 2)

    assert("Bar" in handleToLevels)
    assert(len(handleToLevels["Bar"]) == 1)
    assert(handleToLevels["Bar"][0] == 0)

    assert("Baz" in handleToLevels)
    assert(len(handleToLevels["Baz"]) == 3)
    assert(handleToLevels["Baz"][0] == 9)
    assert(handleToLevels["Baz"][1] == 2)
    assert(handleToLevels["Baz"][2] == 8)
}

// --- end tests --------------------------------------------------------------------
