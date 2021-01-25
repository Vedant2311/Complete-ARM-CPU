Program5:
;; Demo for Lab 9 - Load Store
@@@ Find sum of array elements
	.text
@ Writing to the array
	mov r1, #1
	mov r2, #100		@ Starting address of the array
Lab1:
	str r1, [r2, #0]		@ Stores i at array[i]
	add r2, r2, #4		@ Pointing to next element 
	add r1, r1, #1
	cmp r1, #11		@ Loop termination check
	bne Lab1

@ Reading from the array
	mov r3, #0			@ Initialize sum
	mov r2, #100		@ Initialize address pointer
Lab2:
	sub r1, r1, #1
	cmp r1, #0			@ Loop termination check
	beq Over
	ldr r4, [r2, #0]		@ array[i] is read
	add r3, r3, r4		@ Add to the sum
	add r2, r2, #4		@ Pointing to next element 
	b Lab2
Over:
	mov r0, #0xf000000e
	mov r1, #1
	mov r2,#200
	str r0, [r2,#0]
   	//read r4//
	add r2, r2 ,#4
	strb r0, [r2,#0]
	add r2, r2 ,#4
	strh r0, [r2,#0]
	sub r2, r2, #8
	//write r4//
	ldr r3, [r2,#0]
	sub r2, r2, #4
	ldr r8, [r2,#4]
	add r2,r2,#4
	ldrsb r4, [r2,#0]
	ldrh r5, [r2,#0]
	ldrsh r7, [r2,#0]
	ldrb r6, [r2,r1, LSL #2]

	mov r1, #15
	mvn r2, #43 
	mov r3, #20
	movs r4, #49 
	mov r5, r4
	mov r6, #5
	ands r0,r3,r6, LSR #1
	eors r0,r1,#15 
	adc r0,r3,#200 
	tst r3, r3, ROR #20 
	rsb r0,r1,r0, ASR r6
	cmn r2, #43
	orr r0,r1, r6, LSL #22
	bic r0,r1, #5

	.end



