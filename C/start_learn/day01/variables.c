#include <stdio.h>

int main(void) 
{
    int age = 18;
    char grade = 'A';
    float height = 1.75f;
    double score = 95.5;

    printf("Age: %d\n", age);
    printf("Grade: %c\n", grade);
    printf("Height: %f\n", height);
    printf("Score: %f\n", score);

    printf("sizeof(int) = %zu\n", sizeof(int));
    printf("sizeof(char) = %zu\n", sizeof(char));
    printf("sizeof(float) = %zu\n", sizeof(float));
    printf("sizeof(double) = %zu\n", sizeof(double));
    
    return 0;
}
