# Day 14｜毕业实验：从“不安心”到“可控制”

> 本日目标：复盘、验证、综合实验，并建立长期使用 Coding Agent 的工作规范。

---

## 一、今天完成了什么

今天完成了整套 14 天训练的最终验收，包含：

1. Day 14 实验环境准备
2. Git checkpoint
3. Round 1：Pi 毕业实验
4. Pi Session 导出与人工检查
5. Round 2：Codex 毕业实验
6. Round 3：人工 Review
7. 35 题毕业答辩
8. 最终 Git 工作区清理

最终状态：

```text
On branch main
nothing to commit, working tree clean
```

这意味着 Day 14 的实验最终已经收尾，工作区回到了干净状态。

---

## 二、实验项目

实验目录：

```text
~/Documents/agent-lab/experiments/day14
```

实验中准备了：

```text
experiments/day14/
├── README.md
└── main.c
```

README 中规定：

- 只允许修改 `experiments/day14/` 目录中的文件
- 不删除文件
- 修改 `main.c` 后必须编译
- 编译命令固定为：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic main.c -o day14
```

- 最终需要说明修改内容和编译结果
- 不允许修改 `AGENTS.md`、Skills、Extensions 或其他无关文件

`main.c` 中故意放入：

- 一个编译错误：缺少分号
- 一个逻辑错误：三个数求平均值却除以 4
- 一些可读性问题：变量名过短

---

## 三、实验前检查

实验开始前执行：

```bash
cd ~/Documents/agent-lab
pwd
git status
```

确认：

```text
/Users/moonlit_boy/Documents/agent-lab

On branch main
nothing to commit, working tree clean
```

我的理解：

- `pwd`：确认当前 cwd / 工作目录
- `git status`：确认实验前是否存在已有改动
- 先建立干净基线，再让 Agent 工作

需要特别记住：

```text
cwd
≠
Sandbox
```

cwd 主要决定默认工作位置和相对路径解析，并不会自动限制 Agent 只能访问该目录。

---

## 四、Git checkpoint

实验前提交原始“有问题版本”：

```bash
git add experiments/day14
git commit -m "checkpoint before day14 graduation"
```

提交：

```text
d138271 checkpoint before day14 graduation
```

checkpoint 的意义：

```text
Agent 工作前的已知状态
↓
Agent 修改
↓
git status / git diff
↓
人工判断真实变化
↓
需要时可以恢复
```

Git 是非常重要的观察与恢复工具，但不是 Sandbox。

---

# 五、Round 1：Pi

## 5.1 启动方式

```bash
pi --name "day14-graduation" \
  --tools read,grep,find,ls,edit,bash
```

Pi 版本：

```text
pi v0.85.1
```

启动时实际加载：

```text
[Context]
  AGENTS.md

[Skills]
  c-language-check

[Extensions]
  tool-blocker.ts, tool-observer.ts
```

这里说明：

```text
--tools ...
只控制 Tool 集合

它并不等于：
--no-skills
--no-extensions
--no-context-files
```

所以 Tool allowlist、Skill、Extension、Context 自动加载是不同控制维度。

---

## 5.2 Pi 实际工作流程

Pi 的关键过程：

```text
加载 Context / Skill / Extensions
        ↓
read README.md
        ↓
read main.c
        ↓
edit main.c
        ↓
bash 编译
        ↓
read 修改后的代码
        ↓
bash 查看 git diff
        ↓
bash 运行程序
        ↓
bash 查看 git status
        ↓
最终回答
```

观察到的 Tool：

```text
read
edit
bash
```

`tool-observer.ts` 也记录了 Tool Call：

```text
[tool-observer] Tool: read
[tool-observer] Tool: edit
[tool-observer] Tool: bash
```

这说明 Extension 确实运行在 Harness 层，而不是普通 Prompt 文本。

---

## 5.3 Pi 修改内容

Pi 发现并修复：

- 缺少分号的编译错误
- 三个数除以 4 的逻辑错误
- `s`、`r` 等变量名可读性差
- 为 `if/else` 增加花括号

其中一种修改思路：

```c
int total = a + b + c;
int count = 3;
double average = total / (double)count;
```

---

## 5.4 编译与运行

Pi 执行：

```bash
cd experiments/day14 && \
clang -std=c17 -Wall -Wextra -Wpedantic main.c -o day14
```

编译结果：

```text
(no output)
```

表示编译成功且没有 warning 输出。

随后运行：

```bash
./day14
```

结果：

```text
Average: 90.00
Pass
```

---

## 5.5 Pi 人工检查

Pi 自己查看：

```text
M experiments/day14/main.c
?? experiments/day14/day14
```

含义：

- `M main.c`：Git 已跟踪文件被修改
- `?? day14`：新出现但尚未被 Git 跟踪的文件

`day14` 是 clang 产生的编译产物，不是源码文件。

这也证明：

> Agent 的最终回答只是报告，必须再用 Git 和真实文件系统验证。

---

## 5.6 Tool Call 与真正执行

最终执行链：

```text
LLM
↓
提出 bash Tool Call

Harness
↓
接收、校验并调度 Tool

bash Tool / 执行层
↓
启动真实系统进程

OS
↓
真正运行 clang
```

所以：

```text
模型提出动作
≠
Harness 允许 / 调度动作
≠
OS 最终执行动作
```

---

## 5.7 Session 导出

Pi 中执行：

```text
/session
/export ./experiments/day14/day14-pi-session.html
/quit
```

导出的文件：

```text
experiments/day14/day14-pi-session.html
```

随后提交：

```bash
git add experiments/day14/day14-pi-session.html
git commit -m "save day14 pi session"
```

提交：

```text
1d7d5bd save day14 pi session
```

---

# 六、Round 2：Codex

为了公平比较，先把 `main.c` 恢复到 checkpoint 中的有问题版本，并删除 Pi 编译生成的 `day14`。

恢复后：

```text
git diff 为空
```

然后给 Codex 与 Pi 基本相同的任务。

---

## 6.1 Codex 实际流程

观察到 Codex 完成了类似流程：

```text
读取 README.md + main.c
        ↓
分析问题
        ↓
修改 main.c
        ↓
clang 编译
        ↓
运行程序
        ↓
检查 diff / status
        ↓
最终回答
```

Codex 同样修复：

- 编译错误
- 平均值逻辑错误
- 变量命名问题
- `if/else` 可读性

并且编译、运行成功。

---

## 6.2 Pi 与 Codex 的一个重要区别

Pi 这次有明确的专门 Tool：

```text
read
edit
bash
```

而 Codex 在读取文件时，实际可以通过 shell 命令完成，例如：

```bash
sed -n '1,240p' experiments/day14/README.md
sed -n '1,300p' experiments/day14/main.c
```

这说明：

```text
同一个“读取文件”目标
≠
所有 Agent 都必须使用相同 Tool 设计
```

Agent 的行为不仅取决于模型，还取决于 Harness、Tool Registry、权限和执行方式。

---

# 七、Round 3：人工 Review

人工 Review 时重点检查：

1. Agent 实际修改了什么？
2. 有没有修改实验目录之外的文件？
3. 有没有不必要修改？
4. 编译产物是不是被误当成源码？
5. 编译是否真的通过？
6. 是否应该接受改动？

我的判断：

- 实际源码修改：`main.c`
- 没有发现越界修改
- `day14` 是编译产物
- 没有明显不必要修改
- 修改后可读性 OK
- 可以接受修改

核心原则：

```text
Agent 自己说“完成了”
≠
真实工作区已经验证正确
```

必须：

```bash
git status
git diff
```

能测试就继续测试。

---

# 八、毕业答辩复盘

## 8.1 LLM / Agent / Harness

### LLM

大语言模型，主要负责理解、推理、生成和判断下一步。

### Agent

可以理解为：

```text
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

### Harness

负责把：

- Context
- Tools
- Skills
- Extensions
- MCP
- Session / State
- Permission Flow
- Execution

组织起来，让模型能够真正完成多步任务。

---

## 8.2 Agent Loop

```text
Observe
↓
Reason / Decide
↓
Tool Call
↓
Tool Execution
↓
Tool Result
↓
再次进入 Context
↓
继续 Reason
```

Tool Calling 是结构化工具调用请求，不等于工具已经执行。

---

## 8.3 Context

Context 中可能包含：

- System Prompt
- Developer / Harness Instructions
- User Prompt
- Project Instructions
- Conversation History
- Tool Results
- File Content

核心：

```text
模型能推理的信息
=
真正进入当前 Context 的信息
```

硬盘上存在的文件并不代表模型自动知道。

---

## 8.4 Session / Memory / Compaction

### Session

一次持续工作的状态与历史。

### Memory

跨 Session 或长期保存的信息机制。

### Compaction

当历史过长时，对旧内容进行压缩 / 总结，降低 Context 占用。

必须分清：

```text
Session ≠ Context
Context ≠ Memory
Compaction ≠ Memory
Memory ≠ 文件系统
```

---

## 8.5 cwd / Sandbox / Approval / OS Permission

### cwd

当前工作目录，决定：

- 默认项目位置
- 相对路径解析
- 命令默认执行位置

但：

```text
cwd ≠ Sandbox
```

### Sandbox

限制 / 隔离 Agent 的执行范围和可访问资源。

### Approval

某些动作执行前，需要用户决定是否放行。

### OS 用户权限

本地进程最终仍然受当前操作系统用户权限约束。

### Project Trust

主要是 Harness 是否信任并加载项目本地资源。

所以：

```text
Project Trust
≠
Sandbox
≠
Approval
≠
OS Permission
```

---

# 九、Skill / Extension / MCP / Sub-agent

## Skill

告诉 Agent：

> 某一类任务应该怎样完成。

更像：

```text
工作说明
+
流程
+
参考知识
+
可选资源
```

Skill 本身不等于新 Tool。

## Extension

修改 Harness 行为的程序扩展。

可能：

- 监听事件
- 注册 Tool
- 拦截 Tool Call
- 添加 Command
- 修改工作流程
- 管理状态

Extension 本身是真正执行的代码，因此第三方 Extension 必须像普通第三方程序一样审查。

## MCP

Model Context Protocol。

核心理解：

```text
Agent / Client
↓
标准化协议
↓
外部 Tool / Resource / Service
```

MCP 解决“怎么连接”，不自动解决“能力是否可信”。

## Sub-agent

主 Agent 将不同任务交给其他 Agent 分工，例如：

```text
Main Agent
├── Research Agent
├── Coding Agent
└── Review Agent
```

优点：

- 分工
- 上下文隔离
- 并行
- 专门角色

代价：

- Context 更多
- 调用更多
- 权限更复杂
- 更难观察

---

# 十、Prompt Injection

Prompt Injection 不只是网页问题。

只要 Agent 读取：

- README
- 注释
- 文档
- Issue
- 构建输出
- 第三方文件

其中的文字就可能尝试误导 Agent，把“数据”伪装成“指令”。

核心原则：

> Agent 读取到的文字，不能自动等价于可信指令。

---

# 十一、Git 的正确定位

Git：

```text
观察
+
Review
+
恢复
```

不是：

```text
Sandbox
```

Git 不能阻止：

- 读取项目外文件
- 网络访问
- 执行外部程序
- 操作未跟踪文件
- 其他系统副作用

但它对 Coding Agent 仍然非常重要，因为它提供：

```bash
git status
git diff
git restore
git commit
```

---

# 十二、陌生 Agent 的分析方法

以后遇到新的 Coding Agent，不先问：

```text
它聪明吗？
```

而先检查：

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

如果不知道：

```text
待查
```

不要猜。

---

# 十三、API Key / OAuth / ChatGPT 订阅

必须分清：

```text
API Key
→ 程序调用 API / Provider 的秘密凭据

OAuth Token
→ OAuth 授权流程产生的访问凭据

ChatGPT Plus / Pro
→ ChatGPT 产品订阅权益
```

所以：

```text
ChatGPT Plus / Pro
≠
自动获得一个任意 Python 程序可用的 OPENAI_API_KEY
```

如果某个 Harness 明确支持 ChatGPT 订阅 OAuth，可以通过它自己的授权流程使用。

---

# 十四、Mini Agent 的安全重点

Mini Agent 主进程需要 API Key 调模型，但 `run_command` 子进程没必要看到这些密钥。

正确做法：

```python
SAFE_ENV = os.environ.copy()

SAFE_ENV.pop("DEEPSEEK_API_KEY", None)
SAFE_ENV.pop("OPENROUTER_API_KEY", None)
SAFE_ENV.pop("OPENAI_API_KEY", None)
```

然后：

```python
subprocess.run(
    command,
    env=SAFE_ENV,
    ...
)
```

这样：

```text
Mini Agent 主进程
→ 能调用模型

Tool 子进程
→ 看不到模型 API Key
```

避免：

```text
env / printenv
↓
API Key 出现在 Tool Result
↓
Tool Result 再进入模型 Context
```

这就是最小权限的真实应用。

---

# 十五、Day 14 中暴露出的薄弱点

毕业答辩中，以下概念需要以后偶尔复习：

1. Context 的组成不只包括用户消息和 Tool Result
2. Compaction 是 Context 压缩机制，不是 Memory
3. cwd 不是权限边界，也不是 Sandbox
4. Extension 不只是“可能带 Tool”，而是 Harness 层扩展
5. Sub-agent 不只是“子智能体”，还涉及分工、Context 隔离和权限复杂度
6. Prompt Injection 要理解成“不可信文本影响 Agent 行为”
7. API Key、OAuth Token、产品订阅属于不同层面

这些都已经在答辩中完成纠正。

---

# 十六、我现在的一句话 Agent 模型

> **LLM 负责判断下一步做什么；Harness 负责组织 Context、Tools、状态和权限；Tool 在真实环境中执行动作；Tool Result 再回到 Agent Loop。**

安全原则：

> **不要靠“相信 Agent”获得安全感，要靠最小权限、可观察、可验证和可回滚获得安全感。**

---

# 十七、Day 14 最终结论

Day 14 完成。

```text
Round 1：Pi             ✅
Round 2：Codex          ✅
Round 3：人工 Review    ✅
毕业答辩                ✅
Git 最终状态 clean      ✅
```

14 天基础训练正式毕业。
