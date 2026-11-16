# gcd_u32_asm: binary GCD, hand-written RV32I.
#
# uint32_t gcd_u32_asm(uint32_t a, uint32_t b)   a in a0, b in a1, result in a0
#
# RV32I and Zicsr only: no mul, div, rem, no floating point, no compressed
# instructions. Tests: tests/tgcd.c.

    .text

    .globl  gcd_u32_asm
    .type   gcd_u32_asm, @function
    .align  2
gcd_u32_asm:
    addi a2, zero, 0
initial_zero_test:
    beq a0, zero, initially_a_is_zero
    beq a1, zero, initially_b_is_zero
loop_1:
    andi t0, a0, 1    # a & 1U
    andi t1, a1, 1    # b & 1U
    beq t0, t1, check_if_even
loop_1_body:
    bne t1, zero, loop_1_cond_2  # only a is even
    bne t0, zero, loop_1_cond_3  # only b is even
check_if_even:                      # a and b are both odd or both even
    bne t0, zero, loop_2            # t0 != 0  <=> t0 == t1 == 1 => they are all odd
loop_1_cond_1:
    addi a2, a2, 1
    srli a0, a0, 1
    srli a1, a1, 1
    jal zero, loop_1
loop_1_cond_2:
    srli a0, a0, 1
    jal zero, loop_1
loop_1_cond_3:
    srli a1, a1, 1
    jal zero, loop_1

loop_2:
    beq a0, a1, loop_2_same_inputs
loop_2_cond_1:
    bgeu a1, a0, loop_2_cond_2         # use 1 instruction to replace two instructions with same behavior in hot path loop(loop_2).
    sub a0, a0, a1
loop_2_cond_1_inner:
    srli a0, a0, 1
    andi t0, a0, 1
    beq t0, zero, loop_2_cond_1_inner
    jal zero, loop_2

loop_2_cond_2:
    sub a1, a1, a0
    # addi t0, a1, 0
    # jal a4, loop_2_inner_while
    # addi a1, t0, 0
    # jal zero, loop_2
loop_2_cond_2_inner:
    srli a1, a1, 1
    andi t0, a1, 1
    beq t0, zero, loop_2_cond_2_inner
    jal zero, loop_2


initially_a_is_zero:
    addi a0, a1, 0
    jal zero, gcd_u32_done
initially_b_is_zero:
    jalr zero, 0(ra)

loop_2_same_inputs:
   sll a0, a0, a2

gcd_u32_done:
    jalr zero, 0(ra)
    .size   gcd_u32_asm, .-gcd_u32_asm
