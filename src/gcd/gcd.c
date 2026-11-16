#include "gcd.h"

/* Dummy: returns 0 for every input. Replace with the binary GCD. */
uint32_t gcd_u32(uint32_t a, uint32_t b)
{
    uint32_t shift = 0;
    if (a == 0) {
        return b;
    }
    if (b == 0) {
        return a;
    }
    while (!(a & 1U) || !(b & 1U)) {   // either a or b is even.
        if (!(a & 1U) && !(b & 1U)) {  // both of them are even
            ++shift;
            a >>= 1;
            b >>= 1;
        } else if (!(a & 1U)) {  // only one of them is even
            a >>= 1;
        } else if (!(b & 1U)) {
            b >>= 1;
        }
    }
    while (1) {  // version 1 condition: (a && b) <==> if both a and b are not
                 // 0. BUT a and b will not be zero 'cause even if we subtract
                 // the larger one with the smaller one, but if they are the
                 // same, we simply just return the shifted value.
        if (a == b) {
            return (a << shift);
        } else if (a > b) {
            a -= b;  // and odd - odd = even ==> can factor a 2 value from
                     // subtracted number
            while (!(a & 1U)) {  // factor out 2's from subtracted number a
                                 // until it's odd
                a >>= 1;
            }
        } else {
            b -= a;
            while (!(b & 1U)) {
                b >>= 1;
            }
        }
    }
}
