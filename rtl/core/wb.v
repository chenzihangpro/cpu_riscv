`include "defines.v"

module wb(
    input  wire                   rst,
    
    // ���� MEM/WB ��ˮ�߼Ĵ���
    input  wire [`INSTR_BUS]       instr_i,
    input  wire [`INSTR_ADDR_BUS]  instr_addr_i,
    input  wire                   reg_wr_i,
    input  wire [`REG_ADDR_BUS]    reg_waddr_i,
    input  wire [`REG_BUS]         reg_wdata_i,
    input  wire                   csr_wr_i,
    input  wire [`MEM_ADDR_BUS]    csr_waddr_i,
    input  wire [`REG_BUS]         csr_wdata_i,
    
    // ������Ĵ����Ѻ�CSR�Ĵ���
    output wire                   reg_wr_o,
    output wire [`REG_ADDR_BUS]    reg_waddr_o,
    output wire [`REG_BUS]         reg_wdata_o,
    output wire                   csr_wr_o,
    output wire [`MEM_ADDR_BUS]    csr_waddr_o,
    output wire [`REG_BUS]         csr_wdata_o
);

    // д�ؽ׶���Ҫ�ǽ����ݴ��ݸ��Ĵ����Ѻ�CSR�Ĵ���
    // �򵥵Ĵ�͸�߼�
    
    assign reg_wr_o = reg_wr_i;
    assign reg_waddr_o = reg_waddr_i;
    assign reg_wdata_o = reg_wdata_i;
    
    assign csr_wr_o = csr_wr_i;
    assign csr_waddr_o = csr_waddr_i;
    assign csr_wdata_o = csr_wdata_i;

endmodule