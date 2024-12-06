#include <stdio.h>

// Define the Pstring structure
typedef struct {
    char length;
    char str[255];
} Pstring;

// Declare the swapCase function
extern void swapCase(Pstring* pstr);
extern char pstrlen(Pstring* pstr);
extern Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j);
extern Pstring* pstrcat(Pstring* dst, Pstring* src);
extern void run_func(int choice, Pstring *pstr1, Pstring *pstr2);


int main() {
    // Create a Pstring
    Pstring pstr;
    pstr.length = 13;
    Pstring pstr2;
    pstr2.length = 12;

    snprintf(pstr.str, sizeof(pstr.str), "Hello  World!");
    snprintf(pstr2.str, sizeof(pstr2.str), "ShallomOllam");

    // Print the original string
    printf("Original string: %s\n", pstr.str);
    printf("Original string2: %s\n", pstr2.str);

    run_func(33, &pstr, &pstr2);
    // Call the pstrijcpy function
    // pstr2 = *(pstrijcpy(&pstr, &pstr2, 5, 9));
    pstrijcpy(&pstr, &pstr2, 7, 11);
    // Call the pstrlen function
    printf("Length of string: %d\n", pstrlen(&pstr));
    // Call the swapCase function
    swapCase(&pstr);
    swapCase(&pstr2);
    pstrcat(&pstr, &pstr2);

    // Print the modified string
    printf("Modified string: %s\n", pstr.str);
    printf("Modified string2: %s\n", pstr2.str);


    return 0;
}