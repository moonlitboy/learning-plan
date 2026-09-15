# AI Agent 14 天基础训练｜Day 11

## 主题：Codex 拆解——重新看你已经在用的 Agent

> 今日目标：把前 10 天学到的 Harness、Context、Tools、Permission、Sandbox、Execution、Verification 等概念重新套回 Codex，理解 Codex 到底是怎样工作的，而不是只把它看成“一个会写代码的 AI”。

---

## 一、今天的核心结论

### 1. Codex ≠ LLM

Codex 不是底层大模型本身。

更准确地说：

```text
Codex = Coding Agent / Agent 系统
```

它里面包含：

- LLM
- Agent Harness
- Context
- Tools
- Permission Flow
- Sandbox / Execution
- Session / UI
- Verification 相关能力

LLM 主要负责：

```text
理解任务
↓
推理
↓
决定下一步动作
↓
提出 Tool Request
```

Codex Harness 则负责：

```text
组织 Context
↓
提供 Tool
↓
处理权限
↓
执行 Tool
↓
把 Tool Result 返回给模型
```

---

## 二、Pi 对照实验：观察 Agent Loop

### 实验命令

```bash
pi --mode json --tools read,grep,find,ls   "列出项目结构，不要修改文件。"
```

### 观察到的真实事件流

先出现：

```text
session
→ agent_start
→ turn_start
→ user message
```

然后模型提出：

```text
toolcall_start
toolName: ls
```

参数类似：

```json
{
  "path": ".",
  "limit": 500
}
```

接着才真正执行：

```text
tool_execution_start
↓
tool_execution_end
```

得到目录结果之后，Harness 又把结果包装成：

```text
role: toolResult
```

重新送回 Agent Loop。

### 结论

```text
Tool Call
≠
Tool 已经执行
```

完整流程：

```text
LLM
 ↓
Tool Call
 ↓
Harness
 ↓
Tool Execution
 ↓
Tool Result
 ↓
重新进入 Context
 ↓
下一轮 LLM
```

---

## 三、一次模型调用可以提出多个 Tool Call

第二轮中，Pi 一次提出了多个 `find`：

```text
find c/
find experiments/
find notes/
find .pi/
```

这说明：

```text
一次 LLM 调用
不一定只有一个 Tool Call
```

可以是：

```text
LLM
 ↓
Tool Call A
Tool Call B
Tool Call C
Tool Call D
 ↓
Harness 执行
 ↓
A Result
B Result
C Result
D Result
 ↓
全部返回 Context
 ↓
下一轮 LLM
```

---

## 四、`turn_end` 不等于整个 Agent 结束

日志中出现：

```text
stopReason: toolUse
```

含义：

```text
模型这一轮没有输出最终答案
↓
而是请求使用 Tool
↓
当前模型调用结束
↓
Harness 执行 Tool
↓
Tool Result 返回
↓
再启动新的 turn
```

因此：

```text
turn_end
≠
整个 Agent 任务结束
```

只有 Agent Loop 真正达到停止条件时，任务才结束。

---

## 五、Context 对照实验：Context ≠ Disk

今天做了三组关键实验。

---

### 实验 A：没有 Tool，但保留自动 Context

命令：

```bash
pi -p --no-tools   "根据你当前知道的信息，说明这个项目规定的 C 编译命令。不要猜。"
```

结果：

```text
项目规定：

clang -std=c17 -Wall -Wextra -Wpedantic
```

Pi 明确说明依据来自项目 Context 中的 `AGENTS.md`。

### 结论

即使没有：

```text
read
find
grep
ls
```

模型仍然知道项目编译规则。

原因：

```text
Pi Harness
↓
自动发现 AGENTS.md
↓
把 AGENTS.md 注入 Context
↓
LLM 直接获得项目规则
```

所以：

```text
没有 Tool
≠
模型什么项目知识都没有
```

---

### 实验 B：关闭自动 Context，但保留只读 Tool

命令：

```bash
pi -p --no-context-files --tools read,grep,find,ls   "说明这个项目的编译命令。"
```

结果中 Pi 仍然知道：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o c/hello
```

但它同时说明：

```text
我检查了 AGENTS.md、README.md、c/hello.c
```

### 结论

这里不是因为 AGENTS.md 自动进入了 Context。

而是：

```text
--no-context-files
↓
禁止自动加载 AGENTS.md
↓
但 read / find / ls 仍然可用
↓
模型主动发现并读取 AGENTS.md
↓
重新获得编译规则
```

所以：

```text
关闭自动 Context
≠
禁止模型读取那个文件
```

---

### 实验 C：既关闭 Tool，又关闭自动 Context

命令：

```bash
pi -p --no-tools --no-context-files   "根据你当前知道的信息，说明这个项目规定的 C 编译命令。不要猜。"
```

结果：

```text
无法确定这个项目规定的 C 编译命令。
```

Pi 只知道当前目录：

```text
/Users/moonlit_boy/Documents/agent-lab
```

但不知道 README、Makefile、构建脚本或 AGENTS.md 的内容。

### 最终结论

```text
文件存在于 Disk
≠
模型知道文件内容
```

模型要获得文件内容，通常需要：

```text
方式 1：Harness 自动注入 Context

方式 2：模型通过 Tool 主动读取
```

---

## 六、`--no-context-files` 和 `--no-tools` 的区别

### `--no-context-files`

控制：

```text
Harness 自动向模型提供哪些项目 Context 文件
```

例如：

```text
AGENTS.md
CLAUDE.md
```

### `--no-tools`

控制：

```text
模型还能不能主动通过 Tool 获取外部信息或执行动作
```

### 核心区别

```text
--no-context-files
→ 控制“自动塞给模型什么”

--no-tools
→ 控制“模型还能主动去拿什么”
```

---

## 七、Codex 只读实验

### 给 Codex 的任务

```text
读取 c/hello.c，告诉我它现在做了什么。
不要修改任何文件。
如果需要读取项目规则，可以读取。
最后告诉我你实际使用了哪些工具或操作。
```

### 实际观察

Codex 使用了类似：

```bash
pwd
rg --files
sed
```

去定位和读取：

```text
AGENTS.md
c/hello.c
```

### 说明

Codex 最终知道 `hello.c` 的内容，不是因为 LLM 自己“看见了磁盘”。

而是：

```text
磁盘上的 hello.c
↓
Codex Harness / Tool
↓
读取文件
↓
Tool Result
↓
进入模型 Context
↓
LLM 根据源码回答
```

---

## 八、Pi 与 Codex 的 Tool 表现不同，但底层结构一致

### Pi

常见表现：

```text
ls
find
read
grep
```

### Codex

本次观察到：

```text
pwd
rg --files
sed
```

### 结论

Tool 名字、UI、Harness 实现方式可以不同。

但底层仍然是：

```text
User
 ↓
Harness
 ↓
LLM
 ↓
Tool Request
 ↓
Execution
 ↓
Tool Result
 ↓
LLM
```

---

## 九、Codex 修改实验

### 给 Codex 的任务

```text
给 c/hello.c 增加一行简单输出，不改变原有三行输出。
修改后使用项目规定的编译命令进行编译。
完成后告诉我：
1. 修改了什么
2. 执行了什么命令
3. 编译结果
不要修改其他文件。
```

### Codex 实际修改

新增：

```c
printf("One more simple line.\n");
```

原有输出没有删除。

### 编译命令

Codex 实际运行：

```bash
mkdir -p /private/tmp/agent-lab-build && clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /private/tmp/agent-lab-build/hello
```

结果：

```text
Success
No output
```

### 注意

这只能说明：

```text
编译成功
且没有 warning / error 输出
```

不能直接推出：

```text
程序运行结果一定正确
```

因为本次并没有证明它实际运行了编译后的程序。

---

## 十、Permission / Approval 的正确理解

本次 Codex 修改文件、运行 `mkdir`、执行 `clang` 时，没有弹 Approval。

正确结论是：

```text
在当前 Codex 权限模式下，
这些操作被允许直接执行。
```

不能推出：

```text
Codex 所有操作都不需要 Approval
```

更高风险的操作，例如：

```text
网络访问
沙箱外路径
危险 shell 命令
更敏感的文件操作
```

可能走不同的 Permission Flow。

所以：

```text
这次没有 Approval
≠
Codex 没有 Approval 机制
```

---

## 十一、Sandbox 的理解

本次 Codex 把编译产物放到：

```text
/private/tmp/agent-lab-build/hello
```

这只能说明：

```text
Codex 选择在那里输出编译产物
```

不能仅凭这个现象断言：

```text
一定是 Sandbox 强迫它只能写 /private/tmp
```

专业习惯：

```text
观察到什么 → 说什么
没有观察到的内部机制 → 不猜
```

---

## 十二、模型、Harness、Execution / OS 三层必须分开

今天再次验证了这条核心原则：

```text
模型提出动作
≠
Harness 允许动作
≠
OS 最终执行动作
```

### 1. LLM

负责：

```text
理解
推理
决定动作
提出 Tool Request
```

### 2. Codex Harness

负责：

```text
组织 Context
提供 Tool
处理 Permission
调用执行能力
返回 Tool Result
```

### 3. Execution / OS

负责：

```text
真正读取文件
真正修改文件
真正启动进程
真正运行 clang
```

---

## 十三、为什么修改成功后仍然必须看 `git diff`

Codex 最终说：

```text
没有修改其他文件
```

不能只因为它这么说就相信。

必须自己检查：

```bash
git status
git diff
```

本次结果：

```text
On branch main
nothing to commit, working tree clean
```

只读实验中的：

```bash
git diff
```

为空。

修改实验中 `git diff` 显示：

```text
只新增一行
没有删除原有内容
```

所以：

```text
Agent 的总结
≠
独立验证
```

正确工作流：

```text
Agent 修改
↓
git diff
↓
确认真实改动
↓
编译 / 测试
↓
人工 Review
```

---

## 十四、Git 能降低风险，但不能“保证万无一失”

今天复盘时一度说：

```text
人工检查保证万无一失
```

更准确应该是：

```text
人工检查 + diff + 测试
可以降低风险
```

但仍然不能保证绝对正确。

### `git diff`

用于：

```text
确认改了什么
检查有没有多改
检查有没有误删
```

### 编译 / 测试

用于：

```text
验证代码是否满足某类技术条件
```

### 人工 Review

用于：

```text
检查逻辑是否符合需求
```

三者组合比单纯相信 Agent 更可靠。

---

## 十五、今天最终形成的 Codex 架构模型

```text
User
 ↓
Codex Harness
 ↓
Instructions + Context
 ↓
LLM
 ↓
Tool Request
 ↓
Sandbox / Approval / Execution
 ↓
Tool Result
 ↓
LLM
 ↓
Diff / Answer
```

### 各层职责

```text
User
→ 提出目标

Codex Harness
→ 组织整个 Agent 系统

Instructions + Context
→ 给模型提供规则和当前信息

LLM
→ 推理并决定下一步动作

Tool Request
→ 模型提出结构化动作请求

Sandbox / Approval / Execution
→ 控制权限并执行真实操作

Tool Result
→ 把真实结果返回给模型

LLM
→ 根据结果继续推理

Diff / Answer
→ 最终产出，并由用户继续验证
```

---

## 十六、今日自查题与答案

### 1. Codex 与底层 LLM 是同一个东西吗？

不是。

```text
Codex = Coding Agent / Agent 系统
```

LLM 只是其中负责推理和决策的核心组件之一。

---

### 2. Sandbox 属于模型能力吗？

不是。

```text
Sandbox
→ Harness / Execution 层
```

它不是 LLM 智力的一部分。

---

### 3. Approval 能保证代码逻辑正确吗？

不能。

Approval 解决的是：

```text
某个动作是否允许执行
```

而不是：

```text
这个动作是否一定正确
```

---

### 4. 为什么编译成功后还要看 `git diff`？

因为编译成功只能说明代码通过了这次编译检查。

`git diff` 用来确认：

```text
Agent 实际改了什么
有没有多改
有没有误删
是否符合任务范围
```

---

### 5. Tool Call 出现时，Tool 已经执行了吗？

没有。

```text
Tool Call
→ 动作请求

Tool Execution
→ 真正执行

Tool Result
→ 执行结果
```

---

### 6. 为什么 Tool Result 要重新进入 Context？

因为 LLM 本身看不到真实执行结果。

必须：

```text
Tool Result
↓
重新进入 Context
↓
下一轮 LLM
```

模型才能继续判断下一步。

---

### 7. 为什么 `turn_end` 后 Agent 还能继续？

因为一次 `turn_end` 可能只是：

```text
当前模型调用因为 toolUse 结束
```

Tool Result 返回后，Agent Loop 会继续：

```text
turn_start
```

---

## 十七、今日必须牢记的几句话

```text
Codex ≠ LLM
```

```text
Context ≠ Disk
```

```text
Tool Call ≠ Tool 已执行
```

```text
模型决定动作
≠
Harness 允许动作
≠
OS 最终执行动作
```

```text
没有 Tool
≠
模型没有任何项目 Context
```

```text
关闭自动 Context
≠
禁止模型通过 Tool 重新读取同一个文件
```

```text
编译成功
≠
程序逻辑一定正确
```

```text
Agent 说“没有修改”
≠
已经完成验证
```

```text
git diff / 测试 / 人工 Review
→ 用来降低风险，而不是保证绝对正确
```

---

## 十八、Day 11 完成情况

今日已完成：

- [x] 使用 Pi JSON 模式观察真实 Agent Loop
- [x] 区分 Tool Call / Tool Execution / Tool Result
- [x] 理解一次 LLM 调用可以产生多个 Tool Call
- [x] 理解 `turn_end` 不等于整个 Agent 结束
- [x] 完成 `--no-tools` Context 对照
- [x] 完成 `--no-context-files` 对照
- [x] 实验验证 `Context ≠ Disk`
- [x] 用 Codex 完成只读任务
- [x] 观察 Codex 的文件读取 / shell 执行
- [x] 用 Codex 完成小范围代码修改
- [x] 使用项目规定的 clang 参数编译
- [x] 分析 Permission / Approval
- [x] 分析 Sandbox / Execution
- [x] 使用 `git status` / `git diff` 进行人工验证
- [x] 能画出 Codex 的完整 Agent 架构

## Day 11 状态

```text
✅ 完成
```

下一步：

```text
Day 12
Pi / Codex / GitHub Copilot CLI / OpenCode
横向比较
```
