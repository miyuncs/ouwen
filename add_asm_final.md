add.c 改为 add.asm 

```
原方案：StaffAdd 项目用 add.c 实现加法
新方案：StaffAdd 项目用 add.asm 汇编实现加法
```

项目结构

```
Solution 'Company'
├── BossMain              ← 主程序（老总）exe
│   ├── 头文件
│   │   └── add.h        ← 老总定义接口
│   └── 源文件
│       └── main.c       ← 老总主函数
│
├── StaffAdd              ← 静态库（员工汇编实现加法）lib
│   ├── 头文件
│   │   └── add.h        ← 引用BossMain的add.h
│   └── 源文件
│       ├── add.asm      ← 汇编实现
│       └── empty.c      ← 空文件（用于显示C/C++属性页）
│
└── OutsourceSub          ← 静态库（外包实现减法）lib
    ├── 头文件
    │   └── subtract.h
    └── 源文件
        └── subtract.c
```

第一步：StaffAdd 启用 MASM

```
右键 StaffAdd 项目
→ 生成依赖项→ 生成自定义→ 勾选 masm(.targets, .props) ✓→ 确定
```

第二步：排除 add.c

```
右键 StaffAdd 源文件下的 add.c→ 从项目中排除
```

第三步：新建 add.asm

```
右键 StaffAdd 源文件
→ 添加 → 新建项→ C++文件 → 名称改为 add.asm→ 确定
```

右键 add.asm → 属性：
```
所有配置→ 常规 → 项类型→ Microsoft Macro Assembler→ 确定
```

第四步：add.asm 内容（Win32 x86）

```asm
.386
.model flat, c
.code
int_add PROC
    PUSH EBP
    MOV EBP, ESP
    MOV EAX, [EBP+8]
    ADD EAX, [EBP+12]
    POP EBP
    RET
int_add ENDP
END
```

堆栈布局

```
调用 add(100, 30) 时：

高地址
┌──────────┐
│    30    │ ← [EBP+12]  第2参数 b
├──────────┤
│   100    │ ← [EBP+8]   第1参数 a
├──────────┤
│ 返回地址  │ ← [EBP+4]
├──────────┤
│  旧EBP   │ ← [EBP+0]
└──────────┘  ← EBP 指向这里
低地址
```

为什么用 int_add 而不是 add

```
add 是 MASM 保留字（汇编指令名）
不能直接用作函数名，会报语法错误
用 int_add 命名，再用宏映射，保持C接口不变
```

.model flat, c 符号导出规则

```
汇编写 int_add  →  导出符号 _int_add  →  对应C的 int_add()
```

第五步：add.h（用宏映射保持接口不变）

```c
int int_add(int a, int b);
#define add(a, b) int_add(a, b)
```

> main.c 里调用 add(a, b)，宏自动替换为 int_add(a, b)，接口完全不变

第六步：main.c 完全不用改

第七步：subtract.h 和 subtract.c 不变

第八步：StaffAdd 添加 empty.c

```
右键 StaffAdd 源文件
→ 添加 → 新建项 → C++文件 → 命名 empty.c
→ 文件内容留空
```

然后关闭预编译头：
```
右键 StaffAdd → 属性 → 所有配置
→ C/C++ → 预编译头
→ 预编译头 → 不使用预编译头
→ 确定
```

第九步：确认 StaffAdd 是静态库

```
右键 StaffAdd → 属性 → 所有配置
→ 配置属性 → 常规
→ 配置类型 → 静态库(.lib)
→ 确定
```

第十步：配置头文件路径

StaffAdd 配置（需要找到 add.h）

```
右键 StaffAdd → 属性 → 所有配置
→ C/C++ → 常规 → 附加包含目录→ 填入：..\BossMain→ 确定
```

BossMain 配置（需要找到 add.h 和 subtract.h）

```
右键 BossMain → 属性 → 所有配置→ C/C++ → 常规 → 附加包含目录
→ 填入：..\StaffAdd;..\OutsourceSub→ 确定
```

第十一步：配置引用关系

```
右键 BossMain → 添加 → 引用→ 勾选 StaffAdd     ✓
→ 勾选 OutsourceSub ✓→ 确定
```

## 职责分工总结

| 角色 | 项目 | 文件 | 说明 |
|------|------|------|------|
| 老总 | BossMain | main.c / add.h | 定义接口，写主函数 |
| 员工 | StaffAdd | add.asm | 汇编实现加法 |
| 外包 | OutsourceSub | subtract.h / subtract.c | C实现减法 |

---

## 注意事项

| 注意点 | 说明 |
|--------|------|
| add 是 MASM 保留字 | 不能用 add 做汇编函数名，改用 int_add |
| 用宏映射保持接口 | #define add(a,b) int_add(a,b)，main.c不用改 |
| 启用 MASM | 必须勾选生成自定义里的 masm |
| 项类型必须改 | add.asm 项类型改为 Microsoft Macro Assembler |
| 配置类型必须是静态库 | StaffAdd 和 OutsourceSub 都要是 .lib |
| 平台统一为 Win32 | 三个项目都要是 Win32，不能混用 x64 |
| 预编译头关闭 | 三个项目都关闭预编译头 |
