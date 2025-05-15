# TinyRISCV - 使用Vivado IP核的ROM和RAM实现

本仓库包含使用Vivado Distributed Memory Generator IP核实现ROM和RAM的TinyRISCV SoC代码。

## 文件说明

1. **rom_ip.v** - 使用Vivado IP核实现的ROM模块封装
2. **ram_ip.v** - 使用Vivado IP核实现的RAM模块封装
3. **ip_core_config.md** - Vivado中配置ROM和RAM IP核的详细指南

## 使用方法

1. 将rom_ip.v和ram_ip.v文件添加到您的工程中
2. 按照ip_core_config.md中的说明，在Vivado中创建IROM和DRAM IP核
3. 在工程中保持原有的接口连接不变，实现无缝替换

## 优势

1. **更高效的资源利用** - 使用FPGA内置的Block RAM或Distributed RAM资源
2. **更好的性能** - 优化的内存访问路径
3. **完全兼容** - 与原有接口完全兼容，无需修改其他代码

## 注意事项

1. 确保IP核配置与内存需求匹配（ROM和RAM均为64KB，16384个32位字）
2. 字节写入功能在DRAM IP核中需要通过Byte Write Enable选项支持
3. 地址映射需要注意字寻址和字节寻址的转换，使用addr_i[15:2]映射到IP核地址 