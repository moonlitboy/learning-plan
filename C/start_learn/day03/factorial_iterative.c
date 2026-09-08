#include <stdio.h>

int factorial(int n);

int main(void)
{
    int n;

    printf("Enter a non-negative integer: ");
    scanf("%d", &n);

    if (n < 0 || n > 12)
    {
        printf("Please enter an integer from 0 to 12.\n");
        return 1;
    }

    int result = factorial(n);

    printf("The factorial of %d is %d\n", n, result);

    return 0;
}

int factorial(int n)
{
    int result = 1;

    for (int i = 1; i <= n; i++)
    {
        result *= i;
    }

    return result;
}
