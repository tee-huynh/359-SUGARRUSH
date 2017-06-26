//*************** PRINTS BRICK LAYOUT, BORDER, AND PAUSE MENU ***************//
.section .text

	.global	vid
vid:
	push	{r4-r10, lr}
	ldr	r2, =0x97FF 		// load the colour for the main background (#97ffff - sky blue)
	bl	Background 		// draw background
	bl	Border 			// draw border
	bl	DrawLayoutOne 		// draw brick layout
	bl	Stats 			// draw number of lives and candy collected
	pop	{r4-r10, lr}
	bx	lr

	.global changeBackground
changeBackground:
	push	{r4-r10, lr}
	mov	r0, #0 			// initializes r0 = 0
	mov	r1, #0 			// initializes r1 = 0
	mov	r6, #0 			// initializes r6 = 0 (counter)
	mov	r8, r2 			// r8 = r2

loopAgain:

	ldrh	r2,[r8],#2 		// loads offset of halfword to get the colour of each pixel in the array
	bl	DrawPixel 		// branch to draw each pixel
	add	r6, #1 			// increment r6
	ldr	r5, =786482 		// r5 = maximum offset of background
	cmp	r6, r5 			// compare r6 and r5
	mov	r0, r6 			// r0 =r6
	blt	loopAgain 		// continue looping while counter is less than maximum offset
	
	pop	{r4-r10, lr}
	bx	lr

	.global Background
Background:
	push	{r4-r10, lr}
	mov	r0, #0 			// initializes r0 = 0
	mov	r1, #0 			// initializes r1 = 0
	mov	r6, #0 			// initializes r6 = 0 (counter)
loop:

	bl	DrawPixel 		// draw each pixel of the background with the blue colour
	add	r6, #1 			// increment counter
	ldr	r5, =786482 		// r5 = maximum offset of background
	cmp	r6, r5 			// compare r6 and r5
	mov	r0, r6 			// r0 =r6
	blt	loop 			// continue looping while counter is less than maximum offset
	
	pop	{r4-r10, lr}
	bx	lr

// PRINTING STATS SUCH AS LIVES AND NUMBER OF CANDIES COLLECTED

Stats:
	push	{r4-r10, lr}
	mov	r0, #448 		// x coordinate of snake lives icon
	mov	r1, #704 		// y coordinate of snake lives icon
	ldr	r2, =snakelives 	// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #480 		// x coordinate of "number of" icon
	mov	r1, #704 		// y coordinate of "number of" icon
	ldr	r2, =multiply 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #512 		// x coordinate of the number, zero
	mov	r1, #704 		// y coordinate of the number, zero
	ldr	r2, =zero 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour
					// lives begin at three
	mov	r0, #544 		// x coordinate of the number, three
	ldr	r1, =702 		// y coordinate of the number, three
	ldr	r2, =three 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #448 		// x coordinate of number of candies icon
	mov	r1, #736 		// y coordinate of number of candies icon
	ldr	r2, =candylives 	// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #480 		// x coordinate of "number of" icon
	mov	r1, #736 		// y coordinate of "number of" icon
	ldr	r2, =multiply 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #512 		// x coordinate of the number, zero
	mov	r1, #736 		// y coordinate of the number, zero
	ldr	r2, =zero 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #544 		// x coordinate of the number, zero
	ldr	r1, =736		// y coordinate of the number, zero
	ldr	r2, =zero 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour
	
	pop	{r4-r10, lr}
	bx	lr

Border:
	push	{r4-r10, lr}
	mov	r4, #0 			// initialize r4 = 0
printBy:
	mov	r0, #0 			// initialize r0 = 0
	mov	r1, r4 			// r1 = r4
	ldr	r2, =borderLeft 	// prints correct border for left side in a loop from (0, 32) to (0, 672)
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =992 		// r0 = 992
	mov	r1, r4 			// r1 = r4
	ldr	r2, =borderRight 	// prints correct border for left side in a loop from (992, 32) to (992, 672)
	bl	DrawPhoto 		// print pixel of each corresponding colour
next:
	add	r4, #32 		// r4 = r4 + 32
	ldr	r0, =672 		// r0 = 672	
	cmp	r4, r0 			// continues to loop until max y coordinate, 672
	ble	printBy 		// prints every 32 by 32 border on the left

	mov	r4, #0 			// initialize r4 = 0
printBx:
	mov	r0, r4 			// r0 = r4
	mov	r1, #0 			// initialize r1 = 0
	ldr	r2, =borderUp 		// prints correct border for top side in a loop from (32, 0) to (992, 0)
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, r4 			// r0 = r4
	ldr	r1, =672 		// initialize r1 = 672
	ldr	r2, =borderDown 	// prints correct border for bottom side in a loop from (32, 672) to (992, 672)
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, r4 			// r0 = r4
	mov	r1, #704 		// initialize r1 = 704
	ldr	r2, =otherBrick 	// prints correct background for score side in a loop from (0, 704) to (992, 704)
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, r4 			// r0 = r4
	mov	r1, #736 		// initialize r1 = 736
	ldr	r2, =otherBrick 	// prints correct background for score side in a loop from (0, 736) to (992, 736)
	bl	DrawPhoto 		// print pixel of each corresponding colour

	add	r4, #32 		// r4 = r4 + 32
	ldr	r0, =992 		// r0 = 992
	cmp	r4, r0 			// continues to loop until max x coordinate, 992
	ble	printBx 		// prints every 32 by 32 border at the bottom

	mov	r0, #0 			// x coordinate = 0
	mov	r1, #0 			// y coordinate = 0
	ldr	r2, =conerLeftUp 	// load each pixel colour of the correct top left corner of the border
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #0 			// x coordinate = 0 			
	ldr	r1, =672 		// y coordinate = 672
	ldr	r2, =conerLeftDown 	// load each pixel colour of the correct bottom left corner of the border
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =992 		// x coordinate = 992
	ldr	r1, =672 		// y coordinate = 672
	ldr	r2, =conerRightDown	// load each pixel colour of the correct bottom right corner of the border
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =992 		// x coordinate = 992
	mov	r1, #0 			// y coordinate = 0
	ldr	r2, =conerRightUp	// load each pixel colour of the correct top right corner of the border
	bl	DrawPhoto 		// print pixel of each corresponding colour

	pop	{r4-r10, lr}
	bx	lr
	
	.global DrawLayoutOne

DrawLayoutOne:

	push	{r4-r10, lr}
	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =224 		// y coordinate = 224
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =256 		// y coordinate = 256
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =288 		// y coordinate = 288
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =480 		// x coordinate = 480
	ldr	r1, =288 		// y coordinate = 288
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =544 		// x coordinate = 544
	ldr	r1, =288 		// y coordinate = 288
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =352 		// y coordinate = 352
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =480 		// x coordinate = 480
	ldr	r1, =352 		// y coordinate = 352
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =544 		// x coordinate = 544
	ldr	r1, =352 		// y coordinate = 352
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =384 		// y coordinate = 384
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =512 		// x coordinate = 512
	ldr	r1, =416 		// y coordinate = 416
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

// DIAMOND

	ldr	r0, =480 		// x coordinate = 480
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =544 		// x coordinate = 544
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =448 		// x coordinate = 448
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =576 		// x coordinate = 576
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =256 		// x coordinate = 256
	ldr	r1, =192 		// y coordinate = 1192
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =256 		// x coordinate = 256
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =256 		// x coordinate = 256
	ldr	r1, =448 		// y coordinate = 448
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =768 		// x coordinate = 768
	ldr	r1, =192 		// y coordinate = 192
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =768 		// x coordinate = 768
	ldr	r1, =448 		// y coordinate = 448
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =576 		// x coordinate = 576
	ldr	r1, =288 		// y coordinate = 288
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =544 		// x coordinate = 544
	ldr	r1, =256 		// y coordinate = 256
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =480 		// x coordinate = 480
	ldr	r1, =256 		// y coordinate = 256
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =448 		// x coordinate = 448
	ldr	r1, =288 		// y coordinate = 288
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =480 		// x coordinate = 480
	ldr	r1, =384 		// y coordinate = 384
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =448 		// x coordinate = 448
	ldr	r1, =352 		// y coordinate = 352
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =576 		// x coordinate = 576
	ldr	r1, =352 		// y coordinate = 352
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =544 		// x coordinate = 544
	ldr	r1, =384 		// y coordinate = 384
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =608 		// x coordinate = 608
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	ldr	r0, =416 		// x coordinate = 416
	ldr	r1, =320 		// y coordinate = 320
	ldr	r2, =brick 		// load each pixel colour of the white chocolate brick
	bl	DrawPhoto 		// print pixel of each corresponding colour

	pop	{r4-r10, lr}
	bx	lr

	
