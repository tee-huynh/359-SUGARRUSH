.section .text

	.global initGameMap
initGameMap:
	push	{r4-r10, lr}
restartAgain:
	bl	startMenu		// print startMenu
game:
	bl 	vid			// print game map
	bl	initArr0y		// initialize the snake
	ldr	r0, =candy
	bl	r0ndomPhoto		// print a random candyoio
	mov	r10, #0			// candy counter
	mov	r0, r10			// set the score = 0
	bl	updateScore
	mov	r0, #3			// set the live = 3
	bl	updateLive
	bl	printCandyLives		// print the score
	bl	printSnakeLives		// print the snake lives
	mov	r9, #0			// set the flag of Bonanza = 0
	ldr 	r0, =setBonanza
	mov	r1, #0
	str	r1, [r0]	
	ldr 	r0,=door		// the flag for the door to false 
	str 	r1,[r0]
	bl	initInterrupt		// initialize the interrupt
gameloop:
	bl	Snes
	mov	r8, r0		

	cmp	r8, #4			// check if teh user press start
	bne	direct			// if not go to direct
	bl	pauseMenu		// else, display pause menu
	mov	r7, r0
	ldr	r0, =200000		// load the wait value
	bl	Wait			// wait
	bl	enableInterrupt		// enable interrupt

	cmp	r7, #0			// if the user choose to restart
	bne	userquit
	bl	disableInterrupt	// disable interrupt
	b	game			// go to game
userquit:
	cmp	r7, #1
	bne	checkr2			// if the user choose to quit
	bl	disableInterrupt	// disable interrupt
	bl	clearArray		// go to main menu
	b	restartAgain
checkr2:
	cmp 	r7, #2
	bne	direct			// if the user choose to continue
	bl	DrawLayoutOne		// redraw the bricks
	ldr	r0, =100000		// load the wait time
	bl	Wait			// wait
direct:
	mov	r0, r8
	bl	getDirection		// get the direction from the controller

	bl	checkCollision		// branch to checkCollsion
	mov	r5, r1			// if r1 = 1, snake ate a candy
	mov	r6, r0			// if r0 = 1, collision
	mov	r7, r2			// if r2 = 1, snake went to the door
	
	cmp	r3, #1			// check if snake eat the value pack
	movne	r9, #4
	bne	checK			// if not move on
	bl	getScore		// get the score
	add	r0, #5			// add 5 to the score 
	bl	updateScore		// update the score
	bl	printCandyLives		// print the score
	bl	pickValuePack		// pick a value pack
	cmp	r0, #1			// check if candy thief is set
	bne	checK			// if it is not skip
	mov	r0, r10
	mov	r1, #2			// if it is divide the candy counter to half
	bl	division
	mov	r10, r2	
checK:
	cmp	r5, #1			// check if the snake ate a candy
	bne	checkForCollision	// if not move on to checkD
	bl	insertBody		// increase the size of the snake by 1
	add	r10, #1			// candy counter++
	bl	getScore		// add 1 to the score
	add	r0, #1			
	bl	updateScore		// update the score
	bl	printCandyLives		// print the score 
checkForCollision:
	cmp	r6, #1			// check for collision
	bne	noCollision		// if there's none, go to noCollision
	bl	clearArray		// if there is, clear the snake
	bl	initArr0y		// initialize the snake
	bl	Move			// draw the snake
	bl	getLive			// get the # of lives of the snake left
	sub	r0, #1			// snake live = snake live - 1
	bl	updateLive		// update the snake live
	bl	printSnakeLives 	// print the snake live
	bl	gameloop		// go back to gameloop
noCollision:
	cmp	r7, #1			// check if the snake went to the door
	bne	checkLose
	bl	clearArray		// clear the snake
	bl	disableInterrupt
	bl	winner			// if it did, set winner flag = true
	b	restartAgain		// go back to main menu
checkLose:
	bl	getLive			// get the snake lives
	cmp	r0, #0			// check if it is 0
	bne	checkD			// if not skip
	bl	clearArray		// clear the snake
	bl	disableInterrupt
	bl	loser			// if it is, set the loser flag = true
	b	restartAgain		// go back to main menu
checkD:
	ldr	r0, =door		// check if the door flag is set
	ldr	r1, [r0]
	cmp	r1, #0			// if not skip
	bne	checkNext

	cmp 	r10,#25			// check if the # of candies = 25
	bne	checkNext		// if not go to checkNext	
	ldr	r0, =door		// if it is, print a random door
	mov	r1, #1
	str	r1, [r0]		// set the flag to false
	ldr	r0, =doorRight
	bl	r0ndomPhoto		
	mov	r10, #0
checkNext:
	ldr	r4, =state		// load the state struct address
	ldr	r0, [r4, #48]		// load delta x
	ldr	r1, [r4, #52]		// load delta y
	bl	shiftArr0y		// shift the snake based on these

	bl	Move			// draw the snake

	cmp	r5, #1			// check if a candy is eaten
	bne	skipit
	ldr	r0, =setBonanza		// cehck if the bonanza flag is on
	ldr	r1, [r0]
	cmp	r1, #0			// check if candy bonanza is set
	ble	printCandies		// if not print more candies
	sub	r1, #1			// # of candies in bonanza - !
	str	r1, [r0]		// store it back
	b	skipit
printCandies:
	ldr	r0, =candy		
	bl	r0ndomPhoto		// print a random candy
skipit:
	ldr	r0, [r4, #8]		// load the velocity value
	bl	Wait			// set the velocity of the snake

	b	gameloop		// loop again

	pop 	{r4-r10, lr}
	bx 	lr

	.global getDirection
getDirection:
	push 	{r4-r10,lr}
	mov	r4, r0
	ldr 	r5,=state
	mov 	r4,r0			// Move return value for comparison
	mov 	r1,#1 			// For setting direction flags
	mov 	r2,#0 			// For clearing direction flags
button_up:
	cmp 	r4,#5 			// check if clock cycle = 5
	bne 	button_down		// if not go to button_down
	ldr	r3,[r5,#40]		// load no up
	cmp	r3, #0			// check if it is set, if not
	bne	button_down		// go to button_down
	str 	r1,[r5,#44] 		// set the no down flag	
	str 	r1,[r5,#24] 		// set the up flag
	str 	r2,[r5,#16] 		// clear the left flag
	str 	r2,[r5,#20] 		// clear the right flag
	str 	r2,[r5,#28] 		// clear the down flag
	str 	r2,[r5,#32] 		// clear the no left flag
	str 	r2,[r5,#36] 		// clear the no right flag

	b 	doneDirection		
button_down:
	cmp 	r4,#6 			// check if clock cycle = 6
	bne 	button_left		// if not go to button_left
	ldr	r3,[r5,#44]		// load no down
	cmp	r3, #0			// check if it is set, if not
	bne	button_left		// go to button_left
	str 	r1,[r5,#40] 		// set the no up flag	
	str 	r1,[r5,#28] 		// set the down flag
	str 	r2,[r5,#16] 		// clear the left flag
	str 	r2,[r5,#20] 		// clear the right flag
	str 	r2,[r5,#24] 		// clear the up flag
	str 	r2,[r5,#32] 		// clear the no left flag
	str 	r2,[r5,#36] 		// clear the no right flag

	b 	doneDirection
button_left:
	cmp 	r4,#7 			// check if clock cycle = 7
	bne 	button_right		// if not go to button_right
	ldr	r3,[r5,#32]		// load no left
	cmp	r3, #0			// check if it is set, if not
	bne	button_right		// go to button_roght
	str 	r1,[r5,#36] 		// set the no right flag
	str 	r1,[r5,#16] 		// set the left flag
	str 	r2,[r5,#20] 		// clear the right flag
	str 	r2,[r5,#24] 		// clear the up flag
	str 	r2,[r5,#28] 		// clear the down flag
	str 	r2,[r5,#40] 		// clear the no up flag
	str 	r2,[r5,#44] 		// clear the no down flag
	b 	doneDirection	
button_right:
	cmp 	r4,#8 			// check if clock cycle = 8
	bne 	doneDirection		// if not go to doneDirection
	ldr	r3,[r5,#36]		// load no right
	cmp	r3, #0			// check if it is set, if not
	bne	doneDirection		// go to doneDirection
	str	r1,[r5,#32] 		// set the no right flag
	str 	r1,[r5,#20] 		// set the right flag
	str 	r2,[r5,#16] 		// clear the left flag
	str 	r2,[r5,#24] 		// clear the up flag
	str 	r2,[r5,#28] 		// clear the down flag
	str 	r2,[r5,#40] 		// clear the no up flag
	str 	r2,[r5,#44] 		// clear the no down flag
doneDirection:
	bl	getCoordinates
	
	pop	{r4-r10, lr}
	bx 	lr


	.global getCoordinates
getCoordinates:
	push 	{r4-r10,lr}
	ldr 	r5,=state
	ldr 	r1,[r5,#16]		// left flag
	ldr 	r2,[r5,#20] 		// right flag
	ldr 	r3,[r5,#24] 		// up flag
	ldr 	r4,[r5,#28] 		// down flag
	ldr 	r6,[r5,#48]		// delta x
	ldr 	r7,[r5,#52] 		// delta y

check_l:
	cmp 	r1,#1
	bne 	check_r
	mov 	r0,#-1 			// change in x value when moving left
	str 	r0,[r5, #48] 		// store value in delta x for move subroutine
	mov 	r0,#0 			// change in y value when moving left
	str 	r0,[r5, #52] 		// store value in delta y for move subroutine
	b 	doneCoordinates
check_r:
	cmp 	r2,#1
	bne 	check_u
	mov 	r0,#1 			// change in x value when moving left
	str 	r0,[r5, #48] 		// store value in delta x for move subroutine
	mov 	r0,#0 			// change in y value when moving left
	str 	r0,[r5, #52] 		// store value in delta y for move subroutine
	b 	doneCoordinates
check_u:
	cmp 	r3,#1
	bne 	check_d
	mov 	r0,#0 			// change in x value when moving left
	str 	r0,[r5, #48] 		// store value in delta x for move subroutine
	mov 	r0,#-1 			// change in y value when moving left
	str 	r0,[r5, #52] 		// store value in delta y for move subroutine
	b 	doneCoordinates
check_d:
	cmp 	r4,#1
	bne 	doneCoordinates
	mov 	r0,#0 			// change in x value when moving left
	str 	r0,[r5, #48] 		// store value in delta x for move subroutine
	mov 	r0,#1 			// change in y value when moving left
	str 	r0,[r5, #52] 		// store value in delta y for move subroutine
	b 	doneCoordinates
doneCoordinates:
	pop	{r4-r10, lr}
	bx 	lr

	.global	calculateOffset
calculateOffset:
	push	{r4-r10, lr}
	mov	r4, #8			// mov 8 to r4
	mul	r0, r4			// index *8
	ldr	r5, =snakeAddress	// load the base address 
	add	r0, r5			// r0 = index * 8 + base address
	pop	{r4-r10, lr}
	bx	lr

	.global	initArr0y
initArr0y:
	push	{r4-r10, lr}	
	
	mov	r4, #4			
	ldr	r0, =state		// load the state struct
	str	r4, [r0, #12]		// set the length = 4

	mov	r4, #1			
	str	r4, [r0, #16]		// set the left flag to 1
	str	r4, [r0, #36]		// set the no roght flag to 1

	mov	r4, #0
	str	r4, [r0, #20]		// set the right flag to 0
	str	r4, [r0, #24]		// set the up flag to 0
	str	r4, [r0, #28]		// set the down flag to 0
	str	r4, [r0, #32]		// set the no left flag to 0
	str	r4, [r0, #40]		// set the no up flag to 0
	str	r4, [r0, #44]		// set the no down flag to 0
	
	mov	r4, #864		
	str	r4, [r0]		// set x = 864
	mov	r4, #352
	str	r4, [r0, #4]		// set y = 352
	ldr	r4, =75000
	str	r4, [r0, #8]		// set velocity = 75000
	mov	r4, #0
	str	r4, [r0, #56]

	ldr	r5, =state		// load the state struct 
	ldr	r1, [r5]		// load head.x 
	ldr	r2, [r5, #4]		// load head.y
	ldr	r5, =snakeAddress	// laod the snake address
	str	r1, [r5], #4		// storing the address of the head in the arr0y
	str	r2, [r5], #4
		
	add	r1, #32			// head.x = head.x + 32
	str	r1, [r5], #4		// storing the address of the body in the arr0y
	str	r2, [r5], #4

	add	r1, #32			// head.x = head.x + 32
	str	r1, [r5], #4		// storing the address of the tail in the arr0y
	str	r2, [r5], #4

	add	r1, #32			// head.x = head.x + 32
	str	r1, [r5], #4		// storing the address of the clearing box in the arr0y
	str	r2, [r5], #4

	pop	{r4-r10, lr}
	bx	lr

	.global	clearArray
clearArray:
	push	{r4-r10, lr}
	ldr	r0, =300000		// load the wait value
	bl	Wait			// set the wait
	ldr	r0, =state		// load the state struct
	ldr	r10, [r0, #12]		// load the length
	mov	r9, #0			// counter = 0
	mov	r4, #32			// r4 = 32
topClear:
	cmp	r9, r10			// check if counter < length
	bge	clearState		// if not break the loop
	mov	r0, r9			// r0  = counter
	bl	calculateOffset		// calculate the offset of the counter
	mov	r2, r0			
	ldr	r0, [r2]		// load the [piece].x
	ldr	r1, [r2, #4]		// load the [piece].y
	ldr	r2, =0x97FF		// load the background colour
	bl	DrawBox			// draw the box at this position
	add	r9, #1			// counter++
	b	topClear
clearState:
	pop	{r4-r10, lr}
	bx	lr

	.global	shiftArr0y
shiftArr0y:
	push	{r4-r10, lr}
	ldr	r4, =state		// load the state struct address
	ldr	r10, [r4, #12]		// loading the length
	sub	r10, #1			// to get index of the clearing box
	mov	r5, r0			// preserving the parameters
	mov	r6, r1			
update:
	cmp	r10, #0			// check if the length is 0 
	beq	updateHead		// if it is go to updateHead
	mov	r0, r10			// r0 = length
	bl	calculateOffset		// calculate the offset of the length
	sub	r1, r0, #8		// subtr0ct 8 from the calculated offset to get x of length-1
	ldr	r7, [r1]		// load the value of x in pos[length -1]
	str	r7, [r0]		// store the x to pos[length]
	sub	r1, r0, #4		// subtr0ct 4 from the calculated offset to get y of length-1
	ldr	r7, [r1]		// load the value of y in pos[length -1]
	str	r7, [r0, #4]		// store the y to pos[length]	
	
	sub	r10, #1			// length = length-1
	b	update
updateHead:
	mov	r0, #0			
	bl	calculateOffset		
	mov	r7, r0			// getting the head.x offset

	add	r8, r7, #4	
	mov	r0, #32			// getting the head.y offset

	ldr	r9, [r7]		// loading the x head
	mul	r5, r0			// delta x * 35
	add	r9, r5			// r9 = add x + delta x
	str	r9, [r7]		// update the x head

	ldr	r9, [r8]		// loading the y head
	mul	r6, r0			// delta y * 35
	add	r9, r6			// r9 = add y + delta y
	str	r9, [r8]		// update the y head

	pop	{r4-r10, lr}
	bx	lr

	.global checkCollision
checkCollision:
	push	{r4-r10, lr}
	ldr 	r4,=state
	mov	r0, #32			// r0 = 32
	ldr 	r6,[r4,#48]		// load delta x
	ldr 	r7,[r4,#52] 		// load delta y
	ldr	r5, =snakeAddress	// load the snake address
	ldr	r8, [r5], #4		// load head.x
	ldr	r9, [r5]		// load head.y
	mul	r6, r0			// delta x * 32
	mul	r7, r0			// delta y * 32
	add	r6, r8               	// delta x + x
	add	r7, r9			// delta y + y

	mov	r0, r6			
	mov	r1, r7
	bl	CheckBox		// check for collision at this xy 
	cmp	r0, #0			// if there is no collision
	moveq	r1, #0			// set r1 = 0
	moveq	r2, #0			// set r2 = 0
	mov	r3, #0
	beq	doneChecking		// and go to doneChecking
	
	mov	r0, r6			
	mov	r1, r7
	ldr	r2, =candy
	bl	checkForPhoto		// check for candy at this xy 
	cmp	r0, #0			
	bne	checkDoor		// if there is none go to checkDoor
	moveq	r1, #1			// set r1 if the snake eats a candy
	movne	r1, #0			// set r1 = 0 if the snake does not eat a candy
	mov	r2, #0			// set r2 = 0, no door
	mov	r3, #0			// set r3 = 0, value pack
	b	doneChecking
checkDoor:
	mov	r0, r6			
	mov	r1, r7
	ldr	r2, =doorRight
	bl	checkForPhoto		// check for door at this xy 
	cmp	r0, #0			// if there is a door
	bne	checkValuePack
	moveq	r2, #1			// set r2 = 1 to indicate that the snake went to the door	
	mov	r1, #0			// set r1 = 0, no candy
	mov	r3, #0			// set r3 = 0
	b	doneChecking
checkValuePack:
	mov	r0, r6			
	mov	r1, r7
	ldr	r2, =valuepack	
	bl	checkForPhoto		// check for value pack at this xy 
	cmp	r0, #0			// if there is a door
	moveq	r3, #1			// set r3 = 1
	mov	r1, #0			// set r1 = 0, no candy
	mov	r2, #0			// set r1 = 0, no collision
doneChecking:
	pop	{r4-r10, lr}
	bx	lr

.section .data	

	.global	snakeAddress
snakeAddress:
	.word	x, y
x:
	.rept	256
	.word	0
	.endr
y:
	.rept	256
	.word	0
	.endr

	.global	setBonanza
setBonanza:
	.int 0

	.global score
score:
	.int 0

	.global lives
lives:
	.int 0
	
	.global door
door:
	.int 0

	.global state
	.align 2
state:
	.int 864		//h_x OFFSET = 0
	.int 352		//h_y OFFSET = 4
	.int 75000		//vel OFFSET = 8
	.int 4			//length OFFSET = 12	
	.int 1			//left 	 OFFSET = 16
	.int 0			//right	 OFFSET = 20
	.int 0 			//up	 OFFSET = 24
	.int 0 			//down   OFFSET = 28	
	.int 0 			//n_left OFFSET = 32	
	.int 1 			//n_rightOFFSET = 36	
	.int 0 			//n_up	 OFFSET = 40
	.int 0 			//n_down OFFSET = 44
	.int 0 			//deltaX OFFSET = 48
	.int 0 			//deltaY OFFSET = 52
