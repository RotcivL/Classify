.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # set up arguments for fopen
    mv a1, s0                   # a1 = file name
    li a2, 0                    # a2 = read only
    jal fopen
    li t0, -1                   # var to compare
    beq a0, t0, fopen_error     # check for error when opening
    mv s3, a0                   # file descriptor for fread

    # fread 1st byte for rows
    mv a1, s3                   # a1 = file descriptor
    mv a2, s1                   # a2 = pointer to row var
    li a3, 4                    # a3 = 4 bytes
    jal fread
    li t0, 4                    
    bne t0, a0, fread_error     # check for 4 bytes being read
    
    # fread 2nd byte for columns
    mv a1, s3                   # a1 = file descriptor
    mv a2, s2                   # a2 = pointer for column var
    li a3, 4                    # a3 = 4 bytes
    jal fread
    li t0, 4
    bne t0, a0, fread_error     # check for 4 bytes being read

    lw s1, 0(s1)                # load s1 = number for rows
    lw s2, 0(s2)                # load s2 = number of columns 
    
    # malloc matrix
    mul s4, s1, s2             # s4 = number of elements
    slli s4, s4, 2             # s4 = number of bytes
    mv a0, s4
    jal malloc 
    beqz a0, malloc_error
    mv s5, a0

    mv a1, s3
    mv a2, s5
    mv a3, s4
    jal fread
    bne s4, a0, fread_error     # check for 4 bytes being read

    mv a1, s3
    jal fclose
    bnez a0, fclose_error

    mv a0, s5                   # set a0 to pointer to matrix

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    ret

fopen_error:
    li a1, 50
    jal exit2

fread_error:
    li a1, 51
    jal exit2

malloc_error:
    li a1, 48
    jal exit2

fclose_error:
    li a1, 52
    jal exit2