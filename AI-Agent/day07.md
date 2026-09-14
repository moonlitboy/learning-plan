# AI Agent 学习笔记｜Day 07：Skills——给 Agent 工作方法，而不是新手臂

> 日期：2026-09-14  
> 项目：`/Users/moonlit_boy/Documents/agent-lab`  
> 平台：Pi Agent  
> 今日状态：✅ 完成

---

## 一、今日目标

今天重点理解 **Skill 是什么，以及 Skill 和 Tool 的区别**。

核心结论：

```text
Tool：
Agent 能做什么

Skill：
Agent 应该怎样完成某类任务
```

Skill 更像是：

```text
工作说明
+
流程
+
参考知识
+
可选脚本 / 资源
```

它不会凭空给 Agent 增加新的执行能力。

---

## 二、最重要的核心概念

### 1. Skill ≠ Tool

今天反复确认：

```text
Tool 决定“能不能做”
Skill 决定“应该怎么做”
```

例如：

```text
Skill：
“修改 C 文件后必须使用 clang 编译”
```

如果 Pi 根本没有 `bash` Tool，那么即使 Skill 里明确要求编译，它也无法真正执行 `clang`。

所以：

```text
Skill 不会创造新的执行能力
```

---

### 2. Skill 不会改变原本的能力边界

实验中 Pi 使用的 Tool 一直是：

```text
read
edit
bash
```

加载 Skill 前后，Tool 没有增加。

变化的是 Agent 的行为流程：

```text
没有 Skill：
read → edit → clang → answer

有 Skill：
read → edit → clang → git diff → answer
```

因此可以总结：

```text
Capability 基本没变
Behavior / Workflow 发生了变化
```

---

### 3. Skill 不能绕过 OS 权限

Skill 只是当前权限范围内的一套工作规范。

真正能不能执行某个动作，还取决于：

```text
Harness 提供了什么 Tool
+
Tool 配置是否允许
+
操作系统最终权限
```

所以：

```text
Skill
≠
权限提升
≠
Sandbox 绕过
≠
OS 权限绕过
```

---

### 4. 第三方 Skill 仍然可能危险

虽然 Skill 通常只是 Markdown / 指令，但它仍然可能包含恶意或不合理的规则，例如：

```text
删除所有 .c 文件
跳过 git diff
运行来源不明的脚本
执行危险 shell 命令
```

如果 Agent 同时拥有：

```text
bash
edit
write
```

这些危险指令就可能真正被执行。

所以：

```text
第三方 Skill
→ 先审内容
→ 再决定是否加载
```

不能因为“只是 Markdown”就默认可信。

---

## 三、创建项目级 Skill

今天没有使用全局 Skill，而是创建了 **项目级 Skill**。

当前项目根目录：

```text
/Users/moonlit_boy/Documents/agent-lab
```

创建目录：

```bash
cd /Users/moonlit_boy/Documents/agent-lab
mkdir -p .pi/skills/c-language-check
```

因此实际路径是：

```text
/Users/moonlit_boy/Documents/agent-lab/.pi/skills/c-language-check
```

这属于：

```text
agent-lab 项目级 Skill
```

不是全局 Skill。

---

## 四、关于相对路径 `./`

今天顺便确认：

```bash
touch .pi/skills/c-language-check/SKILL.md
```

与：

```bash
touch ./.pi/skills/c-language-check/SKILL.md
```

在当前目录下是等价的。

因为：

```text
.      = 当前目录
./.pi  = 当前目录下的 .pi
.pi    = 同样是当前目录下的 .pi
```

所以普通相对路径前面的 `./` 通常可以省略。

---

## 五、创建 `SKILL.md`

创建文件：

```bash
touch .pi/skills/c-language-check/SKILL.md
```

最终使用的 Skill：

```md
---
name: c-language-check
description: Check C source changes by compiling with clang and reviewing the resulting diff.
---

# C Language Check

处理 C 语言文件时，遵循以下流程：

1. 修改 `.c` 文件后必须编译。
2. 使用 `clang -std=c17 -Wall -Wextra -Wpedantic`。
3. 如果编译失败，先分析错误原因。
4. 不要为了消除 warning 随意改变程序语义。
5. 完成修改后检查 Git diff。
6. 最终回答中说明实际执行过的编译命令。
```

---

## 六、第一次遇到的 Skill 格式错误

第一次写 `SKILL.md` 时，只写了正文，没有写元数据。

Pi 启动后提示：

```text
[Skill conflicts]
~/Documents/agent-lab/.pi/skills/c-language-check/SKILL.md
  description is required
```

这说明：

```text
磁盘上存在 SKILL.md
≠
Pi 一定成功加载这个 Skill
```

Pi 会先解析 Skill，并校验所需元数据。

因此补上：

```yaml
---
name: c-language-check
description: Check C source changes by compiling with clang and reviewing the resulting diff.
---
```

之后 Pi 才成功识别该 Skill。

---

## 七、实验 1：无 Skill 基线实验

启动：

```bash
pi --no-skills --tools read,edit,bash
```

含义：

```text
--no-skills
→ 禁用自动发现的 Skills

--tools read,edit,bash
→ 只给当前 Pi 读取、编辑、执行命令的能力
```

给 Pi 的 Prompt：

```text
给 c/hello.c 做一个很小的代码修改，不改变原有程序主要行为。
完成后告诉我你做了什么。
```

故意没有在 Prompt 里告诉它：

```text
必须编译
必须使用哪些 clang 参数
必须 git diff
必须使用 Skill
```

### 实际过程

Pi 执行：

```text
read
→ edit
→ bash
```

其中使用：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /tmp/hello
```

编译通过，无警告。

但是：

```text
没有主动执行 git diff
```

---

## 八、为什么无 Skill 时仍然会主动编译

项目中已经存在：

```text
AGENTS.md
```

并且其中已有类似：

```text
修改 C 文件后必须先编译
```

的项目规则。

因此即使：

```bash
--no-skills
```

Pi 仍然可能因为：

```text
AGENTS.md
+
现有 Context
+
模型判断
```

主动执行编译。

所以：

```text
--no-skills
≠
没有任何项目指令
```

Skill 和 `AGENTS.md` 是不同的指令来源。

---

## 九、实验 2：显式加载自己的 Skill

先恢复实验文件：

```bash
git restore c/hello.c
```

然后启动：

```bash
pi --no-skills \
  --skill ./.pi/skills/c-language-check/SKILL.md \
  --tools read,edit,bash
```

这里：

```text
--no-skills
→ 禁止自动发现其他 Skills

--skill ...
→ 明确只加载指定 Skill
```

启动成功后看到：

```text
[Context]
  AGENTS.md

[Skills]
  c-language-check
```

执行任务时还出现：

```text
[skill] c-language-check
```

说明 Skill 确实被成功使用。

---

## 十、有 Skill 时的真实执行过程

使用和第一轮完全相同的 Prompt：

```text
给 c/hello.c 做一个很小的代码修改，不改变原有程序主要行为。
完成后告诉我你做了什么。
```

Pi 执行：

```text
read
→ edit
→ bash
```

然后实际运行：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /tmp/hello_check
git diff -- c/hello.c
```

最终：

```text
编译通过
+
主动检查 Git diff
```

这正好对应 Skill 中：

```text
完成修改后检查 Git diff
```

这一条规则。

---

## 十一、无 Skill / 有 Skill 对照

### 无 Skill

```text
read
→ edit
→ clang
→ answer
```

### 有 Skill

```text
read
→ edit
→ clang
→ git diff
→ answer
```

最关键的结论：

```text
git diff 不是 Skill 新增的能力
```

因为 Pi 原本就有：

```text
bash
```

而 `bash` 本来就可以执行：

```bash
git diff
```

Skill 只是明确要求：

```text
修改完成后必须检查 diff
```

所以更准确地说：

```text
Skill 规范了工作流
而不是给 Agent 新增了“git diff 能力”
```

---

## 十二、手动调用 Skill

在 Pi 中输入：

```text
/skill:c-language-check
```

Pi 显示：

```text
[skill] c-language-check
```

并回应会按照该流程处理 C 文件。

这说明除了 Agent 自动选择 Skill 外，也可以：

```text
用户显式调用 Skill
```

---

## 十三、`/reload` 实验

保持 Pi 不退出。

在磁盘上的 `SKILL.md` 新增：

```md
6. 最终回答中说明实际执行过的编译命令。
```

保存后回到 Pi：

```text
/reload
```

`/reload` 本身没有明显输出。

然后重新执行：

```text
/skill:c-language-check
```

Pi 回应：

```text
之后处理 C 文件时，我会在最终回答中明确说明实际执行过的编译命令。
```

说明新加入的规则已经被当前 Pi 会话读取。

因此：

```text
修改磁盘上的 SKILL.md
        ↓
/reload
        ↓
Pi 重新加载资源
        ↓
再次调用 Skill
        ↓
使用更新后的规则
```

要记住：

```text
保存 SKILL.md
≠
当前运行中的 Pi 一定立刻使用新版
```

需要时可以：

```text
/reload
```

明确重新加载资源。

---

## 十四、Project Trust 顺便复习

启动 Pi 时遇到了 Project Trust 提示。

今天选择思路：

```text
Trust (this session only)
```

只在当前会话信任：

```text
/Users/moonlit_boy/Documents/agent-lab
```

没有扩大到整个：

```text
/Users/moonlit_boy/Documents
```

继续牢记：

```text
Project Trust
≠
Tool Permission
≠
Sandbox
≠
OS Permission
```

Project Trust 不会凭空给 Pi 增加：

```text
write
bash
edit
```

这些 Tool。

---

## 十五、今天的自查题

### 1. Skill 是 Tool 吗？

不是。

Skill 主要用于：

```text
规范工作流程
```

Tool 才代表：

```text
Agent 能执行什么能力
```

---

### 2. Skill 能直接绕过 OS 权限吗？

不能。

Skill 只是在当前权限边界内工作的规则。

真正的执行能力仍取决于：

```text
Tool
Harness
OS Permission
```

---

### 3. 为什么 Skill 能明显改变 Agent 行为？

因为它明确规定了：

```text
一步一步应该做什么
```

所以可以让 Agent 的流程：

```text
更一致
更规范
更可预测
```

---

### 4. 第三方 Skill 有什么风险？

它可能包含不怀好意或危险的规则，例如：

```text
rm
删除文件
跳过检查
运行陌生脚本
```

一旦 Agent 同时拥有对应 Tool，这些规则就可能被执行。

---

### 5. 什么时候应该写 Skill，而不是新 Tool？

当需求是：

```text
规范工作流程
```

而不是：

```text
加入一种新的执行能力
```

时，更适合写 Skill。

---

## 十六、今天最终掌握的心智模型

```text
Tool
= Agent 能做什么

Skill
= Agent 应该怎样做
```

进一步：

```text
Skill 不创造 Tool
Skill 不提升 OS 权限
Skill 不自动绕过 Sandbox
Skill 会影响模型决策与工作流程
第三方 Skill 仍然必须审查
```

今天最有价值的真实实验：

```text
同样的 Tools：read + edit + bash

没有 Skill：
修改 → 编译 → 回答

有 Skill：
修改 → 编译 → git diff → 回答
```

说明：

```text
能力边界基本没变
工作流程明显改变
```

---

## 十七、Day 07 完成情况

```text
✅ 理解 Skill ≠ Tool
✅ 理解 Tool 决定能力，Skill 规范流程
✅ 创建项目级 Skill
✅ 编写 c-language-check
✅ 修正 description 元数据问题
✅ 完成无 Skill 基线实验
✅ 完成有 Skill 对照实验
✅ 观察到 git diff 流程变化
✅ 手动调用 /skill:c-language-check
✅ 修改 Skill 后执行 /reload
✅ 完成全部自查题
```

---

# Day 07 ✅ 完成

下一步：

```text
Day 08｜Extensions / Hooks
```

目标：

```text
开始进入 Harness 内部
理解 Extension 如何监听事件、注册 Tool、拦截 Tool Call、增加 Command、修改工作流程
```
