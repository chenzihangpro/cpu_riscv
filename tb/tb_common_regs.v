`include "test_defines.v"
`include "../rtl/core/defines.v"

module common_regs_tb;
    // 信号声明
    reg clk;
    reg rst;
    reg wr_i;
    reg [`REG_ADDR_BUS] waddr_i;
    reg [`REG_BUS] wdata_i;
    reg jtag_wr_i;
    reg [`REG_ADDR_BUS] jtag_addr_i;
    reg [`REG_BUS] jtag_data_i;
    reg [`REG_ADDR_BUS] raddr1_i;
    reg [`REG_ADDR_BUS] raddr2_i;
    wire [`REG_BUS] rdata1_o;
    wire [`REG_BUS] rdata2_o;
    wire [`REG_BUS] jtag_data_o;
    
    // 实例化被测模块
    common_regs u_regs(
        .clk(clk),
        .rst(rst),
        .wr_i(wr_i),
        .waddr_i(waddr_i),
        .wdata_i(wdata_i),
        .jtag_wr_i(jtag_wr_i),
        .jtag_addr_i(jtag_addr_i),
        .jtag_data_i(jtag_data_i),
        .raddr1_i(raddr1_i),
        .raddr2_i(raddr2_i),
        .rdata1_o(rdata1_o),
        .rdata2_o(rdata2_o),
        .jtag_data_o(jtag_data_o)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #(`CLK_PERIOD/2) clk = ~clk;
    end
    
    // 测试序列
    initial begin
        // 初始化
        rst = `RST_ENA;
        wr_i = `WR_DISA;
        waddr_i = 0;
        wdata_i = 0;
        jtag_wr_i = `WR_DISA;
        jtag_addr_i = 0;
        jtag_data_i = 0;
        raddr1_i = 0;
        raddr2_i = 0;
        
        // 复位
        #20;
        rst = `RST_DISA;
        #20;
        
        // 测试1: 基本读写
        waddr_i = 5;
        wdata_i = 32'h12345678;
        wr_i = `WR_ENA;
        #10;
        wr_i = `WR_DISA;
        raddr1_i = 5;
        #10;
        if(rdata1_o == 32'h12345678)
            $display("测试1通过: 写入和读取寄存器r5成功");
        else
            $error("测试1失败: 预期r5=%h, 实际=%h", 32'h12345678, rdata1_o);
        
        // 测试2: 写后读转发
        waddr_i = 6;
        wdata_i = 32'hABCDEF01;
        wr_i = `WR_ENA;
        raddr1_i = 6;
        #1; // 在时钟边沿之前检查
        if(rdata1_o == 32'hABCDEF01)
            $display("测试2通过: 写后读转发成功");
        else
            $error("测试2失败: 预期转发值=%h, 实际=%h", 32'hABCDEF01, rdata1_o);
        
        // 测试3: x0寄存器恒为0
        waddr_i = 0;
        wdata_i = 32'h12345678;
        wr_i = `WR_ENA;
        #10;
        wr_i = `WR_DISA;
        raddr1_i = 0;
        #10;
        if(rdata1_o == 32'h0)
            $display("测试3通过: x0寄存器恒为0");
        else
            $error("测试3失败: x0寄存器值=%h, 应为0", rdata1_o);
        
        // 测试4: JTAG接口读写
        jtag_addr_i = 10;
        jtag_data_i = 32'h55AA55AA;
        jtag_wr_i = `WR_ENA;
        #10;
        jtag_wr_i = `WR_DISA;
        raddr1_i = 10;
        #10;
        if(rdata1_o == 32'h55AA55AA)
            $display("测试4通过: JTAG写寄存器成功");
        else
            $error("测试4失败: 预期r10=%h, 实际=%h", 32'h55AA55AA, rdata1_o);
        
        #100;
        $display("寄存器测试完成");
        $finish;
    end
endmodule