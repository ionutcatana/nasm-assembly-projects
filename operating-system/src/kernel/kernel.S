bits 32

; the kernel has to be in the text section!

CODE_SEG equ 0x08
DATA_SEG equ 0x10

extern kmain

global _start
_start:
    ; setup segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; enable fast A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    call kmain
    jmp $

; magic alignment fix
times 512 - ($ - $$) db 0