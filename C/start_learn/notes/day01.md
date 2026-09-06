# C语言康复训练 Day 01 学习总结

> 日期：2026-09-05  
> 主题：重新找回 C 语言手感

---

## 一、今日目标

Day 01 主要恢复以下内容：

- C 程序基本结构
- 变量
- 基本数据类型
- `printf` / `scanf`
- `sizeof`
- 算术运算符
- 关系运算符
- 逻辑运算符
- `if / else if / else`

今日最终验收：

> 能独立完成“输入三个整数，输出最大值”。

今天已完成并通过验收。

---

## 二、今日环境

固定工作目录：

```bash
cd ~/Documents/learning-plan/C/start_learn
```

当前编译器：

```text
Apple clang version 17.0.0
Target: arm64-apple-darwin
```

统一编译格式：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day01/源文件.c -o build/程序名
```

统一运行格式：

```bash
./build/程序名
```

说明：

- `day01/`：保存源码和笔记
- `build/`：保存编译生成的可执行文件
- `-g`：加入调试信息
- macOS 下可能生成 `.dSYM` 调试符号目录，这是正常现象

---

## 三、C 程序基本结构

最基本的 C 程序：

```c
#include <stdio.h>

int main(void)
{
    printf("Hello, C!\n");

    return 0;
}
```

理解：

```text
#include <stdio.h>
```

使用标准输入输出库。

```text
int main(void)
```

程序入口。

```text
return 0;
```

表示程序正常结束。

---

## 四、基本数据类型

今天恢复了：

```c
int
char
float
double
```

示例：

```c
int age = 18;
char grade = 'A';
float height = 1.75f;
double score = 95.5;
```

注意：

- 字符使用单引号：`'A'`
- 字符串使用双引号：`"Hello"`
- `float` 常量可以写成 `1.75f`

---

## 五、sizeof

示例：

```c
printf("sizeof(int) = %zu\n", sizeof(int));
printf("sizeof(char) = %zu\n", sizeof(char));
printf("sizeof(float) = %zu\n", sizeof(float));
printf("sizeof(double) = %zu\n", sizeof(double));
```

本机运行结果：

```text
sizeof(int) = 4
sizeof(char) = 1
sizeof(float) = 4
sizeof(double) = 8
```

重点：

> 不必死背所有类型大小，需要时用 `sizeof` 查看。

---

## 六、printf 与 scanf

### 1. 常用格式符

| 类型 | printf | scanf |
|---|---|---|
| `int` | `%d` | `%d` |
| `char` | `%c` | `%c` |
| `float` | `%f` | `%f` |
| `double` | `%f` | `%lf` |

重点：

```c
double score = 95.5;
printf("%f\n", score);
```

而输入 `double` 时：

```c
double score;
scanf("%lf", &score);
```

### 2. `&变量`

例如：

```c
scanf("%d", &age);
```

今天先记住：

```text
age   → 变量中的值
&age  → 变量的地址
```

`scanf` 要把输入的数据写进变量，所以需要变量地址。

指针部分会在 Day 05 彻底学习。

---

## 七、算术运算符

```c
+
-
*
/
%
```

示例：

```c
int a = 10;
int b = 3;
```

结果：

```text
a + b = 13
a - b = 7
a * b = 30
a / b = 3
a % b = 1
```

### 整数除法

```c
10 / 3
```

因为两边都是 `int`，结果是：

```text
3
```

小数部分会被舍掉。

例如：

```c
5 / 8
```

结果是：

```text
0
```

### `%`

```c
10 % 3
```

结果：

```text
1
```

注意：

```c
printf("a %% b = %d\n", a % b);
```

字符串里的 `%%` 用于真正输出 `%`。

---

## 八、关系运算符

```c
>
<
>=
<=
==
!=
```

例如：

```c
10 > 3
10 == 3
10 != 3
```

结果分别是：

```text
1
0
1
```

注意：

```c
a = 10;
```

是赋值。

```c
a == 10
```

是比较是否相等。

---

## 九、逻辑运算符

```c
&&
||
!
```

理解：

```text
&&   并且
||   或者
!    取反
```

示例：

```c
10 > 3 && 5 > 2
10 < 3 || 5 > 2
!(10 > 3)
```

结果：

```text
1
1
0
```

---

## 十、if / else if / else

基本结构：

```c
if (条件)
{
    ...
}
else if (条件)
{
    ...
}
else
{
    ...
}
```

执行规律：

1. 从上往下判断
2. 一旦某个分支成立并执行
3. 后续 `else if / else` 不再执行

示例：

```c
if (score >= 90)
{
    printf("Excellent\n");
}
else if (score >= 60)
{
    printf("Pass\n");
}
else
{
    printf("Fail\n");
}
```

测试结果：

```text
95 → Excellent
75 → Pass
50 → Fail
```

---

# 十一、今日正式练习

## 练习 1：两个整数计算

文件：

```text
day01/calc.c
```

完成内容：

- 输入两个整数
- 输出和
- 输出差
- 输出积
- 输出商
- 额外完成求余
- 额外处理除数为 0

关键逻辑：

```c
if (b != 0)
{
    printf("a / b = %d\n", a / b);
    printf("a %% b = %d\n", a % b);
}
else
{
    printf("不能除以0\n");
}
```

注意：

> 除数为 0 时，`/` 和 `%` 都不能执行。

---

## 练习 2：判断正数、负数、0

文件：

```text
day01/sign.c
```

逻辑：

```c
if (number > 0)
{
    printf("Positive\n");
}
else if (number < 0)
{
    printf("Negative\n");
}
else
{
    printf("Zero\n");
}
```

练习 2：通过。

---

## 练习 3：判断闰年

文件：

```text
day01/leap_year.c
```

闰年规则：

```text
能被 400 整除

或者

能被 4 整除并且不能被 100 整除
```

实现条件：

```c
if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
```

建议测试：

```text
2000 → 闰年
1900 → 非闰年
2024 → 闰年
2023 → 非闰年
```

练习 3：通过。

---

## 练习 4：输入三个整数，输出最大值

文件：

```text
day01/max3.c
```

最终写法：

```c
#include <stdio.h>

int main(void)
{
    int a, b, c;
    printf("Enter three integers: ");
    scanf("%d %d %d", &a, &b, &c);

    int max = a;

    if (b > max)
    {
        max = b;
    }

    if (c > max)
    {
        max = c;
    }

    printf("The maximum value is %d\n", max);

    return 0;
}
```

思路：

```text
先假设 a 最大
↓
比较 b
↓
必要时更新 max
↓
比较 c
↓
必要时再次更新 max
↓
输出 max
```

这是今天的最终验收题。

**Day 01 验收：通过。**

---

# 十二、今天最容易混淆的内容

## 1. printf 和 scanf 的 double

```text
printf double → %f
scanf  double → %lf
```

---

## 2. int 除法

```c
5 / 8
```

结果是：

```text
0
```

因为是整数除法。

---

## 3. scanf 中的 `&`

```c
scanf("%d", &number);
```

今天先记住：

> `scanf` 通常需要变量地址。

---

## 4. `=` 和 `==`

```c
a = 10;     // 赋值
a == 10     // 比较
```

---

## 5. `/` 和 `%` 的除数都不能是 0

判断：

```c
if (b != 0)
```

之后再进行：

```c
a / b
a % b
```

---

# 十三、Day 01 完成情况

- [x] C 程序基本结构
- [x] 变量
- [x] `int`
- [x] `char`
- [x] `float`
- [x] `double`
- [x] `sizeof`
- [x] `printf`
- [x] `scanf`
- [x] 算术运算符
- [x] 关系运算符
- [x] 逻辑运算符
- [x] `if / else if / else`
- [x] 两整数计算
- [x] 正负数判断
- [x] 闰年判断
- [x] 三数最大值
- [x] Day 01 最终验收

**Day 01：完成。**

---

# 十四、Day 02 开始指令

Day 02 主题：

# 循环彻底恢复

明天将恢复：

```c
for
while
do while
break
continue
```

重点不是只练习“输出 1～100”，而是开始写计算型循环。

Day 02 必须完成：

1. `1 + 2 + ... + 100`，分别使用 `for` 和 `while`
2. 输入一个正整数，求它有多少位
3. 求 `n!`
4. 判断一个整数是不是质数
5. 输出 1～100 之间所有质数
6. 打印九九乘法表
7. 提升练习：水仙花数

Day 02 最终验收：

> 能独立写出质数判断，并解释为什么循环只需要检查到某个范围。

---

## 明天开始时

进入工作目录：

```bash
cd ~/Documents/learning-plan/C/start_learn
```

Day 02 源码统一放：

```text
day02/
```

编译格式：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day02/源文件.c -o build/程序名
```

运行：

```bash
./build/程序名
```

然后从 `for` 循环正式开始 Day 02。
