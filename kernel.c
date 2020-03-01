//
// timeout queue example
//

#include "os.h"
#include "dev.h"

extern struct dev devtab[];

void
init_kernel()
{
    log("init_kernel called", NOVAL);
	struct dev *dp;
	int i;

    // init functions
    init_io();

	// I/O devices are up and running.
	blink_led_stall(5);

	// initial console output
    uart_puts("\n\n");
	log("...", NOVAL);
    log("System is booting, cpuid = ", cpu_id());
	log(kversion, NOVAL);

	if (DEBUG_MED >= DEBUG_LEVEL) {
		log("Available devices:", NOVAL);
		for (dp = devtab, i=0; i<MAX_DEVICES; i++, dp++) {
			log(dp->devname, NOVAL);
			log("Device number:  ", i);
			log("Device type:    ", dp->devtype);
			log("Init function:  ", (long)(dp->init));
			log("Read function:  ", (long)(dp->read));
			log("Write function: ", (long)(dp->write));
		}
	}

    // wake up
	log("...", NOVAL);
    log("Please hit any key to continue and set up timer interrupt.\n", NOVAL);

    uart_recv();
	set_timer();

	return;
}

static int enbale_irq_print = 1;
static int enable_irq_led_indicator = 0;
static int led_is_on = 0;

void irq_print() {
    if (enable_irq_led_indicator) {
        if (led_is_on) {
            led_off();
            led_is_on = 0;
        }
        else {
            led_on();
            led_is_on = 1;
        }
    }

    if (enbale_irq_print) {
        log("irq being handled", NOVAL);
    }
}

void assembly_checkpoint(int a) {
    uart_puts("assembly_checkpoint ");
    uart_put3d(a);
    uart_puts("\n");
}

void assembly_print_int(int a) {
    uart_puts("assembly_print_int.");
    uart_puts("data in 3d:");
    uart_put3d(a);
    uart_puts(". data in 64x:");
    uart_put64x(a);
    uart_puts("\n");
}

int get_cpsr() {
	register int a asm("r4");
    asm volatile (
        "mrs r4, cpsr"
        :"=r"(a)
        :
    );
    return a;
}

void print_and_parse_cpsr() {
    int cpsr = get_cpsr();
    int mode_id = cpsr&0x1F;
    int FIQ_disabled= cpsr&0b1000000; 
    int IQR_disabled= cpsr&0b10000000; 

    uart_puts("cpsr=0x"); 
    uart_put32x(cpsr); 
    uart_puts(". "); 
    uart_puts("modeid=0x"); 
    uart_put32x(mode_id); 
    uart_puts(". "); 
    switch (mode_id) {
        case 0x10:
            uart_puts("USR mode."); 
            break;
        case 0x11:
            uart_puts("FIQ mode."); 
            break;
        case 0x12:
            uart_puts("IRQ mode."); 
            break;
        case 0x13:
            uart_puts("SVC mode."); 
            break;
        case 0x17:
            uart_puts("About mode."); 
            break;
        case 0x1B:
            uart_puts("Undefined mode."); 
            break;
        case 0x1F:
            uart_puts("SYS mode."); 
            break;
        default:
            uart_puts("Can't parse the mode id."); 
            break;
    }
    if (FIQ_disabled) {
        uart_puts("FIQ is disabled.");
    }
    else {
        uart_puts("FIQ is enabled.");
    }
    if (IQR_disabled) {
        uart_puts("IQR is disabled.");
    }
    else {
        uart_puts("IQR is enabled.");
    }
    uart_puts("\n");
}
