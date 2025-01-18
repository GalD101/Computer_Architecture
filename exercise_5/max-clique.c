#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_VERTICES 100

void printSolution(int vertices[], int size) {
    int *end = vertices + size -1;

    while (vertices < end) {
        printf("%d ", *vertices++);
        printf("%d ", *vertices++);
    }

    end += 1;
    while (vertices < end) {
        printf("%d", *vertices++);
    }

    printf("\n");
}

bool isClique(int graph[MAX_VERTICES][MAX_VERTICES], int clique[], int size, int n) {
    int* orgclique = clique;
    for (int i = 0; i < size; i++) {
        int* cliquecpyj = orgclique;
        int a = *clique++;
        for (int j = 0; j < size; j++) {
            int b = *cliquecpyj++;
            if (!(i ^ j)) {
                continue;
            }
            // Time for !(a || b): 0.204211 seconds
            // Time for !a & !b: 0.177094 seconds
            // I can changed using De Morgan's law to run faster
            // TODO: Should I do !a & !b or the other way around? I need to think what will be the case in the average case so it will use short-circuiting.
            // I will also use loop unrolling and perform multiple comparisons at once
            // NOTE: I tried something like (*(graph[an + b])) and more variations but it doesn't work and I wasted hours on it and no progress :((((((((((((((((((((((((((((
            // wasted too much time on this annoying exercise. I quit. ex6 here I come. edit: ex6 is just an additional exercise and not replacing this annoying task :(
            // I tried sitting on this for hours and nothing works I hate this exercise
            // I literaly wasted more than 6 hours and everything I tried failed I am so fucking done
            if (!(graph[a][b]) && !(graph[b][a])) return false;
        }
    }
    return true;
}

void generateCombinations(int graph[MAX_VERTICES][MAX_VERTICES], int n, int *clique, int k, int start, int currentSize, int *maxSize, int *maxClique) {
    int orgn = n;
    if (currentSize == k) {
        if (isClique(graph, clique, k, orgn)) {
            if (k > *maxSize) {
                *maxSize = k;

                // Temporary pointers so I won't have to fetch from memory everytime.
                int *dest = maxClique;
                int *src = clique;

                // I will use duff device similar to what we saw in recitation.
                // I found this online and it looks almost identical to what we saw in class https://stackoverflow.com/questions/58002180/fast-copy-selected-elements-of-an-array-in-c
                // P.S. OSINT is helpful, knowing how to google can be a good skill. check this out and ctrl F: duff: https://github.com/RangelReale/freesci-pnd/blob/e6bbd638a40c98caf3be899a0c1a20c7efd59b17/src/tools/bdf.c
                int n = (k + 7) / 8; // This is a cool trick we saw in recitation to calculate k / 8 ceil. here I use % instead to get the remainder
                switch (k % 8) {
                    case 0: do { *dest++ = *src++;
                    case 7:      *dest++ = *src++;
                    case 6:      *dest++ = *src++;
                    case 5:      *dest++ = *src++;
                    case 4:      *dest++ = *src++;
                    case 3:      *dest++ = *src++;
                    case 2:      *dest++ = *src++;
                    case 1:      *dest++ = *src++;
                            } while (--n > 0);
                }
                maxClique = dest;
            }
        }
        return;
    }

    for (int i = start; i < n; i++) {
        clique[currentSize] = i;
        generateCombinations(graph, n, clique, k, i + 1, currentSize + 1, maxSize, maxClique);
    }
}

void findMaxClique(int graph[MAX_VERTICES][MAX_VERTICES], int n) {
    int *clique = (int *)malloc(n * sizeof(int));
    int *maxClique = (int *)malloc(n * sizeof(int));
    int maxSize = 0;

    for (int k = 1; k <= n; k++) {
        generateCombinations(graph, n, clique, k, 0, 0, &maxSize, maxClique);
    }
    printf("Clique Members: ");
    printSolution(maxClique, maxSize);
    printf("Size: %d\n", maxSize);

    free(clique);
    free(maxClique);
}
