`include "defines.v"

module wb(
    input  wire                   rst,
    
    // 来自 MEM/WB 流水线寄存器
    input  wire [`INSTR_BUS]       instr_i,
    input  wire [`INSTR_ADDR_BUS]  instr_addr_i,
    input  wire                   reg_wr_i,
    input  wire [`REG_ADDR_BUS]    reg_waddr_i,
    input  wire [`REG_BUS]         reg_wdata_i,
    input  wire                   csr_wr_i,
    input  wire [`MEM_ADDR_BUS]    csr_waddr_i,
    input  wire [`REG_BUS]         csr_wdata_i,
    
    // 输出到寄存器堆和CSR寄存器
    output wire                   reg_wr_o,
    output wire [`REG_ADDR_BUS]    reg_waddr_o,
    output wire [`REG_BUS]         reg_wdata_o,
    output wire                   csr_wr_o,
    output wire [`MEM_ADDR_BUS]    csr_waddr_o,
    output wire [`REG_BUS]         csr_wdata_o
);

    // 写回阶段主要是将数据传递给寄存器堆和CSR寄存器
    // 简单的穿透逻辑
    
    assign reg_wr_o = reg_wr_i;
    assign reg_waddr_o = reg_waddr_i;
    assign reg_wdata_o = reg_wdata_i;
    
    assign csr_wr_o = csr_wr_i;
    assign csr_waddr_o = csr_waddr_i;
    assign csr_wdata_o = csr_wdata_i;

endmodule