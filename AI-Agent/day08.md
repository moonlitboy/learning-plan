# AI Agent 学习笔记｜Day 08：Extensions / Hooks

> 主题：从 Agent 用户走向 Harness 理解者  
> 核心目标：理解 Extension、Hook、Tool Call interception，以及它们和 Skill / Tool 的区别。

---

## 一、今天的核心结论

### 1. Skill 和 Extension 的区别

```text
Skill
→ 主要属于指令 / Context 层
→ 告诉 LLM 某类任务应该怎样完成
→ 本身不直接提供新的真实执行能力

Extension
→ 属于 Harness 层
→ 本身是可运行的程序代码
→ 可以监听事件、拦截 Tool Call、注册 Tool、增加 Command、修改工作流程等
```

一句话：

> **Skill 更像“工作规范”，Extension 更像“修改 Harness 行为的程序”。**

---

## 二、Tool、Hook、Event、Extension 的关系

### Tool

Tool 是模型主动请求使用的能力，例如：

```text
read
edit
write
bash
```

模型会主动提出 Tool Call。

---

### Event

Event 是 Harness 内部发生的事件。

今天重点使用：

```text
tool_call
```

它表示：

```text
模型已经提出一个 Tool Call
↓
Harness 进入工具调用流程
```

---

### Hook

Hook 是挂在某个 Harness 事件上的回调。

例如：

```ts
pi.on("tool_call", async (event, ctx) => {
    // ...
});
```

可以理解为：

```text
当 tool_call 事件发生时
↓
Harness 自动执行这段回调
```

模型不会主动选择 Hook。

---

### Extension

Extension 是承载 Hook / Tool / Command / UI / 状态管理等扩展逻辑的程序。

关系：

```text
Pi Harness
│
├── Tools
│   ├── read
│   ├── edit
│   └── bash
│
└── Extension
    │
    └── 注册 Hook
        │
        └── 监听 tool_call
```

---

## 三、第一个实验：tool-observer.ts

项目级 Extension 目录：

```text
.pi/extensions/
```

创建：

```bash
mkdir -p .pi/extensions
touch .pi/extensions/tool-observer.ts
```

第一版观察型 Extension：

```ts
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
    pi.on("tool_call", async (event, ctx) => {
        ctx.ui.notify(`[tool-observer] Tool: ${event.toolName}`, "info");
    });
}
```

这份 Extension：

```text
只观察 Tool Call
不修改参数
不阻止调用
不增加新 Tool
```

---

## 四、只显式加载一份 Extension

启动：

```bash
pi --no-extensions -e ./.pi/extensions/tool-observer.ts
```

拆开理解：

```text
pi
→ 启动 Pi

--no-extensions
→ 禁止自动发现 / 自动加载其他 Extension

-e ./.pi/extensions/tool-observer.ts
→ 手动加载指定 Extension
```

最终效果：

```text
自动加载：关闭
手动加载：tool-observer.ts
```

---

## 五、观察实验结果

任务：

```text
读取 c/hello.c 第一行，不要修改文件。
```

Pi 调用了：

```text
read c/hello.c:1-1
```

同时出现：

```text
[tool-observer] Tool: read
```

说明：

```text
LLM
↓
提出 read Tool Call
↓
tool_call 事件发生
↓
Hook 被触发
↓
tool-observer 观察到 read
↓
read 真正执行
↓
Tool Result 返回 LLM
```

结论：

> **Extension 确实运行在 Harness 一侧，不只是提示词。**

---

## 六、对照实验：完全禁用 Extension

启动：

```bash
pi --no-extensions
```

再次执行：

```text
读取 c/hello.c 第一行，不要修改文件。
```

结果：

```text
read 仍然正常执行
```

但没有：

```text
[tool-observer] Tool: read
```

说明：

```text
read
→ Pi 原本就有的 Tool

tool-observer
→ 没有创造 read 能力
→ 只是监听已有的 Tool Call
```

所以：

> **Extension 不一定增加能力，也可以只做观察 / 审计。**

---

## 七、第二个实验：tool-blocker.ts

创建：

```bash
touch .pi/extensions/tool-blocker.ts
```

实验代码：

```ts
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
    pi.on("tool_call", async (event, ctx) => {
        if (
            event.toolName === "bash" &&
            event.input.command?.includes("BLOCK_ME")
        ) {
            ctx.ui.notify(
                "[tool-blocker] 已阻止这个 bash Tool Call",
                "warning"
            );

            return {
                block: true,
                reason: "Blocked by tool-blocker extension",
            };
        }
    });
}
```

---

## 八、Tool Call interception

拦截逻辑：

```text
tool_call
↓
是不是 bash？
↓
command 是否包含 BLOCK_ME？
↓
是 → block
否 → 放行
```

这说明：

```text
Tool 是否存在
≠
每一次 Tool Call 都一定允许执行
```

Harness 可以在中间加入策略：

```text
LLM
↓
Tool Call
↓
Extension / Hook
↓
允许 / 阻止
↓
Tool Execution
```

---

## 九、拦截实验

只加载 blocker：

```bash
pi --no-extensions -e ./.pi/extensions/tool-blocker.ts
```

任务：

```text
请执行 echo BLOCK_ME
```

实际结果：

```text
$ echo BLOCK_ME

Blocked by tool-blocker extension

Warning: [tool-blocker] 已阻止这个 bash Tool Call
```

没有真正输出：

```text
BLOCK_ME
```

因此真实流程是：

```text
LLM 已经提出 bash Tool Call
↓
Extension 在执行前截获
↓
命中规则
↓
Harness block
↓
bash 没有真正执行
```

这里再次证明：

> **Tool Call ≠ Tool 已经执行。**

---

## 十、放行实验

任务：

```text
请执行 echo HELLO
```

结果：

```text
$ echo HELLO

HELLO
```

说明 blocker 并不是禁用了整个 bash，而是在检查 Tool Call 参数后：

```text
echo BLOCK_ME
→ 命中规则
→ block

echo HELLO
→ 未命中规则
→ 正常执行
```

---

## 十一、Hook 的关键理解

今天写的：

```ts
pi.on("tool_call", ...)
```

其中：

```text
tool_call
→ Harness 事件名
```

不是 Tool 名字。

Hook 工作方式：

```text
事件不发生
→ Hook 不执行

事件发生
→ Harness 自动触发 Hook
```

例如模型主动选择的是：

```text
bash Tool
```

而不是：

```text
tool-blocker Hook
```

真实流程：

```text
LLM
↓
选择 bash Tool
↓
Harness 产生 tool_call 事件
↓
Hook 自动触发
↓
检查 / 干预
↓
Tool 执行或被阻止
```

---

## 十二、今天最重要的四层区分

```text
Tool
→ 模型主动请求使用的能力

Event
→ Harness 内部发生的事情

Hook
→ 挂在 Event 上的回调

Extension
→ 承载 Hook / Tool / Command 等扩展逻辑的程序
```

---

## 十三、为什么第三方 Extension 风险更高

Extension 本身是程序代码。

所以它可能：

```text
读写文件
调用系统能力
监听事件
拦截 Tool Call
注册新 Tool
改变 Harness 工作流程
```

因此：

> **第三方 Extension 必须像普通第三方代码一样审查源码，而且最好真正看懂。**

不能因为它叫：

```text
Agent 插件
Extension
```

就默认可信。

---

## 十四、Day 08 自查题

### 1. Skill 与 Extension 最大区别是什么？

我的回答：

```text
Skill 属于指令 / Context 层，主要告诉 LLM 怎么做。
Extension 属于 Harness 层，本身是可运行的程序代码，可以直接改变 Harness 行为。
```

---

### 2. Extension 为什么比 Skill 权限潜力更高？

因为：

```text
Extension 有真正可执行的程序代码。
```

它可以参与 Harness 的真实运行流程，而 Skill 主要是工作规范。

---

### 3. Tool Call interception 有什么价值？

可以在 Tool 真正执行前：

```text
检查 Tool Call
↓
判断风险
↓
允许 / 阻止
```

例如今天：

```text
echo BLOCK_ME
→ Tool Call 已经提出
→ Extension 拦截
→ Harness block
→ 没有真正执行
```

---

### 4. Extension 能否改变默认 Tool 行为？

可以。

Extension 可以：

```text
检查 Tool Call
阻止 Tool Call
干预参数
修改工作流程
```

今天亲手验证的是：

```text
block
```

---

### 5. 为什么第三方 Extension 应该先看源码？

因为 Extension 本身就是程序。

恶意代码或有 bug 的代码可能直接影响：

```text
文件
命令执行
Harness 流程
Tool 权限
```

所以不仅要“看源码”，还应该尽量**看懂它具体会做什么**。

---

## 十五、Day 08 最终心智模型

```text
                 User
                   ↓
                  LLM
                   ↓
              Tool Call
                   ↓
          Harness 产生 Event
                   ↓
            Hook 被自动触发
                   ↓
         Extension 检查 / 干预
            ↓            ↓
          放行          block
            ↓
           Tool
            ↓
        Tool Result
            ↓
           LLM
```

---

## 十六、Day 08 完成状态

今天已经完成：

- [x] 理解 Extension 属于 Harness 层
- [x] 理解 Skill 与 Extension 的区别
- [x] 理解 Event 与 Hook
- [x] 理解 Hook 不是 Tool
- [x] 创建 `tool-observer.ts`
- [x] 监听真实 `tool_call`
- [x] 使用 `--no-extensions`
- [x] 使用 `-e` 显式加载 Extension
- [x] 使用 `/reload`
- [x] 完成禁用 Extension 对照实验
- [x] 创建 `tool-blocker.ts`
- [x] 拦截 bash Tool Call
- [x] 验证 `BLOCK_ME` 被阻止
- [x] 验证普通 `echo HELLO` 正常放行
- [x] 完成 Day 08 五道自查题

> **Day 08 完成。**
