`include "defines.v"

module common_regs(
    clk,
    rst,
    wr_flag,
    wr_addr,
    wr_data,
    jtag_wr_flag,
    jtag_addr,
    jtag_wr_data,
    rd_addr1,
    rd_data1,
    rd_addr2,
    rd_data2,
    jtag_rd_data
);
    input wire clk;
    input wire rst;
    
    //执行模块产生
    input wire wr_flag;
    input wire[`REG_ADDR_BUS] wr_addr;
    input wire[`REG_BUS] wr_data;
    
    //jtag模块产生
    input wire jtag_wr_flag;
    input wire[`REG_ADDR_BUS] jtag_addr; //jtag读或写地址
    input wire[`REG_BUS] jtag_wr_data;
    
    //译码模块产生
    input wire[`REG_ADDR_BUS] rd_addr1;
    input wire[`REG_ADDR_BUS] rd_addr2;
    
    //送往译码模块
    output reg[`REG_BUS] rd_data1;
    output reg[`REG_BUS] rd_data2;
    //送往jtag模块
    output reg[`REG_BUS] jtag_rd_data;
    
    reg[`REG_BUS] regs[0:`REG_NUM-1];
    
    //写操作
    always@(posedge clk)begin
        if(rst == `RST_DISA)begin
            //优先进行执行模块的写操作
            if((wr_flag == `WR_ENA) && (wr_addr != `ZERO_REG))begin
                regs[wr_addr] <= wr_data;
            end else if((jtag_wr_flag == `WR_ENA) && (jtag_addr != `ZERO_REG))begin
                regs[jtag_addr] <= jtag_wr_data;
            end
        end
    end
    
    //rd1读操作
    always@(*)begin
        if(rd_addr1 == `ZERO_REG)begin
            rd_data1 = `ZERO_WORD;
        //读地址等于写地址时直接返回写的数据
        end else if(rd_addr1 == wr_addr && wr_flag ==`WR_ENA)begin
            rd_data1 = wr_data;
        end else begin
            rd_data1 = regs[rd_addr1];
        end
    end
    
    //rd2读操作
    always@(*)begin
        if(rd_addr2 == `ZERO_REG)begin
            rd_data2 = `ZERO_WORD;
        //读地址等于写地址时直接返回写的数据
        end else if(rd_addr2 == wr_addr && wr_flag ==`WR_ENA)begin
            rd_data2 = wr_data;
        end else begin
            rd_data2 = regs[rd_addr2];
        end
    end
    
    //jtag读操作
    always@(*)begin
        if(jtag_addr == `ZERO_REG)begin
            jtag_rd_data = `ZERO_WORD;
        //读地址等于写地址时直接返回写的数据
        end else if(jtag_addr == wr_addr && wr_flag ==`WR_ENA)begin
            jtag_rd_data = wr_data;
        end else begin
            jtag_rd_data = regs[jtag_addr];
        end
    end

endmodule