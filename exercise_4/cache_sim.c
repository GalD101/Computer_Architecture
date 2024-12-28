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

// Helper function prototypes (optional, you might implement these as needed)
// int find_LFU_line(cache_line_t* set, int E);
// void update_frequency(cache_line_t* line);

// int main() {
//     uchar arr[] = {1, 2, 3, 4, 5, 6, 7, 8};
//     cache_t cache = initialize_cache(1, 1, 1, 2);
//     read_byte(cache, arr, 0);
//     read_byte(cache, arr, 1);
//     read_byte(cache, arr, 2);
//     read_byte(cache, arr, 6);
//     read_byte(cache, arr, 7);
//     print_cache(cache);
// }

// TODO: add the main function from the instructions

// Function: initialize_cache
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

    // I now need to allocate space.
    // I need to create an array (pointer) of an array (another pointer)
    // such that the dimensions are [S][E]
    // and each element is a line and thus is of size: sizeof(cache_line_t)

    // Allocate memory for S number of sets
    // Notice the pointer here (cache_line_t*).
    // Because this is an array of arrays, I need every set to be of size of pointer to cache_line_t
    cache.cache = (cache_line_t**) calloc(S, sizeof(cache_line_t*));

    // Allocate memory for E number of lines for all S sets
    for (int i = 0; i < S; i++) {
        cache.cache[i] = (cache_line_t*) calloc(E, sizeof(cache_line_t));
        
        // Allocate memory for every block in every set in every line
        for (int j = 0; j < E; j++) {
            cache.cache[i][j].block = (uchar*) calloc(B, sizeof(uchar));
            
            // Also initialize primitive values to zero
            // (calloc is supposed to take care of that
            // but I want to be sure because last time I lost points
            // because apperantly in RHE the string was not initialized to null bytes)
            cache.cache[i][j].valid = 0;
            cache.cache[i][j].frequency = 0;
            cache.cache[i][j].tag = 0;
            // block can be junk because I have the valid bit to indicate if it is valid or not
        }
    }
    return cache;
}

// Function: read_byte
uchar read_byte(cache_t cache, uchar* start, long int off) {
    // TODO: Implement the function to simulate cache read
    // - Extract the tag, set index, and block offset from 'off'
    // - Search for the line in the corresponding set
    // - If found, update the frequency and return the byte
    // - If not found, replace the LFU line, load the block from memory, and return the byte
    
    // TODO: Create a helper function to validate input
    if ((cache.cache == NULL) || (start == NULL)) {
        return 0; // check the input is valid
    }

    // Calculate all parameters
    uchar s = cache.s;
    uchar t = cache.t;
    uchar b = cache.b;
    uchar E = cache.E;
    uchar m = s + t + b; // better be less than max val of uchar or we will get an overflow

    int S = 1 << s; // 2^s
    int B = 1 << b; // 2^b
    unsigned long int C = B * E * S; // probably not necessary but I saw this in the book. This is capacity

    // I need to view the address as binary - this is tedious so I will use bitwise operations instead
    // Masks for each part:

    // For the block I will need to look at the last B digits of off.
    // In order to do that in binary, I need to get the remainder when dividing the number by 2^B
    // This is too hard to do, instead I will use logical operations
    // I will simply create a number that has a binary representation of 11...1 B times
    // and I will AND it with off.
    // TODO: check if you need to use B OR b
    long int b_ones = (1 << b) - 1; // 1 << b Will create 10...0 with b zeros, -1 will make it b 1's
    long int block = off & b_ones; // this should have b valuable bits

    // The set index is more complex, I need s ones followed by b zeroes
    // I will create (s+b) ones and I will subtract from it b ones
    // (I just played around with python until I realized this is how I can achieve this)
    long int s_ones_b_zeros = ((1 << (b + s)) - (1 << (b)));
    long int set_index = (off & s_ones_b_zeros) >> b; // this extracts the s_bits representing the index

    // The tag bits are literally 'the rest'
    // I will just shift off by b+s bits.
    // WIP: I NEED TO FIX THIS:But I also need to make sure that the tag is a t long bits number, so I AND it with t one's
    long int tag = off >> (b + s) & ((1 << t) - 1);

    // Search if this address was already loaded into the cache
    // Sometimes cache.cache[set_index] is NULL. TODO: figure out why
    cache_line_t* set = cache.cache[set_index];
    uchar least_frequent_val = set ? set[0].frequency : 0;
    cache_line_t* least_frequent_ptr = set;
    cache_line_t* open_spot = NULL;
    for (int i = 0; i < E; i++) {
        if (set[i].valid) {

            // check the tag
            if (set[i].tag == tag) {
                set[i].frequency++;
                return set[i].block[block]; // cache hit!
            }

            // keep hold of the least frequent address in case of a conflict miss
            if (open_spot == NULL && least_frequent_val < set[i].frequency) {
                least_frequent_val = set[i].frequency;
                least_frequent_ptr = set + i;
            }

        }
        else {
            // occupy the first open spot found
            open_spot = open_spot == NULL ? set + i : open_spot;
        }
    }

    // cache miss
    // TODO: There is a lot of repetition here. Refactor this and use write_byte (I think)
    if (open_spot != NULL) {
        open_spot->valid = 1;
        open_spot->frequency = 1;
        open_spot->tag = tag;
        while (off % m != 0) {
            off--;
        }
        for (int i = 0; i < B; i++) {
            open_spot->block[i] = start[off + i];
        }
        return open_spot->block[block];
    }
    else {
        least_frequent_ptr->valid = 1;
        least_frequent_ptr->tag = tag;
        least_frequent_ptr->frequency = 1;
        while (off % m != 0) {
            off--;
        }
        for (int i = 0; i < B; i++) {
            least_frequent_ptr->block[i] = start[off + i];
        }
        return least_frequent_ptr->block[block];
    }
    
    return 0; // Placeholder
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

    return 0;
}

// Function: write_byte
void write_byte(cache_t cache, uchar* start, long int off, uchar new) {
    // TODO: Implement the function to simulate cache write
    // - Similar to read_byte, but also update memory since it is write-through
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