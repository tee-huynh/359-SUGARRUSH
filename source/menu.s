.section .text
	.global startMenu
startMenu:
	push	{r4-r10, lr}
gameMenuStart:
	ldr	r2, =startmenu			// load the photo of start menu
	bl	changeBackground		// change the background
gameMenuStartLoop:
	bl	Snes				// ask the user for input
	mov	r4, r0				// r4 = input frm the controller
	cmp	r4, #6				// check if the input is Down
	beq	gameMenuStory			// if it is, go to gameMenuStory
	cmp	r4, #9				// if not check if the input is A
	beq	start				// if it is, go to start
	
	b	gameMenuStartLoop		// else, ask for input again
gameMenuStory:
	ldr	r2, =storymenu			// load the photo of story menu
	bl	changeBackground		// change the background
gameMenuStoryLoop:
	bl	Snes				// ask the user for input
	mov	r4, r0				// r4 = input frm the controller
	cmp	r4, #6				// check if the input is Down
	beq	gameMenuQuit			// if it is, go to gameMenuQuit
	cmp	r4, #5				// if not check if it is Up
	beq	gameMenuStart			// if it is, go to gameMenuStart
	cmp	r4, #9				// if not check if the input is A	
	beq	story				// if it is, go to story

	b	gameMenuStoryLoop		// else, ask for input again
gameMenuQuit:
	ldr	r2, =quitmenu			// load the photo of quit menu
	bl	changeBackground		// change the background
gameMenuQuitLoop:
	bl	Snes				// ask the user for input
	mov	r4, r0				// r4 = input frm the controller
	cmp	r4, #5				// if not check if it is Up
	beq	gameMenuStory			// if it is, go to gameMenuStory
	cmp	r4, #9				// if not check if the input is A	
	beq	quit				// if it is, go to quit

	b	gameMenuQuitLoop		// else, ask for input again
story:
	ldr	r2, =storyPhoto			// load the photo of story menu
	bl	changeBackground		// change the background
askAgain:
	bl	Snes				// ask for input from the user
	mov	r4, r0
	
	cmp	r4, #1				// ask again until they press B
	beq	gameMenuStart

	b	askAgain
quit:
	mov	r2, #0
	bl	Background
	bl	haltLoop$			// loop forever
start:						
	pop	{r4-r10, lr}
	bx	lr

	.global	loser
loser:
	push	{r4-r10, lr}
	ldr	r2, =lose2			// load address of loser photo2 
	bl	changeBackground		// print the loser photo2
loseLoop:	
	bl	Snes				// ask for any user input
	mov	r4, r0				// to quit the loop
	cmp	r4, #0				
	beq	loseLoop			 

	pop	{r4-r10, lr}
	bx	lr

	.global	winner
winner:
	push	{r4-r10, lr}
	ldr	r2, =win2			// load address of winner photo2 
	bl	changeBackground		// print the winner photo2
winLoop:	
	bl	Snes				// ask for any user input
	mov	r4, r0				// to quit the loop
	cmp	r4, #0
	beq	winLoop

	pop	{r4-r10, lr}
	bx	lr

	.global	pauseMenu
pauseMenu:
	push	{r4-r10, lr}
	bl	disableInterrupt		// disable interrupt
printPauseBox:
	mov	r0, #448
	mov	r1, #288
	ldr	r2, =pause1			// draw the pause menu on the screen
	bl	DrawPause	

	ldr	r0, =200000			// load the wait value
	bl	Wait				// wait
restartLoop:
	bl	Snes				// ask the user for input
	mov	r4, r0				// r4 = input frm the controller
	cmp	r4, #6				// check if the input is Down
	beq	quitPM				// if it is, go to quit
	cmp	r4, #9				// if not check if the input is A	
	moveq	r0, #0				// if it is, go to 
	beq	breakLoop
	cmp 	r4, #4				// check if the input is Start
	beq 	resume				// if it is, resume game

	ldr	r0, =100000			// load the wait value
	bl	Wait				// wait
	b	restartLoop			// else, ask for input again
quitPM:
	mov	r0, #448
	mov	r1, #288
	ldr	r2, =pause2			// draw the pause menu on the screen
	bl	DrawPause	
	ldr	r0, =200000			// load the wait value
	bl	Wait				// wait
quitLoop:
	bl	Snes				// ask the user for input
	mov	r4, r0				// r4 = input frm the controller
	cmp	r4, #5				// check if the input is Up
	beq	printPauseBox			// if it is, go to restartLoop
	cmp	r4, #9				// if not check if the input is A	
	moveq	r0, #1				// if it is, go to startMenu
	beq	breakLoop
	cmp 	r4, #4				// check if the input is Start
	beq 	resume				// if it is, resume game
	
	ldr	r0, =100000			// load wait value
	bl	Wait				// wait
	b	quitLoop			// else, ask for input again
resume:
	mov 	r0, #2
breakLoop:					// if r0 = 0, start over the game
						// if r0 = 1, quit game
						// if r0 = 2, resume game
	pop	{r4-r10, lr}	
	bx	lr


