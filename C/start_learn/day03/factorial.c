#include <stdio.h>

int factorial(int n);

int main(void)
{
    // 输入 n
    int n;
    printf("Enter a non-negative integer: ");
    scanf("%d", &n);

    // 调用 factorial(n)
    int result = factorial(n);

    // 输出结果
    printf("The factorial of %d is %d\n", n, result);

    return 0;
}

int factorial(int n)
{
    // 阶乘计算
    if (n == 0)
        return 1;
    else
        return n * factorial(n - 1);
}
