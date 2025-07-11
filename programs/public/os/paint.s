# bootup
_start:
    li t2, 15           # x coordinate
    li t3, 15           # y coordinate
    li t4, 0x00ffffff   # current color (white)
    li s0, 0            # previous x coordinate
    li s1, 0            # previous y coordinate
    li s2, 0x00000000   # previous pixel color (black)

main_loop:
    # Restore previous cursor position only if we moved
    bne t2, s0, restore_previous
    bne t3, s1, restore_previous
    j update_display

restore_previous:
    # Calculate previous pixel address: display + 4*prev_x + 128*prev_y
    la t0, display
    slli t5, s0, 2        # t5 = 4*prev_x
    slli t6, s1, 7        # t6 = 128*prev_y
    add t0, t0, t5        # t0 = display + 4*prev_x
    add t0, t0, t6        # t0 = display + 4*prev_x + 128*prev_y
    sw s2, 0(t0)          # Restore previous pixel color

update_display:
    # Save current pixel color before overwriting with cursor
    la t0, display
    slli t5, t2, 2        # t5 = 4*x
    slli t6, t3, 7        # t6 = 128*y
    add t0, t0, t5        # t0 = display + 4*x
    add t0, t0, t6        # t0 = display + 4*x + 128*y
    lw s2, 0(t0)          # Save current pixel color
    
    # Show cursor at current position
    sw t4, 0(t0)          # Write cursor color to display
    
    # Update previous position
    mv s0, t2
    mv s1, t3
    
    # Wait for keyboard input
loop_wait:
    la t0, keyboard_ready
    lw t0, 0(t0)
    andi t0, t0, 1
    beqz t0, loop_wait
    
    la t5, keyboard_data
    lb t1, 0(t5)         # t1 = ASCII code
    
    # Handle movement
    li t0, 0x77          # 'w'
    beq t1, t0, move_up
    li t0, 0x61          # 'a'
    beq t1, t0, move_left
    li t0, 0x73          # 's'
    beq t1, t0, move_down
    li t0, 0x64          # 'd'
    beq t1, t0, move_right
    
    # Handle color change
    li t0, 0x72          # 'r'
    beq t1, t0, toggle_red
    li t0, 0x67          # 'g'
    beq t1, t0, toggle_green
    li t0, 0x62          # 'b'
    beq t1, t0, toggle_blue
    
    # Handle paint
    li t0, 0x20          # spacebar
    beq t1, t0, paint_pixel
    
    j main_loop          # Ignore other keys

move_up:
    beqz t3, main_loop   # If y == 0, stay
    addi t3, t3, -1
    j main_loop

move_left:
    beqz t2, main_loop   # If x == 0, stay
    addi t2, t2, -1
    j main_loop

move_down:
    li t0, 31
    bge t3, t0, main_loop # If y == 31, stay
    addi t3, t3, 1
    j main_loop

move_right:
    li t0, 31
    bge t2, t0, main_loop # If x == 31, stay
    addi t2, t2, 1
    j main_loop

toggle_red:
    li t0, 0x00ff0000
    xor t4, t4, t0       # Flip red bits
    j main_loop

toggle_green:
    li t0, 0x0000ff00
    xor t4, t4, t0       # Flip green bits
    j main_loop

toggle_blue:
    li t0, 0x000000ff
    xor t4, t4, t0       # Flip blue bits
    j main_loop

paint_pixel:
    # The pixel is already painted since we don't restore it
    # Just update the saved color so it stays painted
    mv s2, t4            # Save current color as the painted color
    j main_loop