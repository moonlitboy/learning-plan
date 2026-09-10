# AI Agent 学习笔记｜Day 01

## 主题

**LLM、Agent、Harness、Tool、Agent Loop、Environment**

今天的目标不是安装 Pi，也不是追求复杂操作，而是先把 Coding Agent 从“黑盒”拆开，理解它为什么能读取文件、执行命令、连续完成多步任务。

---

## 今天学了什么

今天完成并理解了：

- LLM 与 Agent 的区别
- Agent Harness 是什么
- Tool 是什么
- Tool Call 与 Tool Execution 的区别
- Agent Loop 为什么能让 Agent 连续工作
- Environment 为什么会影响 Tool 的执行结果
- Codex 的两次观察实验
- 使用 `git status` 与 `git diff` 验证 Agent 是否修改项目
- 最终完整解释 Agent 的基础执行链路

---

## 核心概念

### 1. LLM

LLM 是大语言模型。

我的理解：

> LLM 主要负责根据当前输入和上下文进行判断，并生成输出。  
> 输出可以是普通文本，也可以是一个 Tool Call（工具调用请求）。

最简单的普通模型调用可以理解为：

```text
用户输入
↓
LLM
↓
模型输出
```

LLM 本身不会因为“想执行命令”，就自动操作真实电脑。

例如：

```text
LLM：
“执行 clang hello.c”
```

这并不等于电脑已经真正执行了 `clang`。

---

### 2. Agent

我的理解：

> Agent 是由 LLM、Harness、Tools、Context、Loop、Environment 等组成，并且能够持续完成多步任务的智能体。

可以用下面的简化模型理解：

```text
Agent
=
LLM
+
Harness
+
Context
+
Tools
+
Loop
+
Environment
```

LLM 更像“大脑”，Tool 更像“手脚”。

---

### 3. Agent Harness

我的理解：

> Harness 是负责组织 LLM、Tools、Context、状态和权限，并维持 Agent 工作流程的框架。

今天先记住：

```text
Harness
=
Agent 的组织与调度框架
```

后续课程会继续拆：

- Instructions
- Tool Registry
- Permission Flow
- Session / State
- Context

---

### 4. Tool

我的理解：

> Tool 是 Agent 在真实环境中执行具体动作的接口。

例如：

```text
read
edit
write
bash
```

Tool 不只是“执行命令”。

例如：

```text
read
```

可以读取文件。

```text
edit
```

可以修改文件。

```text
bash
```

可以执行 Shell 命令。

---

### 5. Tool Call

我的理解：

> Tool Call 是 LLM 提出的结构化工具调用请求。

必须分清：

```text
Tool Call
≠
Tool 已经执行
```

例如 LLM 请求：

```text
read(path="c/hello.c")
```

这只是“模型希望调用 read”。

之后还需要 Harness 调度 Tool，Tool 才会真正访问文件。

---

### 6. Tool Result

我的理解：

> Tool Result 是 Tool 在真实环境中执行后得到的结果。

例如运行：

```bash
clang -fsyntax-only -Wall -Wextra -pedantic c/hello.c
```

可能得到：

```text
无错误
无警告
退出成功
```

这些结果会再次返回给 LLM，成为下一轮判断的新信息。

---

### 7. Agent Loop

我的理解：

> Agent Loop 是 LLM 判断、调用 Tool、获得结果、再次判断，并决定继续还是结束的循环过程。

核心流程：

```text
观察
↓
判断
↓
行动
↓
工具执行
↓
观察结果
↓
再次判断
↓
继续 / 结束
```

也可以理解为：

```text
LLM 判断
↓
Tool Call
↓
Tool 执行
↓
Tool Result
↓
LLM 再判断
↓
……
```

为什么 Agent 可以连续工作很多步？

因为 Harness 会维持 Agent Loop，把 Tool Result 再返回给 LLM，让 LLM 根据新的结果继续判断下一步。

---

### 8. Environment

我的理解：

> Environment 是 Agent 动作真正发生的运行环境。

例如：

```text
macOS
zsh
当前工作目录
文件系统
已安装的程序
PATH
环境变量
当前用户权限
```

同一个 LLM、同一个 Tool、同一个命令，在不同 Environment 中，结果可能不同。

例如：

```bash
clang hello.c -o hello
```

电脑 A 安装了 clang：

```text
Tool 执行
↓
Shell 找到 clang
↓
可以继续编译
```

电脑 B 没安装 clang：

```text
Tool 执行
↓
Shell 找不到 clang
↓
command not found
↓
错误结果返回 LLM
```

所以：

```text
Tool
=
可以尝试做什么

Environment
=
这个动作真正执行时会得到什么结果
```

---

## 今天最重要的三个层级

今天必须分清：

```text
模型“提出一个动作”
≠
Harness“允许 / 调度这个动作”
≠
操作系统“最终允许执行”
```

例如：

```text
LLM：
我要执行 clang

↓
Harness：
检查并调度 Tool

↓
Tool 执行层：
真正启动 clang

↓
操作系统 / Environment：
决定这个进程能不能运行以及运行结果
```

---

## Codex 实验 1｜只读 hello.c

给 Codex 的任务：

```text
阅读 c/hello.c，告诉我它做了什么，不要修改任何文件。
```

观察到：

```text
用户提出任务
↓
LLM 判断需要读取文件
↓
提出 read Tool Call
↓
Harness 调度 read
↓
Tool 读取 c/hello.c
↓
Tool Result 返回文件内容
↓
LLM 根据内容回答
```

完成后执行：

```bash
git status
git diff
```

结果：

```text
git diff 为空
```

说明没有已跟踪文件内容发生修改。

这个实验让我第一次真正看到：

```text
User
↓
LLM 判断
↓
Tool
↓
Tool Result
↓
LLM 回答
```

---

## Codex 实验 2｜检查 hello.c 是否可以编译

给 Codex 的任务：

```text
检查 c/hello.c 是否可以编译。
如果需要执行 clang，可以执行，但不要修改任何文件。
```

Codex 实际执行：

```bash
clang -fsyntax-only -Wall -Wextra -pedantic c/hello.c
```

其中：

```text
-fsyntax-only
```

表示只进行编译相关检查，不生成最终输出文件。

实际流程：

```text
用户提出任务
↓
LLM 判断需要用 clang 检查
↓
LLM 提出 Tool Call
↓
Harness 调度命令 Tool
↓
Tool 在当前 Environment 中执行 clang
↓
clang 返回检查结果
↓
Tool Result 返回 LLM
↓
LLM 根据结果判断
↓
最终回答
```

结果：

```text
没有错误
没有警告
```

之后再次执行：

```bash
git status
git diff
```

确认没有文件修改。

---

## git status 与 git diff

### git status

```bash
git status
```

作用：

> 查看 Git 仓库当前总体状态。

可以看到：

- 当前分支
- 哪些文件被修改
- 哪些文件是新建但未跟踪
- 哪些文件被删除
- 哪些修改已经 `git add`

简单记：

```text
git status
=
哪些文件发生了变化？
```

---

### git diff

```bash
git diff
```

作用：

> 查看未暂存的已跟踪文件具体改了哪些内容。

例如：

```diff
- printf("Hello, Agent!\n");
+ printf("Hello, Codex!\n");
```

简单记：

```text
git diff
=
具体改了哪里？
```

今天实验中 `git diff` 为空，说明没有未暂存的已跟踪文件内容修改。

---

## 今天的完整 Agent 基础链路

我现在可以自己解释：

```text
User
↓
Harness
↓
LLM
↓
Tool Call
↓
Tool 执行
↓
Tool Result
↓
LLM
```

逐层解释：

### User

用户写出任务或提示词。

### Harness

组织用户提示词、相关 Context、可用 Tools、状态和权限流程，并负责调度。

### LLM

根据当前信息判断问题应该如何解决，决定是否需要调用 Tool。

### Tool Call

LLM 提出的工具调用请求。

### Tool 执行

真正访问文件、执行命令等真实动作。

### Tool Result

工具执行后得到的真实结果。

### 最后回到 LLM

LLM 根据 Tool Result 继续判断：

```text
继续调用 Tool
```

或者：

```text
任务完成，输出最终结果
```

---

## Day 1 自查题

### 1. LLM 与 Agent 最大的区别是什么？

LLM 主要根据输入进行判断并生成输出，本身不会直接操作真实环境。

Agent 则通过 Harness、Tools、Loop、Environment 等，可以持续完成多步任务。

---

### 2. Agent 为什么能连续工作很多步？

因为 Agent 有 Agent Loop。

Harness 会把 Tool Result 再返回给 LLM，LLM 根据新的结果继续判断下一步，所以可以持续工作多轮。

---

### 3. Harness 在 Agent 中主要负责什么？

负责组织：

```text
LLM
Tools
Context
状态
权限
```

并维持整个 Agent 工作流程。

---

### 4. Tool 是 LLM 本身拥有的能力吗？

不是。

Tool 是 Harness / Agent 系统提供给模型使用的外部能力接口。

---

### 5. Codex 执行 `clang hello.c` 时，真正运行命令的是谁？

Tool 执行层。

LLM 只是提出调用请求，Harness 负责调度。

---

### 6. 如果没有任何 Tool，一个 Coding Agent 还能直接修改 SSD 吗？

不能。

如果没有任何能够操作文件或执行命令的接口，LLM 只能生成输出，不能直接修改真实磁盘。

---

## 今天我现在的理解

以前看到 Codex 自动读取文件、运行命令、继续分析，很容易把它理解成：

```text
“AI 自己什么都会做”
```

现在可以拆成：

```text
LLM
负责判断下一步

Harness
负责组织和调度

Tool
负责执行真实动作

Environment
决定真实执行结果

Tool Result
重新返回给 LLM

Agent Loop
让整个过程持续运行
```

所以 Coding Agent 并不是一个神秘整体。

它可以被拆成多个明确的层。

---

## Day 1 完成情况

- [x] 理解 LLM 与 Agent 的区别
- [x] 理解 Agent Harness
- [x] 理解 Tool
- [x] 理解 Tool Call 与 Tool Execution
- [x] 理解 Agent Loop
- [x] 理解 Environment
- [x] 完成 Codex 只读实验
- [x] 完成 Codex clang 检查实验
- [x] 使用 `git status`
- [x] 使用 `git diff`
- [x] 完成 6 道自查题
- [x] 能独立解释 Agent 基础链路

---

## 最后记住

```text
LLM 负责判断下一步做什么

Harness 负责组织 Context、Tools、状态和权限流程

Tool 在真实 Environment 中执行动作

Tool Result 返回 LLM

Agent Loop 让整个过程继续
```

安全方面今天先记住：

```text
模型提出动作
≠
Harness 允许 / 调度动作
≠
操作系统最终允许执行
```

---

## 下一步

```text
Day 02
Tool Calling
```

下一天重点会继续拆：

- Tool Definition
- Tool Name
- Tool Description
- Parameters / Schema
- Tool Call
- Tool Result
- 为什么工具描述会影响模型判断
- 为什么 Tool Result 要重新返回 LLM
