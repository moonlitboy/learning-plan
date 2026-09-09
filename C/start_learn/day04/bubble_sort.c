// 1. 写函数声明 bubble_sort
// 2. main 里准备数组
// 3. 计算 n
// 4. 调用 bubble_sort(arr, n)
// 5. 排序后遍历输出数组
// 6. bubble_sort 里用两层 for
// 7. 如果 arr[j] > arr[j + 1] 就交换

#include <stdio.h>

void bubble_sort(int arr[], int n);

int main(void)
{
    int arr[] = {5, 3, 4, 1, 2};
    int n = sizeof(arr) / sizeof(arr[0]);
    bubble_sort(arr, n);
    for (int i = 0; i < n; i++)
    {
        printf("%d ", arr[i]);
    }
    printf("\n");
    return 0;
}

void bubble_sort(int arr[], int n)
{
    for (int i = 0; i < n - 1; i++)
    {
        for (int j = 0; j < n - 1 - i; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}
