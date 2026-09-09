// 1. 定义长度为 10 的 int 数组
// 2. 用 scanf + for 循环输入 10 个整数
// 3. 再遍历数组
// 4. 求最大值
// 5. 求最小值
// 6. 求平均值
// 7. 输出结果

#include <stdio.h>

int main(void)
{
    int arr[10];
    for (int i = 0; i < 10; i++)
    {
        scanf("%d", &arr[i]);
    }

    int max = arr[0];
    int min = arr[0];
    int sum = 0;
    for (int i = 0; i < 10; i++)
    {
        if (arr[i] > max)
            max = arr[i];
        if (arr[i] < min)
            min = arr[i];
        sum += arr[i];
    }

    double avg = sum / 10.0;
    printf("最大值: %d\n", max);
    printf("最小值: %d\n", min);
    printf("平均值: %.2f\n", avg);

    return 0;
}
