#include <stdio.h>

int main(void)
{
    int number, count = 0;
    printf("Enter a number: ");
    scanf("%d", &number);
    do
    {
        number /= 10;
        count++;
    } while (number != 0);
    printf("Number of digits: %d\n", count);
    return 0;
}
