#include <stdio.h>

int max3(int a, int b, int c);

int main(void)
{
    int x, y, z;

    printf("Enter three integers: ");
    scanf("%d %d %d", &x, &y, &z);

    int result = max3(x, y, z);

    printf("The maximum value is %d\n", result);

    return 0;
}

int max3(int a, int b, int c)
{
    // 你自己完成
    int max = a;
    if (b > max)
        max = b;
    if (c > max)
        max = c;
    return max;
}
