; ==================================================
; MingKernel Kernel
; --------------------------------------------------
; The kernel uses FAT12 (File Allocation Table)
; and other resources to essentially make the full
; operating system.
; ==================================================

;------------------------------------------------------------------------------

; ==========================================================================

	[BITS 16] ; Tell the nasm assembler we are using 16-bit assembly
	[org 0x7c00] ; Set the character offset to hex string 7c00 for printing

; ==========================================================================

	jmp short os_start ; Jump past the rest to bootload_start function
	nop ; Skip disk description table

; ==========================================================================
; ------------------------------------------------------------------
; Disk description table, to make it a valid floppy
; Values are those used by IBM for 1.44 MB, 3.5" diskette

	OEMLabel		db "MINGKERN"	; Disk label
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

	os_start:
		mov si, ProgramManager
		jmp programs_start
	shell_start:
		; Background
		mov ah, 09h
		mov cx, 1000h
		mov al, 20h
		mov bl, 07h
		int 10h

		; Make Header
		mov ah, 09h
		mov cx, 80d
		mov al, 20h
		mov bl, 87h
		int 10h		
		mov si, OsTitle
		call print_string

		jmp $

	programs_start:
		; Background
		mov ah, 09h
		mov cx, 1000h
		mov al, 20h
		mov bl, 17h
		int 10h

		mov ah, 09h
		mov cx, 80d
		mov al, 20h
		mov bl, 0xcf
		int 10h

; ==========================================================================
; Features
; ======================================
  %INCLUDE 'features/disk.asm'
  %INCLUDE 'features/lib.asm'
; ==========================================================================
; Strings and Variables
; =================================

	disk_error	db "Disk error!", 0 ; If there is a disk		   									 			; error print this
	file_not_found	db "Kernel not found!", 0 ; If file doesn't exist print
	OsTitle db "MingKernel Shell",13,10
	ProgramManager db "MingKernel Program Manager"
; ==========================================================================
; File Buffer
; ----------------------------------------
	buffer:
; ==========================================================================
; Validation Bytes
; ---------------------------------
	dw 0xaa55
; ==========================================================================