#include <stdio.h>

int is_prime(int n);

int main(void)
{
    // 输入 n
    int n;
    printf("Enter a number: ");
    scanf("%d", &n);
    // 调用 is_prime(n)
    int result = is_prime(n);

    // 根据返回值输出结果
    if (result)
        printf("%d is a prime number.\n", n);
    else
        printf("%d is not a prime number.\n", n);

    return 0;
}

int is_prime(int n)
{
    // 质数判断逻辑
    if (n <= 1)
        return 0;
    for (int i = 2; i * i <= n; i++)
    {
        if (n % i == 0)
            return 0;
    }
    return 1;
}
