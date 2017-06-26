.section    .init
.globl     _start

_start:
    b       main
    
.section .text
main:
	bl	InstallIntTable	 	// installs interrupt table
	bl	EnableJTAG 		// enable JTAG
	bl	InitFrameBuffer 	// initialize frame buffer
	bl	initGameMap	  	// initialize game map and starts the game

	.global	haltLoop$
haltLoop$:
	b		haltLoop$


