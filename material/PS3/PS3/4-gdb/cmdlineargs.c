#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc < 4) {
        printf("Usage: %s <arg1> <arg2> <arg3>\n", argv[0]);
        return 1;
    }

    printf("argc = %d\n", argc);
    printf("argv[1] = %s\n", argv[1]);
    printf("argv[2] = %s\n", argv[2]);
    printf("argv[3] = %s\n", argv[3]);
}