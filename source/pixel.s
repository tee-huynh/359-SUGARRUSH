.section .text

	.global DrawPixel
DrawPixel:
	push	{r4-r10, lr}			// r0 - x
 						// r1 - y
	offset	.req	r4 			// r2 - color

	add	offset,	r0, r1, lsl #10 	// offset = (y * 1024) + x = x + (y << 10)
	lsl	offset, #1			// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	ldr	r0, =FrameBufferPointer		// get the address of the frambuffeer pointer
	ldr	r0, [r0]			// load the framebuffer pointer
	strh	r2, [r0, offset]		// store the colour to the framebuffer pointer
	
	.unreq offset

	pop	{r4-r10, lr}
	bx	lr

	.global	CheckPixel
CheckPixel:
	push	{r4-r10, lr}			// r0 - x
						// r1 - y
	offset	.req	r4			

	add	offset,	r0, r1, lsl #10 	// offset = (y * 1024) + x = x + (y << 10)
	lsl	offset, #1			// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	ldr	r0, =FrameBufferPointer		// get the address of the frambuffeer pointer 
	ldr	r0, [r0]			// load the framebuffer pointer
	ldrh	r2, [r0, offset]		// load the colour to the framebuffer pointer
	mov	r0, r2				// returns r0 which contains the color code

	pop	{r4-r10, lr}
	bx	lr

	.global DrawPhoto
DrawPhoto:
	push	{r4-r10, lr}			
	mov	r5, r0			 	// r0 - x
	mov 	r6, r1			 	// r1 - y			
	mov	r8, r2				// r2 - address of the photo (32 x 32) 
	mov	r7, #0				// ycounter
init:
	mov	r4, #0				//xcounter = 0
top:
	mov	r0, r5				// r0 = x		
	mov	r1, r6				// r1 = y
	ldr 	r2, [r8], #2			// loading the colour from the photo address
	bl	DrawPixel			// draw the colour to that offset
	
	add	r4, #1				// xcounter++ 
	add	r5, #1				// x++
	cmp	r4, #32				// compare if done 32 times
	bne	top				// if not, do it again

	add	r6, #1				// y++
	add	r7, #1				// ycounter++
	cmp	r7, #32				// compare if done 32 times
	sub	r5, #32				// x = x-32
	bne	init				// if not, do it gain
		
	pop	{r4-r10, lr}
	bx	lr

	.global checkForPhoto
checkForPhoto:
	push	{r4-r10, lr}
	mov	r5, r0				// r0 - x
	mov 	r6, r1				// r1 - y
	mov	r8, r2				// r2 - address of the photo (32 x 32) 
	mov	r7, #0				// ycounter
initP:
	mov	r4, #0				//xcounter = 0
topP:
	mov	r0, r5				// r0 = x
	mov	r1, r6				// r1 = y
	ldrh 	r9, [r8], #2			// loading the colour from the photo address
	bl	CheckPixel			// check the colour of that offset
	cmp	r0, r9				// check if the colour of that offset = colour at the address
	movne	r0, #1				// if not equal, r0 = 1
	bne	finishP				// and break the loop

	add	r4, #1				// xcounter++ 
	add	r5, #1				// x++
	cmp	r4, #32				// compare if done 32 times
	bne	topP				// if not, do it again

	add	r6, #1				// y++
	add	r7, #1				// ycounter++
	cmp	r7, #32				// compare if done 32 times
	sub	r5, #32				// x = x-32
	bne	initP				// if not, do it gain

	mov	r0, #0				// r0 = 0, if the photo at x,y offset = input photo 
finishP:		
	pop	{r4-r10, lr}
	bx	lr

	.global DrawBox
DrawBox:
	push	{r4-r10, lr}
	mov	r5, r0				// r0 - x
	mov 	r6, r1				// r1 - y	
	mov	r8, r2				// r2 - colour code  
	mov	r7, #0				// ycounter
init1:
	mov	r4, #0				// xcounter = 0
top1:
	mov	r0, r5				// r0 = x
	mov	r1, r6				// r1 = y
	mov	r2, r8				// loading the colour 
	bl	DrawPixel			// draw the colour to that offset

	add	r4, #1				// xcounter++ 
	add	r5, #1				// x++
	cmp	r4, #32				// compare if done 32 times
	bne	top1				// if not, do it again

	add	r6, #1				// y++
	add	r7, #1				// ycounter++
	cmp	r7, #32				// compare if done 32 times
	sub	r5, #32				// x = x-32
	bne	init1				// if not, do it gain
		
	pop	{r4-r10, lr}
	bx	lr

	.global CheckBox			
CheckBox:						
	push	{r4-r10, lr}
	mov	r5, r0				// r0 - x
	mov 	r6, r1				// r1 - y
	mov	r7, #0				// ycounter
	ldr	r9, =0x97FF			// r2 - background colour code  
topC:
	mov	r4, #0				// xcounter = 0
botC:
	mov	r0, r5				// r0 = x
	mov	r1, r6				// r1 = y
	bl	CheckPixel			// check the pixel at xy
	cmp	r0, r9				// compare if the pixel = background
	movne	r0, #1				// if not, r0 = 1
	bne	false				// and break the loop

	add	r4, #1				// xcounter++ 
	add	r5, #1				// x++
	cmp	r4, #32				// compare if done 32 times
	bne	botC				// if not, do it again

	add	r6, #1				// y++
	add	r7, #1				// ycounter++
	cmp	r7, #32				// compare if done 32 times
	sub	r5, #32				// x = x-32
	bne	topC				// if not, do it gain

	mov	r0, #0				//return r0 = 0 the photot at xy is the background and 1 if not
false:
	pop	{r4-r10, lr}
	bx	lr

	.global DrawPause
DrawPause:
	push	{r4-r10, lr}			
	mov	r5, r0			 	// r0 - x
	mov 	r6, r1			 	// r1 - y			
	mov	r8, r2				// r2 - address of the pause photo (160 x 64) 
	mov	r7, #0				// ycounter
initU:
	mov	r4, #0				// xcounter = 0
topU:
	mov	r0, r5				// r0 = x		
	mov	r1, r6				// r1 = y
	ldr 	r2, [r8], #2			// loading the colour from the photo address
	bl	DrawPixel			// draw the colour to that offset
	
	add	r4, #1				// xcounter++ 
	add	r5, #1				// x++
	cmp	r4, #160			// compare if done 160 times
	bne	topU				// if not, do it again

	add	r6, #1				// y++
	add	r7, #1				// ycounter++
	cmp	r7, #64				// compare if done 64 times
	sub	r5, #160			// x = x-160
	bne	initU				// if not, do it gain
		
	pop	{r4-r10, lr}
	bx	lr

