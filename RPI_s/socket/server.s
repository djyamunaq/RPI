.global main
.extern printf
@ PARAMS
    @ r5: server socket id
    @ r6: client socket id
main:
    @ .ARM
    @ add r3, pc, #1
    @ bx  r3

    @ .THUMB
    
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

    cmp r5, #0
    bge setsocketopt
    mov r0, #1
    ldr r1, =socket_error_msg
    mov r2, #128
    mov r7, #4 
    svc #1
    b exit

setsocketopt:
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

    cmp r0, #0
    bge listen
    ldr r1, =bind_error_msg
    svc #1
    b exit

listen:
    @ PARAMS
        @ syscall num: 284
        @ socket_id: r5
    @ listen(socket_id, 2)
    mov r0, r5
    mov r1, #2
    add r7, #2
    svc #1

    cmp r0, #0
    bge accept
    mov r0, #1
    ldr r1, =listen_error_msg
    mov r2, #128
    mov r7, #4 
    svc #1
    b exit

accept:
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
    add r7, #1
    svc #1

    @ save client socket id
    mov r6, r0

    @ mov r1, r6
    @ ldr r0, =print_num
    @ bl printf

    cmp r6, #0
    bge read
    mov r0, #1
    ldr r1, =accept_error_msg
    mov r2, #128
    mov r7, #4 
    svc #1
    b exit

read:
    @ PARAMS
        @ socket_id: r6
        @ buffer: sp
        @ msg_len: 1024
    @ msg = read(client_socket, buffer, 1024);
    mov r0, r6
    sub sp, #8
    mov r1, sp
    mov r2, #20
    mov r7, #3
    svc #1

    @ Print message read
    mov r0, #1
    mov r1, sp
    mov r2, #20
    mov r7, #4
    svc #1

    @ PARAMS
        @ syscall: 289
        @ client_socket: r6
        @ msg: server_msg
	@ send(client_socket, msg, strlen(hello), 0);
    mov r0, r6
    ldr r1, =server_msg
    mov r2, #20
    mov r3, #0
    mov r7, #200
    add r7, #89
    svc #1

    @ Print message was sent
    mov r0, #1
    ldr r1, =hello_msg 
    mov r7, #4
    svc #1

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

exit:
    mov r0, #0
    mov r7, #1
    svc #0

.data
struct_addr:
.ascii "\x02\x00"       // AF_INET 0xff will be NULLed 
.ascii "\x1F\x90"       // port number 8080
.byte 10,205,130,176           // IP Address
.align 4
opt: .word 1
.align 2
print_num: .asciz "%d\n"
.align 2
socket_error_msg: .asciz "socket failed\n"
.align 2
bind_error_msg: .asciz "bind failed\n"
.align 2
listen_error_msg: .asciz "listen failed\n"
.align 2
accept_error_msg: .asciz "accept failed\n"
.align 2
server_msg: .asciz "Hello from server"
.align 2
hello_msg: .asciz "Hello message sent\n"
