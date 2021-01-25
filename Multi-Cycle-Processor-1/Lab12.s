	b Reset		@address 0x000
	b Undef		@address 0x004
	b SWI			@address 0x008
gap1:	.space 0x00C
	b IRQ			@address 0x018
gap2:	.space 0x024
Reset:			@ address 0x040
	mov r10, #0x10	@a constant for address generation
	mov sp, r10, LSL #6	@initialise supervisor sp to 0x400
	mov r0, #1
	sub sp, sp, #4
	str r0, [sp]	@push #1 in supervisor stack
	mov r0, #2
	sub sp, sp, #4
	str r0, [sp] 	@push #2 in supervisor stack
	mov r1, r10,LSL #5 	@generate address 0x200 in supervisor area
	mov r2, r10,LSL #7	@generate address 0x800 in data area
	mov r0, #3
	str r0, [r1] 	@store #3 in supervisor data area
	mov r0, #4
	str r0, [r2] 	@store #4 in user data area
	ldr r0, [r1] 	@read from supervisor data area
	ldr r0, [r2] 	@read from user data area
	mov r0, #0x10
	msr cpsr, r0		@set user mode with all flags clear and IRQ enabled
	b User
Undef:	ldr r0, [sp]
	add sp, sp, #4 	@pop from supervisor stack
	movs pc, lr
SWI:	ldr r0, [sp]
	add sp, sp, #4  @pop from supervisor stack
	movs pc, lr
IRQ:	ldr r0, [r2]
	add r0, r0, #1
	str r0, [r2] 	@increment user data
	mrs r0, spsr
	orr r0, r0, #0x80
	msr spsr, r0	@disable IRQ in spsr
	movs pc, lr
gap3:	.space 0x340
User:				@address #400
	mov sp, r10, LSL #8	@initialise user sp to 0x1000
	mov r0, #0x13
	msr cpsr, r0	@make an attempt to change to supervisor mode
	mov r0, #5
	sub sp, sp, #4
	str r0, [sp]	@push #5 in user stack
	mov r0, #6
	sub sp, sp, #4
	str r0, [sp] 	@push #6 in user stack
	ldr r0, [r1]
	add r0, r0, #1
	str r0, [r1] 	@attempt modifying supervisor data 
	ldr r0, [r2]
	add r0, r0, #1
	str r0, [r2] 	@modify user data
	bl F
L:	ldr r0, [r2]	@check if user data incremented by IRQ
	b L			@wait for IRQ
F: 	ldr r0, [sp]	@check top of stack
	bx r0			@an instruction that is not implemented
	ldr r0, [sp]	@check top of stack
	swi 0			@software interrupt
	ldr r0, [sp]	@check top of stack
	mov pc,lr		@check return addresses not mixed up
	.end

