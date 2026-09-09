// 1. 创建一个长度为 5 的 int 数组
// 2. 初始化为 10 20 30 40 50
// 3. 使用 for 循环依次输出每个元素

#include <stdio.h>

int main(void)
{
    int arr[5] = {10, 20, 30, 40, 50};
    for (int i = 0; i < 5; i++)
    {
        printf("%d\n", arr[i]);
    }
    return 0;
}
