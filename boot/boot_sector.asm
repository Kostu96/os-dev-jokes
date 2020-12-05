[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl ; BIOS stores our boot drive in DL, so it’s best to remember this for later.

; Set the stack.
mov bp, 0x9000
mov sp, bp

; load_kernel
mov bx, KERNEL_OFFSET
mov dh, 15
mov dl, [BOOT_DRIVE]
call disk_load

; switch to pm
cli
lgdt [gdt_descriptor]
mov eax, cr0 ; To make the switch to protected mode, we set
or eax, 0x1  ; the first bit of CR0, a control register
mov cr0, eax ; Update the control register
jmp CODE_SEG:start_protected_mode

%include "boot/bios_functions.asm" 
%include "boot/gdt.asm" 

[bits 32]
start_protected_mode: 
mov ax, DATA_SEG
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ebp, 0x90000 ; Update stack position 
mov esp, ebp 

call KERNEL_OFFSET 
jmp $

;VIDEO_MEMORY equ 0xb8000
;WHITE_ON_BLACK equ 0x0f
; prints a null -terminated string pointed to by EDX
;print_string_pm:
;    pusha
;	mov edx, VIDEO_MEMORY ; Set edx to the start of vid mem.
;print_string_pm_loop:
;    mov al, [ebx]            ; Store the char at EBX in AL
;	mov ah, WHITE_ON_BLACK   ; Store the attributes in AH
;    cmp al, 0                ; if (al == 0), at end of string, so
;	je print_string_pm_done  ; jump to done
;    mov [edx], ax            ; Store char and attributes at current character cell.
;	add ebx, 1               ; Increment EBX to the next char in string.
;	add edx, 2               ; Move to next character cell in vid mem.
;    jmp print_string_pm_loop ; loop around to print the next char.
;print_string_pm_done:
;    popa
;	ret

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55
