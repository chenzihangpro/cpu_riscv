`include "defines.v"

//在取指与译码间打一拍
module if_id(
    clk,
    rst,
    instr_i,
    instr_addr_i,
    hold_flag,
    int_flag_i,
    int_flag_o,
    instr_o,
    instr_addr_o
);
    input wire clk;
    input wire rst;
    
    input wire[`INSTR_BUS] instr_i;
    input wire[`INSTR_ADDR_BUS] instr_addr_i;
    
    input wire[`HOLD_FLAG_BUS] hold_flag;
    
    input wire[`INT_FLAG_BUS] int_flag_i;       //中断信号
    output wire[`INT_FLAG_BUS] int_flag_o;
    
    output wire[`INSTR_BUS] instr_o;
    output wire[`INSTR_ADDR_BUS] instr_addr_o;
    
    wire hold_en = (hold_flag >= `HOLD_IF);
    
    //处理指令
    wire[`INSTR_BUS] instr;
    gen_pipe_dff #(32) instr_ff(clk,rst,hold_en,`INSTR_NO_OPERATION,instr_i,instr);
    assign instr_o = instr;
    
    //处理指令地址
    wire[`INSTR_ADDR_BUS] instr_addr;
    gen_pipe_dff #(32) instr_addr_ff(clk,rst,hold_en,`ZERO_WORD,instr_addr_i,instr_addr);
    assign instr_addr_o = instr_addr;
    
    //处理中断信号
    wire[`INT_FLAG_BUS] int_flag;
    gen_pipe_dff #(32) int_ff(clk,rst,hold_en,`INT_NONE,int_flag_o,int_flag);
    assign int_flag_o = int_flag;
    
endmodule