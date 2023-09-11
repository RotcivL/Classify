.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
    bge x0, a2, length_error        # 0 >= a2 -> error
    bge x0, a3, stride_error        # 0 >= a3 -> error
    bge x0, a4, stride_error        # 0 >= a4 -> error

    # Prologue -> no prologue
    add t0, x0, x0                  # i = 0
    add t1, x0, x0                  # sum = 0

    # calculate pointer stride step
    li t2, 4                        # 4 byte int
    mul t3, t2, a4                  # v1_step = 4 * v1_stride
    mul t2, t2, a3                  # v0_step = 4 * v0_stride

loop_start:
    lw t4, 0(a0)                    # load v0[0]
    lw t5, 0(a1)                    # load v1[0]
    mul t4, t4, t5                  # muliply
    add t1, t1, t4                  # sum = sum + multiply

    addi t0, t0, 1                  # i = i + 1
    add a0, a0, t2                  # move v0 pointer by v0_step 
    add a1, a1, t3                  # move v1 pointer by v1_step
    blt t0, a2, loop_start          # i < length -> loop

loop_end:
    mv a0, t1                       # set a0 = sum
    # Epilogue -> no epilogue
    ret

length_error:
    li a1, 5
    j exit2

stride_error:
    li a1, 6
    j exit2