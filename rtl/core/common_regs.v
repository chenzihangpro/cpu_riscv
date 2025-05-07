`include "defines.v"
module common_regs(
    input  wire              clk,
    input  wire              rst,
    // 写端口
    input  wire              wr_i,
    input  wire[`REG_ADDR_BUS] waddr_i,
    input  wire[`REG_BUS]      wdata_i,
    // JTAG写端口
    input  wire              jtag_wr_i,
    input  wire[`REG_ADDR_BUS] jtag_addr_i,
    input  wire[`REG_BUS]      jtag_data_i,
    // 读端口
    input  wire[`REG_ADDR_BUS] raddr1_i,
    input  wire[`REG_ADDR_BUS] raddr2_i,
    output reg [`REG_BUS]      rdata1_o,
    output reg [`REG_BUS]      rdata2_o,
    // JTAG读端口
    output reg [`REG_BUS]      jtag_data_o
);
    // 通用寄存器堆，x0硬连0
    reg[`REG_BUS] regs[0:`REG_NUM-1];
    
    integer i;
    
    // 同步写
    always @(posedge clk) begin
        if (rst == `RST_ENA) begin
            for (i = 0; i < `REG_NUM; i = i + 1) begin
                regs[i] <= `ZERO_WORD;
            end
        end
        else begin
            if (wr_i == `WR_ENA && waddr_i != `ZERO_REG)
                regs[waddr_i] <= wdata_i;
            else if (jtag_wr_i == `WR_ENA && jtag_addr_i != `ZERO_REG)
                regs[jtag_addr_i] <= jtag_data_i;
        end
    end
    
    // 读端口1 - 修改写后读逻辑
    always @(*) begin
        if (raddr1_i == `ZERO_REG) begin
            rdata1_o = `ZERO_WORD;
        end 
        // 写后读冲突检测 - 优先使用当前正在写入的数据
        else if (wr_i == `WR_ENA && raddr1_i == waddr_i) begin
            rdata1_o = wdata_i;
        end 
        // JTAG写冲突检测
        else if (jtag_wr_i == `WR_ENA && raddr1_i == jtag_addr_i) begin
            rdata1_o = jtag_data_i;
        end 
        else begin
            rdata1_o = regs[raddr1_i];
        end
    end
    
    // 读端口2 - 类似的写后读处理
    always @(*) begin
        if (raddr2_i == `ZERO_REG) begin
            rdata2_o = `ZERO_WORD;
        end 
        else if (wr_i == `WR_ENA && raddr2_i == waddr_i) begin
            rdata2_o = wdata_i;
        end 
        else if (jtag_wr_i == `WR_ENA && raddr2_i == jtag_addr_i) begin
            rdata2_o = jtag_data_i;
        end 
        else begin
            rdata2_o = regs[raddr2_i];
        end
    end
    
    // JTAG读端口 - 同样处理写后读
    always @(*) begin
        if (jtag_addr_i == `ZERO_REG) begin
            jtag_data_o = `ZERO_WORD;
        end 
        else if (wr_i == `WR_ENA && jtag_addr_i == waddr_i) begin
            jtag_data_o = wdata_i;
        end 
        else if (jtag_wr_i == `WR_ENA) begin
            jtag_data_o = jtag_data_i;
        end 
        else begin
            jtag_data_o = regs[jtag_addr_i];
        end
    end
endmodule