.section .text
	.equ	BASE, 0x20200000
	.equ	MASK, 0x0000ffff
	.equ	CLK,  0x20003004
	
	.global Snes
Snes:
	push	{r4-r10, lr}	

	bl	Read_SNES 			// branch to read SNES 		
	mov	r6, r0	 			// r6 = button register

	mov	r0, r6 				// r0 = button register
	bl	BtoD				// convert the input cycle to decimal

	pop	{r4-r10, lr}			// returns the decimal for the particular cycle
	bx	lr

Read_SNES:
	push	{r4-r10, lr}
	mov 	r1, #1 				// r1 = function number for clock
	mov 	r0, #11 			// set GPIO pin 11 (CLOCK) to output
	bl 	Init_GPIO

	mov 	r1,#0 	 			// r1 = function number for clock
	mov 	r0, #10 			// set GPIO pin 10 (DATA) to input (code 0)
	bl 	Init_GPIO

	mov 	r1,#1 	 			// r1 = function number for clock
	mov 	r0, #9 				// set GPIO pin 9 (LATCH) to output
	bl 	Init_GPIO

	mov 	r10, #0				// r10 = counter
	mov 	r9, #0				// r9 = value with button	
	
	mov	r0, #1				// writeGPIO(CLOCK, #1)
	bl	Write_Clock			// branch to Write_Clock

	mov	r0, #1 				// writeGPIO(LATCH, #1)
	bl	Write_Latch			// branch to Write_Latch
	
	mov 	r0, #12 			// set the wait time to 12 microseconds
	bl	Wait				// wait 12 microseconds

	mov	r0, #0 				// writeGPIO(LATCH, #0)
	bl	Write_Latch			// branch to Write_Latch
snesLoop:

	cmp	r10, #16			// if (i < 16)
						// pulsing continues for 16 times
	bge	end				// once i >= 16, branch to end

	mov 	r0, #6				// set the wait time to 6 microseconds
	//push	{lr}
	bl	Wait				// wait 6 microseconds
	//pop	{lr}			
		

	mov	r0, #0 				// writeGPIO(CLOCK, #0), falling edge
	//push	{lr}
	bl	Write_Clock			// branch to Write_Clock
	//pop	{lr}


	mov 	r0, #6				// set the wait time to 6 microseconds
	//push	{lr}
	bl	Wait				// wait 6 microseconds
	//pop	{lr}
	
	//push	{lr}
	bl	Read_Data 			// readGPIO(DATA, b), read bit i
	//pop	{lr}	
						// buttons[i] = b
	lsl	r0, r10				// r0 = counter shifted by 1
	orr	r9, r0				// moves value into buttons register (r9)
		

	mov	r0, #1 				// writeGPIO(CLOCK, #1), rising edge; new cycle
	//push	{lr}
	bl	Write_Clock			// branch to Write_Clock
	//pop	{lr}

	add 	r10, #1				// increment the counter, i, so i++
	b	snesLoop			// branch back snesLoop

end:
	mov	r0, r9				// r0 = button
	pop	{r4-r10, lr}
	mov	pc, lr				// return to calling code

Init_GPIO:
	push	{r4-r10, lr}
	mov	r4, r1				// r4 = line, r1 = function number
	mov	r1, r0				// r1 = r0
	ldr	r0, =BASE			// loading the base address into r0

init_loop:
	cmp 	r1, #9				// If line > 9, need to find offset
	subhi 	r1, #10				// "divide" by 10, r1 will contain lsd
	addhi 	r0, #4				// add 4 to base address
	bhi 	init_loop			// branch back to init_loop if greater than 0

	ldr	r10, [r0]			// load from calculated address
	
	mov	r9, #3				// r9 = 3
	mul	r1, r9				// multiply lsd by 3 

	mov	r8, #7				// will shift to the address
	lsl	r8, r1				// shifting 7 by r1 
	lsl	r4, r1				// shift the function number by r1	

	bic	r10, r8				// clear the corresponding bits in r10

	orr     r10, r4				// orr the result by r4
	str	r10, [r0]			// store at corresponding address
	pop	{r4-r10, lr}
	mov	pc, lr				// return to calling code		

Write_Latch:
	push	{r4-r10, lr}
	ldr	r2, =BASE 			// r2 = base address
	mov	r3, #1				// r3 = 1

	lsl	r3, #9				// shift the 1 to bit 9
	teq	r0, #0				// check to see if r1 is 0 or 1

	streq 	r3, [r2, #40] 			// If r1 is 0, 1 will be set in GPCLR0
	strne	r3, [r2, #28] 			// If r1 is 1, 1 will be set in GPSET0
	pop	{r4-r10, lr}
	mov	pc, lr 				// return to calling code

Write_Clock:
	push	{r4-r10, lr}
	ldr	r2, =BASE 			// r2 = base address
	mov	r3, #1				// r3 = 1

	lsl	r3, #11				// shift the 1 to bit 11
	teq	r0, #0				// check to see if r1 is 0 or 1

	streq 	r3, [r2, #40] 			// If r1 is 0, 1 will be set in GPCLR0
	strne	r3, [r2, #28] 			// If r1 is 1, 1 will be set in GPSET0
	pop	{r4-r10, lr}
	mov	pc, lr 				// return to calling code

Read_Data:
	push	{r4-r10, lr}
	ldr 	r2, =BASE 			// r2 = base address
	ldr 	r1, [r2, #52] 			// load r1 with GPLEV0 register 
	mov 	r3, #1 				// r3 = 1

	lsl 	r3, #10				// shift the 1 to bit 10
	and	r1, r3 				// mask everything except for bit 10
	teq	r1, #0				// check the value of r1

	moveq	r0, #0				// if r1 = 0, return a 0
	movne	r0, #1				// if r1 = 1, return a 1
	pop	{r4-r10, lr}
	mov	pc, lr 				// return to calling code
	
	.global Wait
Wait:
	push	{r4-r10, lr}
	ldr 	r2, =CLK 			// r0 = CLO address
	ldr 	r1, [r2]			// r2 = original time
	add	r1, r0				// r1 = original time + delay
delayLoop:
	ldr	r0, [r2]			// r0 = CLO address
	cmp	r1, r0				// compare current time with delayed time
	bgt 	delayLoop			// keep branching until current time = delay 
	pop	{r4-r10, lr}
	mov	pc, lr				// return to calling code

BtoD:
	push	{r4-r10, lr}
	mov	r6, r0				
	mov 	r5, #1 				// bit mask for each button
	ldr 	r4,=MASK			// bit mask for flipping button register
	eor 	r4,r6 				// flips bits
	mov 	r3,#0 				// counter

buttonLoop:	
	mov 	r5, #1 				// bit mask for each button
	cmp	r3, #11				// check if counter = 11
	moveq	r3, #0				// if it is, counter = 0
	beq	done1				// and break the loop
	lsl	r5,r3 				// shifting r5 by the counter 
	and 	r7,r4,r5			// current pressed button

	cmp 	r7, #0 				// if r7 = 0, branch to next
	beq 	next 				// current button is not pressed, branch to the top of the loop	
	bne	doneLoop			
next: 
	add 	r3,#1 				// increment the counter
	b 	buttonLoop 			// branch to buttonLoop
doneLoop:
	add	r3, #1				// counter++
done1:
	mov	r0, r3				// return counter 
	pop	{r4-r10, lr}
	mov	pc, lr				// return to calling code



