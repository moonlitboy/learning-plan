# AI Agent 14 天训练｜Day 06

# 主动限制 Pi：自由不是越大越好

> 今日核心：**Tool 越多 ≠ Agent 越高级。**
>
> 应该根据任务只提供最少必要能力，这就是 **Least Privilege（最小权限原则）**。

---

## 一、今日目标

今天第一次主动控制 Pi 的能力边界，重点学习：

```text
--tools
--exclude-tools
--no-tools
--no-builtin-tools
```

并理解：

```text
Capability
=
Model 能力
× 可用 Context
× 可用 Tools
× Environment Permission
```

同一个模型，在不同 Tool 配置下，真实行动能力会明显不同。

---

# 二、Tool allowlist：只给任务需要的能力

## 1. 第一轮：只读 Agent

启动：

```bash
cd ~/Documents/agent-lab
pi --tools read,grep,find,ls
```

给 Pi 的任务：

```text
阅读 c/hello.c，分析代码目前做了什么，并检查是否存在明显问题。
只分析，不修改文件，也不要执行编译命令。
```

Pi 实际调用：

```text
read c/hello.c
```

没有出现：

```text
edit
write
bash
```

Pi 成功读取并分析了 `c/hello.c`，但没有修改文件，也没有执行编译。

退出后检查：

```bash
git status
git diff
```

结果：

```text
git diff 无修改
```

### 结论

```text
有 read
→ 可以读取和分析

没有 edit / write
→ 不能通过对应 Tool 修改文件

没有 bash
→ 不能通过 bash 执行 clang 等命令
```

---

# 三、第二轮：加入 edit，但不给 bash

启动：

```bash
pi --tools read,grep,find,ls,edit
```

任务：

```text
把 c/hello.c 中的

This is a new line.

修改为

Day 06 edit test.

只修改这一处。修改后告诉我改了什么，不要执行编译命令。
```

Pi 实际过程：

```text
read c/hello.c
↓
edit c/hello.c
↓
read c/hello.c
```

实际修改：

```diff
- printf("This is a new line.\n");
+ printf("Day 06 edit test.\n");
```

Pi 没有执行 `clang`。

### 关键观察

当时 Pi 显示了类似：

```text
Prioritizing developer compilation requirement
```

说明它知道项目中存在“修改 C 文件后应该编译”的规则。

但是当前没有 `bash`。

所以：

```text
Instruction 告诉模型应该做什么
≠
Tool 决定模型实际上能请求什么动作
```

即使项目规则希望它编译，没有 `bash`，它也不能真正执行 `clang`。

---

# 四、第三轮：加入 bash

在开放 `bash` 前先建立 Git checkpoint：

```bash
git status
git add c/hello.c
git commit -m "checkpoint before day06 bash experiment"
```

然后启动：

```bash
pi --tools read,grep,find,ls,edit,bash
```

任务：

```text
读取 c/hello.c，不要修改文件。
使用 clang -std=c17 -Wall -Wextra -Wpedantic 编译它，
将输出程序放到 /tmp/hello-day06，
然后告诉我编译结果。
```

Pi 实际过程：

```text
read c/hello.c

bash:
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /tmp/hello-day06
```

输出：

```text
(no output)
```

结果：

```text
编译成功
无 warning
无 error
```

### 关键理解

`bash` 不是“模拟终端”。

它是 Pi Harness 提供给模型的 Tool。

当模型请求 `bash` 后，Harness 会在真实环境中启动相应进程。

所以这次 `clang` 是真实执行的。

---

# 五、前三轮能力对比

```text
第一轮
read,grep,find,ls
→ 能看
→ 不能改
→ 不能执行命令
```

```text
第二轮
read,grep,find,ls,edit
→ 能看
→ 能改已有文件
→ 不能执行 shell 命令
```

```text
第三轮
read,grep,find,ls,edit,bash
→ 能看
→ 能改
→ 能真实启动进程
```

核心：

```text
同一个模型
+
不同 Tool 集合
=
不同真实行动能力
```

---

# 六、`--no-tools`

启动：

```bash
pi --no-tools
```

任务：

```text
读取 c/hello.c，告诉我里面打印了哪些内容。
```

Pi 回答：

```text
我目前没有可用的文件读取工具，无法直接读取 c/hello.c。
请把 c/hello.c 的内容贴出来，我可以马上告诉你它打印了哪些内容。
```

### 结论

```text
--no-tools
→ 默认不提供任何 Tool
```

但是：

```text
没有 Tool
≠
没有 LLM
```

LLM 仍然可以：

```text
理解问题
推理
聊天
说明自己的限制
```

只是不能通过 Tool：

```text
读取真实磁盘
修改文件
执行命令
```

可以理解成：

```text
LLM 还在
但“手”被拿掉了
```

---

# 七、`--no-builtin-tools`

启动：

```bash
pi --no-builtin-tools
```

再次要求：

```text
读取 c/hello.c，告诉我里面打印了哪些内容。
```

当前环境下，Pi 同样表示没有文件读取能力。

但必须分清：

```text
--no-tools
→ 默认禁用所有 Tool
```

```text
--no-builtin-tools
→ 禁用 Pi 内置 Tool
→ Extension / 自定义 Tool 仍可能存在
```

所以：

```text
当前表现可能一样
≠
配置语义完全一样
```

现在没有额外 Extension Tool，因此两者看起来很像。

---

# 八、`--exclude-tools`

启动：

```bash
pi --exclude-tools bash,write,edit
```

任务：

```text
读取 c/hello.c，告诉我里面打印了哪些内容。
然后尝试判断它是否可以编译，但不要让我手动提供文件内容。
```

Pi 成功：

```text
read c/hello.c
```

并读取到输出内容：

```text
Hello, Agent!
Have a great day!
Day 06 edit test.
```

但没有真正执行 `clang`。

Pi 只能根据源码判断：

```text
“应当可以编译通过”
```

### 重点

```text
--tools
→ 白名单思想
→ 只提供指定 Tool
```

```text
--exclude-tools
→ 从当前可用 Tool 中排除指定 Tool
```

这次：

```text
read 仍然存在
bash 被排除
edit 被排除
write 被排除
```

所以结果是：

```text
能读
能分析
不能修改
不能真实执行编译
```

---

# 九、推理 ≠ 验证

Pi 在没有 `bash` 时说：

```text
“应当可以编译通过”
```

这属于：

```text
根据源码静态判断
→ inference / 推理
```

真正运行：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c
```

并得到成功结果，才属于：

```text
verification / 验证
```

必须分清：

```text
看起来应该成功
≠
已经真实验证成功
```

---

# 十、为什么 read-only 也不是绝对安全

只给：

```bash
pi --tools read,grep,find,ls
```

虽然不能修改文件，但仍然可能读取敏感内容。

例如：

```text
.env
config.json
private-notes.txt
```

如果 `read` 能访问：

```text
敏感文件
↓
Tool Result
↓
进入 Context
↓
模型可能看到内容
```

所以：

```text
Read-only
≠
No data exposure
```

也就是说：

```text
没有写权限风险
≠
没有信息泄露风险
```

---

# 十一、为什么没有 bash 也不等于绝对安全

没有 `bash` 只是少了一种非常强的执行能力。

但如果仍然有：

```text
edit
write
```

Agent 依然可以修改文件。

所以不能只问：

```text
“有没有 bash？”
```

应该问：

```text
“当前到底提供了哪些 Tools？”
```

---

# 十二、edit 和 write 的风险

两者都属于文件修改能力，但方式不同。

```text
edit
→ 对已有内容进行局部修改
```

```text
write
→ 写入文件内容
→ 可能创建文件
→ 也可能整体重写文件
```

不能简单认为：

```text
edit = 安全
write = 危险
```

更准确的是：

```text
二者都有修改风险
只是能力形态和影响范围不同
```

---

# 十三、Least Privilege：最小权限原则

今天最重要的安全原则：

```text
任务需要什么
↓
只给什么
```

例如：

### 代码审查

```text
read
grep
find
ls
```

通常已经够用。

### 小范围修改

```text
read
edit
```

### 需要真实编译

```text
read
edit
bash
```

不要因为“以后可能用到”就顺手把所有 Tool 全开。

---

# 十四、Harness Tool 限制 ≠ OS Sandbox

例如：

```bash
pi --tools read,grep,find,ls
```

只是：

```text
Pi Harness 层
控制给不给模型这些 Tool
```

它不是：

```text
OS 级 Sandbox
```

必须继续记住：

```text
模型提出动作
≠
Harness 提供 / 允许 Tool
≠
操作系统最终允许执行
```

这是三个不同层级。

---

# 十五、今日四个参数总结

## `--tools`

```bash
pi --tools read,grep,find,ls
```

含义：

```text
只提供指定 Tool
```

适合做明确的 Tool allowlist。

---

## `--exclude-tools`

```bash
pi --exclude-tools bash,write,edit
```

含义：

```text
从当前可用 Tool 中排除指定 Tool
```

---

## `--no-tools`

```bash
pi --no-tools
```

含义：

```text
默认禁用所有 Tool
```

LLM 还在，但没有通过 Tool 操作真实环境的能力。

---

## `--no-builtin-tools`

```bash
pi --no-builtin-tools
```

含义：

```text
禁用 Pi 内置 Tool
```

但：

```text
Extension / 自定义 Tool
仍可能存在
```

---

# 十六、今日自查答案

## 1. 为什么第一轮 Pi 能分析 `hello.c`，但不能修改？

因为有：

```text
read
```

但没有：

```text
edit
write
```

所以可以读取和分析，但没有对应文件修改 Tool。

---

## 2. 为什么第二轮项目规则希望编译，但 Pi 没有执行 `clang`？

因为没有：

```text
bash
```

项目指令只能告诉模型：

```text
“应该怎么做”
```

不能凭空创建不存在的 Tool 能力。

---

## 3. `--no-tools` 和 `--no-builtin-tools` 有什么区别？

```text
--no-tools
→ 默认禁用全部 Tool
```

```text
--no-builtin-tools
→ 禁用 Pi 自带 Tool
→ Extension / 自定义 Tool 仍可能存在
```

---

## 4. Tool allowlist 的价值是什么？

针对具体任务，只提供最少必要 Tool：

```text
减少能力范围
↓
降低风险
↓
更容易观察
↓
更容易验证
```

---

## 5. 为什么 read-only Agent 仍然可能泄露敏感内容？

因为它仍然能读取文件。

例如：

```text
.env 中的 API Key
```

文件内容可能进入：

```text
Tool Result
→ Context
→ 模型
```

所以只读不代表没有数据泄露风险。

---

## 6. 为什么禁止 bash 不等于绝对安全？

因为可能仍然有：

```text
edit
write
```

这些 Tool 一样可以修改文件。

---

## 7. 为什么代码审查不应该顺手开放 edit 和 bash？

因为代码审查本身通常只需要：

```text
读取
搜索
分析
```

按照：

```text
Least Privilege
```

不需要的能力就不应该提供。

---

## 8. `--tools read,grep,find,ls` 是 OS Sandbox 吗？

不是。

它只是：

```text
Harness 级 Tool 配置
```

而不是：

```text
OS 级权限隔离
```

---

# 十七、今天最终掌握

今天已经能够解释：

```text
Tool 越多
≠
Agent 越高级
```

真正应该追求的是：

```text
任务所需能力
+
最少权限
+
可观察
+
可验证
```

并且已经亲手验证：

```text
只读
↓
加入 edit
↓
加入 bash
```

Agent 的真实行动能力是如何一步步增加的。

---

# Day 06 完成

完成状态：

- [x] 理解 Tool allowlist
- [x] 使用 `--tools`
- [x] 使用 `--exclude-tools`
- [x] 使用 `--no-tools`
- [x] 使用 `--no-builtin-tools`
- [x] 完成只读实验
- [x] 完成 edit 实验
- [x] 完成 bash 实验
- [x] 使用 `git diff` 独立验证修改
- [x] 理解 read-only 仍有数据泄露风险
- [x] 理解没有 bash 也不等于绝对安全
- [x] 理解 Least Privilege
- [x] 理解 Harness Tool 限制 ≠ OS Sandbox

> **Day 06：完成。**
