#include <stdio.h>
int main(void) 
{
    int age;
    double score;
    printf("Please enter your age: ");
    scanf("%d", &age);
    
    printf("Please enter your score: ");
    scanf("%lf", &score);

    printf("Your age is: %d\n", age);
    printf("Your score is: %f\n", score);

    return 0;
}
