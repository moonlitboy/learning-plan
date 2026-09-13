# AI Agent 14 天基础训练｜Day 05

## 主题：正式认识 Pi——从裸 Agent 开始

> 今日目标：第一次正式使用 Pi，但先保持“裸 Pi”状态，不安装第三方 Skills / Extensions / Packages。重点不是记命令，而是把前四天学过的 **Harness / Context / Tools / Agent Loop / Permission / Git Review** 真正套到 Pi 上。

---

## 一、今天学了什么

今天完成了 Pi 的安装、登录、只读实验、小修改实验，并用 Git 对结果进行了验证。

今天实际完成的流程：

```text
Node / npm 环境确认
↓
安装 Pi
↓
查看 pi --help
↓
理解 Pi = Agent Harness
↓
ChatGPT Plus / Codex OAuth 登录
↓
理解 Personal workspace 与 API Platform 的区别
↓
实验 1：只读仓库
↓
观察 read / bash / Tool Result / Agent Loop
↓
Git 验证没有修改
↓
实验 2：修改 hello.c
↓
read → edit → bash 编译
↓
git diff 人工 Review
↓
Day 05 自查
```

---

## 二、今天的环境

### Node / npm

```bash
node -v
# v24.15.0

npm -v
# 11.12.1
```

### Pi

安装命令：

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

检查：

```bash
which pi
pi --version
pi --help
```

实际版本：

```text
Pi 0.85.1
```

Pi 路径位于 fnm 当前 Node 版本对应的环境中。

---

## 三、Pi 到底是什么

今天最重要的定位：

```text
Pi ≠ LLM
Pi ≠ 模型 Provider

Pi = Agent Harness
```

Pi 负责组织：

```text
Context
Tools
Session / State
模型调用
权限与工具配置
Agent Loop
```

可以把今天的工作过程理解成：

```text
User Prompt
↓
Pi Harness
↓
Context + Instructions + Tools
↓
LLM
↓
Tool Call
↓
Pi 执行 Tool
↓
Tool Result
↓
重新进入 Context
↓
LLM 再判断
```

### 一句话理解

> LLM 负责判断下一步做什么；Pi Harness 负责组织 Context、Tools、状态和执行流程；Tool 在真实环境中完成动作。

---

## 四、Pi 默认核心 Tools

今天重点认识了四个核心 Tool：

```text
read   → 读取文件
edit   → 修改已有文件
write  → 创建 / 覆盖文件
bash   → 在真实系统中执行 shell 命令
```

需要特别记住：

> Tool 不是 LLM 自己直接操作 Mac 的能力，而是 Harness 提供给模型的可调用能力。

例如：

```text
模型提出：调用 bash 执行 clang
↓
Pi Harness 接收 Tool Call
↓
Pi 的 bash Tool 在 macOS 上真正启动进程
↓
命令结果返回给模型
```

所以不能说：

```text
“GPT 自己在我的 Mac 上执行了 clang”
```

更准确的说法是：

```text
LLM 请求调用 bash Tool，Pi 在真实环境中执行了 clang。
```

---

## 五、Prompt 和 Tool 权限不是一回事

今天通过“不要修改任何文件”的实验理解了一个重要区别：

```text
Prompt / Instructions
→ 规定 Agent 应该怎么做

Tools / Permission
→ 决定 Agent 实际能做什么
```

例如：

```text
“不要修改任何文件”
```

只是用户指令。

它不会自动把 `bash` Tool 从 Pi 中删除。

因此 Pi 仍然可以用 `bash` 做：

```text
pwd
find
git status
clang
```

只是它不应该使用这些能力去违反用户要求修改文件。

真正从能力层限制 Tool，是后面 Day 06 要学的内容，例如：

```bash
pi --tools ...
pi --exclude-tools ...
pi --no-tools
```

---

## 六、cwd 为什么重要

启动 Pi 前先确认：

```bash
cd ~/Documents/agent-lab
pwd
git status
```

`cwd` 可以理解为 Pi 当前工作的起点。

它会影响：

```text
相对路径从哪里解析
项目文件从哪里寻找
项目指令从哪里发现
默认操作哪个项目
```

但是：

```text
cwd ≠ Sandbox
```

当前工作目录并不代表 Agent 在系统层面只能访问这个目录。

---

## 七、ChatGPT Plus / Workspace / API Platform

### 1. 今天使用的是 ChatGPT Plus / Codex OAuth

Pi 登录时使用：

```text
/login
```

浏览器中选择了：

```text
Personal account
```

这里的 Personal account 是 ChatGPT 的个人 workspace。

### 2. Workspace 不是“最高权限模式”

```text
Personal account
= 个人 ChatGPT 工作区
```

它不是 OpenAI 的“超级管理员模式”。

### 3. ChatGPT Plus 与 OpenAI API Platform 不是一回事

```text
ChatGPT Plus
→ ChatGPT 产品中的订阅
→ 可以在明确支持订阅 OAuth 的工具中登录

OpenAI API Platform
→ API Key
→ API Project / Billing / Usage
→ 给自己写的程序调用模型
```

必须记住：

```text
ChatGPT Plus ≠ 通用 OPENAI_API_KEY
```

Day 05 的 Pi：

```text
Pi
→ ChatGPT / Codex OAuth
→ 使用 Plus 订阅身份
```

以后 Day 13 自己写 Mini Agent：

```text
默认使用 DeepSeek API / OpenRouter API
```

不要把这两种接入方式混在一起。

---

## 八、实验 1：只读仓库

### 实验前

先建立干净 baseline：

```bash
git status
```

结果：

```text
On branch main
nothing to commit, working tree clean
```

### 给 Pi 的 Prompt

```text
阅读这个仓库，告诉我有哪些文件以及如何运行 C 示例。不要修改任何文件。
```

### Pi 实际执行过程

#### 1. 先观察项目

Pi 使用 `bash`：

```text
pwd
find ...
```

目的：先了解当前目录和仓库结构。

#### 2. 读取文件

Pi 使用 `read`：

```text
README.md
c/hello.c
.gitignore
AGENTS.md
```

这说明：

```text
文件存在 Disk
≠
模型已经知道文件内容
```

只有文件内容被 Harness 加载 / 读取并进入 Context 后，模型才能利用这些信息。

#### 3. 读取 AGENTS.md

`AGENTS.md` 中存在项目规则。

这再次验证：

```text
AGENTS.md 在磁盘上
↓
被 Harness 发现 / 读取
↓
内容进入模型可以利用的 Context
↓
模型按照项目规则工作
```

### 实验中遇到的真实错误

Pi 执行：

```text
find ... -printf ...
```

macOS 默认 BSD `find` 不支持 GNU `find` 的 `-printf`，因此出现：

```text
find: -printf: unknown primary or operator
```

但是 Agent 没有停止。

真实过程：

```text
Tool Call
↓
命令报错
↓
错误成为 Tool Result
↓
Tool Result 返回模型
↓
LLM 重新判断
↓
换一种命令继续
```

这就是 Agent Loop：

```text
尝试
→ Observe Result
→ 调整
→ 再尝试
```

不是“一开始就知道所有正确命令”。

### 编译验证

Pi 后面执行了：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o <临时文件>
```

并运行了临时二进制。

得到：

```text
Hello, Agent!
Have a great day!
```

Pi 使用 `/tmp` 临时路径进行验证，避免在仓库中额外产生编译产物。

### 实验后验证

退出 Pi 后：

```bash
git status
```

结果仍为：

```text
nothing to commit, working tree clean
```

结论：

> Pi 在真实环境中读取了文件、执行了 shell 和 clang，但没有修改 Git 跟踪文件。

---

## 九、实验 1 的 Agent Loop

完整拆解：

```text
User Prompt
↓
Pi Harness
↓
LLM
↓
bash：pwd / find
↓
Tool Result
↓
LLM
↓
read：README.md / hello.c / AGENTS.md ...
↓
Tool Result
↓
LLM
↓
bash：clang + 临时运行
↓
Tool Result
↓
LLM
↓
最终回答
```

今天第一次真正把：

```text
LLM → Tool Call → Tool Result → LLM
```

从理论变成了真实观察。

---

## 十、实验 2：修改 hello.c

### Prompt

```text
给 c/hello.c 增加一行简单输出，修改后编译并报告结果。
```

### Pi 实际执行流程

```text
read c/hello.c
↓
edit c/hello.c
↓
bash：clang 编译
↓
Tool Result
↓
最终报告
```

### 修改内容

Pi 新增：

```c
printf("This is a new line.\n");
```

### 编译命令

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /tmp/hello
```

编译结果：

```text
(no output)
```

这里需要准确理解：

```text
(no output)
```

不代表“命令没有执行”。

对于 clang：

```text
命令成功结束
+
没有 warning
+
没有 error
↓
通常不会打印任何内容
```

因此可以判断这次编译成功。

但是也要记住：

> `(no output)` 本身不是所有命令的“成功标志”，还需要结合命令的执行状态和语义判断。

另外，这次 Prompt 只要求“编译并报告结果”，所以 Pi 没有继续执行 `/tmp/hello` 也是合理的。

如果要求：

```text
修改后编译、运行并报告程序输出
```

那么 Agent 还应该继续执行生成的程序。

---

## 十一、Git diff Review

实验后执行：

```bash
git status
git diff
```

实际 diff 只增加了一行：

```diff
+    printf("This is a new line.\n");
```

没有：

```text
无关修改
整个文件重写
意外删除
额外格式化
```

所以这次 diff 非常干净。

### Git diff 的作用

```text
git diff
→ 检查 Agent 具体改了什么
→ 人工 Review
→ 判断修改是否符合任务
```

但是：

```text
Git ≠ Sandbox
```

Git 不负责阻止 Agent 修改文件。

它主要是：

```text
观察
+
验证
+
恢复
```

---

## 十二、今天遇到的问题

### 1. Day 03 留下的 hello.c 修改

一开始：

```bash
git status
```

显示：

```text
modified: c/hello.c
```

确认这是 Day 03 已知改动后，没有直接执行 `git restore`，而是先检查并做 checkpoint。

最终：

```text
nothing to commit, working tree clean
```

这样 Day 05 实验前就建立了干净 baseline。

### 2. macOS `find -printf` 不支持

Pi 一开始使用 GNU 风格：

```text
find -printf
```

macOS BSD `find` 报错。

重点不是“Agent 犯错了”，而是观察到了：

```text
Tool Error
↓
Tool Result
↓
LLM 调整策略
↓
继续 Agent Loop
```

---

## 十三、今天我现在的理解

### 1. Pi 是 Harness

我的理解：

> Pi 本身不是 LLM，它负责组织 Context、Tools、权限、Session、模型调用和 Agent Loop。

### 2. Tool 是 Agent 的“手”

```text
read  → 读
edit  → 改
write → 创建 / 覆盖
bash  → 真实执行命令
```

### 3. LLM 不直接执行 shell

```text
LLM
→ 提出 bash Tool Call
→ Pi 执行
→ Tool Result 返回 LLM
```

### 4. Disk 不等于 Context

```text
文件存在硬盘
≠
模型已经知道文件内容
```

文件必须被加载 / 读取后，模型才能利用其内容。

### 5. Prompt 不等于权限隔离

```text
“不要修改文件”
```

是一条指令，而不是从 Harness 中删除 `edit / write / bash`。

### 6. Git 不是 Sandbox

Git 能帮助我：

```text
看改动
验证改动
恢复改动
```

但是不能作为系统级安全边界。

---

## 十四、Day 05 自查答案

### 1. 为什么说 Pi 是 Harness，而不是 LLM？

因为 Pi 主要负责组织：

```text
Context
Tools
权限与配置
Session
模型调用
Agent Loop
```

真正负责推理和决定下一步动作的是底层 LLM。

---

### 2. Pi 默认最核心的四个 Tool 是什么？

```text
read  → 读取文件
edit  → 修改文件
write → 创建 / 覆盖文件
bash  → 执行真实 shell 命令
```

---

### 3. 为什么 cwd 很重要？

因为它决定 Pi 当前工作的项目起点，会影响：

```text
相对路径
项目文件发现
项目指令发现
默认操作范围
```

但是 cwd 本身不是 Sandbox。

---

### 4. Pi 的 bash 是模拟终端吗？

不是。

它会在当前真实运行环境中启动实际进程执行命令。

---

### 5. 为什么 Day 05 不安装第三方 Skill / Extension？

因为今天的目标是先理解原生 Pi。

```text
先理解默认行为
↓
减少变量
↓
后面再增加 Skill / Extension
```

这样之后行为发生变化时，才能判断变化到底来自：

```text
模型
Pi 本身
Skill
Extension
Prompt
Tool
```

同时也能减少早期学习阶段不必要的权限和第三方代码风险。

---

## 十五、课堂小题复盘

### Q1：clang 真正是谁执行的？

答：Pi 提供的 `bash` Tool。

更完整：

```text
LLM 提出 Tool Call
→ Pi Harness 执行 bash Tool
→ bash 启动 clang
```

### Q2：Tool 报错以后为什么 Agent 还能继续？

因为 Tool Result 会返回给 LLM，LLM 根据结果进入下一轮判断。

### Q3：为什么 AGENTS.md 在硬盘上还不够？

因为不加载、不进入 Context，模型就看不到里面的内容。

### Q4：为什么 Prompt 说不要修改文件，Pi 仍然能使用 bash？

因为 Prompt 没有从 Harness 层禁用 bash。

### Q5：谁真正修改了 hello.c？

`edit` Tool 真正执行了文件修改。

### Q6：为什么 edit 后还执行 clang？

因为 User Prompt 要求“修改后编译”，同时项目规则也要求修改 C 文件后进行编译检查。

### Q7：git diff 是安全边界吗？

不是。

它是检查 Agent 具体修改了什么的重要 Review 工具。

---

## 十六、Day 05 完成标准

今天已经完成：

```text
[✓] 安装 Pi
[✓] pi --help / pi --version
[✓] ChatGPT Plus / Codex OAuth 登录
[✓] 理解 Personal workspace
[✓] 区分 Plus 与 OpenAI API Platform
[✓] 认识 read / edit / write / bash
[✓] 完成只读实验
[✓] 观察 Tool Error → Tool Result → 下一轮判断
[✓] git status 验证只读实验无修改
[✓] 完成小修改实验
[✓] edit 修改 hello.c
[✓] bash 调用 clang 编译
[✓] git diff 人工 Review
[✓] 完成 Day 05 自查
```

今天最重要的完整链路：

```text
读取
↓
修改
↓
编译
↓
查看 diff
```

以及：

```text
LLM 决定
↓
Tool Call
↓
Pi Harness 执行
↓
真实环境发生动作
↓
Tool Result
↓
LLM 再判断
```

---

## 十七、仍然不明白 / 下一天继续

Day 05 暂时不深入：

```text
Tool allowlist
--tools
--exclude-tools
--no-tools
只读 Agent 的能力限制
最小权限
```

这些进入 Day 06：

# Day 06｜主动限制 Pi：自由不是越大越好

核心问题将从：

```text
“Pi 能做什么？”
```

进一步变成：

```text
“我怎样主动限制 Pi 只能做任务真正需要的事情？”
```

---

## 今日一句话总结

> **Pi 是负责组织模型、Context、Tools、状态和执行流程的 Agent Harness；LLM 决定下一步动作，Tool 在真实环境中执行，而我通过最小权限、Tool 记录、Git 和编译检查来观察和验证结果。**
