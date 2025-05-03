`include "define.v"

module pc(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  jump_flag,
    input  wire[`INSTR_ADDR_BUS] jump_addr,
    input  wire[`HOLD_FLAG_BUS]  hold_flag,
    input  wire                  jtag_rst_flag,
    output reg [`INSTR_ADDR_BUS] pc_out
);

    always @(posedge clk) begin
        if (rst == `RST_ENA || jtag_rst_flag) begin
            // 复位或 JTAG 重置，跳回初始地址
            pc_out <= `CPU_RST_ADDR;
        end
        else if (jump_flag == `JUMP_ENA) begin
            // 分支/跳转
            pc_out <= jump_addr;
        end
        else if (hold_flag < `HOLD_PC) begin
            // 非暂停状态——正常 PC += 4
            pc_out <= pc_out + 32'h4;
        end
        // else 保持不变（非阻塞赋值下会自动保留上一周期值）
    end

endmodule
