# AI Agent 14 天训练｜Day 09
## Session、Context Window、Compaction、Memory

> 实验环境：Pi Agent v0.85.1  
> 实验目录：`~/Documents/agent-lab`  
> 今日目标：分清 **Session / Context / Context Window / Compaction / Memory**，并亲手验证 Pi 的 Session 创建、恢复、分支与临时会话机制。

---

## 一、今天最重要的核心结论

### 1. Session ≠ Context

一个 Session 可以保存很多历史，但不代表这些历史会在每一轮都完整进入模型当前 Context。

```text
Session History
      ↓
Context Selection / Compaction
      ↓
Current Model Input
```

因此：

```text
存在磁盘上
≠
已经进入当前 Context
```

---

### 2. Context Window 不是硬盘容量

**Context Window** 是模型一次推理能够接收的上下文容量上限。

```text
硬盘上可以保存很多文件 / Session / 历史
                ↓
模型某一轮真正能看到多少
                ↓
受 Context Window 限制
```

---

### 3. Session 与 Memory 的区别

```text
Session
→ 一次持续工作的会话状态
→ 保存用户消息、Assistant 消息、Tool Call、Tool Result 等历史

Memory
→ 跨 Session 或长期保存的额外信息机制
```

必须记住：

```text
Session ≠ Context
Context ≠ Memory
Memory ≠ 文件系统
```

---

### 4. 更多 Context 不一定更好

更多上下文可能带来：

- 更多噪声
- 相关性下降
- 成本增加
- 推理重点被稀释

所以：

> **Context 不是越多越好，而是越相关越好。**

这也是为什么 `AGENTS.md` 应该写得清晰、简洁，只保留真正相关的项目规则。

---

# 二、Session 创建与查看

## 1. 启动时命名 Session

```bash
cd ~/Documents/agent-lab
pi --name "day09-session"
```

## 2. 进入 Pi 后命名 / 改名

```text
/name day09-session
```

两种方式：

```text
--name
→ 启动 Pi 时命名 Session

/name
→ 已经进入 Pi 后给当前 Session 命名或改名
```

---

## 3. 查看 Session 信息

```text
/session
```

实验中看到：

```text
Name: day09-session

File:
~/.pi/agent/sessions/...jsonl

ID:
01a09f6c-096c-73b0-be1b-c7c490851d4f
```

`/session` 还会显示：

```text
Messages
Tokens
Cost
Tool calls / results
```

### 第一次刚创建时

```text
Messages
Total: 0

Tokens
Total: 0
```

### 进行一次 read Tool 调用后

```text
Messages
Total: 4
User: 1
Assistant: 2
Tools: 1 calls, 1 results
```

说明一次简单 Agent Loop 大致经历：

```text
User Prompt
   ↓
Assistant 决定调用 read
   ↓
Tool Call
   ↓
Tool Result
   ↓
Assistant 最终回答
```

---

# 三、Token 统计不能直接等于 Current Context

实验中 `/session` 显示过：

```text
Input: 2,809
Output: 145
Total: 2,954
```

这里的 Input 不只是用户刚刚输入的一句话，还可能包含：

```text
Harness Instructions
+ Project Context
+ AGENTS.md
+ Conversation History
+ Tool Definitions
+ Tool Result
+ User Prompt
...
```

所以：

```text
User Prompt tokens
≠
整个模型 Input tokens
```

后续 Session 增长到：

```text
Input: 16,632
Output: 795
Total: 17,427
```

还看到：

```text
Cached: 4,608
Uncached: 12,024
```

必须注意：

```text
/session 显示的累计 Token
≠
当前这一轮 Context 正好占用同样数量
```

因为多轮调用可能重复携带历史内容。

---

# 四、Session 恢复：/resume、pi -r、pi -c

## 1. `/resume`

先启动 Pi：

```bash
pi
```

进入 Pi 后：

```text
/resume
```

作用：

```text
/resume
→ Pi 交互界面内部命令
→ 打开 Session 选择器
```

实验中成功选回：

```text
day09-session
```

恢复后 `/session` 显示：

```text
Name 不变
ID 不变
File 不变
Messages 不变
```

说明恢复的是原 Session，不是新建一个同名 Session。

---

## 2. `pi -r`

在 zsh 中：

```bash
pi -r
```

作用：

```text
pi -r
→ 启动 Pi 时
→ 直接打开 Session 选择器
```

与：

```text
pi
↓
/resume
```

效果类似，但入口位置不同。

---

## 3. `pi -c`

```bash
pi -c
```

作用：

```text
pi -c
→ 不弹选择器
→ 直接继续当前目录最近一次 Session
```

实验中恢复后，历史内容直接显示出来。

再次 `/session`：

```text
ID:
01a09f6c-096c-73b0-be1b-c7c490851d4f
```

与原 Session 完全一致。

因此：

```text
/resume
→ Pi 内部选择旧 Session

pi -r
→ zsh 启动时直接进入 Session 选择器

pi -c
→ zsh 启动时直接继续当前目录最近 Session
```

---

# 五、/tree：Session 内部的历史树

执行：

```text
/tree
```

第一次看到：

```text
user
tool
assistant
```

说明 `/tree` 不是在选“哪个 Session”，而是在看：

> **当前 Session 内部的历史节点 / 分支。**

核心区别：

```text
/resume
→ 在不同 Session 之间选择

/tree
→ 在同一个 Session 内部选择历史位置
```

---

## 1. 回到旧节点

在 `/tree` 中选中最早的 User 消息后，Pi 提示：

```text
No summary
Summarize
Summarize with custom prompt
```

本次实验选择：

```text
No summary
```

随后出现：

```text
Navigated to selected point
```

并且旧 User Prompt 回到了输入框中。

说明：

```text
/tree
→ 不只是查看历史
→ 可以把当前活动位置移动回旧节点
```

---

## 2. 从旧节点产生新分支

将旧 Prompt 修改后重新发送。

原来：

```text
User
 ↓
read
 ↓
Assistant A
```

从旧 User 节点重新继续后：

```text
User
 ├── read → Assistant A
 │
 └── read → Assistant B
```

再次 `/tree` 后，能同时看到两条分支。

因此：

> **`/tree` 可以在同一个 Session 内回到旧历史节点，并从那里继续产生新分支；原来的分支仍然保留。**

---

# 六、/fork：从旧 User 消息创建新 Session

执行：

```text
/fork
```

选择旧 User 消息后：

```text
Forked to new session
```

随后 `/session`：

```text
原 Session ID:
01a09f6c-096c-73b0-be1b-c7c490851d4f

Fork 后 ID:
01a09f80-52c7-77dd-a05b-89d0635d857e
```

File 也变成新的 `.jsonl`。

因此：

```text
/tree
→ 同一个 Session 内分支
→ Session ID 不变

/fork
→ 从旧 User 消息出发
→ 创建新的 Session
→ 新 ID
→ 新 File
```

---

## 额外实验：空 Fork Session

Fork 后没有真正发送消息，只执行：

```text
/session
```

看到：

```text
Messages: 0
Tokens: 0
```

直接退出后再：

```bash
pi -r
```

没有看到这个 0-message Session 出现在可恢复列表中。

目前能确认：

> **这个空 Session 没有出现在 `/resume` / `pi -r` 的可恢复列表中。**

不能仅凭这个界面断言对应 `.jsonl` 文件一定已经从磁盘物理删除，也可能只是 Pi 忽略 0-message Session。

---

# 七、/clone：复制当前活动分支到新 Session

Clone 前：

```text
Session ID:
01a09f6c-096c-73b0-be1b-c7c490851d4f

Messages:
Total: 8
```

执行：

```text
/clone
```

Clone 后：

```text
Session ID:
01a09f88-5120-73b2-a6e8-ad929d29980c

Messages:
Total: 4
```

为什么原 Session 有 8 条，而 Clone 后只有 4 条？

因为原 Session 已经通过 `/tree` 产生了两条分支。

```text
原 Session Tree
│
├─ 分支 A
│
└─ 分支 B ← 当前活动分支
```

`/clone` 复制的是：

```text
当前活动分支
```

不是：

```text
整棵 Session Tree
```

所以：

```text
/clone
→ 创建新 Session
→ 新 ID
→ 复制当前活动分支
→ 不复制其他旁支
```

---

# 八、/new：完全新的 Session

执行：

```text
/new
```

结果：

```text
✓ New session started
```

随后：

```text
ID:
新的 Session ID

Messages:
Total: 0

Tokens:
Total: 0
```

因此：

```text
/clone
→ 新 Session
→ 继承当前活动分支

/new
→ 新 Session
→ 不继承旧历史
→ 从空白开始
```

---

# 九、四个历史 / 分支命令总表

```text
/tree
→ 同一个 Session 内回到历史节点
→ 可以产生新分支
→ 原分支仍保留

/fork
→ 从某条旧 User 消息出发
→ 创建新的 Session

/clone
→ 把当前活动分支复制成新的 Session
→ 不复制其他旁支

/new
→ 开始一个全新的 Session
→ 不继承旧历史
```

---

# 十、Compaction

## 1. Compaction 的作用

```text
历史越来越长
      ↓
Current Context 压力增加
      ↓
Compaction
      ↓
把旧内容压缩成更短的摘要 / 表示
      ↓
继续在当前 Session 工作
```

因此：

```text
/compact
≠ 删除 Session
≠ /new
≠ /fork
≠ /clone
```

它主要改变：

> **较长历史以后以什么形式进入后续 Context。**

---

## 2. Compaction 是有损的

摘要不可能保证保留全部细节。

可能发生：

```text
原始历史
↓
压缩总结
↓
某些细节 / 条件 / 例外被省略
```

所以可以使用：

```text
/compact 请保留已经修改的文件、编译命令、失败原因和下一步任务
```

告诉 Pi 压缩时优先保留哪些信息。

---

## 3. 今日真实实验结果

第一次：

```text
Messages: 8
Tokens Total: 5,826
```

执行：

```text
/compact
```

结果：

```text
Error: Compaction failed:
Nothing to compact (session too small)
```

后来增加历史：

```text
Messages: 20
Tokens Total: 17,427
```

再次：

```text
/compact
```

仍然：

```text
Error: Compaction failed:
Nothing to compact (session too small)
```

结论：

```text
手动执行 /compact
≠ Pi 一定强制压缩
```

Pi Harness 会自己判断当前 Session 是否有足够的可压缩历史。

注意：

> 不能根据 `/session` 的累计 Token 数直接推断 Compaction 阈值。

因此本次没有猜测 Pi 的具体阈值。

---

# 十一、/tree 与 /compact 的关系：已知与待验证

目前已知：

```text
/tree
→ 操作 Session 历史树
→ 回到旧节点 / 切换或产生分支
→ 原始历史仍保留

/compact
→ 压缩较长历史进入后续 Context 的表示
→ 目标是降低 Context 占用
```

理论上它们属于不同层面：

```text
/tree
→ Session History / Branch Navigation

/compact
→ Context Representation / Context Management
```

---

## ⚠️ 未解决 / 待后续实验

今天 `/compact` 没有真正成功，因此下面这些问题**暂不下结论**：

1. `/compact` 成功后再执行 `/tree`，Tree 中会怎样显示 Compaction 相关节点？
2. Compact 后回到 Compact 之前的旧节点继续，新分支会重新使用原始历史，还是仍依赖压缩摘要？
3. 某个分支 Compact 后，切换到另一个旧分支时，摘要是否共享？
4. `/tree` 回到 Compact 之前的位置继续时，当前 Context 如何重新构造？
5. `/tree` 中的：
   ```text
   No summary
   Summarize
   Summarize with custom prompt
   ```
   与 `/compact` 产生的摘要，在 Session Tree 和 Context 中到底是什么关系？

### 后续实验原则

> 等以后自然产生一个足够长、能够成功 `/compact` 的 Pi Session，再回来做 `/tree + /compact` 混合实验。

不要为了触发 Compaction 故意浪费大量 Token，也不要在没有实验结果时靠猜测下结论。

---

# 十二、--no-session：临时会话

启动：

```bash
pi --no-session
```

完成一次简单 read 后：

```text
/session
```

看到：

```text
File: In-memory

ID:
01a09f99-c906-7245-b499-9c92bb2f4b62

Messages:
Total: 4
```

这说明：

```text
--no-session
≠ 完全没有会话状态
```

更准确地说：

```text
--no-session
→ 当前运行期间仍然有 ID / Messages / Tokens
→ 但 File = In-memory
→ 不按普通可恢复 Session 方式持久化
```

退出后：

```bash
pi -r
```

刚才的 In-memory Session 没有出现。

因此实验验证：

```text
普通 Session
→ 有 .jsonl File
→ 退出后可以恢复

pi --no-session
→ In-memory
→ 退出后不会出现在可恢复 Session 列表
```

---

# 十三、Day 09 自查

## 1. Context Window 是硬盘容量吗？

不是。

> Context Window 是模型一次推理可容纳上下文的最大范围。

---

## 2. Session 与 Memory 有什么区别？

```text
Session
→ 保存一次持续工作的会话状态和历史

Memory
→ 跨 Session 或长期保留的额外信息机制
```

---

## 3. Compaction 为什么存在？

因为 Session 历史越来越长时，无法无限把全部原始历史塞进模型 Context。

Compaction 可以压缩较早内容，让当前 Session 继续工作，而不一定需要直接换 Session。

---

## 4. Compaction 有什么潜在信息损失？

可能把某些重要细节压缩掉。

因此 Compaction 是：

```text
有损压缩
```

---

## 5. 为什么更多 Context 不一定更好？

因为：

```text
更多 Context
→ 更多噪声
→ 重要信息被稀释
→ 模型更难抓重点
```

---

## 6. 为什么 AGENTS.md 应该清晰且相关？

因为只要 Pi 正常自动加载 `AGENTS.md`，它就会作为项目级 Context 的一部分参与模型判断。

因此：

> `AGENTS.md` 应该是项目规则，不是杂记本。

---

# 十四、Day 09 最终心智模型

```text
完整 Session History
        │
        ├── /tree
        │     ↓
        │   历史节点 / 分支导航
        │
        ├── /fork
        │     ↓
        │   从旧 User 消息创建新 Session
        │
        ├── /clone
        │     ↓
        │   当前活动分支 → 新 Session
        │
        └── /new
              ↓
            全新 Session


Session History
      ↓
Context Selection / Compaction
      ↓
Current Model Input
      ↓
LLM
```

最后牢记：

```text
Session ≠ Context
Context ≠ Memory
Memory ≠ 文件系统

存在磁盘上
≠
已经进入模型 Context

更多 Context
≠
一定更好
```

---

# 十五、Day 09 完成情况

已完成：

- [x] 理解 Session
- [x] 理解 Context Window
- [x] 理解 Memory
- [x] 理解 Compaction
- [x] `/session`
- [x] `--name`
- [x] `/name`
- [x] `/resume`
- [x] `pi -r`
- [x] `pi -c`
- [x] `/tree`
- [x] `/fork`
- [x] `/clone`
- [x] `/new`
- [x] `pi --no-session`
- [x] Session 分支实验
- [x] Session ID / File 对照
- [x] 自查题
- [ ] 成功触发一次真实 `/compact`
- [ ] `/compact + /tree` 混合实验

## Day 09 状态

**主体内容完成。**

保留两个后续实验问题：

```text
1. 成功触发真实 Compaction
2. 验证 /compact 与 /tree 混合使用的精确行为
```

这两个问题等自然出现足够长的 Session 后再回来验证，不为了完成实验而刻意浪费 Token。
