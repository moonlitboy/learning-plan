# AI Agent Day 03｜Context：模型这一刻到底“知道”什么

> 学习日期：2026-09-13  
> 今日主题：Context / Project Instructions / Tool Result / Session / Memory / Disk  
> 实验平台：Codex + `~/Documents/agent-lab`

---

## 一、今天学了什么

今天的核心问题：

> **Agent 当前做判断时，到底看到了哪些信息？**

需要建立的核心认识：

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

今天重点理解了：

- System Prompt
- Developer / Harness Instructions
- User Prompt
- Project Instructions
- Conversation History
- Tool Results
- File Content
- Context Window
- Session
- Memory
- Disk

---

## 二、最重要的核心结论

### 1. Disk ≠ Context

一个文件存在于电脑或项目目录中：

```text
文件存在于 Disk
```

并不代表：

```text
文件内容已经进入模型 Context
```

例如：

```text
agent-lab/
├── AGENTS.md
├── hello.c
└── password.txt
```

如果模型只读取了 `hello.c`，那么 `password.txt` 虽然真实存在于硬盘中，也不能因此认为模型已经知道它的内容。

更准确的理解：

```text
Disk 上存在文件
        ↓
Tool / Harness 可能有能力访问
        ↓
文件内容被读取或主动加载
        ↓
进入当前 Context
        ↓
LLM 才能基于内容进行推理
```

---

### 2. User Prompt 只是 Context 的一部分

模型收到的输入不只是用户屏幕上输入的一句话。

一次推理可能包含：

```text
System Prompt
+
Developer / Harness Instructions
+
Project Instructions
+
User Prompt
+
Conversation History
+
Tool Results
+
其他被选择加入的 Context
        ↓
       LLM
```

所以：

```text
User Prompt
≠
模型收到的全部输入
```

---

## 三、不同 Context 来源

### 1. System Prompt

系统级规则。

可以理解成：

```text
系统告诉模型：
“你应该怎样工作”
```

例如安全规则、总体行为规范等。

---

### 2. Developer / Harness Instructions

由 Agent Harness 或产品提供给模型的工作规则。

例如：

```text
如何使用工具
如何组织工作流程
某些操作是否允许
如何处理权限
```

它属于 Harness 层提供的 Instructions。

---

### 3. User Prompt

用户这一轮具体提出的任务。

例如今天给 Codex 的任务：

```text
修改 c/hello.c，再增加一行简单输出。
完成后告诉我你做了什么。
```

这是典型的 User Prompt。

---

### 4. Project Instructions

当前项目自己的工作规则。

今天实际使用：

```text
AGENTS.md
```

例如：

```md
# Project Instructions

- 修改 C 文件后必须使用 `clang -std=c17 -Wall -Wextra -Wpedantic` 编译。
- 不要删除文件。
- 回答时说明你执行过哪些检查。
```

`AGENTS.md`：

```text
不是 Tool
```

而是：

```text
Project Instructions
/
Instructions / Context 的来源
```

它的作用更接近：

```text
告诉 Agent “应该怎么做”
```

而不是：

```text
给 Agent 一个新的执行能力
```

---

### 5. Conversation History

前面的聊天内容也可能被 Harness 选择进入当前 Context。

但：

```text
Conversation History
≠
永远完整存在于当前 Context
```

因为模型一次推理能够接收的 Context Window 是有限的。

当对话越来越长时，较早内容可能：

- 被裁剪
- 被压缩
- 被总结
- 不再进入当前 Context

所以模型可能表现得像“忘记”早期对话。

---

### 6. Tool Result

Tool 执行后的结果会被返回给 Agent Loop。

例如：

```text
LLM
↓
Tool Call：bash
↓
Harness 执行 clang
↓
Tool Result：编译成功 / 编译错误
↓
进入后续 Context
↓
LLM 根据结果继续判断
```

Tool Result 的意义不仅是“工具运行完了”。

更重要的是：

> **模型需要观察 Tool Result，才能决定下一步做什么。**

---

## 四、今天把 Day 01 / Day 02 / Day 03 串起来了

今天终于可以把前三天的知识连成一条完整链路：

```text
User
↓
Harness
↓
System / Harness / Project Instructions
+ User Prompt
+ 当前 Context
↓
LLM
↓
决定下一步动作
↓
Tool Call
↓
Harness 真正执行 Tool
↓
Tool Result
↓
Tool Result 进入后续 Context
↓
LLM 再次判断
↓
继续 Tool Call / 最终回答
```

也就是说：

```text
LLM 负责判断
Harness 负责组织 Context / Tools / 权限 / 状态
Tool 在真实环境中执行动作
Tool Result 再返回 Agent Loop
```

---

## 五、今天的 AGENTS.md 对照实验

今天做了一个很关键的对照实验。

实验仓库：

```text
/Users/moonlit_boy/Documents/agent-lab
```

开始前确认：

```bash
git status
```

工作区：

```text
nothing to commit, working tree clean
```

---

### 实验 A：只要求“修改后必须编译”

最开始 `AGENTS.md` 中的规则比较宽泛：

```text
修改 C 文件后必须先编译。
```

给 Codex 的 User Prompt 并没有明确说：

```text
用 clang
```

也没有指定：

```text
-std=c17
-Wall
-Wextra
-Wpedantic
```

Codex 修改后主动进行了编译。

说明：

```text
Project Instructions
→ 影响了 Agent 的行为
```

---

### 实验 B：改变 AGENTS.md

后来把项目规则修改为：

```text
修改 C 文件后必须使用
clang -std=c17 -Wall -Wextra -Wpedantic
编译。
```

并提交：

```bash
git add AGENTS.md
git commit -m "docs: require clang for C checks"
```

然后重新开启 Codex 的 New Chat。

给出的 User Prompt 仍然只是：

```text
修改 c/hello.c，再增加一行简单输出。
完成后告诉我你做了什么。
```

没有告诉 Codex：

```text
有 AGENTS.md
必须用 clang
必须编译
具体参数是什么
```

但 Codex 主动执行了类似：

```bash
clang -std=c17 -Wall -Wextra -Wpedantic c/hello.c -o /tmp/agent-lab-hello
```

---

## 六、实验得到的结论

实验 A 与实验 B 对比：

```text
实验 A：
AGENTS.md 只要求“必须编译”
↓
Codex 执行编译
```

```text
实验 B：
AGENTS.md 明确要求
clang -std=c17 -Wall -Wextra -Wpedantic
↓
Codex 的 Tool Call 随规则改变
```

因此可以得到：

```text
AGENTS.md 改变
↓
Project Instructions 改变
↓
当前 Context 中的规则改变
↓
模型决策改变
↓
Tool Call 行为改变
```

---

## 七、一个很重要的观察

实验过程中没有明显看到 Codex 显式执行：

```text
read AGENTS.md
```

但 Codex 仍然遵守了 `AGENTS.md` 中的规则。

因此更合理的理解是：

```text
AGENTS.md
↓
被 Codex Harness 识别为 Project Instructions
↓
Harness 将相关规则提供给模型
↓
规则进入当前 Context
↓
LLM 根据规则做决定
```

而不是必须：

```text
LLM
↓
read AGENTS.md
↓
读取规则
↓
再执行
```

今天的重要认识：

> **不是所有进入 Context 的信息，都必须由模型通过 Tool Call 主动读取。**

有些信息可能由 Harness 在模型推理前就组织进去。

---

## 八、Context / Session / Memory / Disk

今天重点区分了这四个概念。

### Context

```text
模型这一刻实际拿到、
能够用于当前推理的信息
```

---

### Session

```text
一次持续工作的会话状态
```

例如：

```text
打开 Codex
↓
读文件
↓
修改
↓
编译
↓
讨论错误
↓
修好
```

这一整段持续工作状态属于 Session。

---

### Memory

```text
跨 Session 或长期保存的额外信息机制
```

例如：

```text
今天关闭 Session
↓
明天开启新 Session
↓
系统仍然能恢复某些长期保存的信息
```

这更接近 Memory。

但要注意：

```text
Memory ≠ 当前 Context
```

只有当相关 Memory 被取出并加入当前 Context 后，模型才能在这一轮推理中使用它。

---

### Disk

```text
真实存在于文件系统中的持久化内容
```

例如：

```text
hello.c
README.md
AGENTS.md
```

它们可以长期保存在硬盘中。

但是：

```text
Disk ≠ Context
```

---

### 四者关系

必须牢记：

```text
Session ≠ Context
Context ≠ Memory
Memory ≠ Disk
Disk ≠ Context
```

---

## 九、Context Window

Context Window：

```text
模型一次推理能够接收的有限上下文
```

因此：

```text
Conversation History 越来越长
+
文件内容越来越多
+
Tool Result 越来越多
        ↓
Context Window 有限
        ↓
不能保证所有历史信息永久原样保留
```

早期内容可能被：

- 选择性保留
- 裁剪
- 压缩
- 总结

所以模型可能“忘记”很早以前的信息。

---

## 十、Context 不是越多越好

今天一个很重要的结论：

```text
更多 Context
≠
一定更好
```

无关信息过多可能导致：

- 相关性下降
- 噪声增加
- 成本增加
- 推理重点被稀释

所以 Context 更应该追求：

```text
相关
+
足够
+
清晰
```

而不是：

```text
把整个硬盘全部塞进去
```

---

## 十一、Agent 为什么会“知道”某件事？

以后看到 Agent 知道某个信息时，不应该直接认为：

```text
AI 自己知道
```

或者：

```text
它扫描了整台电脑
```

而应该追问：

> **这条信息到底从哪里进入当前 Context？**

例如 Agent 知道：

```text
这个项目应该执行 npm test
```

可能来源包括：

1. User Prompt
2. Project Instructions / `AGENTS.md`
3. Conversation History
4. Memory 被 Harness 取出并加入 Context
5. Agent 读取了 README / package.json / Makefile
6. 某个 Tool Result 暴露了测试命令
7. Harness Instructions

以后应该形成：

```text
Agent 知道某件事
↓
追踪信息来源
↓
判断它是如何进入 Context 的
```

---

## 十二、今天做过的分类练习

### 示例 1

```text
“你是一个 Coding Agent，需要遵守系统安全规则。”
```

更接近：

```text
System Prompt
```

---

### 示例 2

```text
“这个项目修改 C 文件后必须使用 clang 编译。”
```

属于：

```text
Project Instructions
```

---

### 示例 3

```text
“把 hello.c 的输出改成 Hello World。”
```

属于：

```text
User Prompt
```

---

### 示例 4

```text
bash 返回：

hello.c:5:3: error: ...
```

属于：

```text
Tool Result
```

随后会进入后续 Context。

---

## 十三、今天遇到的问题

### 1. `.DS_Store`

实验开始前发现：

```text
.DS_Store
```

未被 Git 跟踪，但需要忽略。

创建：

```text
.gitignore
```

内容：

```text
.DS_Store
```

提交：

```bash
git add .gitignore
git commit -m "chore: ignore .DS_Store"
```

检查整个仓库是否存在已经追踪的 `.DS_Store`：

```bash
git ls-files | grep '\.DS_Store$'
```

没有输出：

```text
仓库中没有被 Git 追踪的 .DS_Store
```

检查是否被 `.gitignore` 命中可使用：

```bash
git check-ignore -v .DS_Store
```

---

## 十四、今天的自查答案

### 1. 一个文件存在项目里，就一定已经进入模型 Context 吗？

不是。

因为：

```text
存在于 Disk
≠
已经进入 Context
```

---

### 2. System Prompt 与 User Prompt 有什么区别？

System Prompt：

```text
系统级规则，
告诉模型整体应该怎样工作。
```

User Prompt：

```text
用户这一轮具体提出的任务。
```

核心区别是它们的来源和层级不同。

---

### 3. AGENTS.md 更接近 Tool 还是 Instructions / Context？

```text
Instructions / Context
```

因为它主要提供项目规则，不提供新的执行能力。

---

### 4. Tool Result 为什么也可能进入 Context？

因为模型需要知道 Tool 实际执行后的结果，才能决定下一步。

```text
Tool Call
↓
Tool Result
↓
Context
↓
LLM 下一步判断
```

---

### 5. 模型为什么可能忘记很早以前的对话？

因为：

```text
Context Window 有限
```

当历史过长时，早期信息可能不再完整进入当前 Context。

---

### 6. Context 越多一定越好吗？

不是。

过多无关信息会：

```text
增加噪声
降低相关性
增加成本
稀释推理重点
```

---

## 十五、我现在的理解

我现在对 Context 的理解是：

> **模型不是天然知道电脑、项目和所有历史信息。模型只能根据当前真正进入 Context 的内容进行推理。**

Agent 的 Context 可能来自：

```text
System Prompt
Developer / Harness Instructions
User Prompt
Project Instructions
Conversation History
Tool Results
File Content
Memory Retrieval
```

其中：

```text
文件存在于 Disk
≠
模型已经知道内容
```

而：

```text
Tool Result
```

会被送回 Agent Loop，让模型观察真实环境后继续判断。

`AGENTS.md` 不是 Tool，而是 Project Instructions。今天通过实际实验看到：

```text
修改 AGENTS.md
↓
Project Instructions 改变
↓
模型当前 Context 中的规则改变
↓
模型决策改变
↓
Tool Call 行为改变
```

---

## 十六、Day 03 一句话总结

> **Agent“知道什么”，取决于这一刻真正进入 Context 的信息，而不是电脑上总共有多少信息。**

再补一句：

> **看到 Agent 突然知道某件事时，要追踪这条信息从哪里进入 Context，而不是认为模型自动扫描了整个环境。**

---

## 十七、Day 03 完成状态

- [x] 理解 System Prompt
- [x] 理解 Developer / Harness Instructions
- [x] 理解 User Prompt
- [x] 理解 Project Instructions
- [x] 理解 Conversation History
- [x] 理解 Tool Result
- [x] 理解 Disk ≠ Context
- [x] 区分 Context / Session / Memory / Disk
- [x] 理解 Context Window 有限
- [x] 理解 Context 越多不一定越好
- [x] 完成 `AGENTS.md` 对照实验
- [x] 观察到 Project Instructions 改变后 Agent Tool Call 行为变化
- [x] 完成 Day 03 自查

**Day 03：完成 ✅**
