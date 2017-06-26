.section .text

	.global Move
Move:
	push	{r4-r10, lr}
	ldr	r4, =snakeAddress	// load the array that contains the address of each snake piece
	ldr	r0, =state		// load the state struct
	add	r0, #12			// adding the offset for length
	ldr	r9, [r0]		// load the length
	sub	r9, #3			// length = length - (#head + #tail + #clearing box)
	mov	r7, #1			// min number of body pieces, body counter
	mov	r0, #0			// get the offset of the head
	bl	calculateOffset		// calculate the offset
	ldr	r5, [r0]		// load head x 		
	ldr	r6, [r0, #4]		// load head y 
	mov	r0, r5			// r0 = head x
	mov	r1, r6			// r1 = head y
	ldr	r2, =head		// r2 = photo addres of the head
	bl	DrawPhoto		// draw the head photo at this xy
sketch:
	cmp	r7, r9			// check body counter = length
	bhi	finish			// if counter > length, break the loop
	mov	r0, r7			// if not, r0 = counter
	bl	calculateOffset		// calculate the offset of counter
	mov	r8, r0			// r8 = calculated offset
	ldr	r5, [r8]		// load body[counter] x 		
	ldr	r6, [r8, #4]		// load body[counter] y 
	mov	r0, r5			// r0 = body[counter] x 
	mov	r1, r6			// r1 = body[counter] y 
	ldr	r2, =body		// r2 = photo addres of the body
	bl	DrawPhoto		// draw the body photo at this xy
	add	r7, #1			// counter++
	b	sketch			// do it again
finish:
	mov	r0, r7			// r0 = counter
	bl	calculateOffset		// calculate the offset of counter
	ldr	r5, [r0]		// load tail x 		
	ldr	r6, [r0, #4]		// load tail y 

	mov	r0, r5			// r0 = tail x 	
	mov	r1, r6			// r1 = tail y 
	ldr	r2, =tail		// r2 = photo addres of the tail
	bl	DrawPhoto		// draw the tail photo at this xy

	add	r0, r7, #1 		// r0 = counter+1
	bl	calculateOffset		// calculate the offset of counter
	ldr	r5, [r0]		// load clearing box x 		
	ldr	r6, [r0, #4]		// load clearing box y 
	mov	r0, r5			// r0 = clearing box x 	
	mov	r1, r6			// r1 = clearing box y 
	ldr	r2, =0x97FF		// r2 = background colour
	bl	DrawBox			// draw the draw the clearing box at this xy

	pop	{r4-r10, lr}
	bx 	lr

	.global	insertBody
insertBody:
	push	{r4-r10, lr}
	ldr	r0, =state		// load the state struct address
	ldr	r4, [r0, #12]		// load the length of the snake
	mov	r0, r4			// r0 = length
	bl	calculateOffset		// calculate the offset of the clearing box
	mov	r5, r0			// r5 = clearing box offset
	sub	r0, r4, #1		// r0 = length -1
	bl	calculateOffset		// calculate the tail offset
	mov	r4, r0			// r4 = tail offset
	ldr	r6,[r5]			// load the box.x
	ldr	r7,[r5, #4]		// load box.y
	ldr	r8,[r4]			// load tail.x
	ldr	r9,[r4, #4]		// load tail.y
	
	cmp	r6, r8			// if box.x = tail.x
	bne	yCoordinates 		// if not, check the y coordinates
	cmp	r7, r9			// if equal, compare box.y and tail.y
	blt	decrementY		// if box.y < tail.y, go to decrementY
	add	r7, #32			// if box.y > tail.y, box.y = box.y + 32
	b	storeItBack		// go to storeItBack
decrementY:
	sub	r7, #32			// decrement box.y by 32
	b	storeItBack		// go to storeItBack
yCoordinates:
	cmp	r6, r8			// if box.y = tail.y, then compare box.x and tail.x
	blt	decrementX		// if box.x < tail.x, go to decrementX
	add	r6, #32			// if not, box.x = box.x + 32
	b	storeItBack		// go to storeItBack
decrementX:
	sub	r6, #32			// decrement box.x by 32
storeItBack:
	ldr	r0, =state		// load the struct address
	ldr	r4, [r0, #12]		// load the length
	add	r4, #1			// length = length + 1
	str	r4, [r0, #12]		// store the new length
	mov	r0, r4			// r0 = length
	bl	calculateOffset		// calculate the offset of the clearing box
	str	r6,[r0]			// update the box.x	
	str	r7,[r0, #4]		// update the box.y

	pop	{r4-r10, lr}
	bx 	lr


