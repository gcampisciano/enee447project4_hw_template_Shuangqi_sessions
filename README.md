# Project4
Read p4.pdf :) then try to understand **thoroughly** what is happning in `1_boot.s`

# Things might be useful to you

## ARM assembly cheatsheet
- [here](http://infocenter.arm.com/help/topic/com.arm.doc.qrc0001l/QRC0001_UAL.pdf)

## What are `sp` and `lr` registers in ARM?
- read [this](https://stackoverflow.com/questions/8236959/what-are-sp-stack-and-lr-in-arm)

## To understand `push {r0-12, lr}`
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Babefbce.html) says
    > Push registers onto, and pop registers off a full descending stack.
    
- [this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731152499.htm) says
    > Descending or ascending: The stack grows downwards, starting with a high address and progressing to a lower one (a descending stack), or upwards, starting from a low address and progressing to a higher address (an ascending stack).
  
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0283b/Babefbce.html) says
    > Registers are stored on the stack in numerical order, with the lowest numbered register at the lowest address.

## To understand the difference between `ldr r13, =label` and `ldr r13, label`
- According to [this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731149945.htm), 
    - `ldr r13, =label`: r13=address of the label
    - `ldr r13, label`: r13=MEMORY[address of the label]

## Why is `subs pc, lr, #4` at the end of the interrupt handler?
- it sets pc=lr-4, where lr is pointing to interrupted thread
    - why subtract 4? Read [this](https://stackoverflow.com/questions/19909410/setting-irq-handler-in-arm-assembly)
    
    
## How to use assembly labels in C?
- read [this](https://stackoverflow.com/questions/43532109/get-label-address-of-assembly-using-c)

## What is the data tpye in C that corresponds to `word` in assembly?
- According to this [site](https://gcc.gnu.org/onlinedocs/gccint/Type-Layout.html), by default, a `int` in C corresponds to a `word` in assembly.
    
## What is CPSR/SPSR? 
- read [this](https://heyrick.eu/armwiki/The_Status_register)

## What is SVC/SYS/IRQ/FIQ/USR mode?
- read [this](https://heyrick.eu/armwiki/Processor_modes)
