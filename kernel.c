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

void irq_print() {
    uart_puts("irq being handled\n");
}


extern int *current_threadsave;
extern int threadsave_for_shell;
void schedule() {
    int **current_threadsave_ptr = &current_threadsave;
    int *threadsave_for_shell_ptr = &threadsave_for_shell;
}
