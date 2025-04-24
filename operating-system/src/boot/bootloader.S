org 0x7C00
bits 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
_boot_start:
    jmp short boot
    nop

times 33 db 0 ; bios parameter block

boot:
    jmp 0x00:setup ; ensures CS is 07C0

setup:
    cli            ; clear interrupts
    mov ax, 0x00
    mov ds, ax     ; setup data segment
    mov es, ax
    ; mov ax, 0x00
    mov ss, ax     ; setup stack segment
    mov sp, 0x7C00 ; setup stack pointer
    sti            ; enables interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32 ; moved to another file
    
; Global Descriptor Table
gdt_start:
gdt_null:
    dd 0
    dd 0 ; 64 zero bits

; offset 0x08
gdt_code:     ; CS point here!
    dw 0xFFFF ; segment limit for first 0-15 bits
    dw 0      ; base first 0-15 bits
    db 0      ; base 16-23 bits
    db 0x9A   ; access byte
    db 11001111b ; the high 4 bit flags and the 4 low bit flags
    db 0         ; base 24-31 bits

; offset 0x10
gdt_data:     ; DS, SS, ES, FS, GS
    dw 0xFFFF ; segment limit for first 0-15 bits
    dw 0      ; base first 0-15 bits
    db 0      ; base 16-23 bits
    db 0x92   ; access byte (only change from above)
    db 11001111b ; the high 4 bit flags and the 4 low bit flags
    db 0         ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size
    dd gdt_start               ; offset

bits 32
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; Backup the LBA for later

    ; Send highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; select the master drive
    mov dx, 0x1F6
    out dx, al ; Finished sending

    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al ; Finished sending

    ; Send more bits of the LBA
    mov eax, ebx ; restore backup
    mov dx, 0x1F3
    out dx, al

    ; Send more bits of the LBA (2)
    mov dx, 0x1F4
    mov eax, ebx ; restore backup just to be sure
    shr eax, 8
    out dx, al

    ; Send upper 16 bits of the lba
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

; checking if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

; we need to read 256 words at a times
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; end of reading sectors into memory

    ret

times 510 - ($ - $$) db 0
dw 0xAA55
