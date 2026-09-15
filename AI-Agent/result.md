# AI Agent 14 天总复盘

> 目标不是“敢让 AI 随便跑”，而是：知道它能做什么、不能做什么；能看到它做了什么；即使做错，也能发现并恢复。

---

# 一、14 天主线

```text
Day 01  LLM / Agent / Harness / Agent Loop
Day 02  Tool Calling
Day 03  Context / Prompt / Project Instructions
Day 04  Permission / Sandbox / Approval / Prompt Injection
Day 05  Pi 基础与裸 Agent
Day 06  Tool Allowlist 与最小权限
Day 07  Skills
Day 08  Extensions / Hooks
Day 09  Session / Context Window / Compaction / Memory
Day 10  Planning / MCP / Sub-agent / Autonomy
Day 11  Codex 架构拆解
Day 12  Pi / Codex / Copilot CLI / OpenCode 横向分析
Day 13  Mini Agent
Day 14  综合实验 + 毕业答辩
```

这 14 天真正建立的是一套分析 Coding Agent 的方法，而不是某个具体工具的使用教程。

---

# 二、Day 01｜LLM、Agent、Harness

最重要的第一步：

```text
LLM ≠ Agent
```

Agent 可以理解为：

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

最小心智模型：

```text
User
↓
Harness
↓
LLM
↓
Tool Call
↓
Tool Execution
↓
Tool Result
↓
LLM
```

从这一天开始，不再用“AI 自己改了代码”这种模糊说法，而是尝试拆解每一步。

---

# 三、Day 02｜Tool Calling

理解了：

```text
Tool Call
≠
Tool 已经执行
```

Tool Call 是结构化行动请求。

例如模型请求：

```text
read(path="hello.c")
```

真正流程更接近：

```text
LLM 选择 Tool
↓
Harness 校验 Tool Call
↓
Tool 执行
↓
结果返回 Harness
↓
Tool Result 进入 Context
↓
LLM 再判断下一步
```

也理解了减少 Tool 数量会直接缩小 Agent 的真实能力范围。

---

# 四、Day 03｜Context

核心突破：

```text
模型能推理的信息
=
真正进入当前 Context 的信息
```

而不是：

```text
电脑上有这个文件
=
模型自动知道
```

Context 可能包括：

- System Prompt
- Developer / Harness Instructions
- User Prompt
- Project Instructions
- Conversation History
- Tool Results
- File Content

`AGENTS.md` 属于项目说明 / Context 来源，不是 Tool。

---

# 五、Day 04｜权限与安全

建立了五层安全模型：

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

开始不再只问：

```text
这个 Agent 安全吗？
```

而问：

```text
它能访问什么？
它能修改什么？
它能执行什么？
哪些操作需要批准？
出了问题怎么发现？
出了问题怎么恢复？
```

并且区分：

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

# 六、Day 05｜正式认识 Pi

第一次用 Pi 做完整：

```text
读取
↓
修改
↓
编译
↓
查看 diff
```

开始真正从 Harness 视角看 Pi，而不是只把它当“另一个 AI 聊天工具”。

认识了 Pi 的核心 Tool 思路：

```text
read
write
edit
bash
```

也开始区分 Credential 与 Tool：

```text
Harness 能调用模型
≠
模型应该看到 API Key
```

---

# 七、Day 06｜Tool Allowlist 与最小权限

学习主动限制 Agent：

```text
--tools
--exclude-tools
--no-tools
--no-builtin-tools
```

核心结论：

```text
Tool 越多
≠
Agent 越高级
```

真正有用的是：

> 按任务提供最少必要能力。

能力模型：

```text
Capability
=
Model 能力
×
可用 Context
×
可用 Tools
×
Environment Permission
```

---

# 八、Day 07｜Skills

理解：

```text
Tool
→ Agent 能做什么

Skill
→ Agent 应该怎样完成某类任务
```

自己制作并使用了：

```text
c-language-check
```

规则包括：

- 修改 C 文件后必须编译
- 使用规定 clang 参数
- 编译失败先分析
- 不为消除 warning 随意改语义
- 最后查看 Git diff

关键结论：

```text
Skill
≠
新能力
```

Skill 更接近 Prompt / 工作流程层规则。

---

# 九、Day 08｜Extensions / Hooks

理解了 Extension 属于 Harness 层扩展。

它可以：

- 监听事件
- 注册 Tool
- 拦截 Tool Call
- 增加 Command
- 修改工作流程
- 管理状态

自己观察了：

```text
tool-observer.ts
```

以及危险行为拦截思路。

关键结论：

> Extension 本身是程序代码。

所以：

```text
安装第三方 Extension
≈
安装第三方程序
```

必须审查来源和实现。

---

# 十、Day 09｜Session / Context Window / Compaction / Memory

彻底区分：

### Session
一次持续工作的状态与历史。

### Context Window
模型一次推理能够接收的有限上下文。

### Compaction
压缩 / 总结历史，降低 Context 占用。

### Memory
跨 Session 或长期保存的信息机制。

必须记住：

```text
Session ≠ Context
Context ≠ Memory
Memory ≠ 文件系统
Compaction ≠ Memory
```

并实际体验：

```text
/session
/resume
/tree
/fork
/clone
/new
/compact
```

理解“更多 Context”不一定更好，因为会增加：

- 噪声
- 成本
- 无关信息
- 注意力稀释

---

# 十一、Day 10｜Planning / Autonomy / MCP / Sub-agent

开始把常见 Agent 术语放回正确层级。

## Planning

可能只是：

```text
先生成计划
↓
再执行
```

也可能是 Harness 专门设计的模式。

## Autonomy

不能只说“自主程度高”。

应该拆成：

- 最多循环多少步
- 有哪些 Tools
- 是否需要 Approval
- 是否能联网
- 是否能修改文件
- 是否能启动其他 Agent

## MCP

```text
Agent / Client
↓
标准化协议
↓
外部 Tool / Resource / Service
```

MCP 解决标准化连接，不自动解决可信问题。

## Sub-agent

提供：

- 分工
- Context 隔离
- 并行
- 专门角色

同时增加：

- Context
- 调用次数
- 权限复杂度
- 观察难度

---

# 十二、Day 11｜Codex 架构拆解

重新用前 10 天的概念分析 Codex：

```text
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

真正重要的是开始问：

```text
这是谁的能力？

模型？
Harness？
Tool？
Sandbox？
OS？
Git？
```

而不是把全部行为都归因于“模型很聪明”。

---

# 十三、Day 12｜横向比较 Agent

建立统一分析矩阵：

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

面对陌生 Agent 的正确习惯：

```text
知道
→ 写真实观察

不知道
→ 写“待查”

绝不凭印象补齐
```

这一天真正学会的是：

> 分析 Agent，而不是依赖品牌熟悉度。

---

# 十四、Day 13｜亲手实现 Mini Agent

这是 14 天中最重要的“开窍实验”之一。

亲手实现最小：

```text
用户提出问题
↓
模型决定调用 Tool
↓
程序执行 Tool
↓
Tool Result 返回模型
↓
模型继续判断
↓
最终回答
```

理解了 Mini Agent Harness 的核心部件：

- Loop
- Tool Definition
- Tool Dispatch
- Tool Result
- State
- Stopping Condition

并设置：

```text
MAX_STEPS
```

避免 Agent Loop 无限运行。

---

## Provider 与 Harness 解耦

DeepSeek：

- 直接模型 API Provider
- OpenAI-compatible
- 适合学习 API Key、Tool Calling、Messages、Agent Loop

OpenRouter：

- 统一 API 接口
- 支持不同模型 Provider / Model 切换与路由

重要架构原则：

```text
Agent Loop
≠
具体 Provider
```

更换 Provider 时尽量不改 Agent Loop。

---

## API Key 隔离

Mini Agent 主进程需要 Key 调模型，但 Tool 子进程不需要。

所以构造：

```python
SAFE_ENV = os.environ.copy()
SAFE_ENV.pop("DEEPSEEK_API_KEY", None)
SAFE_ENV.pop("OPENROUTER_API_KEY", None)
SAFE_ENV.pop("OPENAI_API_KEY", None)
```

再传给：

```python
subprocess.run(..., env=SAFE_ENV)
```

这是最小权限的真实实践。

---

# 十五、Day 14｜综合毕业实验

完成：

```text
Pi
↓
Codex
↓
人工 Review
↓
毕业答辩
```

实验中故意准备：

- 编译错误
- 逻辑问题
- 可读性问题
- README 项目规则

然后分别观察不同 Harness 如何：

```text
读取
分析
修改
编译
运行
Review
报告
```

最后由人确认：

- 修改范围
- 是否越界
- 是否存在无关改动
- 编译是否成功
- 是否应该接受

最终：

```text
working tree clean
```

14 天毕业实验完成。

---

# 十六、14 天后形成的核心心智模型

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
              ┌────────────────────┐
              │ read/edit/bash/... │
              └─────────┬──────────┘
                        │
                   Tool Result
                        │
                        └──────► 再进入 Context
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
继续 / 结束
```

---

# 十七、三层执行模型

必须永远分清：

```text
模型“提出一个动作”
        ≠
Harness“允许 / 调度这个动作”
        ≠
操作系统“最终允许并执行”
```

例如：

```text
LLM
↓
请求 bash Tool Call
↓
Harness 调用 bash Tool
↓
Tool 启动系统进程
↓
OS 真正运行 clang
```

---

# 十八、安全模型

14 天后，安全感不再来自：

```text
这个 Agent 很聪明
```

而来自：

```text
最小权限
+
可观察
+
可验证
+
可回滚
```

长期使用任何 Agent 前，都问：

### 开始前

- 我在哪个目录？
- Git 是否干净？
- 是否需要 checkpoint？
- 有哪些 Tools？
- 能否执行 shell？
- 能否修改文件？
- 能否联网？
- 是否加载 Skills / Extensions / MCP？
- 当前权限模式是什么？

### 工作中

- Agent 正在做什么？
- 为什么执行这个命令？
- 有没有越界？
- 有没有读取不相关敏感文件？
- 有没有不理解的高权限操作？

### 完成后

```bash
git status
git diff
```

再确认：

- 修改范围符合任务
- 无无关修改
- 无意外删除
- 编译 / 测试通过
- 看懂主要 diff
- 确认后再 commit

---

# 十九、目前最稳的知识点

经过 14 天实验与毕业答辩，目前已经比较扎实：

- LLM 与 Agent 的区别
- Harness 的作用
- Tool Call ≠ Tool Execution
- Tool Result 回到 Context
- Tool allowlist 与最小权限
- Git 的 Review / Recovery 定位
- Skill 与 Tool 的区别
- MCP 的基本定位
- Pi 与 Codex 的 Harness 差异意识
- Mini Agent Loop
- `MAX_STEPS`
- API Key 不写进代码 / Git
- Tool 子进程不继承模型 Key
- 遇到不懂的 shell 命令先拒绝并弄懂

---

# 二十、需要继续巩固的知识点

毕业答辩中暴露出以下几个还需要偶尔复习的点：

1. Context 的完整组成
2. Compaction 与 Memory 的区别
3. cwd 不等于 Sandbox / 权限边界
4. Extension 是 Harness 层扩展，而不仅是“能加 Tool”
5. Sub-agent 的上下文隔离与权限复杂度
6. Prompt Injection 是不可信文本影响 Agent 行为
7. API Key、OAuth Token、ChatGPT 订阅属于不同层面
8. OpenRouter 更准确地说是统一模型路由 / API 平台，而不是简单等同单一模型提供商

这些都不是“没学会”，而是下一阶段需要继续使用来加深的概念。

---

# 二十一、以后分析任何新 Agent 的固定问题

看到一个新 Agent，不再先问“好不好用”，而是问：

```text
1. 底层模型 / Provider 是谁？
2. Harness 是谁？
3. 默认 Tools 有什么？
4. Context 从哪里来？
5. Project Instructions 怎么加载？
6. Approval 怎么做？
7. Sandbox / Isolation 在哪一层？
8. cwd 是什么？
9. 能不能联网？
10. 能不能修改文件？
11. Skill / Extension / MCP 从哪里来？
12. Session 如何保存？
13. Diff 怎么看？
14. 出错怎么恢复？
15. 谁最终执行真实系统动作？
```

只要这 15 个问题能逐步回答，一个新 Agent 就不会再只是黑盒。

---

# 二十二、14 天后的正确工作方式

```text
先看懂
↓
再限制
↓
再实验
↓
再验证
↓
再扩展
↓
最后才考虑更高自动化
```

不要反过来：

```text
先给全部权限
↓
跑起来再说
```

---

# 二十三、毕业结论

14 天之前的问题更像：

> “Agent 到底会不会乱动我的电脑？”

14 天之后，更应该变成：

> “这个 Harness 给了模型哪些 Context、Tools 和权限？这些动作在哪里执行？我能不能观察、验证和恢复？”

这就是这套训练真正完成的转变。

最终一句话：

> **LLM 负责判断下一步做什么；Harness 负责组织 Context、Tools、状态和权限；Tool 在真实环境中执行动作；Tool Result 再回到 Agent Loop。**

最终安全原则：

> **不要靠相信 Agent 获得安全感，要靠最小权限、可观察、可验证、可回滚获得安全感。**

---

# 二十四、毕业状态

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
Day 13  ✅
Day 14  ✅
```

**AI Agent 14 天基础训练：毕业。**
