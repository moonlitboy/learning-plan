# AI Agent 14 天基础训练｜Day 12

> 主题：横向比较 Pi / Codex / Copilot CLI / OpenCode  
> 今日目标：学会分析一个陌生 Coding Agent，而不是只看它用了什么模型。  
> 状态：✅ 已完成

---

# 一、今天最核心的结论

今天最重要的一句话：

> **分析 Coding Agent，要分析整个系统，而不是只分析它背后的 LLM。**

一个 Coding Agent 的实际能力与安全性，通常由多方面共同决定：

```text
Model / Provider
+
Harness
+
Context / Instructions
+
Tools
+
Extensions / Plugins / MCP / Sub-agent
+
Approval
+
Sandbox
+
OS / Network Permission
+
Session
+
Verification / Recovery
```

因此：

```text
同一个 LLM
≠
同一个 Agent

同样的 Tool 名称
≠
同样的权限

Tool 更多
≠
一定更高级

有 Approval
≠
一定有 Sandbox

有 Tool Allowlist
≠
已经被隔离
```

---

# 二、模型与 Harness 必须分开看

今天首先确认：

```text
LLM 强弱
```

和：

```text
Harness 好坏
```

不是同一个维度。

即使两个 Agent 使用相同的模型、相似的 Tool，它们的实际表现仍然可能差很多。

原因包括：

```text
Harness 的控制策略不同
Tool Definition 不同
Tool 参数 Schema 不同
Context 组织不同
Approval 不同
Sandbox 不同
执行环境不同
Session 机制不同
Extension / MCP 不同
```

所以不能只比较：

```text
“谁用了更强的模型？”
```

而应该比较整个 Agent 系统。

---

# 三、Tool Allowlist、Approval、Sandbox 的区别

这是今天最重要的权限模型之一。

## 1. Tool Allowlist

Tool Allowlist 控制：

```text
Agent 当前可以调用哪些 Tool
```

例如：

```text
read
edit
bash
```

它只是在 Harness 层控制“能力入口”。

可以理解为：

> **给不给 Agent 这只手。**

但是：

```text
Tool Allowlist
≠
Sandbox
```

因为即使 Tool 很少，其中某个 Tool 仍然可能拥有很大的能力。

例如：

```text
bash
```

可以通过 shell 做很多操作。

即使没有 `write`，只要有足够强的 `bash`，依然可能修改文件。

---

## 2. Approval

Approval 控制：

```text
这一次具体动作是否允许执行
```

概念流程：

```text
LLM
↓
提出 Tool Call
↓
Harness
↓
需要 Approval
↓
用户 Allow / Deny
↓
允许后才执行
```

所以 Approval 更像：

> **这一次要不要让它做。**

但点击：

```text
Allow
```

并不代表：

```text
绕过 Sandbox
```

Approval 和 Sandbox 是不同层级。

---

## 3. Sandbox

Sandbox 控制：

```text
即使操作被执行
它最多能够影响哪里
```

例如可能限制：

```text
文件路径
网络
进程
系统资源
宿主环境
```

可以理解为：

> **这只手伸出去之后，最多能碰到哪里。**

因此：

```text
Tool Allowlist
= 给哪些能力

Approval
= 这一次让不让执行

Sandbox
= 执行后最多能影响哪里
```

---

# 四、Sandbox 也不是“绝对安全结界”

Sandbox 是重要的 Execution Isolation。

但不能理解为：

```text
有 Sandbox
=
100% 安全
```

判断 Agent 安全性还要继续看：

```text
Tools
Approval
Sandbox
OS Permission
Network
cwd
MCP
Extension
Plugin
Sub-agent
Context 中是否有敏感信息
```

所以不能只问：

```text
“这个 Agent 有没有 Sandbox？”
```

而应该问：

```text
Sandbox 限制了什么？
没有限制什么？
执行最终以什么 OS 权限进行？
```

---

# 五、Git 属于验证与恢复，不属于权限边界

今天再次确认：

```text
git diff
```

属于：

```text
验证
```

而：

```text
git restore
```

属于：

```text
恢复
```

Git 本身：

```text
不是 Sandbox
不是 Approval
不是权限边界
```

它不能阻止 Agent 犯错。

但是它可以帮助我们：

```text
发现改动
检查改动
确认范围
恢复文件
建立 checkpoint
```

所以 Git 仍然是 Agent 工作流里非常重要的安全辅助工具。

---

# 六、cwd 为什么重要

`cwd` 表示 Agent 当前工作的目录 / 项目环境。

它会影响：

```text
相对路径如何解析
默认在哪个项目中工作
Tool 从哪里开始操作
Agent 看到哪些项目文件
```

因此：

> **cwd 是 Agent Environment 的重要组成部分。**

---

# 七、Project Instructions 属于 Context / Instructions

今天再次确认：

```text
AGENTS.md
```

属于：

```text
Instructions / Context
```

不是：

```text
Tool
Sandbox
OS Permission
```

它可以告诉 Agent：

```text
应该怎样工作
应该使用什么命令
哪些流程必须执行
```

但它不会凭空增加 Agent 的系统权限。

---

# 八、Tool 的名字不是权限边界

一个非常重要的结论：

```text
Tool 名字相同
≠
实现相同
≠
权限相同
```

例如两个 Agent 都提供：

```text
bash
```

但是：

```text
Agent A
bash 在宿主系统执行

Agent B
bash 在严格 Sandbox 中执行
```

虽然 Tool 名称一样，但实际风险完全不同。

判断一个 Tool，应该看：

```text
Tool Definition
参数 Schema
底层执行方式
执行环境
OS 权限
返回结果
Approval
Sandbox
```

---

# 九、禁掉 bash 不代表不能执行代码

今天做了一个重要思考实验：

```text
bash → deny
```

但是 Extension 新注册：

```text
run_python(code)
```

如果这个 Tool 可以直接在宿主机运行 Python，那么：

```text
bash → deny
```

仍然不能推出：

```text
Agent 无法执行任意代码
```

所以比较 Agent 时不能只看：

```text
默认 Tools
```

还必须看：

```text
Built-in Tools
+
Extension Tools
+
Plugin Tools
+
MCP Tools
+
Custom Tools
```

真正应该分析的是：

> **当前 Agent 最终可用的全部能力集合。**

---

# 十、Skill 与 Tool 仍然要分开

今天再次复习：

```text
Tool
=
Agent 能做什么
```

而：

```text
Skill
=
Agent 应该怎样完成某类任务
```

Skill 更接近：

```text
工作方法
流程
参考知识
操作规范
```

Tool 则提供真实行动能力。

所以：

```text
Skill
≠
Tool
```

Skill 也不能直接绕过 OS 权限。

---

# 十一、MCP 不是一个 Tool

今天确认：

```text
MCP
≠
某一个 Tool
```

MCP 更准确地说是一套：

```text
标准化连接协议
```

用于让：

```text
Agent / Client
↓
连接
↓
外部 Tool / Resource / Service
```

所以一个 MCP Server 可能提供很多能力。

例如：

```text
filesystem
database
browser
search
external service
```

因此接入 MCP 后：

```text
新增能力
↓
新增权限来源
↓
新增网络 / 数据 / 执行边界
↓
权限审查变复杂
```

重要原则：

> **MCP 解决“如何连接能力”，不自动解决“能力是否可信”。**

---

# 十二、默认 Tool 少，不代表最终权限小

例如：

```text
Agent A
默认：
read / edit

MCP：
filesystem
database
browser
```

和：

```text
Agent B
默认：
read / edit / bash

无 MCP / Extension
```

不能因为 Agent A 默认 Tool 少，就直接判断：

```text
Agent A 权限更小
```

因为 MCP 可能已经加入很多外部能力。

所以应该分析：

```text
最终能力集合
```

而不是只看：

```text
默认 Tool 数量
```

---

# 十三、Sub-agent 不是“更强的模型”

Sub-agent 的价值主要来自：

```text
分工
上下文隔离
并行
专门角色
```

例如：

```text
Main Agent
├── Research Agent
├── Coding Agent
└── Review Agent
```

可能分别承担不同任务。

Sub-agent 不一定使用更强模型。

甚至可能：

```text
Main Agent
和
Sub-agent
```

使用相同模型。

---

# 十四、Sub-agent 为什么能减少 Context 污染

例如：

```text
Research Agent
只处理研究资料

Coding Agent
只处理代码

Review Agent
只处理审查结果
```

这样不同子任务产生的大量细节不必全部进入 Main Agent 的 Context。

所以：

```text
任务分工
+
Context 隔离
```

可以降低上下文污染。

---

# 十五、多 Agent 也会增加复杂度

Sub-agent 越多，不一定越好。

它同时可能增加：

```text
Context
调用次数
权限主体
执行路径
Agent 间通信
失败点
观察难度
```

因此：

```text
多 Agent
≠
天然更可控
```

---

# 十六、Read-only 也不是 No-risk

今天一个非常重要的安全结论：

```text
Read-only
≠
No-risk
```

即使一个 Agent 只有：

```text
read
```

仍然可能读取：

```text
API Key
.env
配置文件
私人文件
凭据
内部资料
```

读取结果可能：

```text
File
↓
Tool Result
↓
Context
↓
Model
```

因此 read-only Agent 仍然存在：

```text
敏感信息泄漏风险
```

所以最小权限不仅要考虑：

```text
能不能修改
```

还要考虑：

```text
能不能读取不该读取的内容
```

---

# 十七、多 Agent 系统应该分别分析权限

假设：

```text
Main Agent
├── Research Agent：联网
├── Coding Agent：read / edit / bash
└── Review Agent：read

另外：
Database MCP
```

不能只分析：

```text
Main Agent
```

而应该分别检查：

```text
Main Agent
Research Agent
Coding Agent
Review Agent
Database MCP
```

因为它们都是独立的能力入口。

---

# 十八、Pi 当前实际验证结果

今天实际执行：

```bash
pi --version
pi --help
pi list
pi config
```

当前版本：

```text
Pi 0.85.1
```

## Pi 内置 Tools

当前帮助信息显示：

```text
read
bash
edit
write
```

另外还有：

```text
grep
find
ls
```

这些属于只读内置 Tool，但默认关闭。

---

## Pi Tool 控制

Pi 当前支持：

```text
--no-tools
--no-builtin-tools
--tools
--exclude-tools
```

因此可以对当前 Agent 的 Tool 能力进行 allowlist / denylist 控制。

但是：

```text
Tool 控制
≠
Sandbox
```

---

## Pi Project Trust

Pi 当前有：

```text
--approve
--no-approve
```

但这里的：

```text
approve
```

表示：

```text
是否信任项目本地文件 / 资源
```

更接近：

```text
Project Trust
```

并不是我们讨论的：

```text
每个危险 Tool Call 都弹窗 Allow / Deny
```

因此：

```text
Project Trust
≠
Tool Execution Approval
```

---

## Pi Sandbox

根据今天实际查看的 Pi 0.85.1 核心 CLI 帮助：

```text
没有看到内置 Sandbox 参数
```

因此目前不能把：

```text
Pi Tool Allowlist
```

理解成：

```text
OS Sandbox
```

如果未来通过：

```text
Container
VM
OS Permission
Extension
```

增加隔离，那属于额外的 Execution / Environment 层。

---

## Pi Skill / Extension

Pi 支持：

```text
Skill
Extension
Package
```

今天再次确认：

```text
Skill
→ 主要改变 Agent 工作方式

Extension
→ 可以扩展 / 修改 Harness 行为
```

Extension 还可能注册新的：

```text
Tool
Command
Flag
Hook
```

所以 Extension 的权限潜力通常比 Skill 更高。

---

## Pi 当前 Package 状态

今天执行：

```bash
pi list
```

结果：

```text
No packages installed.
```

所以目前的 Pi 环境确实非常接近：

> **“毛坯房 Agent Harness”**

这也是我目前最喜欢 Pi 的地方之一：

```text
核心干净
结构容易观察
Tools / Context / Skill / Extension 容易拆开理解
```

---

# 十九、四类 Agent 的横向比较思路

今天比较：

```text
Pi
Codex
GitHub Copilot CLI
OpenCode
```

我们的目标不是选：

```text
“谁最强？”
```

而是用统一维度分析。

建议比较：

| 维度                    | Pi                                                           | Codex                                                        | Copilot CLI                                                  | OpenCode                                                     |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Harness 类型            | Minimal Coding Harness / CLI                                 | Coding Agent Harness；CLI / IDE / Desktop                    | CLI Coding Agent Harness                                     | CLI/TUI Coding Agent Harness                                 |
| 核心 Tools              | `read / bash / edit / write`；`grep/find/ls` 内置但默认关闭  | 文件、Shell 等；具体 Tool 集随版本/界面变化，不写死          | Shell、读写文件、搜索、Web、Sub-agent 等 ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/allowing-tools?utm_source=chatgpt.com)) | `read/edit/shell/glob/grep/web...`，还可扩展 Tool ([OpenCode](https://opencode.ai/v2/docs/tools/?utm_source=chatgpt.com)) |
| cwd / 工作区            | 启动 Pi 的工作目录                                           | cwd / workspace 很重要，AGENTS 会沿项目路径发现 ([OpenAI](https://openai.com/index/unrolling-the-codex-agent-loop/?utm_source=chatgpt.com)) | 以当前项目/仓库工作环境为基础                                | Active Location / project worktree                           |
| Project Instructions    | `AGENTS.md / CLAUDE.md`，可 `--no-context-files` 关闭        | 支持 `AGENTS.md / AGENTS.override.md` 等 ([OpenAI](https://openai.com/index/unrolling-the-codex-agent-loop/?utm_source=chatgpt.com)) | 支持 `AGENTS.md`、Copilot instructions 等 ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions?utm_source=chatgpt.com)) | V2 支持分层 `AGENTS.md` ([OpenCode](https://opencode.ai/v2/docs/instructions?utm_source=chatgpt.com)) |
| Approval                | 当前核心帮助中没有看到逐 Tool Call Approval；`--approve` 是 Project Trust | 有独立 Approval Policy，例如 `on-request` ([OpenAI Help Center](https://help.openai.com/en/articles/11369540?utm_source=chatgpt.com)) | 有 Tool Approval，可一次允许/本 Session 允许/拒绝 ([GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-copilot-cli?utm_source=chatgpt.com)) | 权限规则支持 `allow / ask / deny` ([OpenCode](https://opencode.ai/v2/docs/permissions?utm_source=chatgpt.com)) |
| Sandbox                 | 当前 0.85.1 `--help` 没发现核心内置 Sandbox                  | 有；Sandbox 和 Approval 是两套独立控制 ([OpenAI](https://openai.com/index/running-codex-safely/?utm_source=chatgpt.com)) | 有本地 OS Sandbox，也有 Cloud Sandbox，目前属于 preview ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/cloud-and-local-sandboxes?utm_source=chatgpt.com)) | V2 重点是权限规则；`shell` 直接具有宿主用户的文件、进程和网络权限 ([OpenCode](https://opencode.ai/v2/docs/permissions?utm_source=chatgpt.com)) |
| Skill / Extension / MCP | Skill + Extension，Package 可扩展；你当前 `pi list` 是空的   | 支持 MCP、Web Search 等扩展能力 ([OpenAI](https://openai.com/index/introducing-upgrades-to-codex/?utm_source=chatgpt.com)) | Skills、Hooks、Extensions、Plugins、MCP、Custom Agents 都有 ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/overview?utm_source=chatgpt.com)) | Agents、Skills、Plugins、MCP、Custom Tools 等 ([OpenCode](https://opencode.ai/v2/docs?utm_source=chatgpt.com)) |
| Sub-agent               | 核心默认不主打，需要扩展                                     | 可有更复杂 Agent 工作流，具体按当前配置看                    | 明确内置/支持 Sub-agent 与 Custom Agents ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli?utm_source=chatgpt.com)) | 明确支持 Primary Agent / Sub-agent，并可分别设置权限 ([OpenCode](https://opencode.ai/docs/agents?utm_source=chatgpt.com)) |
| Session                 | 很清楚：`-c/-r/--session/--fork/--no-session` 等             | 支持持续 Agent 会话；具体管理随界面不同                      | 有本地 Session、恢复和历史，例如 `copilot --continue` ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview?utm_source=chatgpt.com)) | 有父/子 Session，Sub-agent 可建立 child session ([OpenCode](https://opencode.ai/docs/agents?utm_source=chatgpt.com)) |
| 你的优势评价            | **毛坯房，非常适合学 Harness**                               | **开箱即用、控制体系完整**                                   | **扩展生态和现成功能很多**                                   | **可配置性、Provider 和 Agent 权限设计很灵活**               |
| 主要担心                | 默认能力较少，需要自己搭；扩展后自己负责审查                 | 封装较深，不主动观察容易感觉黑盒                             | 能力/扩展很多后权限模型明显更复杂                            | `shell` 是宿主权限，配置不严时要特别注意                     |

不知道的地方：

```text
待查
```

不要猜。

---

# 二十、我目前对 Pi 的评价

## Harness 类型

```text
Minimal Coding Harness / CLI Coding Agent
```

我更喜欢把它理解成：

> **非常干净的“毛坯房 Agent Harness”。**

---

## 我喜欢的地方

```text
核心简单
结构透明
容易观察 Tool
容易观察 Context
容易理解 Skill
容易理解 Extension
适合学习 Agent Harness
```

---

## 我担心的地方

不是简单说：

```text
“能力不够”
```

更准确地说：

```text
默认高级能力较少
很多能力需要自己扩展
扩展越多
权限模型越需要自己重新审查
```

---

# 二十一、我目前对 Codex 的理解

Codex 不能只理解成：

```text
GUI
```

GUI 只是交互形式。

更准确地说：

```text
Codex
=
Coding Agent Harness
+
Model
+
Context
+
Tools
+
Sandbox / Approval
+
Execution
+
Session
```

我目前喜欢它的地方：

```text
开箱即用程度高
很多 Agent 工作流已经集成
```

我担心的地方：

```text
抽象层较高
不像 Pi 那么“裸”
如果不主动观察 Tool Call / Diff / Approval
容易产生“它到底干了什么”的黑盒感
```

所以：

```text
不是“无法控制”
```

而是：

```text
需要主动观察控制点
```

---

# 二十二、面对陌生 Agent 的分析顺序

以后出现一个我从来没用过的 Coding Agent，我不应该先问：

```text
“它用什么模型？”
```

而可以按照下面顺序分析。

## Step 1：默认 Tools

先问：

```text
有哪些默认 Tools？
```

例如：

```text
read
edit
write
bash
browser
search
```

---

## Step 2：执行环境

问：

```text
Tool 在哪里执行？
```

检查：

```text
cwd
Workspace
宿主系统
Container
VM
Sandbox
OS User
```

---

## Step 3：权限模型

检查：

```text
allow
ask
deny
Approval
Tool Allowlist
Sandbox
```

---

## Step 4：Context / Instructions

检查：

```text
System Prompt
Project Instructions
AGENTS.md
Conversation History
Tool Results
自动加载文件
```

问：

> 模型为什么会知道这些信息？

---

## Step 5：Network

检查：

```text
能不能联网？
哪些 Tool 可以联网？
可以访问哪些服务？
```

---

## Step 6：扩展能力

检查：

```text
Skill
Extension
Plugin
MCP
Custom Tool
Sub-agent
```

并问：

```text
这些东西新增了什么能力？
```

---

## Step 7：Harness 控制方式

检查：

```text
CLI
GUI
配置文件
Tool logs
Session
Tool Call records
```

---

## Step 8：验证与恢复

检查：

```text
git status
git diff
编译
测试
lint
checkpoint
rollback
session log
```

---

# 二十三、今日自查题

## 1. 模型强弱和 Harness 好坏是不是同一个维度？

我的答案：

```text
不是。
```

---

## 2. 为什么两个 Agent 使用同一个模型，实际表现仍可能差很多？

我的答案：

```text
因为 Harness 不同。
```

进一步包括：

```text
Context
Tools
Tool Definition
Permission
Sandbox
Execution
Session
```

都可能不同。

---

## 3. 为什么 Tool 的设计会影响 Agent 表现？

我的答案：

```text
Tool 的定义、参数和执行方式都可能不同。
```

---

## 4. 为什么不能简单说“这个 Agent 很自由”？

我的答案：

```text
因为“自由”包含很多方面。
```

例如：

```text
Tools
Approval
Sandbox
Network
OS Permission
Skill
Extension
MCP
Sub-agent
```

必须拆开分析。

---

## 5. 比较 Coding Agent 时，最不应该只看什么？

我的答案：

```text
LLM
```

因为：

> **Agent 的实际表现由整个系统共同决定。**

---

# 二十四、今天最终建立的 Agent 心智模型

```text
                         User
                           │
                           ▼
                    Agent Harness
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
     Instructions       Context         Permissions
          │                │                 │
          └────────────────┼─────────────────┘
                           ▼
                          LLM
                           │
                           ▼
                      Tool Call
                           │
             ┌─────────────┼──────────────┐
             │             │              │
          Approval      Sandbox       Tool Policy
             │             │              │
             └─────────────┼──────────────┘
                           ▼
                       Execution
                           │
                           ▼
                       Tool Result
                           │
                           ▼
                          LLM
```

同时还可能外挂：

```text
Skills
Extensions
Plugins
MCP
Sub-agents
```

所以真正分析 Agent 时必须看：

```text
整个系统
```

而不是只看：

```text
模型名字
```

---

# 二十五、Day 12 完成标准

今天已经能够做到：

- [x] 不再把模型能力和 Harness 能力混为一谈
- [x] 理解相同模型不代表相同 Agent
- [x] 理解相同 Tool 名称不代表相同权限
- [x] 区分 Tool Allowlist / Approval / Sandbox
- [x] 理解 Git 是验证与恢复工具，不是安全边界
- [x] 理解 Project Instructions 属于 Context / Instructions
- [x] 理解 Skill 与 Tool 的区别
- [x] 理解 MCP 不是某一个 Tool
- [x] 理解接入 MCP 会让权限模型更复杂
- [x] 理解 Sub-agent 的价值与风险
- [x] 理解 Read-only 仍然存在敏感信息泄漏风险
- [x] 实际检查 Pi 当前版本与核心能力
- [x] 建立分析陌生 Coding Agent 的统一框架
- [x] 完成 Day 12 自查题

---

# 二十六、今天结束后的进度

```text
Day 01  ✅
Day 02  ✅
Day 03  ✅
Day 04  ✅
Day 05  ✅
Day 06  ✅
Day 07  ✅
Day 08  ✅
Day 09  ✅
Day 10  ✅
Day 11  ✅
Day 12  ✅

下一步：
Day 13｜亲手实现 Mini Agent
```

Day 13 将第一次亲手写出：

```text
User
↓
LLM
↓
Tool Call
↓
Tool Executor
↓
Tool Result
↓
LLM
↓
Final Answer
```

也就是：

> **亲手实现真正的 Agent Loop。**

---

# Day 12 一句话总结

> **以后判断一个 Coding Agent，不再只问“它用了什么模型”，而是系统地分析 Harness、Context、Tools、权限、Sandbox、扩展能力、执行环境以及验证恢复机制。**
