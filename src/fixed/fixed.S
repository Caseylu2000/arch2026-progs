# op1, op2, op3 and q_mul: hand-written RV32I.
#
# uint32_t op1_asm(uint32_t a, uint32_t b, int *n)   a0, a1, a2 -> a0
# uint32_t op2_asm(uint32_t a, uint32_t b)           a0, a1 -> a0
# uint32_t op3_asm(uint32_t a, uint32_t b)           a0, a1 -> a0
# int32_t  q_mul_asm(int32_t a, int32_t b)           a0, a1 -> a0
#
# RV32I and Zicsr only: no mul, div, rem, no floating point, no compressed
# instructions. q_mul forms a 64-bit product in a register pair. Tests:
# tests/tfixed.c.

    .text

    .globl  op1_asm
    .type   op1_asm, @function
    .align  2
op1_asm:
    addi t1, zero, 0
op1_loop:
    beq a1, zero, op1_done
    and t0, a0, a1
    xor a0, a0, a1
    slli a1, t0, 1
    addi t1, t1, 1
    jal zero, op1_loop
op1_done:
    sw t1, 0(a2)
    jalr zero, 0(ra)
    .size   op1_asm, .-op1_asm



    .globl  op2_asm
    .type   op2_asm, @function
    .align  2
op2_asm:
    sub a0, a0, a1
    jalr zero, 0(ra)
    .size   op2_asm, .-op2_asm

    .globl  op3_asm
    .type   op3_asm, @function
    .align  2
op3_asm:
    andi t0, a0, 1
    andi t1, a1, 1
    srli a0, a0, 1
    srli a1, a1, 1
    and t0, t0, t1
    add a0, a0, a1
    add a0, a0, t0
    jalr zero, 0(ra)
    .size   op3_asm, .-op3_asm

    .globl  q_mul_asm
    .type   q_mul_asm, @function
    .align  2
q_mul_asm:
    addi a2, zero, 0
check_sign_a:
    bge a0, zero, check_sign_b
    sub a0, zero, a0
    addi a2, zero, 1              # a2: negativeness
check_sign_b:
    bge a1, zero, initial_64_bits
    sub a1, zero, a1
    xori a2, a2, 1
initial_64_bits:
    addi a3, zero, 0               # ext_multiplicand_hi
    addi a4, a0, 0                 # ext_multiplicand_lo
    addi a5, zero, 0               # result_hi
    addi a6, zero, 0               # result_lo
op4_loop:
    andi t0, a1, 1
    bgeu zero, t0, next_state
    add  a6, a6, a4
    sltu t0, a6, a4
    add  a5, a5, a3
    add  a5, a5, t0
next_state:
    srli t1, a4, 31
    slli a3, a3, 1
    or a3, a3, t1
    slli a4, a4, 1
    srli a1, a1, 1
    bne a1, zero, op4_loop
op4_loop_done:
    beq a2, zero, rounding
    xori a6, a6, 0xFFFFFFFF
    addi a6, a6, 1
    xori a5, a5, 0xFFFFFFFF
    bne a6, zero, rounding
    addi a5, a5, 1
rounding:
    addi t0, a6, 0
    lui t1, 0x00080
    add a6, a6, t1
    bltu t0, a6, op4_done
    addi a5, a5, 1
op4_done:
    slli a5, a5, 12
    srli a6, a6, 20
    or a0, a5, a6
    jalr zero, 0(ra)
    .size   q_mul_asm, .-q_mul_asm
