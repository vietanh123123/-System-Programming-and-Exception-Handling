


# bootup
_start: 
    la t0, exception_handler        # setting up exception handler
    csrw mtvec, t0                  # ...

    # TODO: set mepc to user_systemcalls
    la t0, user_systemcalls
    csrw mepc, t0

    mret                            # return to user mode

exception_handler:
    # TODO: save registers you need to handle the exception
    # Save registers that will be used in the handler
    addi sp, sp, -32
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw a0, 12(sp)
    sw a1, 16(sp)
    sw a7, 20(sp)
    sw ra, 24(sp)
    
    # TODO: check the cause of the exception
    csrr t0, mcause
    li t1, 8                        # Exception code for environment call from U-mode
    bne t0, t1, exception_return    # If not a system call, just return
    
    # TODO: handle the system call
    csrr t0, mepc                   # Get the address of ecall instruction
    addi t0, t0, 4                  # Increment by 4 to skip ecall on return
    csrw mepc, t0                   # Update mepc
    
    # Check system call number in a7
    lw t0, 20(sp)                   # Load a7 (system call number)
    li t1, 11
    beq t0, t1, syscall_putchar     # System call 11: print character
    li t1, 4
    beq t0, t1, syscall_putstring   # System call 4: print string
    
    j exception_return              # Unknown system call, just return

syscall_putchar:
    # System call 11: Print character in a0
    lw a0, 12(sp)                   # Load character from saved a0
    jal ra, putchar
    j exception_return

syscall_putstring:
    # System call 4: Print null-terminated string at address in a0
    lw a0, 12(sp)                   # Load string address from saved a0
    jal ra, putstring
    j exception_return


putchar:
    # Print single character in a0
    # Use symbolic addresses for terminal I/O ports
    la t0, terminal_data           # Terminal data port address
    la t1, terminal_ready          # Terminal ready port address
    
putchar_wait:
    lw t2, 0(t1)                   # Read terminal ready register
    andi t2, t2, 1                 # Check ready bit (bit 0)
    beqz t2, putchar_wait          # Wait until terminal is ready
    
    sw a0, 0(t0)                   # Write character to terminal data port
    jr ra


putstring:
    # Print null-terminated string at address in a0
    # Save registers
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw t0, 8(sp)
    
putstring_loop:
    lb t0, 0(a0)                   # Load byte from string
    beqz t0, putstring_done        # If null terminator, we're done

    # Print the character
    mv a0, t0                      # Move character to a0 for putchar
    jal ra, putchar

    lw a0, 4(sp)                   # Restore string address
    addi a0, a0, 1                 # Move to next character
    sw a0, 4(sp)                   # Save updated address
    j putstring_loop

putstring_done:
    # Restore registers
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw t0, 8(sp)
    addi sp, sp, 12
    jr ra

exception_return:
    # TODO: restore registers you saved and return to user mode
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw a0, 12(sp)
    lw a1, 16(sp)
    lw a7, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 32
    
    mret

