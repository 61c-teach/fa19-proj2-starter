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
#   a0 is the pointer to string representing the filename
#   a1 is a pointer to an integer, we will set it to the number of rows
#   a2 is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 is the pointer to the matrix in memory
# ==============================================================================
read_matrix:

    # Prologue

    addi sp, sp, -16

    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)

    add s0, a0, x0        # pointer to string representing filename
    add s1, a1, x0        # pointer to number of rows
    add s2, a2, x0        # pointer to number of col

    mv a1, a0             # setting up arguments for fopen
    mv a2, x0

    jal ra fopen

    addi t0, x0, -1           # checking if fopen worked
    beq a0, t0, eof_or_error


    mv a1, a0                 # setting a1 as file_descriptor ASK TA: CAN WE ASSUME A1 or A3 WILL BE SAME AFTER CALL

    mv a2, s1                 # first call to fread to find number of rows
    add a3, x0, x0
    addi a3, a3, 4
    jal ra fread
    bne a0, a3, eof_or_error

    mv a2, s2                 # second call to fread to find number of columns
    jal ra fread
    bne a0, a3, eof_or_error

    lw t2, 0(s1)              # row int
    lw t3, 0(s2)              # col int


    mul t2, t2, t3            # getting num of bytes (row*col)
    slli t2, t2, 2            # shift logical left to get it in terms of bytes -- accounting for sizeof(int)

    mv a0, t2

    addi sp, sp, -4           # saving number of bytes prior to calling malloc
    sw t2, 0(sp)

    jal ra malloc             # returns a0 that is a pointer to allocated memory

    lw t2, 0(sp)              # restoring number of bytes after calling malloc
    addi sp, sp, 4

    mv a2, a0                 # preparing to call fread
    mv a3, t2

    jal ra fread

    bne a0, a3, eof_or_error  # error case if expected doesn't match actual

    mv a0, a2                 # returning malloc pointer

    # Epilogue

    mv a1, s1
    mv a2, s2

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    ret

eof_or_error:
    li a1 1
    jal exit2
