`include "defines.v"

module if_id(
    input  wire               clk,
    input  wire               rst,
    // 来自 IF 级的原始指令和 PC
    input  wire [`INSTR_BUS]       instr_i,
    input  wire [`INSTR_ADDR_BUS]  instr_addr_i,
    // 控制信号：当 hold_flag >= HOLD_IF 时，flush 本级为 NOP
    input  wire [`HOLD_FLAG_BUS]   hold_flag,
    // 中断/异常信号（8 位）
    input  wire [`INT_FLAG_BUS]    int_flag_i,

    // 送到 ID 级的输出
    output wire [`INSTR_BUS]       instr_o,
    output wire [`INSTR_ADDR_BUS]  instr_addr_o,
    output wire [`INT_FLAG_BUS]    int_flag_o
);

    // 当 hold_flag 表示 IF 级需要 flush 时，这个信号为 1
    wire flush_if = (hold_flag >= `HOLD_IF);

    // ———— 指令管线寄存器 ————
    gen_pipe_dff #(.DW(32)) instr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (flush_if),             // flush = 1 时输出 def_val
        .def_val (`INSTR_NO_OPERATION),  // flush 默认插入 NOP
        .din     (instr_i),
        .qout    (instr_o)
    );

    // ———— PC/地址管线寄存器 ————
    gen_pipe_dff #(.DW(32)) addr_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (flush_if),
        .def_val (`ZERO_WORD),           // flush 默认 0（或任意安全值）
        .din     (instr_addr_i),
        .qout    (instr_addr_o)
    );

    // ———— 中断标志管线寄存器 ————
    gen_pipe_dff #(.DW(8)) int_ff (
        .clk     (clk),
        .rst     (rst),
        .hold_en (flush_if),
        .def_val (`INT_NONE),            // flush 时清零中断
        .din     (int_flag_i),           // 正确挂到输入
        .qout    (int_flag_o)            // 正确驱动到输出
    );

endmodule



