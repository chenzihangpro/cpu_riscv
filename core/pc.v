`include "define.v"

module pc(
    clk,
    rst,
    jump_flag,
    jump_addr,
    hold_flag,          //流水线暂停标志
    jtag_rst_flag,
    
    pc_out
);

    input wire clk;
    input wire rst;
    
    input wire jump_flag;
    input wire[`INSTR_ADDR_BUS] jump_addr;
    input wire[`HOLD_FLAG_BUS] hold_flag;
    input wire jtag_rst_flag;
    
    output reg[`INSTR_ADDR_BUS] pc_out;
    
    always@(posedge clk) begin
        if(rst == `RST_ENA || jtag_rst_flag == 1)begin  //复位操作
            pc <= `CPU_RST_ADDR;
        end else if(jump_flag == `JUMP_ENA)begin        //分支跳转
            pc_out <= jump_addr;
        end else if(hold_flag >= `HOLD_PC)begin         //流水线暂停
            pc_out <= pc_out;
        end else begin                                  //一般情况执行pc+4
            pc_out <= pc_out + 4'h4;
        end
    end

endmodule