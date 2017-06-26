.section .text

.global	candyThief
candyThief:
	push	{r4-r10, lr}

	bl	getScore		// get the current score
	mov	r1, #2			// score / 2
	bl	division 		// call division
	mov	r0, r2 			// r0 = r2
	bl	updateScore		// current score = score / 2
	bl	printCandyLives		// print the score 

	pop	{r4-r10, lr}
	bx	lr

	.global	candyThiefIcon
candyThiefIcon: 			// prints words candy thief to signal user of the type of value pack picked
	push	{r4-r10, lr}

	mov	r0, #768 		// x coordinate of candy thief icon
	mov	r1, #704 		// y coordinate of candy thief icon
	ldr	r2, =ca 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #800 		// x coordinate of candy thief icon
	mov	r1, #704 		// y coordinate of candy thief icon
	ldr	r2, =nd 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #832 		// x coordinate of candy thief icon
	mov	r1, #704 		// y coordinate of candy thief icon
	ldr	r2, =y 			// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #864 		// x coordinate of candy thief icon
	mov	r1, #704 		// y coordinate of candy thief icon
	ldr	r2, =th 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #896 		// x coordinate of candy thief icon
	mov	r1, #704 		// y coordinate of candy thief icon
	ldr	r2, =ief 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour
	
	pop	{r4-r10, lr}
	bx	lr

	.global	candyBonanza
candyBonanza:
	push	{r4-r10, lr}		
	ldr	r0, =candy 		// prints 4 more candies in random locations
	bl	r0ndomPhoto
	ldr	r0, =candy
	bl	r0ndomPhoto
	ldr	r0, =candy
	bl	r0ndomPhoto
	ldr	r0, =candy
	bl	r0ndomPhoto
	pop	{r4-r10, lr}
	bx	lr

	.global pickValuePack
pickValuePack:
	push	{r4-r10, lr}	
	ldr 	r2, =0x20003004		// r0 = CLO address
	ldr 	r4, [r2]		// load the clock 
	mov	r5, #4			// r5 = 4
	mov	r0, r4			// r0 = r4	
	mov	r1, r5 			// r1 = r5
	bl	division		// call division
	add	r0, #1			// returns 1 or 2 

	cmp	r0, #1 			// if r0 = 1, then candy thief was picked
	bne	checkBonanza 		// if not, then branch to checkBonanza to see if something else was picked
	bl	candyThief		// go to candyThief
	bl	candyThiefIcon		// display the description 
	mov	r0, #1 			// r0 = 1
	b	doneValuePack	 	// branch to doneValuePack
checkBonanza:
	cmp	r0, #2 			// if r0 = 2, then candy bonanza was picked
	bne	checkEmpty 		// if not, then branch to checkEmpty to see if something else was picked
	bl	candyBonanza 		// go to candyBonanza
	bl	candyBonanzaIcon 	// display the description
	mov	r1, #4 			// r1 = 4 which is the number of random candies that will spawn
	ldr	r0, =setBonanza 	// setting candyBonanza flag to be true
	str	r1, [r0]
	mov	r0, #0 			// r0 = 0
	b 	doneValuePack 		// branch to doneValuePack

checkEmpty:
	cmp 	r0,#3 			// if r0 = 3, then empty was picked
	bne 	checkLifeSaver 		// if not, then branch to checkLiveSaver to see if life saver was picked
	bl 	emptyIcon 		// display the description
	mov	r0, #0 			// r0 = 0
	b 	doneValuePack 		// branch to doneValuePack

checkLifeSaver:
	cmp 	r0,#4 	 		// if r0 = 4, then life saver was picked
	bne 	doneValuePack 		// if not, then branch to doneValuePack
	ldr 	r0,=lives 		// load the lives 
	ldr 	r1,[r0]
	add 	r1,#1 			// add one life
	str 	r1,[r0]
	bl 	printSnakeLives 	// print the new snake lives
	bl 	lifeSaverIcon 		// display the description
	mov	r0, #0	 		// r0 = 0
doneValuePack:
	pop	{r4-r10, lr}
	bx	lr


	.global emptyIcon
emptyIcon:
	push	{r4-r10, lr}
	
	mov	r0, #768 		// x coordinate of empty icon
	mov	r1, #704 		// y coordinate of empty icon
	ldr	r2, =em			// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #800 		// x coordinate of empty icon
	mov	r1, #704 		// y coordinate of empty icon
	ldr	r2, =pt 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #832 		// x coordinate of empty icon
	mov	r1, #704 		// y coordinate of empty icon
	ldr	r2, =ytwo 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #864 		// x coordinate of empty icon
	mov	r1, #704 		// y coordinate of empty icon
	ldr	r2, =lo 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #896 		// x coordinate of empty icon
	mov	r1, #704 		// y coordinate of empty icon
	ldr	r2, =l 			// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	pop	{r4-r10, lr}
	bx	lr	


	.global	candyBonanzaIcon
	
candyBonanzaIcon:

	push	{r4-r10, lr}

	mov	r0, #768 		// x coordinate of candy bonanza icon
	mov	r1, #704 		// y coordinate of candy bonanza icon
	ldr	r2, =can		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #800 		// x coordinate of candy bonanza icon
	mov	r1, #704 		// y coordinate of candy bonanza icon
	ldr	r2, =dy 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #832 		// x coordinate of candy bonanza icon
	mov	r1, #704 		// y coordinate of candy bonanza icon
	ldr	r2, =bon 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #864 		// x coordinate of candy bonanza icon
	mov	r1, #704 		// y coordinate of candy bonanza icon
	ldr	r2, =anz 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #896 		// x coordinate of candy bonanza icon
	mov	r1, #704 		// y coordinate of candy bonanza icon
	ldr	r2, =atwo 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour
	
	pop	{r4-r10, lr}
	bx	lr


lifeSaverIcon:
	push	{r4-r10, lr}

	mov	r0, #768 		// x coordinate of life saver icon
	mov	r1, #704 		// y coordinate of life saver icon
	ldr	r2, =lif		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #800 		// x coordinate of life saver icon
	mov	r1, #704 		// y coordinate of life saver icon
	ldr	r2, =eend 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #832 		// x coordinate of life saver icon
	mov	r1, #704 		// y coordinate of life saver icon
	ldr	r2, =sa 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #864 		// x coordinate of life saver icon
	mov	r1, #704 		// y coordinate of life saver icon
	ldr	r2, =ve 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour

	mov	r0, #896 		// x coordinate of life saver icon
	mov	r1, #704 		// y coordinate of life saver icon
	ldr	r2, =rend 		// load each pixel of the 32 by 32 picture to print
	bl	DrawPhoto 		// print pixel of each corresponding colour
	
	pop	{r4-r10, lr}
	bx	lr
	
