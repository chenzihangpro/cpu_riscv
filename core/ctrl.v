`include "defines.v"
// 控制模块：生成跳转和流水线暂停信号
module ctrl(
    input  wire                  rst,
    // 来自执行阶段的跳转请求
    input  wire                  jump_flag_i,
    input  wire[`INSTR_ADDR_BUS] jump_addr_i,
    input  wire                  hold_flag_ex,   // EX 级暂停请求

    // 来自外设总线的暂停请求（例如 load/store 还没完成）
    input  wire                  hold_flag_rib,

    // 来自 JTAG 的暂停请求
    input  wire                  jtag_halt_flag,

    // 来自中断仲裁模块的暂停请求
    input  wire                  hold_flag_clint,

    // 输出到 IF/ID 级的暂停信号（3 位，用于决定是停 PC 还是 ID 级停）
    output reg [`HOLD_FLAG_BUS]  hold_flag_o,

    // 输出到 PC 寄存器的跳转控制
    output reg                   jump_flag_o,
    output reg [`INSTR_ADDR_BUS] jump_addr_o
);

    always @(*) begin
        // 默认无跳转、无暂停
        jump_flag_o = jump_flag_i;
        jump_addr_o = jump_addr_i;
        hold_flag_o = `HOLD_NONE;

        // 优先级：JTAG 停止 > EX 跳转/暂停 > CLINT 中断 > 总线暂停
        if (jtag_halt_flag == `HOLD_ENA) begin
            hold_flag_o = `HOLD_ID;
        end
        else if (jump_flag_i == `JUMP_ENA || hold_flag_ex == `HOLD_ENA) begin
            // EX 级请求跳转或自身停顿都要停整个流水线
            hold_flag_o = `HOLD_ID;
        end
        else if (hold_flag_clint == `HOLD_ENA) begin
            // CLINT 中断处理也需要停整个流水线
            hold_flag_o = `HOLD_ID;
        end
        else if (hold_flag_rib == `HOLD_ENA) begin
            // 总线还没响应，PC 保持不变
            hold_flag_o = `HOLD_PC;
        end
        // else 保持 `HOLD_NONE`
    end

endmodule
