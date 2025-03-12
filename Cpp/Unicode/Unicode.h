#pragma once

namespace tm42 {

enum UnicodeResult {
    SUCCESS = 0,
    INVALID_CODEPOINT = -1
};

namespace utf8 {

// Read the UTF-8 codepoint starting at the input. This function validates that the
// codepoint is well-formed. If successful, the value of the codepoint will be stored
// in `codepointOut`, and the number of bytes the codepoint occupied in the input
// will be returned. If not successful, this returns `INVALID_CODEPOINT`.
//
// This function may read up to 4 bytes from the start of the input.
int
readCodepoint( const char * utf8Input, int * codepointOut );

} // namespace utf8

} // namespace tm42
