#include <cstdint>

#include "Unicode.h"

static char ERROR_MSG[ 1024 ];

namespace tm42 {

namespace utf8 {

static int
codepointSize( uint8_t firstByteOfCodepoint ) {
    if ( ( firstByteOfCodepoint & 0b1000'0000 ) == 0 ) {
        return 1;
    }
    if ( ( firstByteOfCodepoint & 0b1110'0000 ) == 0b1100'0000 ) {
        return 2;
    }
    if ( ( firstByteOfCodepoint & 0b1111'0000 ) == 0b1110'0000 ) {
        return 3;
    }
    if ( ( firstByteOfCodepoint & 0b1111'1000 ) == 0b1111'0000 ) {
        return 4;
    }
    return INVALID_CODEPOINT;
}

int
readCodepoint( const char * utf8Input, int * codepointOut ) {
    const uint8_t *input = reinterpret_cast< const uint8_t * >( utf8Input );

    const int size = codepointSize( *input );
    switch ( size ) {
    case 1:
        if ( !( input[ 0 ] >= 0x00 && input[ 0 ] <= 0x7F ) ) {
            return INVALID_CODEPOINT;
        }
        *codepointOut = input[ 0 ];
        break;
    case 2:
        if ( !( ( input[ 0 ] >= 0xC2 && input[ 0 ] <= 0xDF ) &&
                ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        }
        *codepointOut = input[ 0 ] | ( input[ 1 ] << 8 );
        break;
    case 3:
        if ( ( input[ 0 ] == 0xE0 ) &&
             !( ( input[ 1 ] >= 0xA0 && input[ 1 ] <= 0xBF ) &&
                ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else if ( ( input[ 0 ] >= 0xE1 && input[ 0 ] <= 0xEC ) &&
                    !( ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0xBF ) &&
                       ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else if ( ( input[ 0 ] == 0xED ) &&
                    !( ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0x9F ) &&
                       ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else if ( ( input[ 0 ] >= 0xEE && input[ 0 ] <= 0xEF ) &&
                    !( ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0xBF ) &&
                       ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else {
            return INVALID_CODEPOINT;
        }
        *codepointOut = ( input[ 0 ] |
                          ( input[ 1 ] << 8 ) |
                          ( input[ 2 ] << 16 ) );
        break;
    case 4:
        if ( ( input[ 0 ] == 0xF0 ) &&
             !( ( input[ 1 ] >= 0x90 && input[ 1 ] <= 0xBF ) &&
                ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) &&
                ( input[ 3 ] >= 0x80 && input[ 3 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else if ( ( input[ 0 ] >= 0xF1 && input[ 0 ] <= 0xF3 ) &&
                    !( ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0xBF ) &&
                       ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) &&
                       ( input[ 3 ] >= 0x80 && input[ 3 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else if ( ( input[ 0 ] == 0xF4 ) &&
                    !( ( input[ 1 ] >= 0x80 && input[ 1 ] <= 0x8F ) &&
                       ( input[ 2 ] >= 0x80 && input[ 2 ] <= 0xBF ) &&
                       ( input[ 3 ] >= 0x80 && input[ 3 ] <= 0xBF ) ) ) {
            return INVALID_CODEPOINT;
        } else {
            return INVALID_CODEPOINT;
        }
        *codepointOut = ( input[ 0 ] |
                          ( input[ 1 ] << 8 ) |
                          ( input[ 2 ] << 16 ) |
                          ( input[ 2 ] << 24 ) );
        break;
    default:
        return INVALID_CODEPOINT;
    };

    return size;
}

} // namespace utf8

} // namespace tm42
