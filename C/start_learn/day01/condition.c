#include <stdio.h>

int main(void)
{
    int score;
    printf("Please enter your score: ");
    scanf("%d", &score);

    if (score >= 90) {
        printf("Excellent\n");
    }
    else if (score >= 60) {
        printf("Pass\n");
    }
    else {
        printf("Fail\n");
    }
    
    return 0;
}
