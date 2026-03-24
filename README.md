# FPGA Vivado 工程导入

## 概述
使用ALINX `AX7Z020B`开发板与ALINX `AN9238` 模块
连接：AN9238----J21----AX7Z020B
      ADG708----J20----AX7Z020B
本脚本用于自动导入 Vivado FPGA 工程 `SciFiDetector`，目标器件为 `xc7z020clg400-2`。

## 目录结构

克隆仓库后的目录结构：
```
/path/to/your_worksapce/             # Vivado工程目录
├── project_repository/           # 克隆的仓库目录（本文件夹）
│   ├── create_project.tcl       # 工程导入脚本
│   ├── sources_1/               # 源文件目录
│   │   ├── ip/                 # IP 核文件 (.xci)
│   │   ├── src/                # RTL 源码 (.v, .vh, .vhd, .vhdl)
│   │   └── bd/                 # Block Design 文件 (.bd, .tcl)
│   ├── constrs_1/               # 约束文件 (.xdc)
│   ├── sim_1/                   # 仿真文件
│   └── sdk/                     # SDK 工程目录
└── SciFiDetector/                # 生成的 Vivado 工程
```

## 使用方法

### 步骤一：克隆仓库

```bash
cd /path/to/your_worksapce
git clone <repository_url>
```

### 步骤二：导入工程

#### 方法一：Vivado Tcl Console

1. 打开 Vivado
2. 在 Tcl Console 中执行：
   ```tcl
   cd /path/to/your_worksapce/project_repository
   source ./create_project.tcl
   ```

#### 方法二：命令行模式

```bash
cd /path/to/your_worksapce/project_repository
vivado -mode batch -source create_project.tcl
```

## 脚本功能

| 功能 | 说明 |
|------|------|
| 工程导入 | 在克隆目录的上一级导入 Vivado 工程 |
| IP 导入 | 自动复制并添加 IP 核文件 |
| 源码导入 | 支持 Verilog/VHDL 源文件 |
| BD 处理 | 自动处理 Block Design 并生成 Wrapper |
| 约束导入 | 自动添加 XDC 约束文件 |
| 仿真导入 | 自动添加仿真文件 |

## 输出位置

执行脚本后，Vivado 工程将创建在克隆目录的上一级：
```
/path/to/your_worksapce/SciFiDetector/
```

# SDK 工程导入（旧版 SDK）

## 导入步骤

### 步骤一：启动 SDK

在 Vivado 中：
```
菜单栏 File → Launch SDK
```

### 步骤二：导入已有工程

在 SDK 中：
```
菜单栏 File → Import...
```
在弹出的对话框中：
1. 选择 **General → Existing Projects into Workspace**
2. 点击 **Next**
3. 选择 **Select root directory**，选择或填入 SDK 工程路径
4. 勾选需要导入的工程
5. 点击 **Finish**

