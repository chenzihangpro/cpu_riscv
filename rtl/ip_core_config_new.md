# Vivado IP核配置指南 - myCPU模板接口

本文档介绍如何在Vivado中为TinyRISCV配置适用于myCPU模板接口的IROM和DRAM IP核。

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

3. **生成输出选项**
   - 确保 `Register Outputs` 选项根据设计要求设置

4. **端口配置**
   - 信号极性: 使用默认上升沿配置

5. **产生IP核**
   - 点击"Generate"生成IP核

## 3. 接口说明

配置的IP核将用于以下接口连接：

### IROM接口
```verilog
IROM u_irom(
  .a(irom_adr),      // input wire [13 : 0] a - 地址，来自myCPU模块
  .spo(irom_dat)     // output wire [31 : 0] spo - 数据输出，连接到myCPU模块
);
```

### DRAM接口
```verilog
DRAM u_dram(
  .a(dram_adr),      // input wire [13 : 0] a - 地址，来自myCPU模块
  .d(dram_dat_w),    // input wire [31 : 0] d - 写入数据，来自myCPU模块
  .clk(clk),         // input wire clk - 时钟
  .we(dram_we),      // input wire we - 写使能，来自myCPU模块
  .spo(dram_dat_r)   // output wire [31 : 0] spo - 数据输出，连接到myCPU模块
);
```

## 4. 字节写入处理

在新的接口中，DRAM IP核本身没有字节使能端口，但myCPU模块提供了dram_sel[3:0]信号。这是因为：

1. DRAM IP核自身不支持字节级写入
2. TinyRISCV处理器核内部的mem模块已经实现了字节写入功能
3. 字节选择信号(dram_sel)仍然需要通过myCPU模块传递给SOC顶层模块
4. 如果需要真正实现字节级写入，可以考虑以下两种方案：
   - 由CPU内部进行读-修改-写操作（当前实现）
   - 在SOC顶层添加额外逻辑，根据dram_sel信号进行数据合并

在当前实现中，虽然dram_sel信号被传递到SOC顶层，但实际的字节写入处理仍在TinyRISCV处理器核内部进行。

## 5. 注意事项

1. **地址映射**:
   - TinyRISCV使用字节寻址，而IP核使用字寻址
   - myCPU模块内部将地址的[15:2]位映射到IROM和DRAM的地址输入端口

2. **数据宽度**:
   - 确保IP核配置的宽度为32位
   - 确保地址宽度设置为14位以支持64KB(16384个32位字)

3. **字节写入**:
   - TinyRISCV的mem模块内部处理字节选择逻辑
   - 对于读操作，根据字节选择信号处理读出的数据
   - 对于写操作，根据字节选择信号修改要写入的数据

4. **测试程序**:
   - 确保测试程序符合myCPU模板的测试约定
   - 通常在程序达到特定PC值时检查特定寄存器内容来判断测试成功与否 