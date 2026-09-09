#include <stdio.h>
int linear_search(int arr[], int n, int target);
int main(void)
{
    int arr[] = {1, 2, 3, 4, 5};
    int n = sizeof(arr) / sizeof(arr[0]);
    int target;
    printf("请输入要查找的数字: ");
    scanf("%d", &target);
    int index = linear_search(arr, n, target);
    if (index != -1)
        printf("数字 %d 在数组中的索引为 %d\n", target, index);
    else
        printf("数字 %d 不在数组中\n", target);
    return 0;
}
int linear_search(int arr[], int n, int target)
{
    for (int i = 0; i < n; i++)
    {
        if (arr[i] == target)
            return i;
    }
    return -1;
}
