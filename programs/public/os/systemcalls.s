# bootup
_start: 
    la t0, exception_handler        # setting up exception handler
    csrw mtvec, t0                  # ...

    # TODO: set mepc to user_systemcalls

    mret                            # return to user mode

exception_handler:
    # TODO: save registers you need to handle the exception
    # TODO: check the cause of the exception
    # TODO: handle the system call
    # TODO: restore registers you saved and return to user mode
    
    mret
