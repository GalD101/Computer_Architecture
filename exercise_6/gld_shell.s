.section .data
    buffer  .space  1024
    prompt  .asciz "G.L.D.223> "


.section 

_start:
    call main
    movl $60, %eax # exit syscal, number
    xor %edi, %edi # startus code 0
    syscall