#include <stdio.h>

void change(int n);

int main(void)
{
    int x = 50;
    printf("Before change function, num = %d\n", x);
    change(x);
    printf("After change function, num = %d\n", x);
    return 0;
}

void change(int n)
{
    n = 100;
    printf("Inside change function, n = %d\n", n);
}
