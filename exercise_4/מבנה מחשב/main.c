#include <stdio.h>
#include <stdlib.h>

int main() {
    int n;
    printf("Size of data: ");
    scanf("%d", &n);
    uchar* mem = malloc(n);
    printf("Input data >> ");
    for (int i = 0; i < n; i++) {
        scanf("%hhd", mem + i);
    }
    int s, t, b, E;
    printf("s t b E: ");
    scanf("%d %d %d %d", &s, &t, &b, &E);
    cache_t cache = initialize_cache(s, t, b, E);
    while (1) {
        scanf("%d", &n);
        if (n < 0) {
            break;
        }
        read_byte(cache, mem, n);
    }
    puts("");
    print_cache(cache);
    free(mem);
}