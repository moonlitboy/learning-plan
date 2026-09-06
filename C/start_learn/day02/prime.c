#include <stdio.h>

int main(void)
{
    int n;

    printf("请输入一个数字\n");
    scanf("%d", &n);

    int is_prime = 1;

    if (n <= 1)
    {
        is_prime = 0;
    }
    else
    {
        for (int i = 2; i * i <= n; i++)
        {
            if (n % i == 0)
            {
                is_prime = 0;
                break;
            }
        }
    }

    if (is_prime == 1)
    {
        printf("该数字是质数\n");
    }
    else
    {
        printf("该数字不是质数\n");
    }

    return 0;
}
