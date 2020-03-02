# Project4
Read p4.pdf :)

# Things might be useful to you

## ARM assembly cheatsheet
- [here](http://infocenter.arm.com/help/topic/com.arm.doc.qrc0001l/QRC0001_UAL.pdf)

## To understand `push {r0-12, lr}`
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Babefbce.html) says
    > Push registers onto, and pop registers off a full descending stack.
    
- [this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731152499.htm) says
    > Descending or ascending: The stack grows downwards, starting with a high address and progressing to a lower one (a descending stack), or upwards, starting from a low address and progressing to a higher address (an ascending stack).
  
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0283b/Babefbce.html) says
    > Registers are stored on the stack in numerical order, with the lowest numbered register at the lowest address.

## To understand the difference between `ldr r13, =threadsave` and `ldr r13, threadsave`
- According to [this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731149945.htm), 
    - `ldr r13, =threadsave`: r13=address of the label threadsave
    - `ldr r13, threadsave`: r13=MEMORY[address of the label threadsave]

## Why does `subs pc, lr, #4` is at the end of interrupt handler?
- it sets pc=lr-4, where lr is pointing to interrupted thread
    - why subtract 4? Read [this](https://stackoverflow.com/questions/19909410/setting-irq-handler-in-arm-assembly)
