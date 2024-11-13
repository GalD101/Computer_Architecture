#include <stdio.h>

int main(void) {
    long array[2] = {0x1122334455667788, 0x99aabbccddeeff00};

    /* Actual memory layout: */
    unsigned char *ptr = (char *) array;
    for (int i = 0; i < sizeof(array); i++) {
        printf("%x\n", ptr[i]);
    }
}