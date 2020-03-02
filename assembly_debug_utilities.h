
void assembly_checkpoint(int checkpoint_id);
void assembly_print_int(int data_to_print);

// NOTE: this function won't work when you're in USR mode
//  because it needs to execute privileged instructions
void print_and_parse_cpsr(void); 
