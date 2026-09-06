#include <stdio.h>

int main(void)
{
    for (int number = 100; number <= 999; number++)
    {
        int hundreds = number / 100;
        int tens = (number / 10) % 10;
        int units = number % 10;
        if (number == hundreds * hundreds * hundreds + tens * tens * tens + units * units * units)
        {
            printf("%d\n", number);
        }
    }
    return 0;
}
