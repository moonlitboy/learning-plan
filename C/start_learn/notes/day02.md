# C语言康复训练 Day 02：循环彻底恢复

> 日期：2026-09-06  
> 主题：`for`、`while`、`do...while`、`break`、`continue`、嵌套循环  
> 今日状态：✅ 已完成全部必做内容 + 提升练习

---

# 一、今日目标

今天重点恢复：

- `for`
- `while`
- `do...while`
- `break`
- `continue`
- 计算型循环
- 嵌套循环
- 状态变量
- 质数判断与循环范围优化

今天的重点不是只会打印数字，而是能真正用循环解决计算问题。

---

# 二、for 循环

基本结构：

```c
for (初始化; 条件; 更新)
{
    循环体;
}
```

执行顺序：

```text
初始化
↓
判断条件
↓
执行循环体
↓
更新变量
↓
再次判断
```

例如：

```c
for (int i = 1; i <= 10; i++)
{
    printf("%d\n", i);
}
```

---

# 三、for 求和

目标：

```text
1 + 2 + 3 + ... + 100
```

```c
#include <stdio.h>

int main(void)
{
    int sum = 0;

    for (int i = 1; i <= 100; i++)
    {
        sum += i;
    }

    printf("Sum: %d\n", sum);
    return 0;
}
```

输出：

```text
Sum: 5050
```

其中：

```c
sum += i;
```

等价于：

```c
sum = sum + i;
```

`sum` 是累加器。

---

# 四、while 循环

基本结构：

```c
while (条件)
{
    循环体;
}
```

`while` 与 `for` 的本质都可以理解为：

```text
初始化 → 判断 → 执行 → 更新 → 再判断
```

练习：

```c
#include <stdio.h>

int main(void)
{
    int sum = 0;
    int i = 1;

    while (i <= 100)
    {
        sum += i;
        i++;
    }

    printf("Sum: %d\n", sum);
    return 0;
}
```

注意：`while` 不会自动帮你更新变量，如果忘记 `i++`，可能产生死循环。

---

# 五、统计整数位数

核心思想：整数每除一次 `10`，就相当于去掉最右边一位。

```text
12345 / 10 = 1234
1234  / 10 = 123
123   / 10 = 12
12    / 10 = 1
1     / 10 = 0
```

```c
while (number != 0)
{
    number /= 10;
    count++;
}
```

例如输入 `100`，得到 `3` 位。

---

# 六、do...while

基本结构：

```c
do
{
    循环体;
} while (条件);
```

区别：

```text
while      → 先判断，再执行，可能一次都不执行
do...while → 先执行，再判断，至少执行一次
```

因此统计数字位数时，`do...while` 可以自然处理：

```text
0 → 1 位
```

```c
do
{
    number /= 10;
    count++;
} while (number != 0);
```

注意最后有分号 `;`。

---

# 七、阶乘

```text
5! = 5 × 4 × 3 × 2 × 1 = 120
0! = 1
```

```c
#include <stdio.h>

int main(void)
{
    int number;
    int factorial = 1;

    printf("Enter a number: ");
    scanf("%d", &number);

    for (int i = 1; i <= number; i++)
    {
        factorial *= i;
    }

    printf("Factorial of %d is %d\n", number, factorial);
    return 0;
}
```

累加初值通常是：

```c
sum = 0;
```

累乘初值通常是：

```c
factorial = 1;
```

因为任何数乘 `0` 都会变成 `0`。

---

# 八、break 与 continue

## break

```text
立即退出当前循环
```

## continue

```text
跳过本轮剩余代码，直接进入下一轮
```

综合练习：

```c
#include <stdio.h>

int main(void)
{
    for (int i = 1; i <= 10; i++)
    {
        if (i == 5)
        {
            break;
        }

        if (i % 2 == 0)
        {
            continue;
        }

        printf("%d\n", i);
    }

    return 0;
}
```

输出：

```text
1
3
```

执行逻辑：

```text
i = 1 → 输出
i = 2 → continue
i = 3 → 输出
i = 4 → continue
i = 5 → break，整个循环结束
```

核心区别：

```text
continue → 只跳过当前一轮
break    → 结束整个当前循环
```

---

# 九、质数判断

质数：

> 大于 1，并且除了 1 和它本身以外，不能被其他正整数整除。

如果：

```c
n % i == 0
```

说明找到了因子，`n` 不是质数。

---

# 十、为什么质数只检查到 √n

如果：

```text
n = a × b
```

那么 `a` 和 `b` 不可能同时大于 `√n`。

如果两者都大于：

```text
a > √n
b > √n
```

那么：

```text
a × b > √n × √n = n
```

但前提又是：

```text
a × b = n
```

矛盾。

因此：

> 如果 `n` 是合数，一对因子中至少有一个不超过 `√n`。

所以只需要检查：

```text
2 ～ √n
```

C 中不需要 `sqrt()`，可以写成：

```c
for (int i = 2; i * i <= n; i++)
```

为什么必须是 `<=`？

例如：

```text
49 = 7 × 7
```

如果写：

```c
i * i < n
```

那么 `7 * 7 < 49` 为假，就会漏掉因子 `7`。

正确：

```c
i * i <= n
```

---

# 十一、质数判断完整程序

```c
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
```

建议测试：

```text
1   → 不是质数
2   → 是质数
4   → 不是质数
17  → 是质数
25  → 不是质数
49  → 不是质数
```

---

# 十二、输出 1～100 所有质数

```c
#include <stdio.h>

int main(void)
{
    for (int number = 2; number <= 100; number++)
    {
        int is_prime = 1;

        for (int i = 2; i * i <= number; i++)
        {
            if (number % i == 0)
            {
                is_prime = 0;
                break;
            }
        }

        if (is_prime)
        {
            printf("%d\n", number);
        }
    }

    return 0;
}
```

输出：

```text
2 3 5 7 11 13 17 19 23 29
31 37 41 43 47 53 59 61 67 71
73 79 83 89 97
```

关键点：

```c
int is_prime = 1;
```

必须放在外层循环里面，因为每判断一个新数字，都要重新初始化状态。

另外：

```c
if (is_prime)
```

等价于：

```c
if (is_prime != 0)
```

在 C 中：

```text
0    → false
非 0 → true
```

---

# 十三、嵌套循环中的 break

在：

```c
for (...)        // 外层
{
    for (...)    // 内层
    {
        break;
    }
}
```

`break` 只退出最近的一层循环，也就是内层循环。

外层循环仍会继续下一轮。

---

# 十四、九九乘法表

```c
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
```

理解：

```text
外层 i：控制第几行
内层 j：控制当前行打印几个式子
```

关键条件：

```c
j <= i
```

它决定乘法表呈三角形。

---

# 十五、水仙花数

三位水仙花数满足：

```text
abc = a³ + b³ + c³
```

例如：

```text
153 = 1³ + 5³ + 3³
```

拆三位数：

```c
int hundreds = number / 100;
int tens = (number / 10) % 10;
int units = number % 10;
```

完整代码：

```c
#include <stdio.h>

int main(void)
{
    for (int number = 100; number <= 999; number++)
    {
        int hundreds = number / 100;
        int tens = (number / 10) % 10;
        int units = number % 10;

        if (number ==
            hundreds * hundreds * hundreds +
            tens * tens * tens +
            units * units * units)
        {
            printf("%d\n", number);
        }
    }

    return 0;
}
```

运行结果：

```text
153
370
371
407
```

---

# 十六、今天容易出错的地方

## 1. scanf 要传地址

错误：

```c
scanf("%d", n);
```

正确：

```c
scanf("%d", &n);
```

## 2. `while` 要自己更新循环变量

忘记 `i++` 可能导致死循环。

## 3. `do...while` 最后有分号

```c
} while (condition);
```

## 4. 累加和累乘初值不同

```text
累加：0
累乘：1
```

## 5. `is_prime` 每检查一个新数字都要重新初始化

## 6. `n <= 1` 都不是质数

## 7. 质数检查范围要用

```c
i * i <= n
```

不能漏掉完全平方数的平方根因子。

---

# 十七、今日完成的代码

```text
day02/
├── for_basic.c
├── sum_for.c
├── sum_while.c
├── digit_count.c
├── digit_count_do_while.c
├── factorial.c
├── break_continue.c
├── prime.c
├── primes_1_100.c
├── multiplication_table.c
└── narcissistic.c
```

编译产物统一放在：

```text
build/
```

---

# 十八、统一编译方式

例如：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day02/prime.c -o build/prime
./build/prime
```

九九乘法表：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day02/multiplication_table.c -o build/multiplication_table
./build/multiplication_table
```

水仙花数：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day02/narcissistic.c -o build/narcissistic
./build/narcissistic
```

---

# 十九、Day 02 最终验收

- [x] `for`
- [x] `while`
- [x] `do...while`
- [x] `break`
- [x] `continue`
- [x] 求 `1 + 2 + ... + 100`
- [x] 统计整数位数
- [x] 阶乘
- [x] 质数判断
- [x] 理解为什么只检查到 `√n`
- [x] 输出 1～100 所有质数
- [x] 嵌套循环
- [x] 九九乘法表
- [x] 三位水仙花数

---

# 二十、今日一句话总结

> **循环的本质，是通过“初始化 → 条件判断 → 执行 → 更新”让程序重复处理数据。**

今天已经从“会写循环语法”恢复到了“能用循环解决实际问题”的程度。

---

# Day 02 完成 ✅

下一天：

```text
Day 03：函数
```

重点：

```text
函数定义
参数
返回值
局部变量
函数声明
模块化思维
```

为后续数据结构中的：

```text
InitList()
Insert()
Delete()
Find()
Print()
```

打基础。
