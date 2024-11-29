# Implement void run_func(int choice, Pstring *pstr1, Pstring *pstr2) here

.section		.rodata

choise_31:        .string "first pstring length: %d, second pstring length: %d\n"
choise_33_34_37:  .string "length: %d, string: %s\n"
invalid:          .string "invalid option!\n"






.section    .text

.globl run_func
.type run_func, @function
