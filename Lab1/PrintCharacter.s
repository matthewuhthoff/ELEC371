
	.text
	.global _start
	.org 0x0000

_start:
main:
	movi sp, 0x7FFC
	movi r2, 'A'
	call PrintChar
	
    break





PrintChar:
	subi sp, sp, 8
	stw r3, 4(sp)
	stw r4, 0(sp)
	
	movia r3,0x10001000
pc_loop:
	ldwio r4, 4(r3) # load 1 byte 
	andhi r4, r4,0xFFFF
	beq r4, r0, pc_loop
	stwio r2, 0(r3) # store 1 byte 


	ldw r3, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 8

	ret
		

	
	