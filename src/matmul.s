.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    bge x0, a1, m0_error        # 0 >= a1 -> error
    bge x0, a2, m0_error        # 0 >= a2 -> error
    bge x0, a4, m1_error        # 0 >= a4 -> error
    bge x0, a5, m1_error        # 0 >= a4 -> error
    bne a2, a4, dim_error

    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a5
    mv s5, a6

    li t0, 0               # i = 0

outer_loop_start:
    li t1, 0               # j = 0
    
    # get m0 row
    slli t2, t0, 2         # i * 4
    mul t2, t2, s2         # step = num_cols m0 * i * 4
    add s6, t2, s0         # s6 = m0 + step

inner_loop_start:
    # load arguments
    mv a0, s6          # m0 row
    # get m1 col
    slli t2, t1, 2
    add a1, t2, s3      # m1 col
    mv a2, s2           # number of elements
    li a3, 1            # stride m0 = 1
    mv a4, s4           # stride m1 = number of columns m1

    # prologue -> save temp registers i and j
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)

    # dot product
    jal dot

    # epilogue -> restore i and j
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8

    # set d 
    sw a0, 0(s5)
    addi s5, s5, 4      # move address to next word

    addi t1, t1, 1                  # j = j + 1
    blt t1, s4, inner_loop_start    # j < num_cols m1 -> inner_loop

inner_loop_end:
    addi t0, t0, 1                  # i = i + 1
    blt t0, s1, outer_loop_start    # i < num_rows m0 -> outer_loop

outer_loop_end:

    # Epilogue    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    
    ret

m0_error:
    li a1, 2
    j exit2

m1_error:
    li a1, 3
    j exit2

dim_error:
    li a1, 4
    j exit2