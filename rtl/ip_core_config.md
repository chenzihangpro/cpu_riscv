# Vivado IP核配置指南 - 为TinyRISCV创建内存IP核

本文档介绍如何在Vivado中为TinyRISCV SoC配置Distributed Memory Generator IP核，以实现指令ROM和数据RAM。

## 1. IROM (指令ROM) 配置

1. **在Vivado中添加IP核**
   - 点击"IP Catalog"
   - 在搜索框中输入"Distributed Memory Generator"
   - 双击打开IP配置向导

2. **基本配置**
   - Component Name: `IROM`
   - Memory Type: 选择 `ROM`
   - Depth: 设置为 `16384` (64KB，按32位字计算)
   - Width: 设置为 `32` (与处理器数据总线宽度一致)
   - Memory Initialization:
     - 选择 `Load Init File`
     - 提供COE格式的ROM初始化文件

3. **地址信号配置**
   - 输入地址宽度将自动计算为14位 (可容纳16384个地址)

4. **端口配置**
   - 勾选 `Single Port ROM`
   - 选择需要的时钟极性 (默认上升沿)

5. **产生IP核**
   - 点击"Generate"生成IP核

## 2. DRAM (数据RAM) 配置

1. **在Vivado中添加IP核**
   - 点击"IP Catalog"
   - 在搜索框中输入"Distributed Memory Generator"
   - 双击打开IP配置向导

2. **基本配置**
   - Component Name: `DRAM`
   - Memory Type: 选择 `Single Port RAM`
   - Depth: 设置为 `16384` (64KB，按32位字计算)
   - Width: 设置为 `32` (与处理器数据总线宽度一致)

3. **Byte Write选项配置**
   - 勾选 `Byte Write Enable` (重要！用于支持字节写入)
   - Port A Width: 保持为 `32`
   - Port A Write Enable: 保持为 `1`

4. **生成输出选项**
   - 确保 `Register Outputs` 选项根据设计要求设置

5. **端口配置**
   - 信号极性: 使用默认上升沿配置

6. **产生IP核**
   - 点击"Generate"生成IP核

## 3. 接口说明

### IROM接口

```verilog
IROM your_instance_name (
  .a(a),      // input wire [13 : 0] a - 地址，连接到addr_i[15:2]
  .spo(spo)   // output wire [31 : 0] spo - 数据输出
);
```

### DRAM接口

```verilog
DRAM your_instance_name (
  .a(a),          // input wire [13 : 0] a - 地址，连接到addr_i[15:2]
  .d(d),          // input wire [31 : 0] d - 写入数据
  .clk(clk),      // input wire clk - 时钟
  .we(we),        // input wire we - 写使能
  .we_mask(we_mask), // input wire [3 : 0] we_mask - 字节写使能，连接到sel_i
  .spo(spo)       // output wire [31 : 0] spo - 数据输出
);
```

## 4. 注意事项

1. **适配处理器地址映射**:
   - 处理器使用字节寻址，而IP核使用字寻址
   - 使用地址的[15:2]位连接到IP核的地址输入端口，支持64KB内存

2. **字节选择处理**:
   - RAM模块中将sel_i直接连接到IP核的we_mask端口，用于字节级写入控制

3. **复位处理**:
   - 在wrapper模块中添加了复位逻辑，确保复位时输出零值

4. **时钟域**:
   - 确保所有使用内存的部分都在同一时钟域中，避免时序问题 