.global main

main:

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
        @if up
        
        @open syscall 
        @ ldr r0, =filebuffer_led
        mov r0, #1  @print to stdout
        @ mov r1, #0101 @ O_WRONLY | O_CREAT
        @ ldr r2, =0666 @ permissions
        @ mov r7, #5 @ 5 is system call number for open
        @ svc #0
        @ cmp r0, #0
        @ blt exit

        @r0 contains fd (file descriptor, an integer)
        @ mov r5, r0

        @write syscall
        @use stack as buffer
        ldr r1, [sp, #10]
        str r1, [sp]
        mov r1, sp
        mov r2, #2
        mov r7, #4 @ 4 is write
        svc #0

        @fsync syscall
        mov r0, r5
        mov r7, #118
        svc #0

        add sp, #8

        @close syscall
        mov r7, #6 @ 6 is close
        svc #0

    b   while

exit:
    mov r0, #0
    mov r7, #1
    svc #0

.data
.align 2
filebuffer_led: .asciz "/dev/fb0"
.align 2
file_joystick: .asciz "/dev/input/event1"
