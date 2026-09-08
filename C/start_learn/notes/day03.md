# C 语言康复训练 Day 03：函数

> 今日主题：函数——从“能写”恢复到“会拆程序”

---

## 一、今日目标

今天重点恢复：

- 函数声明
- 函数定义
- 函数调用
- 形参与实参
- 返回值
- 局部变量
- 普通变量的值传递
- 模块化思维

今天最重要的目标不是“会写一个函数”，而是开始形成：

> **main() 负责整体流程，独立且较复杂的逻辑交给函数。**

后续学习数据结构时，会大量遇到类似：

```c
InitList();
Insert();
Delete();
Find();
Print();
```

所以函数必须熟练。

---

## 二、函数的基本结构

一个普通函数通常写成：

```c
返回值类型 函数名(参数)
{
    函数体
}
```

例如：

```c
int add(int a, int b)
{
    return a + b;
}
```

含义：

```text
int              返回值类型
add              函数名
int a, int b     形参
return           返回结果
```

---

## 三、函数声明、定义与调用

### 1. 函数声明

```c
int add(int a, int b);
```

函数声明的作用：

> 告诉编译器：后面有一个叫 `add` 的函数，它接收两个 `int`，返回一个 `int`。

函数声明只有函数基本信息，结尾有分号。

---

### 2. 函数定义

```c
int add(int a, int b)
{
    return a + b;
}
```

函数定义是真正规定函数如何工作。

---

### 3. 函数调用

```c
int result = add(x, y);
```

调用过程：

```text
x、y 的值
    ↓
传给 add()
    ↓
a、b 接收
    ↓
函数计算
    ↓
return
    ↓
result 接收结果
```

---

## 四、形参与实参

例如：

```c
int result = add(x, y);
```

函数定义：

```c
int add(int a, int b)
{
    return a + b;
}
```

其中：

```text
x、y  → 实参
a、b  → 形参
```

### 实参

调用函数时真正传进去的数据。

### 形参

函数定义中用于接收实参值的变量。

形参名字不需要和实参一样。

例如：

```c
int is_prime(int x);
```

调用：

```c
is_prime(n);
```

完全合法。

可以理解为：

```text
main 中 n 的值
      ↓ 复制
is_prime 中 x
```

---

## 五、C 语言普通变量传参：值传递

示例：

```c
#include <stdio.h>

void change(int n);

int main(void)
{
    int x = 50;

    printf("Before change function, num = %d\n", x);

    change(x);

    printf("After change function, num = %d\n", x);

    return 0;
}

void change(int n)
{
    n = 100;

    printf("Inside change function, n = %d\n", n);
}
```

运行结果：

```text
Before change function, num = 50
Inside change function, n = 100
After change function, num = 50
```

原因：

```text
main 中的 x
┌────┐
│ 50 │
└────┘

调用 change(x)
      ↓
把 50 复制一份给 n

change 中的 n
┌────┐
│ 50 │
└────┘

执行 n = 100

x                  n
┌────┐             ┌─────┐
│ 50 │             │ 100 │
└────┘             └─────┘
```

所以：

> **普通变量传参，本质上是值传递。**

函数中修改形参，不会直接修改外部原变量。

---

## 六、为什么 scanf 要写 &n

例如：

```c
scanf("%d", &n);
```

`scanf` 的任务不是读取 `n` 当前的值，而是要修改 `n`。

所以它需要知道：

```text
n 在内存中的地址
```

因此：

```c
&n
```

表示：

> `n` 的地址。

对比：

```text
add(x, y)
→ 只需要读取 x、y 的值
→ 直接传值

scanf("%d", &n)
→ 需要修改真正的 n
→ 传 n 的地址
```

这部分是 Day 05 指针学习的重要铺垫。

---

## 七、局部变量

例如：

```c
int max3(int a, int b, int c)
{
    int max = a;

    if (b > max)
        max = b;

    if (c > max)
        max = c;

    return max;
}
```

其中：

```c
int max = a;
```

`max` 是：

> **局部变量**

它只在 `max3()` 函数内部有效。

`main()` 不能直接访问它。

注意：

> “临时变量”是日常说法，更准确的术语是“局部变量”。

---

# 八、今日练习

## 练习 1：add()

文件：

```text
day03/add.c
```

示例结构：

```c
#include <stdio.h>

int add(int a, int b);

int main(void)
{
    int x = 5;
    int y = 10;

    int result = add(x, y);

    printf("The sum of %d and %d is %d\n", x, y, result);

    return 0;
}

int add(int a, int b)
{
    return a + b;
}
```

训练重点：

- 函数声明
- 函数调用
- 函数定义
- 参数
- 返回值

---

## 练习 2：值传递实验

文件：

```text
day03/value_pass.c
```

核心函数：

```c
void change(int n)
{
    n = 100;
}
```

结论：

> 修改形参 `n` 不会修改 `main()` 中的原变量。

---

## 练习 3：is_prime()

文件：

```text
day03/is_prime.c
```

函数声明：

```c
int is_prime(int n);
```

核心逻辑：

```c
int is_prime(int n)
{
    if (n <= 1)
        return 0;

    for (int i = 2; i * i <= n; i++)
    {
        if (n % i == 0)
            return 0;
    }

    return 1;
}
```

返回值设计：

```text
return 1 → 是质数
return 0 → 不是质数
```

调用：

```c
int result = is_prime(n);

if (result)
{
    printf("%d is a prime number.\n", n);
}
else
{
    printf("%d is not a prime number.\n", n);
}
```

---

## 练习 4：gcd()

文件：

```text
day03/gcd.c
```

函数声明：

```c
int gcd(int a, int b);
```

使用欧几里得算法：

```text
gcd(a, b) = gcd(b, a % b)
```

循环版：

```c
int gcd(int a, int b)
{
    while (b != 0)
    {
        int remainder = a % b;

        a = b;
        b = remainder;
    }

    return a;
}
```

例如：

```text
gcd(48, 18)

48 % 18 = 12
a = 18, b = 12

18 % 12 = 6
a = 12, b = 6

12 % 6 = 0
a = 6, b = 0

return 6
```

---

## 练习 5：max3()

文件：

```text
day03/max3.c
```

函数声明：

```c
int max3(int a, int b, int c);
```

函数：

```c
int max3(int a, int b, int c)
{
    int max = a;

    if (b > max)
        max = b;

    if (c > max)
        max = c;

    return max;
}
```

与 Day 01 的区别：

```text
Day 01：
main() 自己完成最大值计算

Day 03：
main() 调用 max3()
max3() 专门负责最大值计算
```

---

## 练习 6：factorial()

### 递归版

文件：

```text
day03/factorial.c
```

函数：

```c
int factorial(int n)
{
    if (n == 0)
        return 1;
    else
        return n * factorial(n - 1);
}
```

例如：

```text
factorial(5)
= 5 × factorial(4)
= 5 × 4 × factorial(3)
= 5 × 4 × 3 × factorial(2)
= 5 × 4 × 3 × 2 × factorial(1)
= 5 × 4 × 3 × 2 × 1 × factorial(0)
= 120
```

其中：

```c
if (n == 0)
    return 1;
```

是递归终止条件。

---

### 循环版

建议另存为：

```text
day03/factorial_iterative.c
```

函数：

```c
int factorial(int n)
{
    int result = 1;

    for (int i = 1; i <= n; i++)
    {
        result *= i;
    }

    return result;
}
```

编译：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day03/factorial_iterative.c -o build/day03_factorial_iterative
./build/day03_factorial_iterative
```

---

## 九、阶乘的整数范围问题

如果函数返回类型是：

```c
int
```

在常见环境中：

```text
int 最大值约为 2147483647
```

因此：

```text
12! = 479001600      可以表示
13! = 6227020800     已经超出 int 范围
```

所以当前 `int factorial(int n)` 更适合限制在：

```text
0 <= n <= 12
```

注意：

> C 中有符号整数溢出属于未定义行为，不能依赖溢出后的输出结果。

---

## 十、跨天同名文件的编译命名

Day 01 和 Day 03 可能有同名源码，例如：

```text
day01/max3.c
day03/max3.c
```

源码同名没问题，因为它们在不同目录中。

但如果都编译成：

```text
build/max3
```

后编译的程序会覆盖前一个。

所以跨天同名程序建议：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic -g day03/max3.c -o build/day03_max3
./build/day03_max3
```

例如：

```text
day01/max3.c → build/day01_max3
day03/max3.c → build/day03_max3
```

这样不会混淆。

---

# 十一、main() 的职责

今天最重要的程序结构：

```text
main()
├── 接收输入
├── 调用函数
└── 输出结果
```

函数：

```text
负责具体、独立、较复杂的计算或任务
```

注意：

> `main()` 不是完全“不能计算”。

更准确地说：

> **main() 可以做简单判断和流程控制，但尽量不要承担复杂、独立、可复用的逻辑。**

例如：

```c
if (result)
{
    printf("prime\n");
}
```

放在 `main()` 完全没问题。

而质数判断本身：

```c
is_prime(n)
```

应该拆成单独函数。

---

# 十二、今日验收

## 1. 函数声明与定义

```c
int add(int a, int b);
```

→ 函数声明

```c
int add(int a, int b)
{
    return a + b;
}
```

→ 函数定义

---

## 2. 实参与形参

```c
int result = add(x, y);
```

```text
x、y → 实参
a、b → 形参
```

---

## 3. 值传递

```c
change(x);
```

普通变量传递的是：

```text
值的副本
```

不是外部变量本身。

---

## 4. 局部变量

函数内部定义的变量，例如：

```c
int max = a;
```

属于：

```text
局部变量
```

外部不能直接访问。

---

## 5. 模块化思维

更推荐：

```c
int is_prime(int n);
int factorial(int n);

int main(void)
{
    // 输入
    // 调用函数
    // 输出
}
```

而不是：

```c
int main(void)
{
    // 输入
    // 质数判断全部逻辑
    // 阶乘全部逻辑
    // 输出
}
```

原因：

> 独立逻辑拆成函数后，程序更清晰、更容易维护，也更容易复用。

---

# 十三、今日核心总结

今天最重要的几个结论：

```text
1. 函数声明告诉编译器函数的基本信息。

2. 函数定义规定函数真正怎么工作。

3. 调用函数时，普通变量默认按值传递。

4. 实参是调用时传进去的值，形参是函数中接收值的变量。

5. 函数内部变量通常是局部变量。

6. main() 负责整体流程，独立且较复杂的逻辑交给函数。

7. 写程序时要主动思考：
   “这一段逻辑是不是应该拆成函数？”
```

---

# 十四、Day 03 完成情况

```text
✅ add()
✅ 函数声明 / 定义 / 调用
✅ 形参与实参
✅ 值传递实验
✅ is_prime()
✅ gcd()
✅ max3()
✅ factorial() 递归版
✅ factorial() 循环版
✅ 局部变量
✅ 模块化思维
✅ Day 03 最终验收
```

**Day 03 完成。**

下一天：

```text
Day 04：数组
```

将开始进入数据结构非常重要的前置内容：

- 一维数组
- 数组遍历
- 数组下标
- 数组作为函数参数
- 最大值 / 最小值 / 平均值
- 数组逆序
- 线性查找
- 冒泡排序

