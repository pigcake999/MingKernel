; ========================================
; Colbal Kernel Screen Functions
; Credit Iplo (https://github.com/iplo)
; Created By Christian Barton Randall
; ========================================

;----------------------------------------------------------------

; ========================================
; This uses the [org 0x7c00] offset
; to print strings and clear
; the screen.
; =========================================

os_clear_screen:
	mov al, 02
	mov dl, 0
	mov dh, 0
	int 10
	mov cx, 1000
	int 10
	int 20

os_print_string:
	pusha
	mov ah, 0x0e
	jmp os_print_string_loop
os_print_string_loop:
	mov al, [bx]
	cmp al, 0
	je os_print_string_done
	int 0x10
	add bx, 1
	jmp os_print_string_loop
os_print_string_done:
	popa
	ret