#include <stdio.h>
int main(void)
{
    int a = 10;
    int b = 3;

    printf("a + b = %d\n", a + b);
    printf("a - b = %d\n", a - b);
    printf("a * b = %d\n", a * b);
    printf("a / b = %d\n", a / b);
    printf("a %% b = %d\n", a % b);

    printf("%d\n", 10 > 3);
    printf("%d\n", 10 == 3);
    printf("%d\n", 10 != 3);

    printf("%d\n", 10 > 3 && 5 > 2);
    printf("%d\n", 10 < 3 || 5 > 2);
    printf("%d\n", !(10 > 3));

    return 0;
}
