#include <stdio.h>

int gen_rnd_num(unsigned int seed, long N) {
    srand(seed);
    return (rand() % N) + 1; // In assembly, use div and inc
}

int main() {
    // Set variables
    // M is constant so he should resize in .rodata when implementing assembly
    const int M = 0x05; // The maximum number of allowed mistakes per round

    unsigned int seed;
    long rnd_num = 0xFF; // TODO: Should it be long or something else like int64_t ? maybe int32_t ?
    int rounds = 0x01; // How many rounds the user won (will be used iff the user won at least 1 round hence the initialization to 1)
    char is_easy_mode = 0x6e; // Save user's prefrence (We assume valid input) 0x6e is 'n' in ascii (default is no)
    long N = 0xA; // will create rnd_num between 1,....10 inclusive (see gen_rnd_num for more info) 0xA = 10
    int counter = M; // initialize the number of mistaked counter
    int guess = 0x00; // initialize the guess to a number that can't be generated (Maybe set it's initial value to 0 in assembly too)
    char is_double_or_nothing = 0x6e // Initialize double_or_nothing to 0x6e = 'n' (default is no)


    // Print the promt for the configuration seed (In assembly this would also be saved in .rodata but in C strings are not fun to work with, so I will just write them explicitly here)
    printf("Enter configuration seed: ");
    
    // Save the seed to the variable seed
    scanf("%d", &seed);

    // Call srand with the appropriate seed
    srand(seed);

    // Use the function gen_rnd_num to create the seed and save the returned value in rndnum
    rnd_num = gen_rnd_num(seed, N);
    
    // Print the easy mode prompt
    printf("Would you like to play in easy mode? (y/n) ");

    // Save the easy mode prefrence
    scanf(" %c", &is_easy_mode);


    // I think this if is unecessary. I think this is like a while loop instead of a do while loop
    // if (!((guess != rnd_num) && (counter != 0))) {
    //     goto round_finish;
    // }
    ask_for_guess_loop:
            printf("What is your guess? ");

            // These lines 'update' (so the loop won't be infinite)
            scanf("%d", &guess);
            counter -= 1;
            ///////////////////////////////////////////////////////

            if ((guess != rnd_num) && (counter != 0)) {
                printf("Incorrect. ");

                // In assembly, use cmp and then jmp or is there a better way?
                if (is_easy_mode == 'y') {
                    if (guess < rnd_num) {
                        // Maybe in assembly use something like "Your guess was %s the actual number ...\n" and a condition to print the right answer (below or above)
                        printf("Your guess was below the actual number ...\n");
                    }
                    else {
                        printf("Your guess was above the actual number ...\n");
                    }
                }

                // Keep looping until condition breaks
                goto ask_for_guess_loop;
            }
    
    round_finish:
        if (guess != rnd_num) {
            // User is wrong on the last attempt
            printf("Incorrect. ");
            printf("\nGame over, you lost :(. The correct answer was %u\n", rnd_num);

            // quit the program
            goto quit
        }
        
        
        // double or nothing
        printf("Double or nothing! Would you like to continue to another round? (y/n) ");
        scanf(" %c", &is_double_or_nothing);
        if (is_double_or_nothing == 'n') {
            printf("Congratz! You won %d rounds!\n", rounds);
            goto quit;
        }
        else if (is_double_or_nothing == 'y') {
            rounds += 1;
            seed <<= 1;
            N <<= 1;
            counter = M;
            rnd_num = gen_rnd_num(seed, N);
            goto loop;
        }
        // You are not supposed to get here
    return 0;

    // In assembly you will do more than just return 0 to exit (I think)
    quit:
        return 0;
}