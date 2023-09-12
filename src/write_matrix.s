.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open file
    mv a1, a0
    li a2, 1
    jal fopen
    li t0, -1                   # var to compare
    beq a0, t0, fopen_error     # check for error when opening
    mv s4, a0                   # file descriptor for fread

    # write row
    mv a1, s4                   # file descriptor
    addi sp, sp, -8             # use stack to store row and col
    sw s2, 0(sp)                   
    sw s3, 4(sp)
    mv a2, sp                   # pointer to stack with row and col values at top
    li a3, 2                    # write 2 elements, row and col
    li a4, 4                    # 4 bytes per element
    jal fwrite
    addi sp, sp, 8              # remove row and col from stack
    li t0, 2                   
    bne t0, a0, fwrite_error    # check for 2 elements being written

    # write matrix
    mv a1, s4                   # file descriptor
    mv a2, s1                   # pointer to start of matrix
    mul a3, s2, s3              # multiply row and col for number of elements
    li a4, 4                    # 4 bytes per element
    jal fwrite
    mul t0, s2, s3              
    bne t0, a0, fwrite_error    # check for row*col number of elements written
    
    # Close
    mv a1, s4
    jal fclose
    bnez a0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24

    ret

fopen_error:
    li a1, 53
    jal exit2

fwrite_error:
    li a1, 54
    jal exit2

fclose_error:
    li a1, 55
    jal exit2