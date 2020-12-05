; prints dx as hex
print_hex:
    pusha
	
	mov bx, 5
print_hex_loop:
	mov al, 0x0F
	and al, dl
	cmp al, 0x0A
	jl print_hex_then
	add al, 'A' - 10
	jmp print_hex_end
print_hex_then:
	add al, '0'
print_hex_end:
	mov [bx + HEX_OUT], al
	shr dx, 4
	dec bx
	cmp bx, 1
	jg print_hex_loop
	
	mov bx, HEX_OUT
	call print_string
	
	popa
	ret
HEX_OUT: db '0x0000', 0

; print 0-terminated string pointed by bx
print_string:
	pusha
	
	mov ah, 0x0E
	mov al, [bx]
print_string_loop:
    cmp al, 0
	je print_string_end
	int 0x10
	inc bx
	mov al, [bx]
	jmp print_string_loop

print_string_end:
	popa
	ret

; loads dh sectors to es:bx from drive dl
disk_load:
    push dx        ; Store DX on stack so later we can recall how many sectors were request to be read, even if it is altered in the meantime
	mov ah, 0x02   ; BIOS read sector function
	mov al, dh     ; Read DH sectors
	mov ch, 0x00   ; Select cylinder 0
	mov dh, 0x00   ; Select head 0
	mov cl, 0x02   ; Start reading from second sector
	int 0x13       ; BIOS interrupt
    jc disk_error  ; Jump if error
    pop dx         ; Restore DX from the stack
	cmp dh, al     ; if AL (sectors read) != DH (sectors expected)
	jne disk_error ; display error message
	ret
disk_error:
    mov bx, MSG_DISK_ERROR
	call print_string
	jmp $

MSG_DISK_ERROR db "Disk read error!", 0x0A, 0x0D, 0
