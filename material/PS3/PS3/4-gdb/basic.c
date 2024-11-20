#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc == 2) {
        printf("argv[1] = %s\n", argv[1]);
    }

    char buf[100];
    scanf("%100s", buf);
    printf("Input = %s\n", buf);
}
