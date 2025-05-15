module miniRV_SoC (
    input  logic         fpga_rst,   // High active
    input  logic         fpga_clk,

    output logic         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output logic [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output               debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output logic [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output logic [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
);
    // 时钟信号直接传递
    wire cpu_clk = fpga_clk;
    
    // 需要的接口信号 
    wire over;            // 测试是否完成信号  
    wire succ;            // 测试是否成功信号
    wire halted_ind;      // jtag是否已经halt住CPU信号
    
    // 暂时不使用的信号置为默认值
    wire uart_debug_pin = 1'b0;  // 串口下载使能引脚
    wire uart_tx_pin;            // UART发送引脚
    wire uart_rx_pin = 1'b1;     // UART接收引脚
    wire [1:0] gpio;             // GPIO引脚
    
    // JTAG接口暂时不使用
    wire jtag_TCK = 1'b0;
    wire jtag_TMS = 1'b0;
    wire jtag_TDI = 1'b0;
    wire jtag_TDO;
    
    // SPI接口暂时不使用
    wire spi_miso = 1'b0;
    wire spi_mosi;
    wire spi_ss;
    wire spi_clk;
    
    // 实例化原始tinyriscv_soc_top
    tinyriscv_soc_top u_tinyriscv_soc (
        .clk(cpu_clk),
        .rst(~fpga_rst),  // 注意符号取反，原设计用低电平复位
        
        .over(over),
        .succ(succ),
        .halted_ind(halted_ind),
        
        .uart_debug_pin(uart_debug_pin),
        .uart_tx_pin(uart_tx_pin),
        .uart_rx_pin(uart_rx_pin),
        .gpio(gpio),
        
        .jtag_TCK(jtag_TCK),
        .jtag_TMS(jtag_TMS),
        .jtag_TDI(jtag_TDI),
        .jtag_TDO(jtag_TDO),
        
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_ss(spi_ss),
        .spi_clk(spi_clk)
    );
    
    // 连接调试输出接口到tinyriscv内部的写回阶段信号
    assign debug_wb_have_inst = 1'b1;  // 流水线CPU一直有指令在写回阶段
    assign debug_wb_pc = u_tinyriscv_soc.u_tinyriscv.mw_inst_addr_o; // 写回阶段的PC
    assign debug_wb_ena = u_tinyriscv_soc.u_tinyriscv.wb_reg_we_o;   // 写回阶段的寄存器写使能
    assign debug_wb_reg = u_tinyriscv_soc.u_tinyriscv.wb_reg_waddr_o; // 写回阶段的寄存器地址
    assign debug_wb_value = u_tinyriscv_soc.u_tinyriscv.wb_reg_wdata_o; // 写回阶段的寄存器数据
    
    // 为了满足模板要求而保留的接口，实际不使用
    wire [31:0] unused_data;
    
    IROM Mem_IROM (
        .a          (14'b0),
        .spo        (unused_data)
    );

    DRAM Mem_DRAM (
        .clk        (cpu_clk),
        .a          (14'b0),
        .spo        (),
        .we         (1'b0),
        .d          (32'b0)
    );

endmodule 