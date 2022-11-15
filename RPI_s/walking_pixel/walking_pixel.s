.global main

main:
    mov r8, #0   @ Position counter
    while:
        @ Read from Joystick
        @open syscall 
        ldr r0, =file_joystick
        mov r1, #0 @ O_RDONLY
        ldr r2, =0666 @ permissions
        mov r7, #5 @ 5 is system call number for open
        svc #0
        cmp r0, #0
        blt exit

        @read syscall
        @use stack as buffer
        sub sp, #8
        mov r1, sp
        mov r2, #16
        mov r7, #3 @ 3 is read
        svc #0

        ldr r1, [sp]
        cmp r1, #0
        beq while

        @close syscall
        mov r7, #6 @ 6 is close
        svc #0

        @ Write to LED

        @print to stdout
        mov r0, #1  

        @ Get key code
        ldr r1, [sp, #10]

        @ if up
        cmp r1, #'g'
        bne if_down
        mov r1, #'\r' 
        str r1, [sp]
        mov r1, #'u' 
        str r1, [sp, #1]
        mov r1, #'p' 
        str r1, [sp, #2]
        mov r1, #' ' 
        str r1, [sp, #3]
        mov r1, #' ' 
        str r1, [sp, #4]
        mov r1, #' ' 
        str r1, [sp, #5]
        mov r1, sp
        mov r2, #6
        mov r7, #4 @ 4 is write
        svc #0
        sub r8, r8, #16 
        cmp r8, #0
        bge endif_up
        add r8, r8, #128 
        endif_up:
        b endif_key

        if_down:
            cmp r1, #'l'
            bne if_left
            mov r1, #'\r' 
            str r1, [sp]
            mov r1, #'d' 
            str r1, [sp, #1]
            mov r1, #'o' 
            str r1, [sp, #2]
            mov r1, #'w' 
            str r1, [sp, #3]
            mov r1, #'n' 
            str r1, [sp, #4]
            mov r1, #' ' 
            str r1, [sp, #5]
            mov r1, sp
            mov r2, #6
            mov r7, #4 @ 4 is write
            svc #0
            add r8, r8, #16 
            cmp r8, #126
            ble endif_down
            sub r8, r8, #128 
            endif_down:
            b endif_key
        
        if_left:
            cmp r1, #'i'
            bne if_right
            mov r1, #'\r' 
            str r1, [sp]
            mov r1, #'l' 
            str r1, [sp, #1]
            mov r1, #'e' 
            str r1, [sp, #2]
            mov r1, #'f' 
            str r1, [sp, #3]
            mov r1, #'t' 
            str r1, [sp, #4]
            mov r1, #' ' 
            str r1, [sp, #5]
            mov r1, sp
            mov r2, #6
            mov r7, #4 @ 4 is write
            svc #0
            sub r8, r8, #2
            cmp r8, #0
            bge endif_left
            add r8, r8, #128 
            endif_left:
            b endif_key

        if_right:
            cmp r1, #'j'
            bne if_enter
            mov r1, #'\r' 
            str r1, [sp]
            mov r1, #'r' 
            str r1, [sp, #1]
            mov r1, #'i' 
            str r1, [sp, #2]
            mov r1, #'g' 
            str r1, [sp, #3]
            mov r1, #'h' 
            str r1, [sp, #4]
            mov r1, #'t' 
            str r1, [sp, #5]
            mov r1, sp
            mov r2, #6
            mov r7, #4 @ 4 is write
            svc #0
            add r8, r8, #2
            cmp r8, #126
            ble endif_right
            sub r8, r8, #128 
            endif_right:
            b endif_key

        if_enter:
            cmp r1, #28
            bne endif_key
            mov r1, #'\r' 
            str r1, [sp]
            mov r1, #'e' 
            str r1, [sp, #1]
            mov r1, #'n' 
            str r1, [sp, #2]
            mov r1, #'t' 
            str r1, [sp, #3]
            mov r1, #'e' 
            str r1, [sp, #4]
            mov r1, #'r' 
            str r1, [sp, #5]
            mov r1, sp
            mov r2, #6
            mov r7, #4 @ 4 is write
            svc #0

        endif_key:
            @ mov r1, #'\r' 
            @ str r1, [sp]
            @ mov r1, #'n' 
            @ str r1, [sp, #1]
            @ mov r1, #'o' 
            @ str r1, [sp, #2]
            @ mov r1, #'k' 
            @ str r1, [sp, #3]
            @ mov r1, #'e' 
            @ str r1, [sp, #4]
            @ mov r1, #'y' 
            @ str r1, [sp, #5]
            @ mov r1, sp
            @ mov r2, #6
            @ mov r7, #4 @ 4 is write
            @ svc #0

        @open syscall 
        ldr r0, =filebuffer_led
        mov r1, #0101 @ O_WRONLY | O_CREAT
        ldr r2, =0666 @ permissions
        mov r7, #5 @ 5 is system call number for open
        svc #0
        cmp r0, #0
        blt exit

        @r0 contains fd (file descriptor, an integer)
        mov r5, r0
        
        @write syscall
        @ use stack as buffer
        ldr r3, =mask
        mov r1, #0xFFFF
        str r1, [r3, r8]
        mov r1, r3
        mov r2, #1024
        mov r7, #4 @ 4 is write
        svc #0
        mov r1, #0x0000
        str r1, [r3, r8]
        
        @fsync syscall
        mov r0, r5
        mov r7, #118
        svc #0

        @close syscall
        mov r7, #6 @ 6 is close
        svc #0

        add sp, #8

    b   while

exit:
    mov r0, #0
    mov r7, #1
    svc #0

.data
.align 2
mask: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.align 2
filebuffer_led: .asciz "/dev/fb0"
.align 2
file_joystick: .asciz "/dev/input/event2"
