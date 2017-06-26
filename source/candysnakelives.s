.section .text

	.global r0ndomNumber
r0ndomNumber:
	push	{r4-r10, lr}
	ldr 	r2, =0x20003004		// r0 = CLO address
	ldr 	r4, [r2]		// load the clock 
	mov	r5, #19			// r5 = 19
	mov	r6, #29			// r6 = 29
	mov	r0, r4				
	mov	r1, r5
	bl	division		// clock / 19
	mov	r7, r0	 			
	add	r7, #1			// r7 = (clock / 19) + 1
	ldr 	r2, =0x20003004		// r0 = CLO address
	ldr 	r4, [r2]		// load the clock 
	mov	r0, r4
	mov	r1, r6				
	bl	division		// clock / 29
	mov	r1, r0	 			
	add	r1, #1			// r1 = (clock / 29) + 1
	mov	r0, r7			// r0 = random x, r1 = random y
	pop	{r4-r10, lr}
	bx	lr
	
	.global division
division:
	push	{r4-r10, lr}		// This division algorithm is from the Book, Arm Assembly Language by Hohl and Hinds
	mov	r4, #1			// bit control the division
Div1:
	cmp	r1, #0x80000000		// move r1 until grater than r0
	cmpcc	r1, r0
	lslcc	r1, r1, #1
	lslcc	r4, r4, #1
	bcc	Div1
	mov	r2, #0
Div2:
	cmp	r0, r1			// test for possible substraction
	subcs	r0, r0, r1		// subtract if ok
	addcs	r2, r2, r4		// put relevant bit into result 
	lsrs	r4, r4, #1		// shift control bit 
	lsrne	r1, r1, #1		// halve unless finished

	bne	Div2			// result is in r2 and reminder in r0

	pop	{r4-r10, lr}
	bx	lr

//r0 = photo address
	.global r0ndomPhoto
r0ndomPhoto:
	push	{r4-r10, lr}
	mov	r10, r0			// address of the photo to be printed
	mov	r4, #32			// r4 = 32
recalc:
	bl	r0ndomNumber		// get random number
	mul	r5, r0, r4		// random x * 32
	mul	r6, r1, r4		// random y * 32
	mov	r0, r5				
	mov	r1, r6
	mov	r2, #0
	bl	CheckBox		// check if there is a collision at this xy
	cmp	r0, #1			// if there is, recalculate
	beq	recalc				
nextD:
	mov	r0, r5
	mov	r1, r6
	mov	r2, r10			// if there is no collision
	bl	DrawPhoto 		// draw the photo at this xy
	
	pop	{r4-r10, lr}
	bx	lr

	.global printCandyLives
printCandyLives:
	push	{r4-r10, lr}		// r0 = # to be printed
	bl	getScore
	cmp	r0, #0
	movlt 	r0, #0
	mov	r1, #512		// r1 = x
	mov	r2, #736		// r2 = y
	bl	printNum		// print r0
	pop	{r4-r10, lr}
	bx	lr

.global printSnakeLives
printSnakeLives:
	push	{r4-r10, lr}		// r0 = # to be printed
	bl	getLive
	mov	r1, #512		// r1 = x
	mov	r2, #704		// r2 = y
	bl	printNum		// print r0
	pop	{r4-r10, lr}
	bx	lr

	.global printNum
printNum:
	push	{r4-r10, lr}
	mov	r6,r1			// r0 = input num to be printed	
	mov	r7,r2			// r1 = x
	mov	r4, #10			// r2 = y
	mov	r1, r4		
	bl	division		// r0 / 10
	mov	r4, r2			// your first digit(Quotient)
	mov	r5, r0			// second digit(Remainder)

	mov	r8, #4			// calculate the offset
	mul	r4, r8			// first digit offset
	mul	r5, r8			// second digit offset

	ldr	r0, =numbers		// load the array of numbers
	add	r0, r4			// calculate the offset
	ldr	r4, [r0]		// load the offset of first digit

	mov	r0, r6		
	mov	r1, r7
	mov	r2, r4
	bl	DrawPhoto		// draw the first digit
Check:
	ldr	r0, =numbers		// load the array of numbers
	add	r0, r5			// calculate the offset
	ldr	r5, [r0]		// load the offset of second digit

	add	r0, r6, #32		// calculate the x for the second digit
	mov	r1, r7
	mov	r2, r5
	bl	DrawPhoto		// draw the second digit

	pop	{r4-r10, lr}
	bx	lr

	.global updateScore
updateScore:
	push	{r4-r10, lr}		
	ldr	r4, =score		// load the score address
	str	r0, [r4]		// r0 = score
	pop	{r4-r10, lr}
	bx	lr

	.global getScore
getScore:
	push	{r4-r10, lr}	
	ldr	r4, =score		// load the score address
	ldr	r0, [r4]		// load the score
	pop	{r4-r10, lr}
	bx	lr

	.global updateLive
updateLive:
	push	{r4-r10, lr}		
	ldr	r4, =lives		// load the score address
	str	r0, [r4]		// r0 = score
	pop	{r4-r10, lr}
	bx	lr

	.global getLive
getLive:
	push	{r4-r10, lr}	
	ldr	r4, =lives		// load the score address
	ldr	r0, [r4]		// load the score
	pop	{r4-r10, lr}
	bx	lr

