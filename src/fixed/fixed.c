#include "fixed.h"
uint32_t clz(uint32_t a);

/* Dummies: every function returns 0. Replace with the real routines. */
uint32_t op1(uint32_t a, uint32_t b, int *n)
{
    *n = 0;
    while (b != 0) {
        uint32_t c = (a & b) << 1;
        a = a ^ b;
        b = c;
        ++(*n);
    }
    return a;
}

uint32_t op2(uint32_t a, uint32_t b)
{
    return (uint32_t) (a - b);
}

// let a = 2*q_a + r_a , b = 2*q_b + r_b, which r_a and r_b are either 0 or 1.
// floor((a + b) / 2) = q_a + q_b + (r_a + r_b)/2, which has the same result as
// doing a+b first, which will cause immediate overflow. (r_a + r_b) / 2 == 1
// only when both r_a and r_b are 1 , so we can use bitwise and to get it's
// value without adding then right shifting.
uint32_t op3(uint32_t a, uint32_t b)
{
    uint32_t a_lsb = a & 1U;
    uint32_t b_lsb = b & 1U;
    uint32_t a_half = a >> 1;
    uint32_t b_half = b >> 1;
    return a_half + b_half + (a_lsb & b_lsb);
}

int32_t q_mul(int32_t a, int32_t b)
{
    uint32_t mag_a = a;
    uint32_t mag_b = b;
    uint32_t negativeness = 0;
    if (a <
        0) {  // if a(signed number) is int32_min which is - 2^31 , and if we
              // negate it (-a) directly then the output would be overflow
              // because int32_max = 2^31 - 1 cannot accomondate 2^31.
        mag_a = 0U - (uint32_t) a;
        negativeness = 1;
    }
    if (b < 0) {
        mag_b = 0U - (uint32_t) b;
        negativeness ^= 1U;
    }
    uint32_t result_hi = 0;
    uint32_t result_lo = 0;
    uint32_t ext_multiplicand_hi = 0;
    uint32_t ext_multiplicand_lo = mag_a;
    // uint32_t carry = 0;
    while (mag_b) {
        if ((mag_b & 1U)) {
            uint32_t overflow_det = result_lo;
            result_lo += ext_multiplicand_lo;
            // carry = (result_lo >> 31) ^ (ext_multiplicand_lo >> 31);
            if (result_lo < overflow_det) {
                result_hi += (ext_multiplicand_hi + 1U);
            } else {
                result_hi += ext_multiplicand_hi;
            }
        }
        ext_multiplicand_hi <<= 1;
        ext_multiplicand_hi |= (ext_multiplicand_lo >> 31);
        ext_multiplicand_lo <<= 1;
        mag_b >>= 1;
    }
    if (negativeness) {
        uint32_t carry = (result_lo == 0U);
        result_lo = ~result_lo + 1U;
        result_hi = ~result_hi + carry;
    }
    // rounding: when overflow occurs, result_lo + 0x00080000 >=
    // 2^32(uint32_max) which is equivalent to result_lo >= 2^32 - 0x00080000 =
    // 0xFFF80000
    uint32_t carry = (result_lo >= 0xFFF80000);
    result_lo += 0x00080000;
    result_hi += carry;
    result_lo = ((result_lo >> 20) | (result_hi << 12));
    return result_lo;
}
