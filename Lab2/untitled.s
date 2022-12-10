#-----------------------------------------------------------------------------
# This template source file for ELEC 371 Lab 2 experimentation with interrupts
# also serves as the template for all assembly-language-level coding for
# Nios II interrupt-based programs in this course. DO NOT USE the approach
# shown in the vendor documentation for the DE0 Basic (or Media) Computer.
# The approach illustrated in this template file is far simpler for learning.
#
# Dr. N. Manjikian, Dept. of Elec. and Comp. Eng., Queen's University
#-----------------------------------------------------------------------------
    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF
	
	.equ 		TIMER_STATUS,		0x10002000		
	.equ		TIMER_CONTROL,		0x10002004
	.equ		TIMER_START_LO,		0x10002008
	.equ		TIMER_START_HI,		0x1000200C
	


	.text		# start a code segment (and we will also have data in it)

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# Define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

# mask/edge registers for pushbutton parallel port

	.equ	BUTTON_MASK, 0x10000058
	.equ	BUTTON_EDGE, 0x1000005C

# pattern corresponding to the bit assigned to button1 in the registers above

	.equ	BUTTON1, 0x2 #just 2 
# data register for LED parallel port
	.equ	LEDS, 0x10000010

#-----------------------------------------------------------------------------
# Define two branch instructions in specific locations at the start of memory
#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			#   (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------
# The actual program code (incl. service routine) can be placed immediately
# after the second branch above, or another .org directive could be used
# to place the program code at a desired address (e.g., 0x0080). It does not
# matter because the _start symbol defines where execution begins, and the
# branch at that location simply forces execution to continue where desired.
#-----------------------------------------------------------------------------

main:
	movia   sp, 0x007FFFFC		# initialize stack pointer
	
	movi r2,startString
	call PrintString
	#??????		# call hw/sw initialization subroutine
	
	call Init
	#??????		# perform any local initialization of gen.-purpose regs.
			#   before entering main loop 
	movia 	r7,COUNT
main_loop:
	
	addi 	r7,r7,1 
	stw 	r7,COUNT(r0) #wants to store back in memory 
	#??????		# body of main loop (reflecting typical embedded
			#   software organization where execution does not
			#   terminate)
			
	br main_loop

#-----------------------------------------------------------------------------
# This subroutine should encompass preparation of I/O registers as well as
# special processor registers for recognition and processing of interrupt
# requests. Initialization of data variables in memory can also be done here.
#-----------------------------------------------------------------------------

Init:				# make it modular -- save/restore registers
#parameters button1 and button mask addresses

	#??????			# body of Init() subroutine
	#saving registers
	subi	sp,sp,24
	stw		ra,20(sp)
	stw		r2,16(sp)
	stw		r3,12(sp)
	stw		r4,8(sp)
	stw		r5,4(sp)
	stw 	r6,0(sp)
	
	movia r2,BUTTON_MASK
	movia r3,BUTTON1
	stwio 	r3,0(r2)
	
	
	#r2 <-- button mask
	#r3 <-- button 1
	movia r5, TIMER_STATUS
	movia r6, TIMER_CONTROL
	movia r7, TIMER_START_LO
	movia r8, TIMER_START_HI
	
	movi r10, 0x4B40
	movi r11, 0x004C
	movi r12, 0b111
	movi r13, 0b11
	stwio	r10, 0(r7)
	stwio r11, 0(r8)
	stwio r12, 0(r6)
	wrctl ienable, r13
					#get button mask in register, and button 1 in another register, then store b1 into button mask
					#storing button1 into button mask
	 	# r3 = button 1, button mask = r2 #why 0 and not r0
					#enable interrupt and status
					
	#movi 	r3,0x2 #store flag 2 in r3 or is it the assigned position for interrupt ienable
	#wrctl	ienable,r3 #getting ienable of button1? or is it creating an interrupt from button 1
	movi	r3,0x1 #store flag 1 in r3 or is it the assigned position for the status interrupt 
	wrctl 	status,r3 #getting status of button 1? or is it creating a status interrupt from button 1
					
	movia r3,BUTTON_EDGE
	movia r2,LEDS			
	movia 	r4,0xf 
	stwio 	r4,0(r3)	
	ldwio 	r3,0(r2)
	movi 	r3, 0x4
	stwio 	r3,0(r2)				
					
	#loadint previous register values
	ldw		r6,0(sp)
	ldw		r5,4(sp)
	ldw		r4,8(sp)
	ldw 	r3,12(sp)
	ldw 	r2,16(sp)
	ldw		ra,20(sp)
	addi 	sp,sp,24
	ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below. Therefore,
# the actual code for this routine can be anywhere in memory for convenience.
# This template involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
# Programs with software-generated interrupts must check for hardware sources
# to conditionally adjust the ea register (no adjustment for s/w interrupts).
#-----------------------------------------------------------------------------

isr:
	
	subi	sp,sp,24	# save register values, except ea which
	stw		ra,20(sp)
	stw		r2,16(sp)
	stw		r3,12(sp)
	stw 	r4,8(sp)
	stw 	r5,4(sp)
	stw		r6,0(sp)
	
				#   must be modified for hardware interrupts

	subi	ea, ea, 4	# ea adjustment required for h/w interrupts

	
	rdctl r2,ipending #reading the values from the button and storing them in register 2
	andi r3,r2,0x2 #compares it to flag/ comparing the values of the button input with the location of the interrupt 
	beq r3,r0,TimerInterupt #checks to see if the flag has been triggered 
	call HexDisplay
	movia r3, BUTTON_EDGE
	#movi  r4, 0b10
	stwio r0, 0(r3)
	br Next
	
TimerInterupt:
	andi r3, r2, 0x1
	beq r3, r0, Next
	movi r5, 0x1
	movia r6, TIMER_STATUS
	stwio r5, 0(r6)

	
	call LEDUpdate
	
Next:	
	ldw		r6,0(sp)
	ldw		r5,4(sp)
	ldw		r4,8(sp)
	ldw 	r3,12(sp)
	ldw 	r2,16(sp)
	ldw		ra,20(sp)
	addi 	sp,sp,24			# restore register values
	
	eret			# interrupt service routines end _differently_
				#   than subroutines; execution must return to
				#   to point in main program where interrupt
				#   request invoked service routine


#-----------------------------------------------------------------------------
# pushButton
#-----------------------------------------------------------------------------

LEDUpdate:
	#saving registers
	subi sp,sp,20
	stw		ra,16(sp)
	stw		r2,12(sp)
	stw		r3,8(sp)
	stw		r4,4(sp)
	stw		r5,0(sp)


	movia	r2,LEDS
	movia	r3,BUTTON_EDGE
	movia 	r4,0xf 
	stwio 	r4,0(r3)	
	ldwio 	r3,0(r2)
	movi	r5,0x1
	beq		r3, r5, wrapAround
	srli	r3, r3, 1
	stwio 	r3,0(r2)
	br LEDUpdateEnd
	
wrapAround:
	movi 	r3, 0x200
	stwio	r3, 0(r2)
	
LEDUpdateEnd:	
	#loading registers
	ldw		r5,0(sp)
	ldw		r4,4(sp)
	ldw		r3,8(sp)
	ldw		r2,12(sp)
	ldw		ra,16(sp)
	addi 	sp,sp,20
	ret
	
	
	
HexDisplay:
	subi sp,sp,16
	stw		ra,12(sp)
	stw		r2,8(sp)
	stw		r3,4(sp)
	stw		r4,0(sp)

	movia r3, 0x10000020
	ldwio r4, 0(r3)
	movia r2, 0xffffffff
	xor  r4, r4, r2
	stwio r4, 0(r3)

	ldw		r4,0(sp)
	ldw		r3,4(sp)
	ldw		r2,8(sp)
	ldw		ra,12(sp)
	addi 	sp,sp,16
	ret
#-----------------------------------------------------------------------------
# PrintString and PrintChar functions
#-----------------------------------------------------------------------------

PrintString:
    subi    sp, sp, 12
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)
    mov     r4, r2
ps_loop:
    ldb		r2, 0(r4)
    beq     r2, r0, ps_end_loop
    call    PrintChar
    addi    r4, r4, 1
    beq     r0, r0, ps_loop
ps_end_loop:
    ldw     ra, 8(sp)
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12
    ret

PrintChar:
    subi    sp, sp, 12
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)
    movia   r3, JTAG_UART_BASE
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)
    andhi   r4, r4, WSPACE_MASK
    beq     r4, r0, pc_loop
    stwio   r2, DATA_OFFSET(r3)
    ldw     ra, 8(sp)
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12
    ret


#-----------------------------------------------------------------------------
# Definitions for program data, incl. anything shared between main/isr code
#-----------------------------------------------------------------------------

	.org	0x1000		# start should be fine for most small programs
				
#?????:	???	???		# define/reserve storage for program data

COUNT: .word 0
startString: .asciz "ELEC 371 Lab 2 by Lauren Duncan Matthew\n"
	.end
