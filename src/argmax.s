.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:

    # Prologue -> no prologue
    bge x0, a1, error               # 0 >= a1 -> error
    add t0, x0, x0                  # (t0) i = 0
    lw  t1, 0(a0)                   # max = a[0]
    add t2, x0, x0                  # max_ind = 0
    j loop_continue                 

loop_start:
    slli t3, t0, 2                  #  shift 2 (i*4) to get address of elem in array
    add t3, t3, a0                  
    lw t4, 0(t3)                    # load elem i
    bge t1, t4, loop_continue       # continue if max >= elem i
    mv t1, t4                       # else set max = elem i
    mv t2, t0                       # set max_ind = i

loop_continue:
    addi t0, t0, 1                  # i = i + 1
    blt t0, a1, loop_start          # i < # elem

loop_end:
    # Epilogue -> no epilogue
    mv a0, t2                       # set return value to max_ind
    ret

error:
    li a1, 7
    j exit2