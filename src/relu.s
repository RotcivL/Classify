.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Prologue -> no prologue
    bge x0, a1, error               # 0 >= a1 -> error
    add t0, x0, x0                  # (t0) i = 0

loop_start:
    slli t1, t0, 2                  #  shift 2(i*4) to get address of elem in array
    add t1, t1, a0                     
    lw t2, 0(t1)                    # load elem i
    bge t2, x0, loop_continue       # continue if elem i > 0
    sw x0, 0(t1)                    # else set elem i = 0

loop_continue:
    addi t0, t0, 1                  # i = i + 1
    blt t0, a1, loop_start          # i < # elem

loop_end:
    # Epilogue  -> no epilogue
	ret

error:
    li a1, 8
    j exit2