#include <stdio.h>
int main(void)
{
    int a, b;
    printf("Enter two integers: ");
    scanf("%d %d", &a, &b);

    printf("a + b = %d\n", a + b);
    printf("a - b = %d\n", a - b);
    printf("a * b = %d\n", a * b);
    if (b != 0)
    {
        printf("a / b = %d\n", a / b);
        printf("a %% b = %d\n", a % b);
    }
    else
    {
        printf("不能除以0\n");
    }

    return 0;
}
