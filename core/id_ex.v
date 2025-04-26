`include "defines.v"

module id_ex(
    clk,
    rst,
    instr_i,
    instr_addr_i,
    reg_wr_i,
    reg_waddr_i,
    reg1_rdata_i,
    reg2_rdata_i,
    csr_wr_i,
    csr_waddr_i,
    csr_rdata_i,
    op1_i,
    op2_i,
    op1_jump_i,
    op2_jump_i,
    hold_flag_i,
    
    op1_o,
    op2_o,
    op1_jump_o,
    op2_jump_o,
    instr_o,
    instr_addr_o,
    reg_wr_o,
    reg_waddr_o,
    reg1_rdata_o,
    reg2_rdata_o,
    csr_wr_o,
    csr_waddr_o,
    csr_rdata_o
);
    input wire clk;
    input wire rst;
    input wire[`INSTR_ADDR_BUS] instr_addr_i;
    input wire[`INSTR_BUS] instr_i;
    input wire reg_wr_i;
    input wire[`REG_ADDR_BUS] reg_waddr_i;
    input wire[`REG_BUS] reg1_rdata_i;
    input wire[`REG_BUS] reg2_rdata_i;
    input wire csr_wr_i;
    input wire[`MEM_ADDR_BUS] csr_waddr_i;
    input wire[`REG_BUS] csr_rdata_i;
    input wire[`MEM_ADDR_BUS] op1_i;
    input wire[`MEM_ADDR_BUS] op2_i;
    input wire[`MEM_ADDR_BUS] op1_jump_i;
    input wire[`MEM_ADDR_BUS] op2_jump_i;
    input wire[`HOLD_FLAG_BUS] hold_flag_i;
    
    output wire[`MEM_ADDR_BUS] op1_o;
    output wire[`MEM_ADDR_BUS] op2_o;
    output wire[`MEM_ADDR_BUS] op1_jump_o;
    output wire[`MEM_ADDR_BUS] op2_jump_o;
    output wire[`INSTR_BUS] instr_o;
    output wire[`INSTR_ADDR_BUS] instr_addr_o;
    output wire reg_wr_o;
    output wire[`REG_ADDR_BUS] reg_waddr_o;
    output wire[`REG_BUS] reg1_rdata_o;
    output wire[`REG_BUS] reg2_rdata_o;
    output wire csr_wr_o;
    output wire[`MEM_ADDR_BUS] csr_waddr_o;
    output wire[`REG_BUS] csr_rdata_o;
    
    wire hold_en = (hold_flag_i >= `HOLD_ID);
    
    wire[`INSTR_BUS] instr;
    gen_pipe_dff #(32) instr_ff(clk, rst, hold_en, `INSTR_NOP, instr_i, instr);
    assign instr_o = instr;
    
    wire[`INSTR_ADDR_BUS] instr_addr;
    gen_pipe_dff #(32) instr_addr_ff(clk, rst, hold_en, `ZERO_WORD, instr_addr_i, instr_addr);
    assign instr_addr_o = instr_addr;
    
    wire reg_wr;
    gen_pipe_dff #(32) reg_wr_ff(clk, rst, hold_en, `WR_DISA, reg_wr_i, reg_wr);
    assign reg_wr_o = reg_wr;
    
    wire[`REG_ADDR_BUS] reg_waddr;
    gen_pipe_dff #(32) reg_waddr_ff(clk, rst, hold_en, `ZERO_REG, reg_waddr_i, reg_waddr);
    assign reg_waddr_o = reg_waddr;
    
    wire[`REG_BUS] reg1_rdata;
    gen_pipe_dff #(32) reg1_rdata_ff(clk, rst, hold_en, `ZERO_WORD, reg1_rdata_i,reg1_rdata);
    assign reg1_rdata_o = reg1_rdata;
    
    wire[`REG_BUS] reg2_rdata;
    gen_pipe_dff #(32) reg2_rdata_ff(clk, rst, hold_en, `ZERO_WORD, reg2_rdata_i,reg2_rdata);
    assign reg2_rdata_o = reg2_rdata;
    
    wire csr_wr;
    gen_pipe_dff #(32) csr_wr_ff(clk, rst, hold_en, `WR_DISA, csr_wr_i, csr_wr);
    assign csr_wr_o = csr_wr;
    
    //ÎªÊ²Ã´ÊÇZERO_WORD?
    wire[`REG_ADDR_BUS] csr_waddr;
    gen_pipe_dff #(32) csr_waddr_ff(clk, rst, hold_en, `ZERO_WORD, csr_waddr_i, csr_waddr);
    assign csr_waddr_o = csr_waddr;
    
    wire[`MEM_ADDR_BUS] op1;
    gen_pipe_dff #(32) op1_ff(clk, rst, hold_en, `ZERO_WORD, op1_i, op1);
    assign op1_o = op1;
    
    wire[`MEM_ADDR_BUS] op2;
    gen_pipe_dff #(32) op2_ff(clk, rst, hold_en, `ZERO_WORD, op2_i, op2);
    assign op2_o = op2;
    
    wire[`MEM_ADDR_BUS] op1_jump;
    gen_pipe_dff #(32) op1_jump_ff(clk, rst, hold_en, `ZERO_WORD, op1_jump_i, op1_jump);
    assign op1_jump_o = op1_jump;
    
    wire[`MEM_ADDR_BUS] op2_jump;
    gen_pipe_dff #(32) op2_jump_ff(clk, rst, hold_en, `ZERO_WORD, op2_jump_i, op2_jump);
    assign op2_jump_o = op2_jump;
    
endmodule