`include "defines.v"

module common_regs(
    input  wire              clk,
    input  wire              rst,
    // 普通写端口
    input  wire              wr_flag,
    input  wire[`REG_ADDR_BUS] wr_addr,
    input  wire[`REG_BUS]      wr_data,
    // JTAG 写端口
    input  wire              jtag_wr_flag,
    input  wire[`REG_ADDR_BUS] jtag_addr,
    input  wire[`REG_BUS]      jtag_wr_data,
    // 译码读端口
    input  wire[`REG_ADDR_BUS] rd_addr1,
    input  wire[`REG_ADDR_BUS] rd_addr2,
    output reg [`REG_BUS]      rd_data1,
    output reg [`REG_BUS]      rd_data2,
    // JTAG 读端口
    output reg [`REG_BUS]      jtag_rd_data
);

    // 通用寄存器堆，x0 硬连零
    reg[`REG_BUS] regs[0:`REG_NUM-1];

    // 同步写：reset 期间禁止写，之后优先普通写，再JTAG写
    always @(posedge clk) begin
        if (rst == `RST_DISA) begin
            if (wr_flag == `WR_ENA && wr_addr != `ZERO_REG)
                regs[wr_addr] <= wr_data;
            else if (jtag_wr_flag == `WR_ENA && jtag_addr != `ZERO_REG)
                regs[jtag_addr] <= jtag_wr_data;
        end
    end

    // 读端口 1：支持写后转发（普通写优先于 JTAG 写）
    always @(*) begin
        if (rd_addr1 == `ZERO_REG) begin
            rd_data1 = `ZERO_WORD;
        end else if (wr_flag == `WR_ENA && rd_addr1 == wr_addr)begin
            rd_data1 = wr_data;
        end else if (jtag_wr_flag == `WR_ENA && rd_addr1 == jtag_addr)begin
            rd_data1 = jtag_wr_data;
        end else begin
            rd_data1 = regs[rd_addr1];
        end
    end

    // 读端口 2：同理
    always @(*) begin
        if (rd_addr2 == `ZERO_REG) begin
            rd_data2 = `ZERO_WORD;
        end else if (wr_flag == `WR_ENA && rd_addr2 == wr_addr)begin
            rd_data2 = wr_data;
        end else if (jtag_wr_flag == `WR_ENA && rd_addr2 == jtag_addr)begin
            rd_data2 = jtag_wr_data;
        end else begin
            rd_data2 = regs[rd_addr2];
        end
    end

    // JTAG 读端口：同理
    always @(*) begin
        if (jtag_addr == `ZERO_REG)begin
            jtag_rd_data = `ZERO_WORD;
        end else if (jtag_wr_flag == `WR_ENA && jtag_addr == wr_addr)begin
            jtag_rd_data = wr_data;
        end else if (jtag_wr_flag == `WR_ENA && jtag_addr == jtag_addr)begin
            jtag_rd_data = jtag_wr_data;
        end else begin
            jtag_rd_data = regs[jtag_addr];
        end
    end

endmodule
