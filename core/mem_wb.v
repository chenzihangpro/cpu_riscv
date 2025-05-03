`include "defines.v"

module mem_wb(
    input  wire                  clk,
    input  wire                  rst,

    // 来自 MEM 级
    input  wire [`INSTR_BUS]       instr_i,
    input  wire [`INSTR_ADDR_BUS]  instr_addr_i,
    input  wire                   reg_wr_i,
    input  wire [`REG_ADDR_BUS]    reg_waddr_i,
    input  wire [`REG_BUS]         reg_wdata_i,
    input  wire                   csr_wr_i,
    input  wire [`MEM_ADDR_BUS]    csr_waddr_i,
    input  wire [`REG_BUS]         csr_wdata_i,
    input  wire [`HOLD_FLAG_BUS]   hold_flag_i,

    // 送到 WB 级
    output wire [`INSTR_BUS]       instr_o,
    output wire [`INSTR_ADDR_BUS]  instr_addr_o,
    output wire                   reg_wr_o,
    output wire [`REG_ADDR_BUS]    reg_waddr_o,
    output wire [`REG_BUS]         reg_wdata_o,
    output wire                   csr_wr_o,
    output wire [`MEM_ADDR_BUS]    csr_waddr_o,
    output wire [`REG_BUS]         csr_wdata_o
);

    // 什么时候要 flush（insert NOP / zero）到 WB 级？
    wire hold_en = (hold_flag_i >= `HOLD_ID);

    //—— Instr ——//
    gen_pipe_dff #(.DW(32)) instr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`INSTR_NO_OPERATION),
        .din     (instr_i),
        .qout    (instr_o)
    );

    //—— InstrAddr ——//
    gen_pipe_dff #(.DW(32)) addr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`ZERO_WORD),
        .din     (instr_addr_i),
        .qout    (instr_addr_o)
    );

    //—— reg_wr（1 bit）——//
    gen_pipe_dff #(.DW(1)) reg_wr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`WR_DISA),
        .din     (reg_wr_i),
        .qout    (reg_wr_o)
    );

    //—— reg_waddr（5 bits）——//
    gen_pipe_dff #(.DW(5)) reg_waddr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`ZERO_REG),
        .din     (reg_waddr_i),
        .qout    (reg_waddr_o)
    );

    //—— reg_wdata（32 bits）——//
    gen_pipe_dff #(.DW(32)) reg_wdata_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`ZERO_WORD),
        .din     (reg_wdata_i),
        .qout    (reg_wdata_o)
    );

    //—— csr_wr（1 bit）——//
    gen_pipe_dff #(.DW(1)) csr_wr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`WR_DISA),
        .din     (csr_wr_i),
        .qout    (csr_wr_o)
    );

    //—— csr_waddr（32 bits）——//
    gen_pipe_dff #(.DW(32)) csr_waddr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`ZERO_WORD),
        .din     (csr_waddr_i),
        .qout    (csr_waddr_o)
    );

    //—— csr_wdata（32 bits）——//
    gen_pipe_dff #(.DW(32)) csr_wdata_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (hold_en),
        .def_val (`ZERO_WORD),
        .din     (csr_wdata_i),
        .qout    (csr_wdata_o)
    );

endmodule