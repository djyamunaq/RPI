.global main
.extern printf

@ PARAMS
    @ r5: server socket id
    @ r6: client socket id
    @ r9: row
    @ r10: col
main:

    @ Initialize position variables
    mov r9, #0
    mov r10, #0
    
    @Print 'socket'
    mov r0, #1
    mov r1, #'i' 
    str r1, [sp]
    mov r1, #'n' 
    str r1, [sp, #1]
    mov r1, #'i' 
    str r1, [sp, #2]
    mov r1, #'s' 
    str r1, [sp, #3]
    mov r1, #'c' 
    str r1, [sp, #4]
    mov r1, #'k' 
    str r1, [sp, #5]
    mov r1, #'\n' 
    str r1, [sp, #6]
    mov r1, sp
    mov r2, #7
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall num: 281
        @ AF_INET: 2
        @ SOCK_STREAM: 1
    @ sock_id = socket(AF_INET, SOCK_STREAM, 0))
    mov r0, #2
    mov r1, #1
    mov r2, #0
    mov r7, #200
    add r7, #81
    svc #1
    
    @ save server socket id
    mov r5, r0

    @ Print socket n
    @ mov r1, r5
    @ ldr r0, =print_num
    @ bl printf

    cmp r5, #0
    bge setsocketopt
    @ mov r0, #1
    @ ldr r1, =socket_error_msg
    @ mov r2, #128
    @ mov r7, #4 
    @ svc #1
    b exit

setsocketopt:
    @Print 'sckopt'
    mov r0, #1
    mov r1, #'s' 
    str r1, [sp]
    mov r1, #'c' 
    str r1, [sp, #1]
    mov r1, #'k' 
    str r1, [sp, #2]
    mov r1, #'o' 
    str r1, [sp, #3]
    mov r1, #'p' 
    str r1, [sp, #4]
    mov r1, #'t' 
    str r1, [sp, #5]
    mov r1, #'\n' 
    str r1, [sp, #6]
    mov r1, sp
    mov r2, #7
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall num: 294
        @ socket_id: r5
        @ SOL_SOCKET: 1
        @ SO_REUSEADDR | SO_REUSEPORT: 2 | 15 
        @ opt: 1
        @ size(opt): 4
    @ setsockopt(socket_id, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))
    mov r1, #1
    mov r2, #2
    orr r2, r2, #15
    ldr r3, =opt 
    mov r4, #4
    mov r7, #200
    add r7, #94
    svc #1

bind:
    @Print 'bind'
    mov r0, #1
    mov r1, #'b' 
    str r1, [sp]
    mov r1, #'i' 
    str r1, [sp, #1]
    mov r1, #'n' 
    str r1, [sp, #2]
    mov r1, #'d' 
    str r1, [sp, #3]
    mov r1, #'\n' 
    str r1, [sp, #4]
    mov r1, sp
    mov r2, #7
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall num: 282
        @ socket_id: r5
        @ address: 0 
        @ address_len: 16 
    @ bind(socket_id, address, address_len)
    mov r0, r5
    ldr r1, =struct_addr
    mov r2, #16
    mov r7, #200
    add r7, #82
    svc #1

    @ Print bind ret
    @ mov r1, r0
    @ ldr r0, =print_num
    @ bl printf

    cmp r0, #0
    bge listen
    @ ldr r1, =bind_error_msg
    @ svc #1
    b exit

listen:
    @Print 'lstn'
    mov r0, #1
    mov r1, #'l' 
    str r1, [sp]
    mov r1, #'s' 
    str r1, [sp, #1]
    mov r1, #'t' 
    str r1, [sp, #2]
    mov r1, #'n' 
    str r1, [sp, #3]
    mov r1, #'\n' 
    str r1, [sp, #4]
    mov r1, sp
    mov r2, #7
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall num: 284
        @ socket_id: r5
    @ listen(socket_id, 2)
    mov r0, r5
    mov r1, #2
    add r7, #2
    mov r7, #200
    add r7, #84
    svc #1

    @ Print listen ret
    @ mov r1, r0
    @ ldr r0, =print_num
    @ bl printf

    cmp r0, #0
    bge accept
    @ mov r0, #1
    @ ldr r1, =listen_error_msg
    @ mov r2, #128
    @ mov r7, #4 
    @ svc #1
    b exit

accept:
    @Print 'acc'
    mov r0, #1
    mov r1, #'a' 
    str r1, [sp]
    mov r1, #'c' 
    str r1, [sp, #1]
    mov r1, #'c' 
    str r1, [sp, #2]
    mov r1, #'\n' 
    str r1, [sp, #3]
    mov r1, sp
    mov r2, #7
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall num: 285
        @ socket_id: r5
        @ address: 0
        @ addrlen: 16
    @ new_socket = accept(socket_id, address, addrlen))
    mov r0, r5
    @ ldr r1, =struct_addr
    @ mov r2, #16
    sub r1, r1, r1
    sub r2, r2, r2
    mov r7, #200
    add r7, #85
    svc #1

    @ Print accept ret
    @ mov r1, r0
    @ ldr r0, =print_num
    @ bl printf

    @ save client socket id
    mov r6, r0

    @ mov r1, r6
    @ ldr r0, =print_num
    @ bl printf

    cmp r6, #0
    bge read
    @ mov r0, #1
    @ ldr r1, =accept_error_msg
    @ mov r2, #128
    @ mov r7, #4 
    @ svc #1
    b exit

read:
    @ PARAMS
        @ socket_id: r6
        @ buffer: sp
        @ msg_len: 1
    @ msg = read(client_socket, buffer, 1024);
    mov r0, r6
    sub sp, #8
    mov r1, sp
    mov r2, #1
    mov r7, #3
    svc #1

    cmp r0, #0
    ble read

    @Print message read
    mov r0, #1
    mov r1, sp
    mov r2, #1
    mov r7, #4
    svc #1

    ldrb r1, [sp]

    @ if up
    @ Sendo confirmation back to client
    cmp r1, #'w'
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
    mov r0, r6
    mov r1, sp
    mov r2, #7
    mov r3, #0
    mov r7, #200
    add r7, #89
    svc #1
    @ Update row value
    sub r9, r9, #1 
    cmp r9, #0
    bge endif_up
    mov r9, #7 
    endif_up:
    b read

    if_down:
        @ Sendo confirmation back to client
        cmp r1, #'s'
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
        mov r0, r6
        mov r1, sp
        mov r2, #7
        mov r3, #0
        mov r7, #200
        add r7, #89
        svc #1
        @ Update row value
        add r9, r9, #1 
        cmp r9, #7
        ble endif_down
        mov r9, #0 
        endif_down:
        b read
    
    if_left:
        @ Sendo confirmation back to client
        cmp r1, #'a'
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
        mov r0, r6
        mov r1, sp
        mov r2, #7
        mov r3, #0
        mov r7, #200
        add r7, #89
        svc #1
        @ Update col value
        sub r10, r10, #2
        cmp r10, #0
        bge endif_left
        mov r10, #14
        endif_left:
        b read

    if_right:
        cmp r1, #'d'
        bne if_quit
        @ Send confirmation back
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
        mov r0, r6
        mov r1, sp
        mov r2, #7
        mov r3, #0
        mov r7, #200
        add r7, #89
        svc #1
        @ Update col value
        add r10, r10, #2
        cmp r10, #14
        ble endif_right
        mov r10, #0 
        endif_right:
        b read

    if_quit:
        cmp r1, #'q'
        beq exit

    @ Open LED file buffer 
    ldr r0, =filebuffer_led
    mov r1, #0101 @ O_WRONLY | O_CREAT
    ldr r2, =0666 @ permissions
    mov r7, #5 @ 5 is system call number for open
    svc #0
    cmp r0, #0
    blt exit

    @ Calculate position: 16*row + col
    mov r11, r9
    mov r12, #16
    mul r11, r9, r12
    add r11, r11, r10

    @write syscall
    ldr r3, =mask
    mov r1, #0xFFFF
    str r1, [r3, r11]
    mov r1, r3
    mov r2, #1024
    mov r7, #4 @ 4 is write
    svc #0
    mov r1, #0x0000
    str r1, [r3, r11]
        
    @fsync syscall
    mov r7, #118
    svc #0

    @ Close LED file buffer
    mov r7, #6 @ 6 is close
    svc #0

    b read

exit:
    @ close syscall
    mov r0, r6
    mov r7, #6 @ 6 is close
    svc #1

    @ PARAMS
        @ syscall num: 293
        @ socket_id: r5
        @ how: 2
	@ shutdown(server_fd, SHUT_RDWR);
    mov r0, r5
    mov r1, #2
    mov r7, #200
    add r7, #93
    svc #1

    @ Open LED file buffer 
    ldr r0, =filebuffer_led
    mov r1, #0101 @ O_WRONLY | O_CREAT
    ldr r2, =0666 @ permissions
    mov r7, #5 @ 5 is system call number for open
    svc #0
    cmp r0, #0
    blt exit

    @ Calculate position: 16*row + col
    mov r11, r9
    mov r12, #16
    mul r11, r9, r12
    add r11, r11, r10

    @write syscall
    ldr r1, =mask
    mov r7, #4 @ 4 is write
    svc #0
        
    @fsync syscall
    mov r7, #118
    svc #0

    @ Close LED file buffer
    mov r7, #6 @ 6 is close
    svc #0

    @ Break line in stdout
    mov r0, #1
    mov r1, #'\n'
    str r1, [sp]
    mov r1, sp
    mov r2, #1
    mov r7, #4
    svc #1

    mov r0, #0
    mov r7, #1
    svc #0

.data
struct_addr:
.ascii "\x02\x00"       // AF_INET 0xff will be NULLed 
.ascii "\x1F\x90"       // port number 8080
.byte 10,1,0,3    // IP Address
.align 4
opt: .word 1
.align 2
print_num: .asciz "%d\n"
.align 2
mask: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.align 2
filebuffer_led: .asciz "/dev/fb0"
