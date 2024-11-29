#include <stdio.h>

// Define the Pstring structure
typedef struct {
    char length;
    char str[255];
} Pstring;

// Declare the swapCase function
extern void swapCase(Pstring* pstr);

int main() {
    // Create a Pstring
    Pstring pstr;
    pstr.length = 11;
    snprintf(pstr.str, sizeof(pstr.str), "Hello World");

    // Print the original string
    printf("Original string: %s\n", pstr.str);

    // Call the swapCase function
    swapCase(&pstr);

    // Print the modified string
    printf("Modified string: %s\n", pstr.str);

    return 0;
}