# AI Agent 14 天基础训练｜Day 10

> 主题：Planning、Autonomy、MCP、Sub-agent  
> 日期：2026-09-14  
> 实验平台：Pi Agent v0.85.1  
> 实验目录：`~/Documents/agent-lab`

---

# 一、今日目标

今天的目标不是安装一堆新的 Agent 功能，而是把几个常见术语放回正确层级：

```text
Planning
Autonomy
MCP
Sub-agent
```

最终需要做到：

```text
Planning   → 准备怎么做
Autonomy   → 能少依赖人工做到什么程度
MCP        → 怎么标准化接外部能力
Sub-agent  → 谁分别去做
```

不要把这些概念混成“Agent 很高级，所以什么都有”。

---

# 二、Planning：计划不等于新能力

## 1. 核心理解

Planning 最简单可以只是：

```text
收到任务
↓
先分析
↓
制定计划
↓
再执行
```

它不一定意味着：

```text
有专门的 Plan Tool
有另一个 Planning 模型
使用了 Sub-agent
```

同一个 LLM 本身就可以根据 Prompt 和 Context 制定步骤。

所以：

```text
Planning ≠ 必须有 Tool
Planning ≠ 一定换模型
Planning ≠ 一定使用 Sub-agent
```

Planning 的来源可能包括：

```text
User Prompt
Project Instructions
Harness 专门的 Plan Mode
更复杂系统中的 Planner / Sub-agent
```

---

# 三、Planning 实验 1：无 Tool 基线

## 启动命令

```bash
cd ~/Documents/agent-lab

pi --no-tools \
  --no-skills \
  --no-extensions \
  --no-context-files
```

## 标准测试提示词

```text
请为当前这个 C 语言实验项目制定一个排错计划。

要求：
1. 现在只制定计划，不执行任何操作。
2. 不要读取文件。
3. 不要修改文件。
4. 不要执行终端命令。
5. 给出你认为应该依次检查的步骤。
6. 明确说明：你当前的计划是基于哪些已知信息制定的，以及哪些项目事实你目前无法确认。
```

## 实验现象

即使：

```text
Tools            = 无
Skills           = 无
Extensions       = 无
Context Files    = 不自动加载
```

Pi 依然能制定完整的 C 项目排错计划。

但它无法确认：

```text
项目结构
具体 .c / .h 文件
构建脚本
具体编译器
具体编译参数
项目中的真实 bug
测试用例
```

它只能根据：

```text
User Prompt
Harness / Runtime 信息
模型已有的 C 语言通用知识
```

来制定通用计划。

## 结论

```text
Planning 是模型本身可以完成的推理行为。
Tool 决定的是模型是否能够进一步观察和操作真实环境。
```

---

# 四、一个重要对照：`--no-context-files`

在第一次测试中，只使用：

```bash
pi --no-tools --no-skills --no-extensions
```

Pi 仍然知道项目中特定规则，例如：

```text
clang -std=c17 -Wall -Wextra -Wpedantic
不要删除文件
```

原因是：

```text
AGENTS.md
↓
被 Harness 自动加载
↓
进入 Context
```

加入：

```bash
--no-context-files
```

后，这些项目特定规则消失。

因此可以确认：

```text
--no-context-files
=
关闭 AGENTS.md / CLAUDE.md 等 Context 文件的自动发现 / 自动加载
```

但它不等于：

```text
禁止 read 工具读取这些文件
```

---

# 五、Planning 实验 2：加入只读 Tools

## 启动命令

```bash
cd ~/Documents/agent-lab

pi --tools read,grep,find,ls \
  --no-skills \
  --no-extensions \
  --no-context-files
```

## 标准测试提示词

```text
请先读取和分析当前这个 C 语言实验项目，然后为它制定一个排错计划。

要求：
1. 只允许分析和制定计划，不要修改任何文件。
2. 不要创建文件。
3. 不要执行编译或其他 shell 命令。
4. 使用你当前拥有的只读工具了解项目结构和相关 C 源文件。
5. 根据你实际读取到的项目内容给出排错步骤。
6. 在最后明确区分：
   - 你实际从项目中确认的事实
   - 你的推断
   - 你建议后续执行、但本轮没有执行的操作
```

## 实际 Tool 调用

Pi 使用了：

```text
ls
find
read
```

并读取 / 查看了：

```text
项目根目录
c/
experiments/
notes/
README.md
AGENTS.md
.gitignore
c/hello.c
.pi/skills/c-language-check/SKILL.md
```

---

# 六、实验中发现的重要现象

虽然启动参数包含：

```bash
--no-context-files
--no-skills
```

Pi 仍然通过 `read` 主动读取了：

```text
AGENTS.md
.pi/skills/c-language-check/SKILL.md
```

这说明：

```text
--no-context-files
→ 不自动加载 Context 文件

≠

禁止 Tool 读取这些文件
```

同样：

```text
--no-skills
→ 不自动发现 / 加载 Skill

≠

.pi/skills/.../SKILL.md 在磁盘上不可读取
```

只要存在：

```text
read
find
ls
```

模型仍然可能：

```text
发现文件
↓
调用 read
↓
Harness 执行 Tool
↓
得到 Tool Result
↓
Tool Result 进入 Context
↓
模型获得新的真实项目信息
```

---

# 七、Tool 与 Context 的关系

今天的实验再次验证：

```text
Tool 不只是“执行动作的手”
Tool Result 也可以成为新的 Context 来源
```

完整链路：

```text
模型决定读取文件
↓
Tool Call
↓
Harness 调用 read
↓
文件内容成为 Tool Result
↓
Tool Result 进入 Context
↓
模型基于真实信息继续 Planning
```

因此：

```text
Tools
和
Context
不是完全独立的两个东西
```

Tool 可以动态增加当前 Context 中的信息。

---

# 八、三组实验对照

## 实验 A

```text
自动 Context：开启
Tools：无
```

结果：

```text
Pi 自动获得 AGENTS.md
因此知道项目特定编译规则
```

## 实验 B

```text
自动 Context：关闭
Tools：无
```

结果：

```text
Pi 不知道 AGENTS.md 中的项目规则
只能做通用 Planning
```

## 实验 C

```text
自动 Context：关闭
Read Tools：开启
```

结果：

```text
Pi 没有自动加载 AGENTS.md
但通过 read 主动读取它
于是再次获得项目规则
```

完整总结：

```text
Context 的来源可以是：

Harness 自动注入
或
Tool Result
```

---

# 九、Planning 实验最终结论

## 问题 1

为什么没有任何 Tool，Pi 仍然能制定排错计划？

答案：

```text
因为制定计划本来就是模型具备的推理能力。
```

## 问题 2

为什么加入只读 Tools 后，计划明显更具体？

答案：

```text
因为模型调用 read / ls / find
↓
Harness 执行 Tool
↓
产生真实 Tool Result
↓
Tool Result 进入 Context
↓
模型可以基于真实项目事实重新推理
```

因此：

> Tool 没有给模型增加“会规划”这种能力，而是给 Planning 提供了更加可靠的现实依据。

---

# 十、Autonomy：不要把“自主性”当成一个数字

## 1. 基本定义

Autonomy 可以理解为：

> Agent 在具体任务中，能够在多大范围内、以多低的人工干预持续采取行动。

但不能只说：

```text
这个 Agent 很自主
```

应该拆解成：

```text
Tools
Approval
Network
文件修改权限
最大循环步数
是否能启动 Sub-agent
Environment
```

---

# 十一、Autonomy 是多维属性

例如：

```text
Agent A

Tools:
read
edit
bash

Network:
允许

Approval:
不需要

Max Steps:
50
```

相比：

```text
Agent B

Tools:
read

Network:
禁止

Approval:
修改需要确认

Max Steps:
5
```

A 的 Autonomy 通常更高。

但原因不是：

```text
A 的模型更聪明
```

而是：

```text
Harness 给 A 的行动范围更大
人工干预更少
```

---

# 十二、不能只看 Max Steps

实验讨论：

```text
Agent C
Tools: read/edit/bash
Approval: 每次 edit/bash 都确认
Max Steps: 100

Agent D
Tools: read/edit/bash
Approval: 不需要确认
Max Steps: 10
```

不能直接因为：

```text
100 > 10
```

就说 C 一定更 autonomous。

更准确的是：

```text
C
→ 连续循环步数维度更高

D
→ 无需人工批准这个维度更高
```

因此：

> Autonomy 需要结合具体任务判断，而不是脱离场景给 Agent 一个固定总分。

例如：

```text
任务只需要 6 步
→ D 可能更加自主

任务预计需要 40 步
→ D 的 Max Steps 可能成为限制
```

所以：

```text
Autonomy 是任务相关的多维属性
```

---

# 十三、MCP：标准化连接外部能力

MCP 全称：

```text
Model Context Protocol
模型上下文协议
```

基本关系：

```text
Agent / Client
      ↓
     MCP
      ↓
外部 Tool / Resource / Service
```

MCP 不是：

```text
Agent 本身
LLM
自动安全机制
```

它主要解决：

> Agent / Client 如何用标准化方式连接外部能力。

例如：

```text
Agent
↓
GitHub MCP Server
↓
read_repo
read_issue
create_issue
```

这并不是模型“学会了 GitHub”。

而是：

```text
Harness / Client
通过 MCP
接入了一组新的外部能力
```

---

# 十四、MCP 不自动解决安全问题

假设两个 MCP Server：

```text
Server A
- read_repo
- read_issue
```

```text
Server B
- read_repo
- create_issue
- delete_issue
- modify_repo
```

即使两者都遵循 MCP 标准，也不能说：

```text
A 与 B 一样安全
```

因为 B 拥有：

```text
创建
删除
修改
```

等更高风险能力。

MCP 的安全性仍需要继续检查：

```text
模型能看到哪些 Tool
Harness 是否要求 Approval
MCP Server 自身拥有多少权限
外部服务授予 MCP Server 什么权限
```

例如：

```text
GitHub MCP Server
↓
即使暴露 modify_repo
↓
如果 GitHub Token 实际只有只读权限
↓
最终仍可能无法修改仓库
```

所以：

> MCP 标准化的是连接方式，不是权限大小，也不是自动可信。

---

# 十五、为什么 MCP 会让权限模型更复杂

接入 MCP 后，权限链可能变成：

```text
Agent
  ↓
Harness / MCP Client
  ↓
MCP Server
  ↓
外部 Service
```

因此需要同时考虑：

```text
Agent 层
Harness 层
MCP Server 层
外部 Service 层
```

相比单纯的内置 Tool，权限来源更多，控制点也更多。

---

# 十六、Sub-agent：分工，而不是自动更聪明

基本结构：

```text
Main Agent
├── Research Agent
├── Coding Agent
└── Review Agent
```

主要价值：

```text
分工
隔离 Context
并行
专门角色
```

例如：

```text
Research Agent
→ 专门查资料

Coding Agent
→ 专门修改代码

Review Agent
→ 专门检查结果
```

---

# 十七、Sub-agent 与 Context 污染

Main Agent 可能拥有：

```text
大量历史对话
多个文件
大量 Tool Result
多个任务
```

但 Coding Sub-agent 可以只得到：

```text
当前任务说明
相关两个文件
必要项目规则
```

所以：

```text
Main Agent 大量 Context
        ↓
挑选必要信息
        ↓
Coding Sub-agent
        ↓
更小、更相关的 Context
```

这可以：

```text
减少无关信息
降低噪声
缓解 Context 污染
```

注意：

```text
不是“减少 User Prompt”
```

而是减少：

```text
无关历史
无关文件
无关 Tool Results
其他任务细节
```

---

# 十八、Sub-agent 的代价

Sub-agent 不是免费获得好处。

它也会带来：

```text
更多模型调用
更多 Context
更复杂的调用链
更复杂的权限
更难观察
更难定位错误
```

所以：

```text
Sub-agent
可以降低单个 Agent 的 Context 污染
但可能提高整个系统的复杂度
```

---

# 十九、四个概念最终区分

今天最终必须能够分清：

```text
Planning
→ 准备怎么做

Autonomy
→ 能少依赖人工做到什么程度

MCP
→ 怎么标准化连接外部能力

Sub-agent
→ 谁分别去做
```

它们可以组合：

```text
Main Agent
↓
先 Planning
↓
启动 Coding Sub-agent
↓
Sub-agent 通过 MCP 接入 GitHub
↓
调用外部 Tool
↓
整个系统允许自动连续执行若干步
```

这里：

```text
Planning
Sub-agent
MCP
Autonomy
```

分别描述不同层面的机制。

---

# 二十、Day 10 自查题

## 1. Plan Mode 是否一定意味着使用另一个模型？

不是。

Plan Mode 可能只是：

```text
同一个模型
先制定计划
再执行
```

也可能由 Harness 专门设计工作模式。

---

## 2. Autonomy 应该怎样拆解？

Autonomy 是：

> Agent 在少量人工干预下持续完成任务的程度。

但必须拆成：

```text
Tools
Approval
Network
文件修改权限
最大循环步数
Sub-agent 能力
Environment
```

不能只看一个指标。

---

## 3. MCP 是 Agent 本身吗？

不是。

MCP 是：

```text
Agent / Client
如何标准化连接
外部 Tool / Resource / Service
```

的一套协议。

---

## 4. 接入 MCP 后为什么权限模型更复杂？

因为新的调用链变成：

```text
Agent
↓
Harness / MCP Client
↓
MCP Server
↓
外部 Service
```

每一层都可能有不同权限。

---

## 5. 为什么 Sub-agent 可能缓解 Context 污染？

因为：

```text
Sub-agent
只需要获得完成当前任务必要的 Context
```

而不需要继承 Main Agent 全部历史。

---

## 6. 为什么多 Agent 也可能降低可控性？

因为：

```text
结构更复杂
权限更复杂
调用链更长
Context 来源更多
Tool 使用更难追踪
错误更难定位
```

---

# 二十一、今日完成情况

```text
Planning 理论                 ✅
无 Tool Planning 实验        ✅
--no-context-files 对照      ✅
只读 Tool Planning 实验      ✅
Tool Result → Context        ✅
Autonomy                     ✅
MCP                          ✅
Sub-agent                    ✅
Day 10 自查                  ✅
```

## Day 10 完成

今天已经达到完成标准：

```text
看到：

Planning
MCP
Sub-agent
Autonomous

能够把它们拆开解释，
不再把它们混成同一个概念。
```

---

# 二十二、Day 09 尚未补完的两个实验

Day 09 理论已经完成，但由于 Session 当时过短，没有为了触发 Compaction 故意浪费 Token。

保留两个待自然补做实验：

```text
[ ] 成功触发一次真实 /compact
[ ] 验证 /compact 与 /tree 混合使用的精确行为
```

原则：

```text
不为了触发 Compaction 故意制造垃圾 Context
```

等某个真实 Session 自然变长后，再完成这两个实验。

---

# 二十三、今日一句话总结

```text
Planning 决定准备怎么做，
Autonomy 描述能少依赖人工做到什么程度，
MCP 负责标准化连接外部能力，
Sub-agent 负责把任务分给不同 Agent；
Tool 不只提供行动能力，Tool Result 还会成为新的 Context。
```
