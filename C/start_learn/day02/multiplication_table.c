#include <stdio.h>
// 九九乘法表
int main(void)
{
    for (int i = 1; i <= 9; i++)
    {
        for (int j = 1; j <= i; j++)
        {
            printf("%d x %d = %d\t", j, i, i * j);
        }
        printf("\n");
    }
    return 0;
}
