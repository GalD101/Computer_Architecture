/* 322558297 Gal Dali */
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char uchar;

typedef struct cache_line_s {
    uchar valid;
    uchar frequency;
    long int tag;
    uchar* block;      // Pointer to the memory block
} cache_line_t;

typedef struct cache_s {
    uchar s;
    uchar t;
    uchar b;
    uchar E;
    cache_line_t** cache; // Pointer to cache sets (array of arrays of cache_line_t)
} cache_t;

cache_t initialize_cache(uchar s, uchar t, uchar b, uchar E);
uchar read_byte(cache_t cache, uchar* start, long int off);
void write_byte(cache_t cache, uchar* start, long int off, uchar new);

cache_t initialize_cache(uchar s, uchar t, uchar b, uchar E) {
    cache_t cache;
    cache.s = s;
    cache.t = t;
    cache.b = b;
    cache.E = E;

    uchar m = t + s + b;
    int S = 1 << s;
    int B = 1 << b;
    unsigned long int C = B * E * S;

    // Allocate memory for S number of sets
    // Notice the pointer here (cache_line_t*).
    // Because this is an array of arrays, I need every set to be of size of pointer to cache_line_t
    cache.cache = (cache_line_t**) calloc(S, sizeof(cache_line_t*));

    for (int i = 0; i < S; i++) {

        // Allocate memory for E number of lines for all S sets
        cache.cache[i] = (cache_line_t*) calloc(E, sizeof(cache_line_t));
        
        // Allocate memory for every block in every line in every set
        for (int j = 0; j < E; j++) {
            cache.cache[i][j].block = (uchar*) calloc(B, sizeof(uchar));
            
            // Also initialize primitive values to zero
            // (calloc is supposed to take care of that
            // but I want to be sure because last time I lost points
            // because apperantly in RHE the string was not fully initialized with null bytes)
            cache.cache[i][j].valid = 0;
            cache.cache[i][j].frequency = 0;
            cache.cache[i][j].tag = 0;
            // block can be junk because I have the valid bit to indicate if it is valid or not
        }
    }
    return cache;
}

long int calculateLastNBits(long int val, uchar len) {
    long int mask = (1 << len) - 1; // 1...1 len times
    return val & mask;
}

uchar occupy_spot(uchar* start, long int off, cache_line_t* spot, long int tag, int B, long int block, uchar new) {
    spot->valid = 1;
    spot->frequency = 1;
    spot->tag = tag;
    while (off % B != 0) {
        off--;
    }
    for (int i = 0; i < B; i++) {
        spot->block[i] = start[off + i];
    }
    if (new == NULL) {
        return spot->block[block];
    }

    // update
    spot->block[block] = new;
    return NULL;
}

uchar read_byte(cache_t cache, uchar* start, long int off) {
    
    // TODO: Create a helper function to validate input
    if ((cache.cache == NULL) || (start == NULL)) {
        return 0;
    }

    // Calculate all parameters
    uchar s = cache.s;
    uchar t = cache.t;
    uchar b = cache.b;
    uchar E = cache.E;

    int S = 1 << s; // 2^s
    int B = 1 << b; // 2^b

    long int offCopy = off;

    // Calculate the block
    long int block = calculateLastNBits(offCopy, b);

    // get rid of b lsb
    offCopy = offCopy >> b;

    // Calculate the set index
    long int setIndex = calculateLastNBits(offCopy, s);

    // get rid of s lsb
    offCopy = offCopy >> s;

    // Calculate the tag
    long int tag = offCopy;

    cache_line_t* set = cache.cache[setIndex];
    uchar leastFrequentVal = set ? set[0].frequency : 255;
    cache_line_t* leastFrequentPtr = set;
    cache_line_t* openSpot = NULL;
    for (int i = 0; i < E; i++) {
        if (set[i].valid) {
            if (set[i].tag == tag) {
                set[i].frequency++;
                return set[i].block[block]; // cache hit!
            }

            // keep hold of the least frequent address in case of a conflict/capacity miss
            if (openSpot == NULL && set[i].frequency < leastFrequentVal) {
                leastFrequentVal = set[i].frequency;
                leastFrequentPtr = set + i;
            }

        }
        else if (openSpot == NULL) {
            // occupy the first open spot found
            openSpot = set + i;
        }
    }

    // cache miss
    if (openSpot != NULL) {
        return occupy_spot(start, off, openSpot, tag, B, block, NULL);
    }
    
    return occupy_spot(start, off, leastFrequentPtr, tag, B, block, NULL);
}

void write_byte(cache_t cache, uchar* start, long int off, uchar new) {
    
    if ((cache.cache == NULL) || (start == NULL) || (new == NULL)) {
        return;
    }

    // Calculate all parameters
    uchar s = cache.s;
    uchar t = cache.t;
    uchar b = cache.b;
    uchar E = cache.E;

    int S = 1 << s; // 2^s
    int B = 1 << b; // 2^b

    long int offCopy = off;

    // Calculate the block
    long int block = calculateLastNBits(offCopy, b);

    // get rid of b lsb
    offCopy = offCopy >> b;

    // Calculate the set index
    long int setIndex = calculateLastNBits(offCopy, s);

    // get rid of s lsb
    offCopy = offCopy >> s;

    // Calculate the tag
    long int tag = offCopy;

    cache_line_t* set = cache.cache[setIndex];
    for (int i = 0; i < E; i++) {
        if ((set[i].valid) && (set[i].tag == tag)) {
            set[i].frequency++;
            set[i].block[block] = new; // cache hit!
            start[off] = new; // write-through. Update the ram
            return;
        }
    }

    // cache miss - since this cache implements the no-write-allocate policy, we don't update the cache
}

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
    int n;
    printf("Size of data: ");
    scanf("%d", &n);
    uchar* mem = malloc(n);
    printf("Input data >> ");
    for (int i = 0; i < n; i++)
        scanf("%hhd", mem + i);

    int s, t, b, E;
    printf("s t b E: ");
    scanf("%d %d %d %d", &s, &t, &b, &E);
    cache_t cache = initialize_cache(s, t, b, E);
    
    while (1) {
        scanf("%d", &n);
        if (n < 0) break;
        read_byte(cache, mem, n);
    }
    
    puts("");
    print_cache(cache);
    
    free(mem);
}
