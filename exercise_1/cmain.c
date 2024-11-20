#include <stdio.h>

int gen_rnd_num(unsigned int seed, int N) {
    srand(seed);
    return (rand() % N) + 1;
}

int main() {
    unsigned int seed;
    long rnd_num;
    int rounds = 1;
    char is_easy_mode;
    int N = 10;
    const int M = 5;
    int counter = M;
    int guess = -1;
    
    printf("Enter configuration seed: ");
    scanf("%d", &seed);


    srand(seed);
    rnd_num = gen_rnd_num(seed, N);
    
    printf("Would you like to play in easy mode? (y/n) ");
    scanf(" %c", &is_easy_mode);

        if (!((guess != rnd_num) && (counter != 0))) {
            goto done;
        }
        loop:
                printf("What is your guess? ");
                scanf("%d", &guess);
                counter -= 1;
                if ((guess != rnd_num) && (counter != 0)) {
                    printf("Incorrect. ");
                    if (is_easy_mode == 'y') {
                        if (guess < rnd_num) {
                            printf("Your guess was below the actual number ...\n");
                        }
                        else {
                            printf("Your guess was above the actual number ...\n");
                        }
                    }
                    goto loop;
                }
        
        done:
            if (guess != rnd_num) {
                printf("Incorrect. ");
                printf("\nGame over, you lost :(. The correct answer was %u\n", rnd_num);
                return 0;
            }
            
            
            
            // double or nothing
            char is_double_or_nothing;
            printf("Double or nothing! Would you like to continue to another round? (y/n) ");
            scanf(" %c", &is_double_or_nothing);
            if (is_double_or_nothing == 'n') {
                printf("Congratz! You won %d rounds!\n", rounds);
                return 0;
            }
            else if (is_double_or_nothing == 'y') {
                rounds += 1;
                seed <<= 1;
                N <<= 1;
                counter = M;
                rnd_num = gen_rnd_num(seed, N);
                goto loop;
            }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    return 0;
}