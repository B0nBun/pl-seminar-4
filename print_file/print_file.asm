; print_file.asm

%define O_RDONLY 0 
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_MMAP 9
%define SYS_MUNMAP 0xb
%define SYS_CLOSE 0x3
%define SYS_EXIT 60
%define SYS_FSTAT 0x5
%define FD_STDOUT 1
%define FSTAT_STRUCT_SIZE 144
%define FSTAT_SIZE_OFFSET 48
%define PAGE_SIZE 1024 * 4 

global print_file
global print_string
section .text

; use exit system call to shut down correctly
exit:
    mov  rax, SYS_EXIT
    xor  rdi, rdi
    syscall

; These functions are used to print a null terminated string
; rdi holds a string pointer
print_string:
    push rdi
    call string_length
    pop  rsi
    mov  rdx, rax 
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

string_length:
    xor  rax, rax
.loop:
    cmp  byte [rdi+rax], 0
    je   .end
    inc  rax
    jmp .loop 
.end:
    ret

; This function is used to print a substring with given length
; rdi holds a string pointer
; rsi holds a substring length
print_substring:
    mov  rdx, rsi 
    mov  rsi, rdi
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

; rsi - fd
get_file_size:
    sub rsp, FSTAT_STRUCT_SIZE
    mov rax, SYS_FSTAT
    mov rsi, rsp
    syscall
    mov rax, [rsp + FSTAT_SIZE_OFFSET]
    add rsp, FSTAT_STRUCT_SIZE
    ret

; rdi - filename
print_file:
    sub rsp, 8 * 2
    ; Вызовите open и откройте fname в режиме read only.
    mov  rax, SYS_OPEN
    mov  rsi, O_RDONLY    ; Open file read only
    mov  rdx, 0 	      ; We are not creating a file
                          ; so this argument has no meaning
    syscall
    ; rax holds the opened file descriptor now

    ; Вызовите mmap c правильными аргументами
    ; Дайте операционной системе самой выбрать, куда отобразить файл
    ; Размер области возьмите в размер страницы 
    ; Область не должна быть общей для нескольких процессов 
    ; и должна выделяться только для чтения.
    mov [rsp + 0], rax ; rsp + 0 <- fd
    mov r8, rax          ; fd
    mov rax, SYS_MMAP
    mov rdi, 0           ; addr
    mov rsi, PAGE_SIZE   ; len
    mov rdx, PROT_READ   ; prot
    mov r10, MAP_PRIVATE ; flags
    mov r9, 0            ; offset
    syscall
    mov [rsp + 8], rax ; rax <- &str


    ; с помощью print_string теперь можно вывести его содержимое
    mov rdi, [rsp + 0] ; rdi <- fd
    call get_file_size
    mov rsi, rax
    mov rdi, [rsp + 8]
    call print_substring

    ; теперь можно освободить память с помощью munmap
    mov rax, SYS_MUNMAP
    mov rdi, [rsp + 8]
    mov rsi, PAGE_SIZE 
    syscall
    ; закрыть файл используя close

    mov rax, SYS_CLOSE
    mov rdi, [rsp + 0]
    syscall
    ; и выйти
    add rsp, 8 * 2
    ret

