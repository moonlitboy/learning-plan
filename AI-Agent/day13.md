# AI Agent 14 天基础训练｜Day 13

## 今日主题

**亲手实现 Mini Agent：第一次真正造出 Agent Loop**

今天的重点不是继续使用现成 Agent，而是自己实现一个最小 Harness，亲手跑通：

```text
User
  ↓
Harness
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

---

## 一、今日完成情况

Day 13 已完成。

今天实际完成了：

- Pi 三组对照实验
- DeepSeek API 连通性测试
- Python + uv 项目初始化
- Tool Definition
- `read_file`
- `edit_file`
- 受限版 `run_command`
- Tool Dispatcher
- Tool Result 回灌
- 多步 Agent Loop
- `MAX_STEPS`
- workspace 文件边界
- API Key 子进程隔离
- CLI 连续聊天
- 当前会话上下文
- `/clear`、`/quit`、`/help`
- Day 13 自检与验收

---

# 二、项目环境

项目目录：

```text
~/Documents/mini-agent
```

Python：

```text
CPython 3.12.13
```

包管理：

```text
uv
```

依赖：

```text
openai==3.14.0
```

安装：

```bash
uv add openai
```

检查：

```bash
uv run python --version
uv pip show openai
```

项目中的 `.gitignore`：

```gitignore
# Python-generated files
__pycache__/
*.py[oc]
build/
dist/
wheels/
*.egg-info

# Virtual environments
.venv/

# Environment variables / secrets
.env

# macOS
.DS_Store
```

---

# 三、API Key 使用方式

今天使用：

```text
DeepSeek API
```

API Key 不写进：

```text
main.py
README
Git
Prompt
```

推荐临时注入当前 Shell：

```bash
read -s "DEEPSEEK_API_KEY?DeepSeek API Key: "
export DEEPSEEK_API_KEY
echo
```

也可以直接：

```bash
export DEEPSEEK_API_KEY="你的 Key"
```

但直接写在命令行里可能进入 shell history，因此学习阶段优先使用 `read -s`。

关闭当前终端后，这种临时环境变量就会消失。

---

# 四、第一步：普通 LLM API Client

最开始只验证：

```text
Python
 ↓
读取 DEEPSEEK_API_KEY
 ↓
OpenAI-compatible Client
 ↓
DeepSeek API
 ↓
模型回复
```

成功输出：

```text
API connection successful
```

这一阶段还不是 Agent，因为没有：

```text
Tool Definition
Tool Call
Tool Result
Agent Loop
MAX_STEPS
```

---

# 五、Pi 对照实验

## 1. 没有 Tool

命令：

```bash
pi -p --no-tools \
  "告诉我 c/hello.c 的具体内容。"
```

结果：

```text
模型无法直接读取 c/hello.c
```

结论：

```text
文件存在于 Disk
≠
文件已经进入 Context
≠
LLM 知道文件内容
```

---

## 2. 只提供 read

命令：

```bash
pi -p --tools read \
  "读取 c/hello.c，并概括 main 函数做了什么。"
```

Pi 能读取真实文件，然后回答。

---

## 3. JSON 事件流

命令：

```bash
pi --mode json --tools read \
  "读取 c/hello.c，并概括 main 函数做了什么。"
```

真实观察到：

```text
LLM
 ↓
Tool Call: read
 ↓
Tool Execution
 ↓
Tool Result
 ↓
再次进入 Context
 ↓
LLM
 ↓
Final Answer
```

重要结论：

```text
一次 Agent 任务
≠
一次 LLM 调用
```

一次任务可能需要多次模型调用。

---

# 六、Tool Definition 与 Tool Implementation

必须区分：

```text
Tool Definition
→ 给 LLM 看的工具说明书

Tool Implementation
→ 真正执行操作的 Python 函数

Tool Call
→ LLM 产生的结构化调用请求
```

例如：

```text
read_file
```

Tool Definition 告诉模型：

```text
工具名称
用途
参数 Schema
```

真正执行读取的是：

```python
def read_file(...):
    ...
```

LLM 自己不会直接读取磁盘。

---

# 七、read_file

`read_file` 被限制在：

```text
mini-agent/workspace/
```

核心安全思想：

```text
模型提供 path
 ↓
Harness resolve 路径
 ↓
检查是否仍位于 WORKSPACE
 ↓
允许 / 拒绝
```

因此：

```text
workspace 内
→ 可以读取

workspace 外
→ 拒绝
```

这属于：

```text
Harness 级限制
```

不是 OS Sandbox。

---

# 八、edit_file

实现了受限的文本修改：

```text
path
old_text
new_text
```

规则：

```text
文件必须存在
必须位于 workspace
old_text 必须存在
old_text 必须恰好出现一次
```

如果：

```text
old_text 不存在
→ 拒绝

old_text 出现多次
→ 拒绝，避免模糊修改
```

实际实验：

```text
Hello from Mini Agent workspace.
```

被 Agent 修改成：

```text
Hello from my own Mini Agent.
```

后来又修改成：

```text
Hello from CLI Agent.
```

Agent 实际执行流程：

```text
read_file
 ↓
edit_file
 ↓
read_file
 ↓
Final Answer
```

---

# 九、Tool Dispatcher

LLM 产生 Tool Call 后，Harness 根据工具名决定调用哪个真实函数。

结构：

```python
if tool_name == "read_file":
    ...

elif tool_name == "edit_file":
    ...

elif tool_name == "run_command":
    ...

else:
    ...
```

职责：

```text
LLM
→ 决定想用哪个 Tool

Harness
→ 检查 Tool Name
→ 解析 arguments
→ 调用真实 Python 函数

OS
→ 最终执行真实文件或进程操作
```

---

# 十、Tool Result 为什么要回到 messages

Tool 执行完成后：

```text
Tool Result
```

必须 append 回：

```text
messages
```

否则下一轮 LLM 不知道工具到底执行出了什么结果。

完整过程：

```text
LLM
 ↓
Tool Call
 ↓
Harness 执行
 ↓
Tool Result
 ↓
messages
 ↓
LLM 再次推理
```

---

# 十一、Agent Loop

最开始代码是：

```text
LLM #1
 ↓
Tool
 ↓
LLM #2
 ↓
结束
```

后来改成真正循环：

```text
while / for step
 ↓
调用 LLM
 ↓
有 Tool Call？
 ├─ 有 → 执行 Tool → Result 回到 messages → 下一轮
 └─ 无 → Final Answer → 结束
```

因此 Agent 可以：

```text
读取
→ 修改
→ 验证
→ 再判断
→ 最终回答
```

---

# 十二、MAX_STEPS

设置：

```python
MAX_STEPS = 5
```

作用：

防止出现：

```text
LLM
→ Tool
→ LLM
→ Tool
→ LLM
→ Tool
→ ...
```

无限循环。

`MAX_STEPS` 是 Harness 的停止条件之一。

---

# 十三、run_command

今天没有开放任意 Shell，而是实现了受限版：

```text
pwd
ls
check_deepseek_key
```

并使用：

```text
cwd = WORKSPACE
```

所以命令默认在：

```text
mini-agent/workspace/
```

中执行。

同时没有使用全开放的任意 shell 执行方式。

---

# 十四、真实 Tool Error → Agent 自己纠错

实验中模型第一次请求：

```text
ls -la workspace
```

被 Harness 拒绝：

```text
Error: ls may only inspect the workspace directory
```

下一轮 LLM 看到了 Tool Result 后，自动改成：

```text
ls -la
```

成功执行。

这证明：

```text
Tool Error
 ↓
Tool Result
 ↓
重新进入 Context
 ↓
LLM 再判断
 ↓
新的 Tool Call
```

Agent 可以根据工具错误继续调整。

---

# 十五、API Key 隔离

主 Agent Python 进程需要：

```text
DEEPSEEK_API_KEY
```

才能调用模型。

但 `run_command` 子进程不需要。

所以创建：

```python
SAFE_ENV = os.environ.copy()

SAFE_ENV.pop("DEEPSEEK_API_KEY", None)
SAFE_ENV.pop("OPENROUTER_API_KEY", None)
SAFE_ENV.pop("OPENAI_API_KEY", None)
```

然后：

```python
subprocess.run(
    ...,
    env=SAFE_ENV,
)
```

验证实验：

```text
check_deepseek_key
```

结果：

```text
not set
```

证明：

```text
Mini Agent 主进程
→ 有 DEEPSEEK_API_KEY

run_command 子进程
→ 没有 DEEPSEEK_API_KEY
```

核心原则：

```text
模型凭据
≠
所有 Tool 必须拥有的凭据
```

这就是最小权限原则在自己的 Harness 中的真实应用。

---

# 十六、Harness 级限制 ≠ OS Sandbox

当前 Mini Agent 的安全控制包括：

```text
Tool allowlist
路径检查
cwd=WORKSPACE
参数校验
SAFE_ENV
MAX_STEPS
```

这些限制全部写在：

```text
main.py
```

因此属于：

```text
Harness 级限制
```

不是：

```text
OS Sandbox
Container
VM
Filesystem Isolation
```

准确描述：

> Agent 当前被 Harness 设计成只能通过提供的 Tool 在 workspace 范围内活动，但整个 Python 进程并没有被 OS 强制关进一个 Sandbox。

---

# 十七、CLI Agent

原来：

```text
修改 main.py 中固定 Prompt
 ↓
运行
 ↓
完成一次任务
 ↓
退出
```

后来改造成：

```text
uv run python main.py
 ↓
You >
 ↓
用户输入自然语言
 ↓
run_agent()
 ↓
Agent Loop
 ↓
Mini Agent >
 ↓
再次等待输入
```

CLI 命令：

```text
/help
/clear
/quit
```

---

# 十八、当前会话上下文

同一次 CLI 运行期间：

```text
messages
```

一直保存在 Python 内存中。

例如：

```text
You > 读取 hello.txt

Agent > ...

You > 把刚才那个文件里的内容改一下
```

第二句话中的：

```text
刚才那个文件
```

能够被正确理解为：

```text
workspace/hello.txt
```

因为前面的对话历史仍然在：

```text
messages
```

中。

实际实验成功：

```text
“把刚才那个文件里的 my own Mini Agent 改成 CLI Agent”
```

Agent 正确执行：

```text
edit_file(workspace/hello.txt)
 ↓
read_file(workspace/hello.txt)
 ↓
Final Answer
```

---

# 十九、/clear 与 /quit

## /clear

代码：

```python
del messages[1:]
```

作用：

```text
保留 system message
删除 user / assistant / tool history
当前进程继续运行
```

所以：

```text
/clear
≈ 当前程序中新开一段聊天
```

---

## /quit

作用：

```text
结束 Python 进程
内存中的 messages 消失
```

重新启动后：

```text
重新创建 system message
之前 Conversation History 不存在
```

目前还没有：

```text
Session 持久化
/resume
```

---

# 二十、Session 与当前上下文

当前：

```text
运行中的 messages
→ 当前会话 Context / History 来源

退出 Python
→ 内存状态消失

重新启动
→ 新会话
```

因此：

```text
当前 Agent 有会话上下文
但没有跨进程 Session 持久化
```

以后如果实现：

```text
messages
 ↓
JSON / JSONL
 ↓
磁盘 Session 文件
 ↓
下次加载
```

就可以进一步实现：

```text
/session
/resume
```

---

# 二十一、当前 Mini Agent 能做什么

目前可以：

```text
自然语言聊天
当前会话上下文
多步 Agent Loop

read_file
→ 读取 workspace 内文本文件

edit_file
→ 修改 workspace 内已有文本文件

run_command
→ pwd
→ ls
→ check_deepseek_key

Tool Error 后重新判断
Tool Result 回灌
MAX_STEPS
中文回答
```

---

# 二十二、当前 Mini Agent 不能做什么

目前还不能：

```text
读取 workspace 外文件
任意执行 Shell
运行 clang
运行 git
运行 curl
任意联网
创建新文件
删除文件
OS Sandbox
Approval
长期 Memory
Session 持久化
/resume
复杂权限模型
```

这些不是缺陷，而是当前阶段故意保持：

```text
最小能力
+
最小权限
+
容易理解
+
容易观察
```

---

# 二十三、当前架构图

```text
                     User
                      │
                      ▼
                 CLI input()
                      │
                      ▼
                 run_agent()
                      │
                      ▼
                  messages
                      │
                      ▼
               DeepSeek LLM
                      │
            ┌─────────┴─────────┐
            │                   │
       Final Answer         Tool Call
                                │
                                ▼
                         Tool Dispatcher
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
            ▼                   ▼                   ▼
        read_file           edit_file          run_command
            │                   │                   │
            └───────────────────┴───────────────────┘
                                │
                                ▼
                           Tool Result
                                │
                                ▼
                            messages
                                │
                                └──────→ DeepSeek 再判断
```

---

# 二十四、今日自检结果

## 第一轮

### 1. Harness 包含什么？

不能只说：

```text
def
while
```

更完整：

```text
messages 管理
Agent Loop
Tool Definition
Tool Dispatcher
MAX_STEPS
workspace 限制
command allowlist
SAFE_ENV
CLI
```

### 2. LLM 负责什么？

```text
理解任务
决定是否调用 Tool
生成 Tool Call
根据 Tool Result 再判断
生成最终回答
```

LLM 不亲自读取或修改磁盘。

### 3. Tool 真正由谁执行？

```text
Harness / Tool Executor
→ 调用 Python 函数
→ Python 调用文件系统 / subprocess
→ OS 最终执行
```

### 4. 为什么 Tool Result 要回 messages？

因为：

```text
LLM 必须看到真实执行结果
才能决定下一步
```

---

## 第二轮

### Agent Loop

让 Agent 有持续解决问题的能力。

### 没有 Loop

不能形成真正的多步 Agent。

### MAX_STEPS

防止无限循环。

### Provider 与 Harness

```text
DeepSeek
→ Model Provider / LLM

main.py
→ Harness
```

### 子进程为什么不继承 API Key？

防止凭据通过 Tool Result 泄露到 Context。

---

## 第三轮

### Tool Definition vs read_file()

```text
Definition
→ 工具说明

read_file()
→ 工具真实实现
```

### Tool Call

只是：

```text
结构化调用请求
```

不是已经执行。

### 当前会话上下文

来自：

```text
messages
```

### /clear

清空 Conversation History，保留 system。

### Harness 限制

限制写在 Harness 程序里，因此不是 OS Sandbox。

---

# 二十五、今日核心结论

今天最重要的不是写出了多少 Python，而是亲手证明：

```text
Coding Agent 没有魔法
```

它可以被拆成：

```text
LLM
+
Harness
+
Context
+
Tools
+
Tool Dispatcher
+
Tool Result
+
Agent Loop
+
Stopping Condition
+
Permission Boundaries
```

模型只是负责：

```text
理解
判断
提出动作
```

真正的现实操作来自：

```text
Harness 提供的 Tool
```

最终权限还受到：

```text
Harness 限制
+
运行环境
+
OS 权限
```

---

# 二十六、Day 13 完成标准

今天已经能够亲手实现：

```text
用户提出问题
↓
模型决定调用 Tool
↓
Harness 执行 Tool
↓
Tool Result 返回模型
↓
模型继续判断
↓
最终回答
```

并进一步实现：

```text
多步 Agent Loop
文件读取
文件修改
受限命令执行
当前会话上下文
CLI 连续聊天
API Key 隔离
Harness 级最小权限
```

**Day 13：完成。**

下一步：

```text
Day 14
→ 综合验收
→ Pi / Codex 对照
→ Review
→ 建立长期 Agent 使用规范
```
