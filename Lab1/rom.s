	.set noat
	.equ RAM_START, 0x3A80
	.equ BAD_RAM_ADDRESS, 0x4000
	.text
	.global _start
	.org	0x0000
	
_start:
	addi	r1, r0, 0x5678
	stw		r1, RAM_START(r0)
	stw 	r1, BAD_RAM_ADDRESS(r0)
	ldw 	r1, RAM_START(r0)
	ldw 	r1, BAD_RAM_ADDRESS(r0)
	br 		_start
	