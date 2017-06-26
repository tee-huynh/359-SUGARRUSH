.section .text

	.global initInterrupt
initInterrupt:
	// set 30 secs fro the value pack to appear
	ldr	r2, =30000000
	ldr	r1, =0x20003004
	ldr	r0, [r1]
	add	r1, r0, r2
	ldr	r0, =0x20003010
	str	r1, [r0]	

	// enable IRQ Interrupt
	mrs	r1, cpsr
	bic	r1, #0x80
	msr 	cpsr_c, r1

	// set IRQ Pending 1
	ldr	r0, =0x2000B210
	ldr	r1, [r0]
	orr	r1, #0x2
	str	r1, [r0]
	bx	lr

	.global InstallIntTable
InstallIntTable:
	ldr	r0, =IntTable
	mov	r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov	r0, #0xD2
	msr	cpsr_c, r0
	mov	sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov	r0, #0xD3
	msr	cpsr_c, r0
	mov	sp, #0x8000000

	bx	lr	

	.global	disableInterrupt
disableInterrupt:
	// disable IRQ Interrupt
	push	{r0-r12, lr}
	mrs	r1, cpsr
	orr	r1, #0x80
	msr 	cpsr_c, r1
	pop	{r0-r12, lr}
	bx	lr

	.global	enableInterrupt
enableInterrupt:
	push	{r0-r12, lr}
	// enable IRQ Interrupt
	mrs	r1, cpsr
	bic	r1, #0x80
	msr 	cpsr_c, r1
	pop	{r0-r12, lr}
	bx	lr

irq:
	push	{r0-r12, lr}
	
	mrs	r1, cpsr
	orr	r1, #0x80
	msr 	cpsr_c, r1

	// test if there is an interrupt pending in IRQ Pending 1
	ldr	r0, =0x2000B204
	ldr	r1, [r0]
	tst	r1, #2		
	beq	irqEnd

	// clearing IRQ Pending 1
	ldr	r0, =0x2000B204
	ldr	r1, [r0]
	bic	r1, #2	
	str	r1, [r0]

	ldr	r0, =valuepack
	bl	r0ndomPhoto

	// set 30 secs fro the value pack to appear
	ldr	r2, =30000000
	ldr	r1, =0x20003004
	ldr	r0, [r1]
	add	r1, r0, r2
	ldr	r0, =0x20003010
	str	r1, [r0]

	//setting c1 to disable on cs
	ldr	r0, =0x20003000
	ldr	r1, [r0]
	orr	r1, #0x2
	str	r1, [r0]

irqEnd:	
	ldr	r0, =0x20003000
	ldr	r1, [r0]
	str	r1, [r0]
	pop	{r0-r12, lr}
	subs	pc, lr, #4

.section .data

IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word haltLoop$
swi_handler:		.word haltLoop$
prefetch_handler:	.word haltLoop$
data_handler:		.word haltLoop$
unused_handler:		.word haltLoop$
irq_handler:		.word irq
fiq_handler:		.word haltLoop$

