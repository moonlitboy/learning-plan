# AI Agent 14 天基础训练｜Day 02

## 今日主题

**Tool Calling：Agent 的“手”到底是什么**

今天的目标是彻底理解：

- Tool Definition
- Tool Name
- Tool Description
- Parameters / Schema
- Tool Call
- Tool Execution
- Tool Result
- Tool Registry
- Tool 与 Harness 的关系
- 为什么 Tool Result 要重新进入 Agent Loop
- 为什么减少 Tools 会缩小 Agent 的能力范围

---

## 一、今天最核心的流程

```text
User
  ↓
Harness
  ↓
LLM
  ↓
Tool Call
  ↓
Harness 检查 / 调度
  ↓
Tool 真正执行
  ↓
Tool Result
  ↓
结果重新进入 Context
  ↓
LLM 再思考下一步
```

必须牢牢记住：

```text
Tool Call
≠
Tool 已经执行
```

Tool Call 只是：

> LLM 提出的结构化工具调用请求。

真正执行 Tool 的是 Harness / 程序。

---

## 二、Tool Definition 是什么

一个 Tool 不能只告诉模型名字。

通常至少要有：

```text
Tool Name
Description
Parameters / Schema
```

例如：

```text
Tool Name:
read

Description:
读取指定路径的文件内容

Parameters:
path: string
```

模型才知道：

- 工具叫什么
- 工具能做什么
- 调用时需要什么参数
- 参数是什么类型

因此：

```text
Tool Definition
↓
告诉 LLM 有什么工具以及怎么调用
↓
LLM 决定是否使用
↓
生成 Tool Call
```

---

## 三、Tool Call 是什么

例如模型想读取：

```text
c/hello.c
```

可能生成类似请求：

```json
{
  "tool": "read",
  "arguments": {
    "path": "c/hello.c"
  }
}
```

这仍然只是：

```text
“我想读取这个文件”
```

不是模型自己已经读取了文件。

---

## 四、Tool Result 是什么

Harness 真正执行 Tool 后，会产生 Tool Result。

Tool Result 可能是：

### 成功结果

```text
文件内容读取成功
```

### 失败结果

```text
文件不存在
```

或者：

```text
clang 编译失败
```

因此：

> Tool Result 无论成功还是失败，都是一次工具调用返回的新信息。

Tool Result 会重新进入 Agent Loop，LLM 再根据结果继续判断。

---

## 五、为什么 Tool Result 要返回给 LLM

假设用户只说：

```text
读取 c/hello.c，告诉我它做了什么。
```

用户并没有把文件内容直接放进 Prompt。

所以 LLM 一开始并不知道文件内容。

流程：

```text
LLM
↓
需要知道文件内容
↓
Tool Call: read
↓
Harness 执行
↓
Tool Result: 文件内容
↓
结果进入 Context
↓
LLM 才能分析代码
```

所以：

```text
硬盘上存在的信息
≠
模型已经知道的信息
```

---

## 六、Parameters / Schema 为什么重要

例如 Tool 要求：

```text
path: string
```

正确调用：

```json
{
  "tool": "read",
  "arguments": {
    "path": "c/hello.c"
  }
}
```

错误调用可能是：

```json
{
  "tool": "read",
  "arguments": {
    "filename": 123
  }
}
```

问题：

```text
filename
→ 参数名不符合 Schema

123
→ 类型不是 string
```

Schema 的作用：

- 告诉模型怎么调用 Tool
- 规定参数结构
- 方便 Harness 校验参数是否合法

---

## 七、如果模型请求一个不存在的 Tool

例如 Harness 只提供：

```text
read
edit
```

模型却请求：

```text
delete_database(...)
```

流程可能是：

```text
LLM 提出 Tool Call
↓
Harness 查询 Tool Registry
↓
发现不存在
↓
调用失败
↓
错误信息返回给 LLM
```

所以：

```text
模型提出动作
≠
Harness 一定能够执行
```

模型也不能凭空创造一个真正可以执行的 Tool。

---

## 八、read / edit / write / bash 的区别

```text
read
→ 读取内容

edit
→ 修改已有内容

write
→ 写入 / 创建内容

bash
→ 执行 shell 命令
```

### 很重要的结论

禁止某个 Tool，不代表相关能力一定彻底消失。

例如：

```text
没有 edit / write
但仍有 bash
```

Agent 仍可能通过 shell 间接修改文件。

反过来：

```text
禁止 bash
但仍有 edit / write
```

Agent 仍然可以修改文件，只是不能执行 shell 命令。

因此不能只看 Tool 名字，而要看：

```text
Agent 当前整体还拥有哪些 Tools
+
这些 Tools 实际能做什么
```

---

## 九、模型知道怎么做 ≠ Agent 有能力做

假设 Agent 只有：

```text
read
```

LLM 即使已经知道：

```text
return 0
```

后面缺少分号，也只能：

```text
读取
↓
分析
↓
告诉用户如何修改
```

但不能真正修改硬盘上的文件。

所以：

```text
模型能力
≠
Agent 实际行动能力
```

可以把 Agent 能力理解为：

```text
Capability
=
Model 能力
× 可用 Context
× 可用 Tools
× Environment Permission
```

---

## 十、今天的 Codex 实验

### 实验准备

进入：

```bash
cd ~/Documents/agent-lab
```

先确认：

```bash
git status
```

结果：

```text
On branch main
nothing to commit, working tree clean
```

然后人工在：

```text
c/hello.c
```

中故意制造一个小语法错误：

```c
return 0
```

删除原本的分号。

随后：

```bash
git diff
```

确认改动。

---

## 十一、交给 Codex 的任务

任务要求：

```text
检查 c/hello.c 是否存在问题。

如果发现问题：
1. 先说明发现了什么
2. 修复问题
3. 使用 clang 检查或编译
4. 根据编译结果判断是否还需要继续处理

只处理这个问题，不要做无关修改。
```

---

## 十二、Codex 实际发生的过程

大致过程：

```text
User
↓
Codex / Harness
↓
检查当前目录与项目文件
↓
检查是否存在 AGENTS.md
↓
读取 c/hello.c
↓
发现 return 0 缺少 ;
↓
修改文件
↓
执行 clang 检查
↓
clang 返回退出码 0
↓
LLM 判断无需继续修改
↓
最终回答
```

这次真实看到了：

```text
read
↓
observe
↓
edit
↓
bash
↓
observe
```

---

## 十三、关于 AGENTS.md

本项目当前没有 `AGENTS.md`，这是正常的。

Codex 之所以搜索它，是为了确认项目中是否存在给 Agent 的项目级工作规则。

可以粗略理解为：

```text
README.md
→ 主要给人看

AGENTS.md
→ 主要给 Coding Agent 看
```

例如以后可以写：

```md
# Project Instructions

- 修改 C 文件后必须使用 clang 检查
- 不要删除文件
- 只修改完成任务所必需的内容
```

Day 03 会正式学习：

- AGENTS.md
- Project Instructions
- Context
- 为什么这些规则会影响 Agent 行为

---

## 十四、clang 退出码 0 怎么理解

今天 Codex 使用 clang 检查代码。

如果退出码：

```text
0
```

更准确表示：

> 这一次 clang 检查成功完成，在当前检查参数下没有发现错误。

不能理解成：

```text
程序百分之百没有任何逻辑 Bug
```

因为：

```text
能编译
≠
逻辑一定正确
```

---

## 十五、今天的关键理解

### 1. Tool Call

```text
不是工具已经执行
而是结构化工具调用请求
```

### 2. Tool Result

```text
工具执行后的返回信息
成功和失败都可以是 Result
```

### 3. Harness

```text
负责接收 Tool Call
查找 Tool
检查参数
执行 / 调度 Tool
把 Result 返回 Agent Loop
```

### 4. Agent Loop

```text
LLM 思考
↓
Tool Call
↓
Tool Result
↓
LLM 再思考
↓
继续或结束
```

### 5. Tool 数量与能力范围

```text
Tools 越少
→
Agent 可执行的动作范围通常越小
```

---

## 十六、今日自查题与答案

### 1. Tool Call 是不是表示命令已经执行？

不是。

Tool Call 只是：

```text
结构化工具调用请求
```

---

### 2. Tool Result 的作用是什么？

把工具调用结果通过 Harness 返回 Agent Loop / Context，让 LLM 根据新信息思考下一步。

---

### 3. 为什么 Parameters / Schema 很重要？

因为它决定：

```text
Tool 应该用什么参数
参数叫什么
参数是什么类型
应该怎样正确调用
```

Harness 也可以据此校验调用是否合法。

---

### 4. 如果 LLM 请求 Harness 没有提供的 Tool，会发生什么？

```text
LLM 提出 Tool Call
↓
Harness 查找
↓
Tool 不存在
↓
调用失败
↓
错误结果返回 LLM
```

模型不能凭空创造一个真正可执行的 Tool。

---

### 5. 禁止 bash 后，Agent 就一定不能修改文件吗？

不一定。

如果还有：

```text
edit
write
```

仍然可以修改文件。

---

### 6. 为什么减少 Tools 可以减少 Agent 的能力范围？

因为不同 Tool 对应不同真实能力：

```text
read
→ 读

edit / write
→ 改

bash
→ 执行 shell
```

减少 Tools，就是缩小 Agent 可以采取的动作空间。

---

## 十七、今天我自己的理解

今天最重要的一点是：

```text
LLM 只负责判断下一步做什么
↓
Tool Call 只是请求
↓
Harness 才负责真正执行 Tool
↓
Tool Result 再回给 LLM
↓
Agent Loop 继续
```

因此：

```text
模型知道怎么做
≠
Agent 有能力真的去做
```

Agent 能做什么，还要取决于：

```text
Context
Tools
Harness
Environment
Permission
```

---

## 十八、Day 02 完成情况

- [x] 理解 Tool Definition
- [x] 理解 Tool Name / Description
- [x] 理解 Parameters / Schema
- [x] 理解 Tool Call
- [x] 理解 Tool Execution
- [x] 理解 Tool Result
- [x] 理解成功与失败都可以是 Tool Result
- [x] 理解不存在的 Tool 无法凭空调用
- [x] 理解 read / edit / write / bash 的区别
- [x] 完成 Codex 实验
- [x] 能解释 `read → edit → bash → observe`
- [x] 理解减少 Tools 会缩小 Agent 的能力范围

---

## Day 02 一句话总结

> **LLM 提出 Tool Call；Harness 负责检查并执行 Tool；Tool Result 重新进入 Context；LLM 再决定下一步。**

---

## 下一天

**Day 03｜Context：模型这一刻到底“知道”什么**

下一天重点：

```text
System Prompt
User Prompt
Project Instructions
AGENTS.md
Conversation History
Tool Results
File Content
Context Window
```

并正式创建 `AGENTS.md` 做对照实验。
