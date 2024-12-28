#include <stdio.h>
#include <stdlib.h>

void print_cache(cache_t cache) {
    int S = 1 << cache.s;
    int B = 1 << cache.b;
    for (int i = 0; i < S; i++) {
        printf("Set %d\n", i);
        for (int j = 0; j < cache.E; j++) {
            printf("%1d %d 0x%0*lx ", cache.cache[i][j].valid,
            cache.cache[i][j].frequency, cache.t, cache.cache[i][j].tag);
            for (int k = 0; k < B; k++) {
                printf("%02x ", cache.cache[i][j].block[k]);
            }
                puts("");
            }
        }
}

int main() {
    uchar arr[] = {1, 2, 3, 4, 5, 6, 7, 8};
    cache_t cache = initialize_cache(1, 1, 1, 2);
    read_byte(cache, arr, 0);
    read_byte(cache, arr, 1);
    read_byte(cache, arr, 2);
    read_byte(cache, arr, 6);
    read_byte(cache, arr, 7);
    print_cache(cache);
}