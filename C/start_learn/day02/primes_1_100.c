#include <stdio.h>

int main(void)
{
    for (int number = 2; number <= 100; number++)
    {
        int is_prime = 1;
        for (int i = 2; i * i <= number; i++)
        {
            if (number % i == 0)
            {
                is_prime = 0;
                break;
            }
        }
        if (is_prime)
        {
            printf("%d\n", number);
        }
    }
    return 0;
}
