; ==================================================
; MingKernel Bootloader
; --------------------------------------------------
; The bootloader uses FAT12 (File Allocation Table)
; to load kernel.bin into RAM (Random Acess Memory)
; and execute it.
; --------------------------------------------------
; The Reason MingKernel does not just use the
; bootloader relates to the fact the boot sector
; of an operating system only has 512 bytes to use
; this is why you see:
; 	times 510 -($-$$) db 0
; 	dw 0xaa55
; at the end of the bootloader,
; 	times 510 -($-$$) db 0
; means for the remaining bytes except for the two
; fill the binary with 0's
;
; 	dw 0xaa55
; means for the last two bytes store hexadecimal 55
; and AA, this is the key bytes for a bootloader,
; with out these ending bytes the bootloader will
; NOT load.
; ==================================================

;------------------------------------------------------------------------------

; ==========================================================================

	[BITS 16] ; Tell the nasm assembler we are using 16-bit assembly
	[org 0x7c00] ; Set the character offset to hex string 7c00 for printing

; ==========================================================================

	jmp short bootload_start ; Jump past the rest to bootload_start function
	nop ; Skip disk description table

; ==========================================================================
; ------------------------------------------------------------------
; Disk description table, to make it a valid floppy
; Values are those used by IBM for 1.44 MB, 3.5" diskette

	OEMLabel		db "MINGBOOT"	; Disk label
	BytesPerSector		dw 512		; Bytes per sector
	SectorsPerCluster	db 1		; Sectors per cluster
	ReservedForBoot		dw 1		; Reserved sectors for boot record
	NumberOfFats		db 2		; Number of copies of the FAT
	RootDirEntries		dw 224		; Number of entries in root dir
						; (224 * 32 = 7168 = 14 sectors to read)
	LogicalSectors		dw 2880		; Number of logical sectors
	MediumByte		db 0F0h		; Medium descriptor byte
	SectorsPerFat		dw 9		; Sectors per FAT
	SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
	Sides			dw 2		; Number of sides/heads
	HiddenSectors		dd 0		; Number of hidden sectors
	LargeSectors		dd 0		; Number of LBA sectors
	DriveNo			dw 0		; Drive No: 0
	Signature		db 41		; Drive signature: 41 for floppy
	VolumeID		dd 00000000h	; Volume ID: any number
	VolumeLabel		db "MingKernel "; Volume label: any 11 chars
	FileSystem		db "FAT12   "	; File system type: don't change!

; ==========================================================================

	bootload_start:
		; Background
		mov ah, 09h
		mov cx, 1000h
		mov al, 20h
		mov bl, 17h
		int 10h

		; Make Header
		mov ah, 09h
		mov cx, 80d
		mov al, 20h
		mov bl, 87h
		int 10h		
		mov si, OsTitle
		call print_string

		; Load Kernel
		mov ax, 07C0h ; Where we’re loaded mov ds, ax ; Data segment mov ax, 9000h ; Set up stack
		mov ss, ax ; Start the stack
		mov sp, 0FFFFh ; Stack grows downwards!
		cld ; Clear direction flag
		mov si, kern_filename ; Store filename in si REGISTER
		call load_file ; Load and execute the file
		jmp 2000h:0000h ; Jump to loaded kernel

; ==========================================================================
; Features
; ======================================
  %INCLUDE 'features/disk.asm'
; ==========================================================================
; Strings and Variables
; =================================

	disk_error	db "Disk error!", 0 ; If there is a disk
				   									 ; error print this
	file_not_found	db "Kernel not found!", 0 ; If file doesn't exist print
	kern_filename db "kernel.bin" ;
	OsTitle db "MingKernel Bootloader",13,10
; ==========================================================================
	times 510 -($-$$) db 0
	dw 0xaa55
; ==========================================================================
	buffer: ;Disk Buffer Begins
; ==========================================================================