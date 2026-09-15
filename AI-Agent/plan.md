# AI Agent 14 天基础训练计划

> 目标：不是“会用几个 Agent 工具”，而是把 Coding Agent 从黑盒变成你能解释、限制、观察、验证和回滚的系统。  
> 建议投入：每天 3～4 小时。  
> 学习主线：**Agent 原理 → Tool Calling → Context → 权限与安全 → Pi → Skills / Extensions → Session / Memory → Codex 对照 → Mini Agent → 综合验收**  
> 实验平台：Pi Agent  
> 对照工具：Codex、GitHub Copilot CLI、OpenCode Desktop  
> 环境：macOS + zsh + Git（示例命令按此环境设计）  
> 版本说明：本计划于 2026-09-13 更新，并按当时的 Pi / Codex / DeepSeek / OpenRouter 官方资料设计。已为 Day 06～14 加入 Pi 的具体使用命令。工具界面、模型名称和具体参数以后可能变化，因此每次实操先用 `pi --help` 核对当前版本，学习重点仍放在底层概念，而不是死记按钮。
> 当前进度：Day 01～Day 05 已完成；下一步从 Day 06 开始。
> Pi 命令参考：[Pi Coding Agent 官方 README](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/README.md)

---

## 一、14 天结束时，你应该达到什么程度

完成这 14 天后，你应该能够不用背定义，自己解释下面这些问题：

1. LLM 和 Agent 到底有什么区别？
2. Agent Harness 是什么？为什么它是理解 Coding Agent 的关键？
3. 一个模型为什么能够读取文件、修改代码、执行终端命令？
4. Tool Call 是谁提出的？Tool 又是谁真正执行的？
5. `read / write / edit / bash` 分别意味着什么权限？
6. System Prompt、用户提示词、项目说明文件、聊天历史、工具结果，哪些会进入 Context？
7. Agent Loop 为什么能够连续运行很多步？
8. Agent 为什么会“忘记”？Context Window、Compaction、Session、Memory 有什么区别？
9. cwd、用户权限、Tool Allowlist、Approval、Sandbox、Project Trust 分别解决什么问题？
10. 为什么“信任项目”不等于“Agent 被沙箱隔离”？
11. Prompt Injection 为什么对本地 Coding Agent 也是真实风险？
12. Skill、Prompt、Tool、Extension、Hook、MCP、Sub-agent 分别属于 Agent 系统的哪一层？
13. Agent 改坏代码时，你如何通过 Git 看出变化并恢复？
14. 如何判断一个陌生 Agent “自由在哪里、危险在哪里、控制点在哪里”？
15. 如何自己实现一个最小的 `LLM → Tool Call → Tool Result → LLM` Agent Loop？
16. 为什么“我相信模型很聪明”不能替代安全边界和验证？

最终目标不是：

> 我敢让 AI 随便跑。

而是：

> **我知道它能做什么、不能做什么；我能看到它做了什么；就算它做错了，我也能发现并恢复。**

---

# 二、贯穿 14 天的核心心智模型

以后看到任何 Coding Agent，都先把它拆成下面这些部分：

```text
                     User
                       │
                       ▼
              ┌─────────────────┐
              │  Agent Harness  │
              │                 │
              │ Instructions    │
              │ Context         │
              │ Session / State │
              │ Tool Registry   │
              │ Permission Flow │
              └────────┬────────┘
                       │
                       ▼
                    ┌─────┐
                    │ LLM │
                    └──┬──┘
                       │
                 text / tool call
                       │
                       ▼
          ┌─────────────────────────┐
          │ read / edit / write     │
          │ bash / search / ...     │
          └────────────┬────────────┘
                       │
                   Tool Result
                       │
                       └──────────────► 再进入 Context
```

最小 Agent Loop：

```text
Observe
   ↓
Reason / Decide
   ↓
Act（Tool Call）
   ↓
Tool 执行
   ↓
Observe Result
   ↓
再次 Reason
   ↓
……
```

要牢牢记住：

```text
模型“提出一个动作”
        ≠
Harness“允许这个动作”
        ≠
操作系统“最终允许执行”
```

这三个层级必须分开理解。

---

# 三、学习期间统一实验规则

为了让你敢于实验，同时避免把重要项目当试验品，14 天统一使用一个独立实验仓库。

建议：

```bash
mkdir -p ~/Documents/agent-lab
cd ~/Documents/agent-lab
git init
```

创建几个简单文件即可，例如：

```text
agent-lab/
├── README.md
├── c/
│   ├── hello.c
│   └── calculator.c
├── notes/
└── experiments/
```

第一次准备好后：

```bash
git add .
git commit -m "init agent lab"
```

以后每个危险度稍高的实验前，都先确认：

```bash
git status
```

需要时创建检查点：

```bash
git add .
git commit -m "checkpoint before agent experiment"
```

实验后固定执行：

```bash
git status
git diff
```

### 14 天期间的五条铁律

1. **重要项目不用于早期 Agent 实验。**
2. **看不懂的命令，不因为 Agent 建议就直接允许。**
3. **第三方 Skill / Extension 不因为“热门”就直接安装。**
4. **修改代码后必须看 diff，能测试就测试。**
5. **先理解权限边界，再增加 Agent 自由度。**

### 14 天统一模型接入限制（新增）

这 14 天凡是涉及“给 Agent 接真实模型”“调用模型 API”“自己写 Mini Agent”的操作，统一只使用下面三条路线：

```text
路线 A：DeepSeek 开发平台 API
路线 B：OpenRouter
路线 C：ChatGPT Plus / Pro 订阅授权
        仅限工具本身明确支持 OAuth / 订阅登录时使用
```

#### 优先级

```text
自己写代码 / Mini Agent
        ↓
优先 DeepSeek API
        ↓
需要切换或比较多个模型时使用 OpenRouter

Pi 等明确支持订阅 OAuth 的 Harness
        ↓
可优先使用 ChatGPT Plus / Pro 登录
```

### 必须分清：ChatGPT Plus ≠ 通用 OpenAI API

ChatGPT Plus / Pro 可以在**明确支持这种订阅授权的工具**中使用，例如 Pi 当前支持通过 `/login` 选择 ChatGPT Plus/Pro（Codex）。

但是：

```text
ChatGPT Plus / Pro
        ≠
自动获得一个可供任意 Python 程序调用的 OPENAI_API_KEY
```

所以在 Day 13 自己写 Mini Agent 时，本计划**默认不要求购买 OpenAI API 额度**。

Mini Agent 统一优先：

```text
DeepSeek API
```

或者：

```text
OpenRouter API
```

如果以后某个 SDK / Harness 明确支持 ChatGPT 订阅 OAuth，我们再单独分析该授权机制，而不是假设所有程序都能拿 Plus 订阅直接调用 API。

### 为什么默认推荐 DeepSeek + OpenRouter

#### DeepSeek 开发平台

适合学习：

- API Key
- Base URL
- OpenAI-compatible API
- Tool Calling
- Messages
- Agent Loop
- Token / 调用成本

当前 DeepSeek API 提供 OpenAI-compatible 接口，因此很适合拿来写我们的第一个 Mini Agent。

#### OpenRouter

适合学习：

- Provider 与 Model 的区别
- 统一 API 接口
- 模型切换
- 路由
- 一个 Harness 对接多个模型 Provider

OpenRouter 同样提供 OpenAI-compatible API，因此 Day 13 的 Mini Agent 可以在不重写 Agent Loop 的情况下切换 Provider。

### API Key 安全规则

整个 14 天严格执行：

```text
API Key
≠
项目代码
≠
README
≠
AGENTS.md
≠
Prompt
≠
Git 仓库
```

禁止：

```text
const API_KEY = "真实密钥"
```

也禁止把真实 Key 写到：

```text
README.md
AGENTS.md
notes/
示例代码
Git commit
聊天消息
```

#### Pi 中的建议

Pi 当前可以通过 `/login` 管理支持的订阅授权和 API Key Provider。

对 Pi：

```text
ChatGPT Plus / Pro → 优先 /login
OpenRouter          → 优先 /login
DeepSeek            → /login 后选择 API Key，或使用受控凭据方式
```

这样比把 Key 明文写进项目文件更合理。

#### Mini Agent 中的建议

自己写 Python Mini Agent 时，密钥通过环境变量读取：

```python
import os

api_key = os.environ["DEEPSEEK_API_KEY"]
```

或者：

```python
api_key = os.environ["OPENROUTER_API_KEY"]
```

**代码中绝不出现真实 Key。**

在你的 zsh 中，如果只是临时实验，可以使用不回显输入的方式设置当前 Shell 环境变量：

```bash
read -s "DEEPSEEK_API_KEY?DeepSeek API Key: "
export DEEPSEEK_API_KEY
echo
```

OpenRouter：

```bash
read -s "OPENROUTER_API_KEY?OpenRouter API Key: "
export OPENROUTER_API_KEY
echo
```

完成实验并退出该 Shell 后，这种临时环境变量不会作为项目文件保存。

### 一个非常重要的安全实验

Day 13 实现 `run_command` 时，**不要把模型 API Key 自动传给 Agent 启动的子进程**。

错误思路：

```text
Mini Agent Python 进程拥有 API Key
        ↓
run_command 原样继承全部环境变量
        ↓
Agent 执行 env / printenv
        ↓
密钥可能出现在 Tool Result
        ↓
又进入模型 Context
```

正确思路：

```text
Mini Agent 本身可以读取模型 API Key
        ↓
调用模型
        ↓
执行 run_command 时构造“清理后的子进程环境”
        ↓
DEEPSEEK_API_KEY / OPENROUTER_API_KEY 不传进去
```

这会成为 Day 13 的必做安全实验之一。

### 成本控制规则

学习阶段：

- 使用单独的学习 Key / 学习账户配置
- 能设置预算或限额时设置较小限额
- 不开启无意义的超长自动循环
- Mini Agent 必须有 `max_steps`
- 调试时使用短 Prompt、小文件、小任务
- 不为了测试 Agent 让模型无限重试

我们学的是 Agent 架构，不是烧 Token。

### 不使用的接入方式

除非以后专门研究，否则 14 天内不使用：

- 来源不明的免费 API 中转
- 共享 API Key
- 网上复制来的 Key
- 要求关闭 TLS / 证书验证的服务
- 要求把密钥写进仓库配置的未知服务
- 为了省一点费用而牺牲密钥安全的方案

---


# 四、每天统一学习结构

除特殊日外，每天约 3～4 小时：

```text
40～60 分钟   理论
60～90 分钟   实验
40～60 分钟   自己动手
20～30 分钟   复盘 / 自查
```

每天结束必须满足：

```text
能自己解释
+
亲手做过实验
+
知道实验发生了什么
+
通过当天自查
```

不是“看完了”就算结束。

---

# Day 01｜LLM、Agent、Harness：先把黑盒拆开

## 今日目标

彻底理解：

```text
LLM ≠ Agent
Agent ≠ 某个聊天界面
Agent = 模型 + Harness + Context + Tools + Loop + Environment
```

今天**不安装 Pi**。

## 理论内容

学习：

- LLM 的基本输入输出模型
- Chatbot 与 Agent 的区别
- Coding Agent 为什么能连续执行任务
- Agent Harness 是什么
- Agent Loop 是什么
- Environment 是什么
- 为什么 Agent 的“自主”其实来自循环和工具

重点理解：

```text
普通 LLM：

Prompt
  ↓
LLM
  ↓
Response
```

而 Agent：

```text
Prompt
  ↓
LLM
  ↓
决定调用工具
  ↓
工具执行
  ↓
结果返回
  ↓
LLM 再判断
  ↓
继续调用 / 最终回答
```

## Codex 观察实验

给 Codex 一个非常小的任务，例如：

```text
阅读 hello.c，告诉我它做了什么，不要修改任何文件。
```

然后观察：

- Agent 是否读取文件
- 是否使用工具
- 是否执行命令
- 是否产生文件变化
- 最终回答来自哪里

第二个实验：

```text
检查 hello.c 是否可以编译。如果需要执行 clang，可以执行，但不要修改文件。
```

观察 `read → command → result → answer`。

## 今日笔记必须写下

用自己的话写：

```text
LLM：
Agent：
Agent Harness：
Tool：
Agent Loop：
Environment：
```

禁止只复制定义。

## 自查题

1. LLM 与 Agent 最大的区别是什么？
2. Agent 为什么能连续工作很多步？
3. Harness 在 Agent 中负责什么？
4. Tool 是 LLM 本身拥有的能力吗？
5. Codex 执行 `clang hello.c` 时，真正运行命令的是谁？
6. 如果没有任何 Tool，一个 Coding Agent 还能直接修改你的 SSD 吗？

## 完成标准

能够独立画出：

```text
User → Harness → LLM → Tool Call → Tool Result → LLM
```

并逐个解释。

---

# Day 02｜Tool Calling：Agent 的“手”到底是什么

## 今日目标

彻底理解 Tool Calling。

今天结束后看到：

```text
read
edit
write
bash
```

不能只理解成“功能按钮”，而要理解它们背后的调用流程。

## 理论内容

学习：

- Tool Definition
- Tool Name
- Tool Description
- Parameters / Schema
- Tool Call
- Tool Result
- 为什么工具描述会影响模型决策
- 为什么 Tool Result 要再次送回模型
- “模型选择工具”与“程序执行工具”的区别

理解类似：

```json
{
  "tool": "read",
  "arguments": {
    "path": "hello.c"
  }
}
```

这只是一个**结构化行动请求**。

真正执行通常类似：

```text
Harness
  ↓
找到 read 工具
  ↓
校验参数
  ↓
调用文件系统
  ↓
得到内容
  ↓
把结果交还 Agent Loop
```

## 实验

让 Codex 完成：

1. 读取 `hello.c`
2. 找一个你故意放进去的小错误
3. 修改
4. 编译
5. 根据编译结果继续判断

你只观察，不追求任务复杂度。

把过程手工记录成：

```text
Step 1:
Agent 想做什么：
调用了什么工具：
工具输入：
工具结果：
下一步为什么这么做：
```

## 加餐实验

思考：

如果只给 Agent：

```text
read
```

没有：

```text
write / edit / bash
```

它还能做什么？

## 自查题

1. Tool Call 是“命令已经执行”吗？
2. Tool Result 有什么作用？
3. 为什么参数 Schema 很重要？
4. 模型如果请求不存在的 Tool，会发生什么？
5. 禁止 `bash` 后，Agent 还可能修改文件吗？取决于什么？
6. 为什么减少 Tools 可以减少 Agent 的能力范围？

## 完成标准

你能够逐步解释一次真实的：

```text
read → edit → bash → observe
```

而不是只说“Agent 自己改了代码”。

---

# Day 03｜Context：模型这一刻到底“知道”什么

## 今日目标

解决一个非常关键的问题：

> Agent 当前做判断时，到底看到了哪些信息？

## 理论内容

学习：

- System Prompt
- Developer / Harness Instructions
- User Prompt
- Project Instructions
- Conversation History
- Tool Results
- File Content
- Context Window
- Context ≠ 整块硬盘
- “Agent 知道项目”到底意味着什么

理解：

```text
模型能推理的信息
=
当前真正进入 Context 的信息
```

而不是：

```text
电脑上存在的信息
=
模型全部知道
```

## 实验

在实验仓库创建：

```text
AGENTS.md
```

写：

```md
# Project Instructions

- 修改 C 文件后必须先编译。
- 不要删除文件。
- 回答时说明你执行过哪些检查。
```

然后让 Agent 修改一个简单 C 文件。

观察：

- 它有没有遵守说明
- 它为什么知道这些规则
- 改变 `AGENTS.md` 后行为是否变化

## 必学概念

区分：

```text
Context
Memory
Disk
Session
```

这四个词绝不能混为一谈。

## 自查题

1. 一个文件存在项目里，就一定已经进入模型 Context 吗？
2. System Prompt 与 User Prompt 有什么区别？
3. AGENTS.md 更接近“工具”还是“指令/上下文”？
4. Tool Result 为什么也可能进入 Context？
5. 模型为什么可能忘掉很早以前的对话？
6. Context 越多一定越好吗？

## 完成标准

面对“Agent 为什么知道这个项目怎么编译？”时，能够提出多种合理来源，而不是认为模型“扫描了整台电脑”。

---

# Day 04｜权限、安全边界与“不安心”的根源

## 今日目标

建立 Agent 安全的第一套正式模型。

以后不问：

```text
这个 Agent 安全吗？
```

而问：

```text
它能访问什么？
它能修改什么？
它能执行什么？
哪些行为需要批准？
出了问题怎么发现？
出了问题怎么恢复？
```

## 五层安全模型

```text
理解
 ↓
限制
 ↓
观察
 ↓
验证
 ↓
恢复
```

### 1. 理解

知道：

- Agent 有哪些 Tools
- cwd 在哪里
- 环境是什么
- 有无网络
- 有无额外插件

### 2. 限制

学习：

- Tool allowlist
- read-only
- sandbox
- approval
- OS 用户权限
- container / VM 的作用

### 3. 观察

学习：

```bash
git status
git diff
```

以及 Agent 的 tool / command 记录。

### 4. 验证

例如：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic hello.c -o hello
```

以及测试、lint、type check。

### 5. 恢复

学习：

```bash
git restore <file>
git restore .
```

并理解什么时候不能盲目执行恢复命令。

## 必须分清

```text
Project Trust
≠
Sandbox
≠
Approval
≠
OS Permission
```

## Prompt Injection 基础

理解：

仓库里的：

- README
- 注释
- 文档
- Issue 内容
- 构建输出
- 第三方文件

都可能包含误导 Agent 的文字。

核心原则：

> **“Agent 读取到的文字”不能自动等价于“可信指令”。**

## 自查题

1. Agent 在本地运行时，最终文件权限受什么控制？
2. Sandbox 与 Approval 分别解决什么问题？
3. Project Trust 为什么不能当 Sandbox 使用？
4. Git 是安全边界吗？为什么不是？
5. Git 为什么仍然是 Agent 工作的重要恢复工具？
6. Prompt Injection 为什么不仅存在于网页？

## 完成标准

你能解释：

> “为什么我现在比 Day 1 更清楚 Agent 到底危险在哪里？”

---

# Day 05｜正式认识 Pi：从裸 Agent 开始

## 今日目标

第一次正式使用 Pi。

但原则是：

> **先用裸 Pi，暂时不安装第三方 Skills / Extensions / Packages。**

## 官方安装方式（macOS / npm）

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

检查：

```bash
pi --help
```

进入实验仓库：

```bash
cd ~/Documents/agent-lab
pi
```

Pi 可以通过：

```text
/login
```

选择支持的登录方式。

## 今日模型接入选择

Day 05 不需要同时配置三个 Provider。

建议优先顺序：

```text
方案 1：ChatGPT Plus / Pro
        ↓
Pi 中执行 /login
        ↓
选择 ChatGPT Plus/Pro（Codex）

方案 2：DeepSeek 开发平台
        ↓
Pi 中使用 DeepSeek API Key

方案 3：OpenRouter
        ↓
Pi 中 /login OpenRouter
        或使用 OpenRouter API Key
```

第一次学习 Pi，我更建议：

```text
已经有 ChatGPT Plus / Pro
        ↓
先用订阅登录
```

原因不是“Plus 比 API 更高级”，而是这一天的学习目标是观察：

```text
Harness
Tool
Context
Agent Loop
```

暂时不让 API Key 配置分散你的注意力。

随后我们会专门使用 DeepSeek / OpenRouter API 完成 Mini Agent。

### 今天顺便观察 Credential 与 Tool 的边界

登录模型 Provider 后，要思考：

```text
Pi 能调用模型
```

并不等于：

```text
模型应该看到你的登录凭据 / API Key
```

Credential 应由 Harness 管理，而不是作为 Prompt 内容提供给模型。

## 今天只认识默认核心 Tools

Pi 默认模型工具重点观察：

```text
read
write
edit
bash
```

不要急着扩展。

## 实验 1：只读任务

让 Pi：

```text
阅读这个仓库，告诉我有哪些文件以及如何运行 C 示例。不要修改任何文件。
```

完成后退出并检查：

```bash
git status
```

## 实验 2：小修改

提前 checkpoint。

然后让 Pi：

```text
给 hello.c 增加一行简单输出，修改后编译并报告结果。
```

之后：

```bash
git status
git diff
```

你自己 review。

## 今日重点问题

每一次动作都问：

```text
模型为什么知道要这么做？
它用了哪个 Tool？
这个 Tool 实际访问了哪里？
cwd 是什么？
结果怎么回到模型？
```

## 自查题

1. Pi 为什么被称为 minimal coding harness？
2. 默认四个核心 Tool 分别做什么？
3. Pi 的 cwd 为什么重要？
4. Pi 的 `bash` 是“模拟终端”还是实际执行进程？
5. 为什么第一次学习 Pi 不应该先装一堆 Extension？

## 完成标准

完成一次完整的 Pi：

```text
读取 → 修改 → 编译 → 查看 diff
```

且能解释每一步。

---

# Day 06｜主动限制 Pi：自由不是越大越好

## 今日目标

第一次主动控制 Agent 能力。

理解：

> **Tool 越多 ≠ Agent 越高级。**
>
> 最小权限通常更容易理解、更容易验证。

## 学习 Pi Tool 控制

认识：

```text
--tools
--exclude-tools
--no-tools
--no-builtin-tools
```

先查看你当前 Pi 版本的帮助：

```bash
pi --help
```

不要死背参数；理解 allowlist 思想。

## 今日 Pi 命令实操

先在终端进入实验仓库：

```bash
cd ~/Documents/agent-lab
```

第一轮，只允许只读工具：

```bash
pi --tools read,grep,find,ls
```

让 Pi 完成代码审查后，用 `/quit` 退出，再检查：

```bash
git status
git diff
```

第二轮，加入编辑能力，但仍不开放任意 shell：

```bash
pi --tools read,grep,find,ls,edit
```

第三轮，只在已经创建 Git checkpoint 的实验仓库中加入 `bash`：

```bash
pi --tools read,grep,find,ls,edit,bash
```

还要分别观察下面两个边界：

```bash
pi --no-tools
pi --no-builtin-tools
```

必须能解释：

```text
--no-tools
→ 默认禁用所有 Tool

--no-builtin-tools
→ 默认禁用内置 Tool，但 Extension / 自定义 Tool 仍可能存在
```

`--exclude-tools` 用于从当前可用工具中排除指定工具，例如：

```bash
pi --exclude-tools bash,write,edit
```

注意：这属于 Pi Harness 的 Tool 配置，不等于 OS 级 Sandbox。

## 实验 1：只读 Agent

只允许读取相关工具。

目标：

```text
允许分析项目
禁止修改
禁止执行任意 shell
```

让它分析：

```text
找出 calculator.c 中可能的问题，只分析，不修改。
```

检查：

```bash
git status
```

## 实验 2：逐步增加能力

对比：

```text
只读
↓
允许 edit
↓
允许 bash
```

记录 Agent 能力发生了什么变化。

## 今日核心思考

建立：

```text
Capability = Model 能力 × 可用 Context × 可用 Tools × Environment Permission
```

模型很强，但没有 Tool，也无法直接进行某些真实世界操作。

## 自查题

1. Tool allowlist 的价值是什么？
2. 为什么 read-only Agent 仍可能泄露敏感内容给模型？
3. 禁止 bash 是否代表“绝对安全”？
4. `edit` 与 `write` 的风险是否完全相同？
5. 为什么最好按任务提供最少必要能力？

## 完成标准

你能自己设计一个：

```text
“只允许代码审查，不允许修改”
```

的 Agent 权限思路。

---

# Day 07｜Skills：给 Agent 工作方法，而不是新手臂

## 今日目标

理解 Skill 是什么，以及 Skill 和 Tool 的区别。

## 核心区分

```text
Tool：
“Agent 能做什么”

Skill：
“Agent 应该怎样完成某类任务”
```

Skill 更像：

```text
工作说明
+
流程
+
参考知识
+
可选脚本/资源
```

## 自己制作第一个 Skill

主题建议：

```text
C Language Check
```

目标规则：

1. 修改 `.c` 后必须编译
2. 使用：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic
```

3. 编译失败必须先分析错误
4. 不要为了消除 warning 随意改变程序语义
5. 最后查看 Git diff

## 今日 Pi 命令实操

今天使用项目级 Skill，避免一开始污染所有项目的全局配置。

在终端创建目录：

```bash
cd ~/Documents/agent-lab
mkdir -p .pi/skills/c-language-check
```

然后用 VS Code 创建并编写：

```text
.pi/skills/c-language-check/SKILL.md
```

先禁用自动发现的 Skills，完成一次基线实验：

```bash
pi --no-skills --tools read,edit,bash
```

再只显式加载你自己写的 Skill：

```bash
pi --no-skills \
  --skill ./.pi/skills/c-language-check/SKILL.md \
  --tools read,edit,bash
```

进入 Pi 后，可以输入：

```text
/skill:c-language-check
```

如果 Pi 已经在运行，而你刚修改了 `SKILL.md`，输入：

```text
/reload
```

再重新调用 Skill。今天的重点是比较“没有 Skill”和“显式加载 Skill”时，Agent 的工作流程有什么不同。

## 实验

分别：

```text
不使用 Skill 完成任务
```

和：

```text
使用自己的 Skill 完成同一个任务
```

比较：

- 行为一致性
- 检查流程
- 输出质量
- 是否遗漏编译

## 安全重点

Skill 本质上仍然是**对模型的指令来源**。

第三方 Skill 不能因为是 Markdown 就默认可信。

## 自查题

1. Skill 是 Tool 吗？
2. Skill 能直接绕过 OS 权限吗？
3. Skill 为什么能明显改变 Agent 行为？
4. 第三方 Skill 有什么潜在风险？
5. 什么时候应该写 Skill，而不是写一个新 Tool？

## 完成标准

自己写出并实际使用一个简单 Skill。

---

# Day 08｜Extensions / Hooks：开始看 Harness 内部

## 今日目标

从“Agent 用户”向“Agent Harness 理解者”迈一步。

## 理论内容

Pi Extension 可以用于：

- 监听事件
- 注册 Tool
- 拦截 Tool Call
- 增加 Command
- 修改工作流程
- 增加 UI
- 管理状态

重点不是今天就写复杂插件，而是理解：

```text
Extension
是在修改 Agent Harness 的行为
```

## 第一个简单 Extension 思路

只做观察：

```text
Agent 调用工具时
↓
记录 tool name
↓
显示给用户
```

不要一开始做复杂自动化。

## 今日 Pi 命令实操

项目级 Extension 放在：

```text
.pi/extensions/
```

在实验仓库中准备目录：

```bash
cd ~/Documents/agent-lab
mkdir -p .pi/extensions
```

完成 `tool-observer.ts` 后，先禁用自动发现，只加载这一份 Extension：

```bash
pi --no-extensions \
  --extension ./.pi/extensions/tool-observer.ts
```

短参数写法是：

```bash
pi --no-extensions -e ./.pi/extensions/tool-observer.ts
```

修改 Extension 后，在 Pi 中输入：

```text
/reload
```

完全禁用 Extension 做对照：

```bash
pi --no-extensions
```

今天不要安装来源不明的第三方 Extension；你的目标只是理解它如何改变 Harness 行为。

## 第二个实验：危险命令确认

理解一个安全拦截器的思路：

```text
tool_call
   ↓
是不是 bash？
   ↓
命令是否命中高风险规则？
   ↓
要求人工确认 / block
```

今天只在实验仓库演示。

## 必须理解

Extension 代码本身是程序。

因此：

```text
第三方 Extension
```

和普通第三方代码一样需要审查。

不能因为：

```text
“这是 Agent 插件”
```

就降低警惕。

## 自查题

1. Skill 与 Extension 最大区别是什么？
2. Extension 为什么比 Skill 权限潜力更高？
3. Tool Call interception 有什么价值？
4. Extension 能否改变默认 Tool 行为？
5. 为什么第三方 Extension 应该先看源码？

## 完成标准

能够解释：

```text
Prompt 层扩展
vs
Harness 层扩展
```

---

# Day 09｜Session、Context Window、Compaction、Memory

## 今日目标

解决 Agent 经常让人困惑的问题：

> “它刚才明明知道，为什么现在忘了？”

## 学习概念

### Session

一次持续工作状态。

### Context Window

模型一次推理能够接收的有限上下文。

### Conversation History

Session 中曾经发生过的消息与结果。

### Compaction

当历史过长时，通过压缩 / 总结降低 Context 占用。

### Memory

跨 Session 或长期保存的额外信息机制。

必须明确：

```text
Session ≠ Context
Context ≠ Memory
Memory ≠ 文件系统
```

## 实验

在 Pi 中进行一个稍长但安全的实验：

1. 让 Agent 阅读几个文件
2. 讨论修改方案
3. 修改
4. 编译
5. 再追问最早阶段的信息

观察：

- 它能否正确回忆
- 哪些内容是当前 Context
- 哪些内容可能被总结
- 重新开启 Session 后发生什么

## 今日 Pi 命令实操：创建、退出与恢复 Session

### 1. 创建并命名一次 Session

在终端启动：

```bash
cd ~/Documents/agent-lab
pi --name "day09-session"
```

进入 Pi 后依次输入：

```text
/session
/name day09-session
```

`/session` 用于查看当前 Session 的 ID、文件、消息、Token 和成本等信息；把 Session ID 记到当天笔记，但不要手动修改 Session JSONL 文件。

完成几轮对话后退出：

```text
/quit
```

### 2. 恢复 Session

方法 A：启动 Pi 后，在交互界面中选择旧 Session：

```bash
pi
```

```text
/resume
```

方法 B：在终端直接打开 Session 选择器：

```bash
pi -r
```

方法 C：在终端直接继续当前目录最近一次 Session：

```bash
pi -c
```

必须分清：

```text
/resume  → Pi 交互界面内的命令
pi -r    → zsh 中执行的启动命令
pi -c    → 直接继续最近一次 Session
```

### 3. Session 树、分支与新会话

恢复后依次体验：

```text
/tree
/fork
/clone
/new
```

- `/tree`：回到历史中的某个位置，并从那里继续，原历史仍保留。
- `/fork`：从某条旧的用户消息创建新的 Session。
- `/clone`：把当前活动分支复制为一个新 Session。
- `/new`：开始一个全新的 Session。

### 4. 手动 Compaction

在已有较长历史的 Session 中先查看：

```text
/session
```

然后执行：

```text
/compact
```

也可以附加自定义要求：

```text
/compact 请保留已经修改的文件、编译命令、失败原因和下一步任务
```

再次执行 `/session`，观察 Context 变化。要记住：Compaction 有损，但完整历史仍保存在 Session 文件中，可通过 `/tree` 回看。

### 5. 不保存 Session 的对照实验

```bash
pi --no-session
```

退出后尝试恢复，理解“临时对话”和“可恢复 Session”的区别。

## 思考

为什么无限往 Context 塞东西不是好事？

考虑：

- 相关性下降
- 噪声增加
- 成本增加
- 推理重点被稀释

## 自查题

1. Context Window 是硬盘容量吗？
2. Session 与 Memory 有什么区别？
3. Compaction 为什么存在？
4. Compaction 有什么潜在信息损失？
5. 为什么“更多上下文”不一定更好？
6. 为什么 AGENTS.md 应该写得清晰且相关？

## 完成标准

能够画出：

```text
Session History
      ↓
Context Selection / Compaction
      ↓
Current Model Input
```

---

# Day 10｜Planning、Autonomy、MCP、Sub-agent：不要被术语吓到

## 今日目标

把常见 Agent 术语放回正确层级。

今天主要理解，不追求搭建复杂系统。

## 今日 Pi 命令实操

Pi 核心默认不内置 Plan Mode、MCP 和 Sub-agent。今天先用命令验证“核心有什么”，不要为了凑功能急着安装第三方包。

查看当前版本、帮助和已安装资源：

```bash
pi --version
pi --help
pi list
pi config
```

启动一个不带 Tool、Skills 和 Extensions 的纯规划对话：

```bash
cd ~/Documents/agent-lab
pi --no-tools --no-skills --no-extensions \
  "先只为这个项目制定排错计划，不要执行任何操作。"
```

再启动只读版本，让 Pi 根据真实文件修正计划：

```bash
pi --tools read,grep,find,ls \
  --no-skills --no-extensions \
  "阅读项目后制定排错计划，不要修改文件。"
```

对比两次结果，回答：计划差异来自模型本身，还是来自可用 Context 与 Tools？

如果以后要体验 MCP、Sub-agent 或 Plan Mode，应把它当作 Extension / Package 带来的 Harness 扩展，并先审查来源、代码和权限；今天不安装。

## Planning

计划不是魔法。

它可能只是：

```text
先生成步骤
↓
再逐步执行
```

或者 Harness 中专门设计的工作模式。

## Autonomy

不要用“自主程度”这种模糊词单独判断 Agent。

拆成：

```text
最多循环多少步
有哪些 Tools
是否需要 Approval
是否能联网
是否能修改文件
是否能启动其他 Agent
```

## MCP

先建立概念：

```text
Agent / Client
     ↓
标准化协议
     ↓
外部 Tool / Resource / Service
```

今天不要求大量配置 MCP。

先理解：

> MCP 解决“如何标准化连接能力”，并不自动解决“这个能力是否可信”。

## Sub-agent

理解：

```text
Main Agent
 ├── Research Agent
 ├── Coding Agent
 └── Review Agent
```

它的价值可能包括：

- 分工
- 隔离上下文
- 并行
- 专门角色

同时会带来：

- 更多 Context
- 更多调用
- 更复杂权限
- 更难观察

## 自查题

1. Plan Mode 是否一定意味着使用了另一个模型？
2. Autonomy 应该怎样拆解？
3. MCP 是 Agent 本身吗？
4. 接上 MCP 后为什么权限模型更复杂？
5. Sub-agent 为什么可能缓解 Context 污染？
6. 多 Agent 为什么也可能降低可控性？

## 完成标准

看到：

```text
MCP / Sub-agent / Planning / Autonomous
```

不再把它们混成一个概念。

---

# Day 11｜Codex 拆解：重新看你已经在用的 Agent

## 今日目标

把前 10 天学到的知识重新套回 Codex。

今天重点不是“Codex 教程”，而是架构分析。

## 今日 Pi 对照命令

先用 Pi 做一个只读对照，保留输出供后面与 Codex 比较：

```bash
cd ~/Documents/agent-lab
pi -p --tools read,grep,find,ls \
  "说明这个项目的结构、编译方法和你实际使用的工具。不要修改文件。"
```

`-p` / `--print` 表示非交互执行一次并退出。

再观察结构化事件流：

```bash
pi --mode json --tools read,grep,find,ls \
  "列出项目结构，不要修改文件。"
```

做一次 Context 对照：

```bash
pi -p --no-context-files --tools read,grep,find,ls \
  "说明这个项目的编译命令。"
```

将结果与正常加载 `AGENTS.md` 时比较。`--no-context-files` 只关闭 Pi 对 `AGENTS.md` / `CLAUDE.md` 的自动发现，不会删除磁盘上的文件。

## 观察维度

打开你日常使用的 Codex，对一个小 Git 项目完成任务。

从以下角度观察：

### 1. Context

- 用户指令
- 项目指令
- 文件
- command output
- diff
- session

### 2. Tools

记录它实际使用：

- 文件读取
- 文件修改
- shell
- 搜索 / 网络（如果有）

### 3. Permission

关注：

- 什么操作直接执行
- 什么操作要求确认
- 什么环境被限制
- 什么操作涉及网络
- sandbox 的边界

### 4. Verification

Agent 修改后：

```bash
git status
git diff
```

然后自己运行测试 / 编译。

## 今天必须完成一份 Codex 架构说明

格式：

```text
我认为 Codex 的工作过程：

User
 ↓
Codex Harness
 ↓
Instructions + Context
 ↓
Model
 ↓
Tool Request
 ↓
Sandbox / Approval / Execution
 ↓
Tool Result
 ↓
Model
 ↓
Diff / Answer
```

## 自查题

1. Codex 与底层 LLM 是同一个概念吗？
2. Desktop UI 是否就是 Agent 本身？
3. Sandbox 为什么属于 Harness / Execution 层，而不是 LLM 智力？
4. Approval 为什么不能防止所有逻辑错误？
5. Codex 修改成功后为什么仍然应该 review diff？
6. Codex 与 Pi 最大的学习价值差异是什么？

## 完成标准

你能够第一次比较完整地解释：

> **“Codex 到底是什么？”**

而不是回答“一个会写代码的 AI”。

---

# Day 12｜横向比较：Pi / Codex / Copilot CLI / OpenCode

## 今日目标

学会分析新的 Agent，而不是依赖品牌熟悉度。

## 比较原则

不要比较：

```text
谁最聪明？
```

先比较：

```text
1. Model / Provider
2. Harness
3. Tools
4. Context
5. Project Instructions
6. Approval
7. Sandbox / Isolation
8. Session
9. Extensions
10. MCP
11. Diff / Review
12. Rollback
```

## 今日任务

建立自己的表：

| 维度 | Pi | Codex | Copilot CLI | OpenCode |
|---|---|---|---|---|
| Harness 类型 |  |  |  |  |
| 默认 Tools |  |  |  |  |
| cwd |  |  |  |  |
| Project instructions |  |  |  |  |
| Approval |  |  |  |  |
| Sandbox |  |  |  |  |
| Skill / Extension |  |  |  |  |
| Session |  |  |  |  |
| 最喜欢的控制点 |  |  |  |  |
| 我最担心的地方 |  |  |  |  |

不知道的项目不要猜，标：

```text
待查
```

这正是专业习惯。

## 今日 Pi 信息采集命令

只记录你当前安装版本真实显示的信息：

```bash
pi --version
pi --help
pi --list-models
pi list
pi config
```

进入 Pi 后再查看：

```text
/hotkeys
/settings
/session
/model
/thinking
```

可选：用 `/scoped-models` 设置允许快捷切换的模型范围，然后用 `Ctrl+P` / `Shift+Ctrl+P` 观察模型切换。

今天把这些实际输出填进比较矩阵；如果某个工具没有对应能力，就写“无内置能力”或“待查”，不要凭印象补齐。

## 今日重点

学会面对陌生 Agent 时先问：

```text
它有什么能力？
能力从哪里来？
在哪里执行？
谁负责权限？
我能否看到结果？
出错如何恢复？
```

## 自查题

1. 模型强弱与 Harness 好坏是不是同一个维度？
2. 两个 Agent 使用同一模型，为什么表现仍然可能明显不同？
3. 为什么工具设计会影响 Agent 表现？
4. 为什么“自由”需要进一步拆成具体权限？
5. 比较 Agent 最不应该只看什么？

## 完成标准

完成自己的 Agent 对比矩阵。

---

# Day 13｜亲手实现 Mini Agent：第一次造出 Agent Loop

## 今日目标

亲手实现一个最小 Agent。

目的不是造一个 Codex 替代品。

目的只有一个：

> **亲手证明 Coding Agent 的核心机制没有魔法。**

## 今日 Pi 对照命令

在写 Mini Agent 前，用 Pi 做三组对照：

```bash
cd ~/Documents/agent-lab

pi -p --no-tools \
  "告诉我 c/hello.c 的具体内容。"

pi -p --tools read \
  "读取 c/hello.c，并概括 main 函数做了什么。"

pi --mode json --tools read \
  "读取 c/hello.c，并概括 main 函数做了什么。"
```

观察：

```text
没有 read Tool 时，模型不能可靠知道磁盘文件内容
有 read Tool 时，出现 Tool Call 与 Tool Result
JSON 模式会把 Agent 运行事件作为 JSONL 输出
```

可选进阶，只启动并观察 RPC 模式的输入输出形式，不要求今天实现客户端：

```bash
pi --mode rpc
```

随后再写自己的 Python Mini Agent，把 Pi 的事件流程作为参照物。

## Day 13 模型接入固定方案

今天真正需要程序调用模型 API，因此严格按本计划的统一限制执行。

### 默认方案：DeepSeek 开发平台

当前 DeepSeek API 提供 OpenAI-compatible 接口。

Python 项目建议使用你已经习惯的 `uv`：

```bash
mkdir mini-agent
cd mini-agent

uv init
uv add openai
```

客户端结构先理解成：

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["DEEPSEEK_API_KEY"],
    base_url="https://api.deepseek.com",
)
```

模型名称不要凭旧教程死记。

开始 Day 13 时先看 DeepSeek 当前官方模型列表，再选择一个支持 Tool Calling 的模型。

### 备用方案：OpenRouter

Agent Loop 完全可以保持不变，只替换 Provider 配置：

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["OPENROUTER_API_KEY"],
    base_url="https://openrouter.ai/api/v1",
)
```

然后选择 OpenRouter 当前提供的、明确支持 Tool Calling 的模型 ID。

这正好帮助理解：

```text
Agent Harness
        │
        ├── DeepSeek
        └── OpenRouter → 不同模型 Provider
```

也就是说：

> **Agent Loop 与模型 Provider 应尽量解耦。**

### ChatGPT Plus / Pro 在 Day 13 的定位

除非我们届时采用一个**明确支持 ChatGPT 订阅 OAuth 的现成 Harness / SDK 方案**，否则自己写 Mini Agent 时不把 Plus 订阅当作通用 API Key 使用。

因此：

```text
Pi：
可以使用 ChatGPT Plus / Pro 授权

我们自己写的 Mini Agent：
默认 DeepSeek API / OpenRouter API
```

不要混淆这两件事。

## API 连通性测试

正式写 Agent Loop 前，先完成最小测试：

```text
Python
 ↓
读取环境变量中的 API Key
 ↓
调用 Provider
 ↓
发送一句简单消息
 ↓
收到模型文本回复
```

只有这个环节成功后，才加入 Tool Calling。

这样出现问题时能区分：

```text
Provider / API 问题
```

和：

```text
Agent Loop / Tool 问题
```

## 第一版只实现两个 Tool

建议：

```text
read_file
run_command
```

暂时不要直接实现危险的全功能 shell 自动执行。

## 最小结构

```python
messages = [user_message]

while True:
    response = call_model(messages, tools)

    if response.requests_tool:
        result = execute_tool(response.tool_call)
        messages.append(response)
        messages.append(result)
    else:
        print(response.text)
        break
```

实际 API 格式以后根据你选择的模型/provider 调整。

今天重点不是 API 细节，而是：

```text
Loop
Tool Definition
Tool Dispatch
Tool Result
State
Stopping Condition
```

## 第二阶段

增加：

```text
edit_file
```

但把它限制在：

```text
agent-lab/
```

实验时要求：

```text
每次修改后人工查看 diff
```

## 第三阶段：隔离 API Key 与 Tool 子进程

你的 Mini Agent Python 进程需要 API Key 来调用模型，但 `run_command` 没必要获得这个密钥。

因此执行子进程时建立“清理后的环境”。

概念示例：

```python
import os
import subprocess

SAFE_ENV = os.environ.copy()

SAFE_ENV.pop("DEEPSEEK_API_KEY", None)
SAFE_ENV.pop("OPENROUTER_API_KEY", None)
SAFE_ENV.pop("OPENAI_API_KEY", None)

result = subprocess.run(
    command,
    env=SAFE_ENV,
    capture_output=True,
    text=True,
)
```

今天必须亲手理解：

```text
模型凭据
        ≠
Tool 必须拥有的凭据
```

这就是“最小权限”在自己写 Agent 时的真实应用。

然后做安全检查：

```text
让 run_command 执行环境变量查看命令
        ↓
确认 Tool Result 中没有模型 API Key
```

**不要把真实密钥打印出来验证。**  
只检查相关变量是否不存在或已被移除。

## 必须思考的问题

你的 Mini Agent 必须有停止条件。

否则：

```text
Tool → Model → Tool → Model
```

理论上可能持续下去。

考虑：

- max steps
- timeout
- user cancel
- tool error
- repeated action detection

## 自查题

1. 你写的 Agent 哪一部分是 Harness？
2. LLM 在你的代码里负责什么？
3. Tool executor 负责什么？
4. Tool Result 为什么要 append 回 messages？
5. 如果删除 while loop，它还算多步 Agent 吗？
6. 为什么需要 `max_steps`？
7. DeepSeek / OpenRouter 与 Agent Harness 是什么关系？
8. 为什么 ChatGPT Plus 不能默认当成任意程序可用的 OpenAI API Key？
9. 为什么 API Key 不应该写进代码和 Git？
10. 为什么 `run_command` 子进程不应该继承模型 API Key？
11. 如果更换 Provider，但 Agent Loop 完全不用改，这说明我们的架构做对了什么？

## 完成标准

你的 Mini Agent 至少能够：

```text
用户提出问题
↓
模型决定读文件
↓
程序读取文件
↓
结果返回模型
↓
模型根据文件内容回答
```

这是整个 14 天最重要的“开窍实验”之一。

---

# Day 14｜毕业实验：从“不安心”到“可控制”

## 今日目标

不再学习大量新概念。

今天负责：

```text
复盘
+
验证
+
综合实验
+
建立长期工作规范
```

## 综合实验

在 `agent-lab` 中准备一个小项目，故意加入：

- 一个编译错误
- 一个逻辑问题
- 一段不太清晰的代码
- README 中的项目规则

然后完成三次任务。

### Round 1：Pi

要求：

```text
分析问题
→
修改
→
编译
→
检查
```

先建立 Git checkpoint，再用明确的工具集合和命名 Session 启动：

```bash
cd ~/Documents/agent-lab
git status
git add .
git commit -m "checkpoint before day14 graduation"

pi --name "day14-graduation" \
  --tools read,grep,find,ls,edit,bash
```

完成任务后，在 Pi 中查看并导出 Session：

```text
/session
/export ./experiments/day14-pi-session.html
/quit
```

然后在终端验证：

```bash
git status
git diff
```

如果需要继续刚才的验收 Session：

```bash
pi -c
```

### Round 2：Codex

完成类似任务。

### Round 3：人工 Review

你自己执行：

```bash
git status
git diff
```

并判断：

- Agent 改了什么
- 有没有越界
- 有没有不必要修改
- 是否真正解决问题
- 编译是否通过
- 是否应该接受这些改动

---

# 五、最终毕业答辩

不能查笔记，尽量用自己的话回答：

### 基础

1. 什么是 LLM？
2. 什么是 Agent？
3. 什么是 Harness？
4. 什么是 Agent Loop？
5. 什么是 Tool Calling？

### Context

6. Context 中通常有什么？
7. System Prompt 与 AGENTS.md 有什么区别？
8. Context Window 是什么？
9. Session、Memory、Compaction 分别是什么？

### Tool / Permission

10. 模型为什么能修改文件？
11. Tool Call 和 Tool Execution 有什么区别？
12. cwd 为什么重要？
13. Sandbox 是什么？
14. Approval 是什么？
15. OS 用户权限是什么？
16. Project Trust 为什么不等于 Sandbox？

### 扩展

17. Skill 是什么？
18. Extension 是什么？
19. MCP 是什么？
20. Sub-agent 是什么？
21. Hook / Tool interception 有什么价值？

### 安全

22. Prompt Injection 是什么？
23. 为什么本地代码仓库也可能产生 Prompt Injection？
24. 为什么 Git 不是 Sandbox？
25. 为什么 Git 对 Agent 工作仍然非常重要？
26. 为什么第三方 Extension 需要像普通代码一样审查？

### 实战

27. Agent 修改项目以后你第一件事检查什么？
28. 如果 Agent 请求执行一条你完全看不懂的 shell 命令，你怎么办？
29. 如何构造一个只读 Agent？
30. 如何判断一个新 Agent 是否值得信任？
31. API Key、OAuth Token、ChatGPT 订阅分别是什么层面的概念？
32. 为什么 ChatGPT Plus / Pro 不能自动等同于 OpenAI API 额度？
33. DeepSeek 与 OpenRouter 在 Mini Agent 学习中的角色分别是什么？
34. 为什么模型 API Key 不应该进入 Tool Result？
35. 如何做到“Mini Agent 能调用模型，但它运行的 shell 看不到模型密钥”？

---

# 六、毕业时必须能够写出的“一句话模型”

如果只能记住一句：

> **LLM 负责判断下一步做什么；Harness 负责把 Context、Tools、状态和权限组织起来；Tool 在真实环境中执行动作；结果重新进入 Agent Loop。**

再加一句安全原则：

> **不要靠“相信 Agent”获得安全感，要靠最小权限、可观察、可验证和可回滚获得安全感。**

---

# 七、14 天期间暂时不追求的东西

为了把基础打牢，这些内容不要过早占用精力：

- 一上来搭复杂 Multi-Agent 系统
- 收集大量第三方 MCP Server
- 安装几十个 Skills
- 安装大量 Pi Extensions
- 追求全自动无人值守
- 对各种 Agent 跑 benchmark
- 纠结“哪个模型世界第一”
- 自己造完整 IDE Agent
- 在重要真实项目里测试高权限自动化

这些不是没价值，而是应该建立在前面的基础之上。

学习顺序：

```text
看懂
↓
限制
↓
实验
↓
扩展
↓
自动化
```

---

# 八、建议的每日学习产物

和 C / MySQL 学习一样，每天留下笔记：

```text
agent-learning/
├── day01.md
├── day02.md
├── day03.md
├── ...
├── day14.md
├── agent-lab/
└── mini-agent/
```

每天的 `dayXX.md` 固定写：

```md
# Day XX

## 今天学了什么

## 核心概念

## 我做的实验

## Agent 实际进行了什么 Tool Call

## 今天遇到的问题

## 我现在的理解

## 自查答案

## 仍然不明白的地方
```

重点是：

> **记录自己的理解，不复制文档。**

---

# 九、你的 Agent 安心检查表

以后无论打开 Pi、Codex、Copilot CLI、OpenCode，先过这张表。

## 开始前

- [ ] 我现在在哪个目录？
- [ ] 这是重要项目还是实验项目？
- [ ] Git 工作区是否干净？
- [ ] 是否需要 checkpoint？
- [ ] Agent 能使用哪些 Tools？
- [ ] 能否执行 shell？
- [ ] 能否写文件？
- [ ] 是否允许联网？
- [ ] 是否加载了第三方 Skill / Extension / MCP？
- [ ] 我理解当前权限模式吗？

## 工作中

- [ ] Agent 当前在做什么？
- [ ] 它为什么要执行这个命令？
- [ ] 有没有操作项目之外的路径？
- [ ] 有没有请求我不理解的高权限行为？
- [ ] 有没有读取不相关的敏感文件？
- [ ] 遇到不确定行为时是否停止并检查？

## 完成后

```bash
git status
git diff
```

然后确认：

- [ ] 改动范围符合任务
- [ ] 没有无关修改
- [ ] 没有意外删除
- [ ] 测试 / 编译通过
- [ ] 我看懂了主要 diff
- [ ] 确认无误后再 commit

---

# 十、Pi 学习中特别要记住的安全事实

截至本计划编写时，Pi 的设计重点是 minimal、extensible。

你尤其要记住：

### 1. 默认核心工具

Pi 默认重点提供：

```text
read
write
edit
bash
```

另外还存在可配置的只读类工具。

### 2. Project Trust 不是 Sandbox

Project Trust 主要控制项目本地资源是否被加载。

不要理解成：

```text
Trusted Project
=
Agent 被隔离
```

### 3. Pi 没有内置系统级 Sandbox

本地 Pi 工具行为最终受 Pi 进程所拥有的本机用户权限约束。

真正强隔离应该依赖：

- OS sandbox
- container
- VM
- micro-VM
- 远程隔离环境

### 4. Extension 是真正执行的代码

第三方 Extension 可以拥有非常强的能力。

因此：

```text
安装 Extension
≈
安装第三方代码
```

应该审查来源和实现。

### 5. Git 是恢复手段，不是安全边界

Git 很重要，但它不能阻止：

- 读取项目外文件
- 网络访问
- 执行外部程序
- 修改未跟踪文件
- 其他系统副作用

所以：

```text
Git
=
观察 + 恢复工具

不是 sandbox
```

### 6. Pi 常用命令速查

先区分命令运行位置：

| 写法 | 在哪里输入 | 用途 |
|---|---|---|
| `pi` | zsh 终端 | 启动 Pi |
| `pi -c` | zsh 终端 | 继续当前目录最近一次 Session |
| `pi -r` | zsh 终端 | 启动 Session 选择器 |
| `/resume` | Pi 交互界面 | 选择并恢复旧 Session |
| `/session` | Pi 交互界面 | 查看当前 Session 信息 |
| `/new` | Pi 交互界面 | 创建新 Session |
| `/tree` | Pi 交互界面 | 在当前 Session 历史树中跳转 |
| `/fork` | Pi 交互界面 | 从旧消息分叉出新 Session |
| `/clone` | Pi 交互界面 | 复制当前活动分支为新 Session |
| `/compact` | Pi 交互界面 | 手动压缩当前 Context |
| `/model` | Pi 交互界面 | 选择模型 |
| `/thinking` | Pi 交互界面 | 选择思考等级 |
| `/settings` | Pi 交互界面 | 修改常用设置 |
| `/reload` | Pi 交互界面 | 重新加载 Skills、Extensions 等资源 |
| `/quit` | Pi 交互界面 | 退出 Pi |

常用终端启动形式：

```bash
# 查看版本与帮助
pi --version
pi --help

# 单次执行后退出
pi -p "分析当前项目"

# 只读工具集合
pi --tools read,grep,find,ls

# 不保存本次 Session
pi --no-session

# 不自动加载项目说明文件
pi --no-context-files

# 只加载指定 Skill
pi --no-skills --skill ./path/to/SKILL.md

# 只加载指定 Extension
pi --no-extensions -e ./path/to/extension.ts
```

这张表用于复习，不代替每天的实验。具体参数仍以你本机 `pi --help` 的输出为准。

---

# 十一、Codex 对照时要关注的重点

Codex 的学习价值不是让你背界面，而是观察一个更完整 Agent Harness 如何处理：

- 项目上下文
- diff review
- approvals
- sandboxing
- commands
- network access
- session / threads
- project instructions
- skills / hooks 等扩展机制

每次用 Codex，都尽量在脑中完成：

```text
这是谁的能力？

模型？
Harness？
Tool？
Sandbox？
OS？
Git？
```

只要你能不断回答这个问题，对 Codex 的“不安心”就会越来越具体、可解释、可控制。

---

# 十二、14 天进度表

| Day | 主题 | 状态 |
|---|---|---|
| 01 | LLM / Agent / Harness / Agent Loop | ✅ 已完成 |
| 02 | Tool Calling | ✅ 已完成 |
| 03 | Context / Prompt / Project Instructions | ✅ 已完成 |
| 04 | Permission / Sandbox / Approval / Prompt Injection | ✅ 已完成 |
| 05 | Pi 基础与裸 Agent | ✅ 已完成 |
| 06 | Tool Allowlist 与最小权限 | ✅ 已完成 |
| 07 | Skills | ✅ 已完成 |
| 08 | Extensions / Hooks | ✅ 已完成 |
| 09 | Session / Context Window / Compaction / Memory | ✅ 已完成 |
| 10 | Planning / MCP / Sub-agent / Autonomy | ✅ 已完成 |
| 11 | Codex 架构拆解 | ✅ 已完成 |
| 12 | Pi / Codex / Copilot CLI / OpenCode 横向分析 | ✅ 已完成 |
| 13 | Mini Agent | ✅ 已完成 |
| 14 | 综合实验 + 毕业答辩 | ✅ 已完成 |

---

# 十三、执行原则

整个 14 天，我建议坚持：

```text
理论不要一次灌太多
↓
立即做小实验
↓
你自己解释发生了什么
↓
再增加一层复杂度
```

尤其不要为了“进度”跳过 Day 1～Day 4。

前四天看起来没有大量炫酷操作，但它们恰恰是在解决你现在真正的问题：

> **我为什么敢把代码交给 Agent？**

最终答案应该不是：

> 因为 Agent 很聪明。

而是：

> **因为我理解它的架构，知道它的能力边界，能限制它的权限，能观察它的动作，能验证结果，也能在出错时恢复。**

这就是整套 14 天学习计划真正的毕业目标。
