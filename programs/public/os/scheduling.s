# TODO: set up exception handler
# TODO: set up mepc to point to the first instruction of the startup function
# TODO: enable and set up interrupts as needed
# TODO: set up data structures for process control blocks
# TODO: execute the startup process until you get a system call


shutdown:
    j shutdown # infinite loop


exception_handler:
    # TODO: save some registers
    # TODO: identify cause of exception (ecall? which one?)
    # TODO: update time to completion for the process that caused the exception
    # TODO: schedule next process