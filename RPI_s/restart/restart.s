.global main
.extern printf
main:
    @ restart syscall: 88
    mov r0, #0
    mov r7, #88
    svc #1

    mov r1, r0
    ldr r0, =print_num
    bl printf

exit:
    mov r0, #0
    mov r7, #1
    svc #0

.data
.align 2
print_num: .asciz "%d\n"
