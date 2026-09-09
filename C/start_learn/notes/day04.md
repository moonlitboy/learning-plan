# C 语言康复训练 Day 04：数组

> 日期：2026-09-09  
> 主题：一维数组、数组遍历、数组传参、线性查找、冒泡排序

---

## 一、今日目标

今天正式进入 C 语言的数据结构前置内容，重点掌握：

- 一维数组
- 数组下标
- 数组遍历
- 数组作为函数参数
- 最大值 / 最小值 / 平均值统计
- 数组原地逆序
- 线性查找
- 冒泡排序
- 理解数组传参为什么可以修改原数组

今天的最终验收目标：

```text
数组 + 函数 + 冒泡排序
```

---

# 二、数组基础

## 1. 数组定义

```c
int arr[5];
```

表示创建一个可以保存 5 个 `int` 元素的数组。

初始化：

```c
int arr[5] = {10, 20, 30, 40, 50};
```

也可以让编译器自动计算长度：

```c
int arr[] = {10, 20, 30, 40, 50};
```

---

## 2. 数组下标

C 语言数组下标从 `0` 开始。

对于：

```c
int arr[5] = {10, 20, 30, 40, 50};
```

对应关系：

```text
arr[0] = 10
arr[1] = 20
arr[2] = 30
arr[3] = 40
arr[4] = 50
```

合法下标：

```text
0 1 2 3 4
```

`arr[5]` 已经越界。

---

## 3. 数组遍历

```c
for (int i = 0; i < 5; i++)
{
    printf("%d\n", arr[i]);
}
```

注意：

```c
i < 5
```

不能写成：

```c
i <= 5
```

否则最后会访问：

```c
arr[5]
```

造成数组越界。

---

# 三、练习 1：数组基础遍历

文件：

```text
day04/array_basic.c
```

代码：

```c
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
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day04/array_basic.c -o build/array_basic
```

运行：

```bash
./build/array_basic
```

输出：

```text
10
20
30
40
50
```

---

# 四、练习 2：最大值、最小值、平均值

文件：

```text
day04/array_stats.c
```

核心思路：

1. 定义长度为 10 的数组
2. 使用 `scanf` 输入 10 个整数
3. 遍历数组
4. 求最大值
5. 求最小值
6. 累加求和
7. 计算平均值

代码：

```c
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

    printf("最大值：%d\n", max);
    printf("最小值：%d\n", min);
    printf("平均值：%.2f\n", avg);

    return 0;
}
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day04/array_stats.c -o build/array_stats
```

运行：

```bash
./build/array_stats
```

---

## 关键点 1：最大值和最小值的初始化

推荐：

```c
int max = arr[0];
int min = arr[0];
```

不要随便写：

```c
int max = 0;
int min = 0;
```

因为如果数组中的数全部是负数，初始化为 `0` 可能导致结果错误。

---

## 关键点 2：平均值为什么用 `10.0`

```c
double avg = sum / 10.0;
```

`10.0` 是浮点数，因此会进行浮点除法。

如果写：

```c
sum / 10
```

当两边都是整数时，会先进行整数除法，可能丢失小数部分。

---

# 五、练习 3：数组原地逆序

文件：

```text
day04/array_reverse.c
```

初始数组：

```text
1 2 3 4 5
```

逆序后：

```text
5 4 3 2 1
```

代码：

```c
#include <stdio.h>

int main(void)
{
    int arr[5] = {1, 2, 3, 4, 5};

    for (int i = 0; i < 5 / 2; i++)
    {
        int temp = arr[i];
        arr[i] = arr[5 - 1 - i];
        arr[5 - 1 - i] = temp;
    }

    for (int i = 0; i < 5; i++)
    {
        printf("%d ", arr[i]);
    }

    printf("\n");

    return 0;
}
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day04/array_reverse.c -o build/array_reverse
```

运行：

```bash
./build/array_reverse
```

输出：

```text
5 4 3 2 1
```

---

## 为什么只循环一半？

对于长度为 5 的数组：

```text
arr[0] ↔ arr[4]
arr[1] ↔ arr[3]
arr[2] 不动
```

所以只需要交换：

```text
5 / 2 = 2
```

次。

通用的对称位置：

```c
arr[n - 1 - i]
```

其中：

```text
n - 1
```

是最后一个元素的下标。

---

# 六、练习 4：线性查找

文件：

```text
day04/linear_search.c
```

目标函数：

```c
int linear_search(int arr[], int n, int target);
```

规则：

```text
找到目标值 → 返回它的下标
找不到     → 返回 -1
```

代码：

```c
#include <stdio.h>

int linear_search(int arr[], int n, int target);

int main(void)
{
    int arr[] = {1, 2, 3, 4, 5};

    int n = sizeof(arr) / sizeof(arr[0]);

    int target;

    printf("请输入要查找的数字：");
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
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day04/linear_search.c -o build/linear_search
```

运行：

```bash
./build/linear_search
```

---

## `sizeof` 计算数组长度

在 `main` 中：

```c
int n = sizeof(arr) / sizeof(arr[0]);
```

含义：

```text
整个数组占用的字节数
÷
一个元素占用的字节数
=
数组元素个数
```

例如：

```text
5 个 int
20 / 4 = 5
```

---

## 注意：函数中不能这样获取原数组长度

函数：

```c
int linear_search(int arr[], int n, int target)
```

其中：

```c
int arr[]
```

作为函数参数时，本质上相当于：

```c
int *arr
```

因此函数通常不知道原数组长度，所以需要额外传入：

```c
n
```

这也是数据结构代码中非常常见的写法。

---

# 七、练习 5：冒泡排序

文件：

```text
day04/bubble_sort.c
```

初始数组：

```text
5 3 4 1 2
```

排序后：

```text
1 2 3 4 5
```

函数声明：

```c
void bubble_sort(int arr[], int n);
```

代码：

```c
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
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day04/bubble_sort.c -o build/bubble_sort
```

运行：

```bash
./build/bubble_sort
```

输出：

```text
1 2 3 4 5
```

---

# 八、冒泡排序原理

冒泡排序的核心：

```text
比较相邻元素
↓
如果前面大于后面
↓
交换
↓
较大的元素不断向右移动
```

例如：

```text
5 3 4 1 2
```

第一轮：

```text
5 3 4 1 2
↓
3 5 4 1 2
↓
3 4 5 1 2
↓
3 4 1 5 2
↓
3 4 1 2 5
```

第一轮结束后：

```text
5
```

已经位于正确位置。

因此第二轮不需要再比较最后一个元素。

所以内层循环条件写：

```c
j < n - 1 - i
```

---

# 九、今天最重要的新理解：数组传参

昨天函数学习中：

```c
void change(int x)
{
    x = 100;
}
```

调用：

```c
int a = 10;
change(a);
```

传入的是：

```text
a 的值的副本
```

所以修改 `x` 不会影响 `a`。

---

但今天：

```c
void bubble_sort(int arr[], int n)
```

其中：

```c
int arr[]
```

作为参数时，本质上相当于：

```c
int *arr
```

调用：

```c
bubble_sort(arr, n);
```

实际上传入的是：

```text
数组首元素地址的副本
```

所以函数能够通过这个地址访问并修改原数组中的元素。

可以理解为：

```text
main 中的 arr
      ↓
[5][3][4][1][2]
      ↑
bubble_sort 中的 arr
```

函数中的 `arr` 和 `main` 中的数组都能访问同一块数组数据。

因此：

```c
arr[j] = arr[j + 1];
```

修改后，`main` 中的原数组也发生改变。

---

## 重要结论

C 语言函数参数依然全部是：

```text
值传递
```

区别在于：

```text
普通变量：
传递的是数据值的副本

数组作为函数参数：
实际传递的是数组首元素地址的副本
```

因此：

```text
普通变量 → 修改副本通常不影响外部变量
数组参数 → 可以通过地址修改原数组元素
```

这正是 Day 05 指针学习的重要铺垫。

---

# 十、今日代码文件

```text
day04/
├── array_basic.c
├── array_stats.c
├── array_reverse.c
├── linear_search.c
└── bubble_sort.c
```

编译产物统一放：

```text
build/
```

不提交到 Git。

---

# 十一、今日知识总结

今天掌握：

```text
1. 数组用于保存一组相同类型的数据
2. C 数组下标从 0 开始
3. 长度为 n 的数组合法下标是 0 ~ n-1
4. 使用 for 循环遍历数组
5. scanf 输入数组元素时使用 &arr[i]
6. 最大值 / 最小值可以使用 arr[0] 初始化
7. 平均值计算时注意整数除法
8. 数组逆序可以通过左右元素交换完成
9. 对称下标可以写成 n - 1 - i
10. sizeof(arr) / sizeof(arr[0]) 可以在真实数组所在作用域中计算长度
11. 数组作为函数参数时通常需要额外传长度 n
12. 线性查找：逐个比较，找到返回下标，否则返回 -1
13. 冒泡排序：不断比较和交换相邻元素
14. 每一轮冒泡排序都会让一个较大元素进入正确位置
15. 数组传参时实际传入的是首元素地址的副本
16. C 语言依然是值传递
```

---

# 十二、今日验收

今日计划要求：

```text
数组 + 函数 + 冒泡排序
```

已经完成。

当前康复训练进度：

```text
Day 01 ✅ 基础语法、输入输出、条件判断
Day 02 ✅ 循环
Day 03 ✅ 函数
Day 04 ✅ 数组
Day 05 ⏳ 指针基础
```

---

# 十三、明日预告：Day 05 指针基础

明天进入整套康复训练非常重要的一关：

```text
地址
&
指针变量
*
解引用
指针修改变量
指针传参
```

重点练习：

```c
void swap(int *a, int *b);
```

今天数组传参时观察到的：

```text
函数为什么能够修改原数组？
```

将在指针学习中得到更完整的解释。

---

## Day 04 完成 ✅
