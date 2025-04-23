`include "defines.v"
// 控制模块
// 发出跳转、暂停流水线信号
module ctrl(

    rst,
    jump_flag_i,
    jump_addr_i,
    hold_flag_ex,
    hold_flag_lib,
    jtag_halt_flag,
    hold_flag_clint,
    hold_flag_o,
    jump_flag_o,
    jump_addr_o

    );

    input wire rst,

    // 来自执行模块
    input wire jump_flag_i,
    input wire[`INSTR_ADDR_BUS] jump_addr_i,
    input wire hold_flag_ex,

    // 来自总线模块
    input wire hold_flag_rib,

    // 来自jtag模块
    input wire jtag_halt_flag,

    // 来自CSR中断管理，仲裁模块
    input wire hold_flag_clint,

    output reg[`HOLD_FLAG_BUS] hold_flag,

    // 发往PC寄存器
    output reg jump_flag_o,
    output reg[`INSTR_ADDR_BUS] jump_addr_o


    always @ (*) begin
        jump_addr_o = jump_addr_i;
        jump_flag_o = jump_flag_i;
        // 默认不暂停
        hold_flag_o = `HOLD_NONE;
        // 按优先级处理不同模块的请求
        if (jump_flag_i == `JUMP_ENA || hold_flag_ex == `HOLD_ENA || hold_flag_clint == `HOLD_ENA) begin
            // 暂停整条流水线
            hold_flag_o = `HOLD_ID;
        end else if (hold_flag_lib == `HOLD_ENA) begin
            // 暂停PC，即取指地址不变
            hold_flag_o = `HOLD_PC;
        end else if (jtag_halt_flag == `HOLD_ENA) begin
            // 暂停整条流水线
            hold_flag_o = `HOLD_ID;
        end else begin
            hold_flag_o = `HOLD_NONE;
        end
    end

endmodule