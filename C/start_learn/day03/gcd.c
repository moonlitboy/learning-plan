#include <stdio.h>

int gcd(int a, int b);

int main(void)
{
    // 输入两个整数
    int num1, num2;
    printf("Enter two integers: ");
    scanf("%d %d", &num1, &num2);
    // 调用 gcd
    int result = gcd(num1, num2);

    // 输出最大公约数
    printf("The greatest common divisor is: %d\n", result);

    return 0;
}

int gcd(int a, int b)
{
    // 欧几里得算法
    while (b != 0)
    {
        int remainder = a % b;

        a = b;

        b = remainder;
    }

    return a;
}
