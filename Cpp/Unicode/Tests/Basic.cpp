#include "Unicode.h"
#include <assert.h>

int main() {
    int codepoint;
    const int size = tm42::utf8::readCodepoint( "foo", &codepoint );
    assert( size == 1 );
    assert( codepoint == 'f' );
    return 0;
}
