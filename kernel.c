//
// timeout queue example
//

#include "os.h"
#include "dev.h"

extern struct dev devtab[];

void
init_kernel()
{
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

