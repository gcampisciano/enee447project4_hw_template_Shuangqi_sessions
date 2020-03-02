# Project4
Read p4.pdf :)

# Useful things
## To understand `push {r0-12, lr}`
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Babefbce.html) says
    > Push registers onto, and pop registers off a full descending stack.
    
- [this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731152499.htm) says
    > Descending or ascending: The stack grows downwards, starting with a high address and progressing to a lower one (a descending stack), or upwards, starting from a low address and progressing to a higher address (an ascending stack).
  
- [this site](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0283b/Babefbce.html) says
    > Registers are stored on the stack in numerical order, with the lowest numbered register at the lowest address.

## To understand the difference between `ldr r13, =threadsave` and `ldr r13, threadsave`
[this site](http://www.keil.com/support/man/docs/armasm/armasm_dom1359731149945.htm)
