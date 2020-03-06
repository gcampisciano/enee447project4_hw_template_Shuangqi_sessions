.globl _start
_start:
    b res_handler		// RESET                 runs in SVC mode
    b hang				// UNDEF INSTR           runs in UND mode
    b svc_handler		// SWI (TRAP)            runs in SVC mode
    b hang				// PREFETCH ABORT        runs in ABT mode
    b hang				// DATA ABORT            runs in ABT mode
    b hang				// HYP MODE              runs in HYP mode
    b irq_nop		// IRQ INTERRUPT         runs in IRQ mode
	// FIQ can simply be written here, since this is the end of the table:
    b hang		// FIQ INTERRUPT         runs in FIQ mode

.equ    FIQSTACK0 , 0xf0000
.equ    IRQSTACK0 , 0xe0000
.equ    SVCSTACK0 , 0xd0000
.equ    KSTACK0   , 0xc0000
.equ    user_stack_for_shell, 0x80000

.equ	USR_mode,	0x10
.equ	FIQ_mode,	0x11
.equ	IRQ_mode,	0x12
.equ	SVC_mode,	0x13
.equ	HYP_mode,	0x1A
.equ	SYS_mode,	0x1F
.equ	No_Int,		0xC0


res_handler:
    mrc p15, 0, r0, c1, c0, 0 @ Read System Control Register
@   orr r0, r0, #(1<<2)       @ dcache enable
    orr r0, r0, #(1<<12)      @ icache enable
    and r0, r0, #0xFFFFDFFF   @ turn on vector table at 0x0000000 (bit 12)
    mcr p15, 0, r0, c1, c0, 0 @ Write System Control Register

// check core ID
	mrc     p15, 0, r0, c0, c0, 5
	ubfx    r0, r0, #0, #2
	cmp     r0, #0					// is it core 0?
	beq     core0

	// it is not core0, so do things that are appropriate for SVC level as opposed to HYP
	// like set up separate stacks for each core, etc.

	beq     hang

hang: 	wfi
		b hang

core0:
	// Initialize SPSR in all modes.
	MOV    R0, #0
	MSR    SPSR, R0
	MSR    SPSR_svc, R0
	MSR    SPSR_und, R0
	MSR    SPSR_hyp, R0
	MSR    SPSR_abt, R0
	MSR    SPSR_irq, R0
	MSR    SPSR_fiq, R0

	// Initialize ELR_hyp (necessary?)
	MOV		R0, #0
	MSR		ELR_hyp, R0

	// set up stacks (only need SVC and K at this point, but what the heck)
	cps		#IRQ_mode
	mov		sp, # IRQSTACK0

	cps		#FIQ_mode
	mov		sp, # FIQSTACK0

	cps		#SVC_mode
	mov		sp, # SVCSTACK0

	cps		#SYS_mode
	mov		sp, # KSTACK0
	bl		init_kernel

    

	// set up user stack and jump to shell
	cps		#USR_mode
	mov		sp, # user_stack_for_shell

    ldr r0, =threadsave_for_shell
    str r0, current_threadsave

	bl		run_shell
//	bl		do_blinker
	b hang


// courtesy of Prof Vince Weaver, U Maine
svc_handler:

    stmia   sp,{r0-lr}^     @ Save all user registers r0-lr
						@ (the ^ means user registers)

    str lr,[sp,#60]     @ store saved PC on stack

    mrs ip, SPSR        @ load SPSR (assume ip not a swi arg)
    str ip,[sp,#64]     @ store on stack

    sub sp,sp,#80

    @ Call the C version of the handler

    bl  trap_handler

    @ Put our return value of r0 on the stack so it is
    @ restored with the rest of the saved registers

    add sp,sp,#80

    str r0,[sp]

    ldr r0,[sp,#64]     @ pop saved CPSR
    msr SPSR_cxsf, r0       @ move it into place

    ldr lr,[sp,#60]     @ restore address to return to

    @ Restore saved values.  The ^ means to restore the userspace registers
    ldmia   sp, {r0-lr}^
    movs    pc, lr



.global current_threadsave
current_threadsave:
            .word 0

.global threadsave_for_shell
threadsave_for_shell: 
            .word 0 // SPSR
            .word 0 // r0
            .word 0 // r1
            .word 0 // r2
            .word 0 // r3
            .word 0 // r4
            .word 0 // r5
            .word 0 // r6
            .word 0 // r7
            .word 0 // r8
            .word 0 // r9
            .word 0 // r10
            .word 0 // r11
            .word 0 // r12
            .word 0 // r14_irq
            .word 0 // r13 usr
            .word 0 // r14_usr


save_r13_irq: .word 0
save_r14_irq: .word 0


badval: .word   0xdeadbeef


@
@ based on code from rpi discussion boards
@
irq_nop:
	// NOTE: CPSR has been saved into SPSR implicitly when the hardware transition from USR to IRQ mode
	
	// save context
    str     r13, save_r13_irq           @ save the IRQ stack pointer
    ldr     r13, current_threadsave 
    add     r13, r13, #60               @ jump to middle of TCB for store up and store down
    
    // after stmia, sp will remain the same according to this [site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0068b/BABEFCIB.html)                   
    //  > If Rn is in reglist: for an STMIA instruction, the value stored for Rn is the initial value of Rn if Rn is the lowest-numbered register in reglist
    stmia   sp, {sp, lr}^               @ store the USR stack pointer & link register, upwards
    
    push    {r0-r12, lr}                @ store USR regs 0-12 and IRQ link register (r14), downwards
    
    // Since SPSR contains the conditional flags                               
    //  of the interrupted user program, we need to thnk of it                 
    //  as part of the context, too. So let's save it, too.                    
    mrs r0, SPSR // Copy SPSR into R0                                          
    push {r0}
    // done saving context                                                     

    // back to use IRQ stack 
    ldr r13, save_r13_irq

    bl clear_timer_interrupt
    bl irq_print

    cps # SYS_mode
    bl schedule 

    cps # IRQ_mode
	bl		set_timer
	
    // restore context
    ldr     r13, current_threadsave 

    // restore SPSR                                                            
    pop {r0} // this is SPSR                                                   
    msr SPSR, r0 // Copy R0 into SPSR
    
    // restore the registers
    pop     {r0-r12, lr}                @ load USR regs 0-12 and IRQ link register (r14), upwards
    ldmia   sp, {sp, lr}^               @ load the USR stack pointer & link register, upwards
    nop                                 @ evidently it's a god idea to put a NOP after a LDMIA
    ldr     r13, save_r13_irq           @ restore the IRQ stack pointer from way above
    // done restoring context

    // return to user program
    // NOTE: it will copy SPSR into CPSR implicitly
    subs    pc, lr, #4                  @ return from exception


