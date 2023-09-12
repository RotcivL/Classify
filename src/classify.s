.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # check for argc number of command line args being correct
    li t0, 5
    bne a0, t0, arg_error

    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)

    mv s0, a1
    mv s1, a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    # malloc for pointer to row, col
    li a0, 8                    # 8 bytes for row and col
    jal malloc
    beqz a0, malloc_error
    mv s2, a0                   # save row, col pointer to s2

    lw a0, 4(s0)                # m0 located at 1st index of argv
    mv a1, s2                   # pointer for row
    addi a2, s2, 4              # pointer for col = row pointer + 4
    jal read_matrix
    mv s3, a0                   # save m0 pointer to s3

    # Load pretrained m1
    li a0, 8                    # 8 bytes for row and col
    jal malloc
    beqz a0, malloc_error
    mv s4, a0                   # save row, col pointer to s4

    lw a0, 8(s0)                # m1 located at 2nd index of argv
    mv a1, s4                   # pointer for row
    addi a2, s4, 4              # pointer for col = row pointer + 4
    jal read_matrix
    mv s5, a0                   # save m1 pointer to s5

    # Load input matrix
    li a0, 8                    # 8 bytes for row and col
    jal malloc
    beqz a0, malloc_error
    mv s6, a0                   # save row, col pointer to s6

    lw a0, 12(s0)               # input matrix located at 3rd index of argv
    mv a1, s6                   # pointer for row
    addi a2, s6, 4              # pointer for col = row + 4
    jal read_matrix
    mv s7, a0                   # save input matrix pointer to s7


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # malloc d1 matrix for m0*input
    lw t0, 0(s2)                # number of row = m0 row
    lw t1, 4(s6)                # number of col = input col
    mul a0, t0, t1              # elements = row * col
    slli a0, a0, 2              # multiply by 4 to get bytes
    jal malloc
    beqz a0, malloc_error
    mv s8, a0                   # save pointer to d1 to s8

    # m0 * input
    mv a0, s3                   # pointer to m0
    lw a1, 0(s2)                # m0 row
    lw a2, 4(s2)                # m0 col
    mv a3, s7                   # pointer to input
    lw a4, 0(s6)                # input row
    lw a5, 4(s6)                # input col
    mv a6, s8                   # d1 matrix for the result
    jal matmul

    # ReLU (m0*input)
    mv a0, s8                   # d1 matrix with matmul result
    lw t0, 0(s2)                # m0 row
    lw t1, 4(s6)                # input col 
    mul a1, t0, t1              # multiply for number of elements
    jal relu        

    # malloc d2 for m1* ReLU(m0*input)
    lw t0, 0(s4)                # number of row = m1 row
    lw t1, 4(s6)                # number of cols = d1 col = input col
    mul a0, t0, t1              # multiply for elements
    slli a0, a0, 2              # multiply by 4 for number of bytes
    jal malloc
    beqz a0, malloc_error
    mv s9, a0                   # save pointer to d2 in s9

    # m1* ReLU(m0*input)
    mv a0, s5                   # pointer to m1
    lw a1, 0(s4)                # m1 row
    lw a2, 4(s4)                # m1 col
    mv a3, s8                   # pointer to d1
    lw a4, 0(s2)                # d1 row = m0 row
    lw a5, 4(s6)                # d1 col = input col
    mv a6, s9                   # d2 matrix for the result
    jal matmul

    # free 
    mv a0, s2                   # free memory used for row and col of m0
    jal free
    mv a0, s3                   # free memory used for m0
    jal free
    mv a0, s5                   # free memory used for m1
    jal free
    mv a0, s7                   # free memory used for input
    jal free
    mv a0, s8                   # free memory used for d1 matrix
    jal free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s0)               # output file path located at 4th index
    mv a1, s9                   # pointer to d2 matrix
    lw a2, 0(s4)                # d2 row = m1 row
    lw a3, 4(s6)                # d2 col = input col
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s9                   # pointer to d2 matrix
    lw t0, 0(s4)                # d2 row = m1 row
    lw t1, 4(s6)                # d2 col = input col
    mul a1, t0, t1              # multiply for number of elements
    jal argmax
    mv s2, a0                   # classification answer saved to s2

    # Print classification
    li t0, 0                    
    bne s1, t0, end             # check if print_classification !0 -> go to end (skip print)
    mv a1, s2                   # classification answer to print
    jal print_int

    # Print newline afterwards for clarity
    li a1 '\n'
    jal print_char

end:
    
    # free 
    mv a0, s4                   # free memory used for row and col of m1
    jal free
    mv a0, s6                   # free memory used for row and col of input
    jal free
    mv a0, s9                   # free memory used for d2 matrix
    jal free

    mv a0, s2                   # return classification
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    addi sp, sp, 44
    ret

arg_error:
    li a1, 49
    jal exit2

malloc_error:
    li a1 48
    jal exit2
