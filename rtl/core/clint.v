`include "defines.v"

// core local interruptor module
// 核心中断管理、仲裁模块
module clint (
    input  wire               clk,
    input  wire               rst,

    // 来自 core 和流水线
    input  wire [`INT_BUS]    int_flag,         // 外部中断信号
    input  wire [`INSTR_BUS]  instr,            // 当前指令
    input  wire [`INSTR_ADDR_BUS] instr_addr_i, // 当前指令地址
    input  wire               jump_flag,        // EX 级跳转标志
    input  wire [`INSTR_ADDR_BUS] jump_addr,    // EX 级跳转地址
    input  wire [`HOLD_FLAG_BUS] hold_flag_i,   // CTRL 级暂停标志

    // 来自 CSR 寄存器
    input  wire [`REG_BUS]    csr_mtvec,        // mtvec
    input  wire [`REG_BUS]    csr_mepc,         // mepc
    input  wire [`REG_BUS]    csr_mstatus,      // mstatus
    input  wire               global_int_en,    // 全局中断使能

    // 输出到 CTRL
    output wire               hold_flag_o,      // 发往流水线暂停信号
    // 输出到 CSR 寄存器
    output reg                we,               // 写 CSR 使能
    output reg [`MEM_ADDR_BUS] waddr,           // 写 CSR 地址
    output reg [`MEM_ADDR_BUS] raddr,           // 读 CSR 地址（保留或扩展使用）
    output reg [`REG_BUS]     data_o,           // 写 CSR 数据
    // 输出到 EX 级
    output reg [`INSTR_ADDR_BUS] int_addr,      // 中断跳转地址
    output reg                int_assert        // 中断标志
);

//—— 中断状态定义（one-hot） ——//
localparam S_INT_IDLE         = 4'b0001;
localparam S_INT_SYNC_ASSERT  = 4'b0010;
localparam S_INT_ASYNC_ASSERT = 4'b0100;
localparam S_INT_MRET         = 4'b1000;
reg [3:0] int_state;

//—— CSR 写状态定义（one-hot） ——//
localparam S_CSR_IDLE            = 5'b00001;
localparam S_CSR_MSTATUS         = 5'b00010;
localparam S_CSR_MEPC            = 5'b00100;
localparam S_CSR_MSTATUS_MRET    = 5'b01000;
localparam S_CSR_MCAUSE          = 5'b10000;
reg [4:0] csr_state;

// 保存中断返回地址和原因
reg [`INSTR_ADDR_BUS] saved_mepc;
reg [31:0] cause;

// 控制流水线暂停：外部暂停或内部中断序列进行中
assign hold_flag_o = (hold_flag_i == `HOLD_ENA)
                   || (int_state != S_INT_IDLE)
                   || (csr_state != S_CSR_IDLE)
                     ? `HOLD_ENA : `HOLD_DISA;

//三段式状态机

//中断仲裁
always @(*) begin
    // 默认状态
    int_state = S_INT_IDLE;
    
    if (rst == `RST_ENA) begin
        int_state = S_INT_IDLE;
    end 
    // 确保ECALL和EBREAK指令比较正确，使用完整的32位比较
    else if (instr == 32'h00000073 || instr == 32'h00100073) begin
        int_state = S_INT_SYNC_ASSERT;
        $display("CLINT: Detected ECALL/EBREAK: %h", instr);  // 调试输出
    end 
    else if (int_flag != `INT_NONE && global_int_en == `TRUE) begin
        int_state = S_INT_ASYNC_ASSERT;
    end 
    else if (instr == `INSTR_MRET) begin
        int_state = S_INT_MRET;
    end
end

//—— CSR 写状态机（时序逻辑） ——//
always @(posedge clk) begin
    if (rst == `RST_ENA) begin
        csr_state    <= S_CSR_IDLE;
        saved_mepc   <= `ZERO_WORD;
        cause        <= `ZERO_WORD;
    end else begin
        case (csr_state)
            S_CSR_IDLE: begin
                if (int_state == S_INT_SYNC_ASSERT) begin
                    // 保存当前PC作为返回地址，对于同步异常，需要精确保存PC
                    csr_state  <= S_CSR_MEPC;
                    // 非跳转指令，直接使用当前PC；跳转指令，使用减4后的PC
                    saved_mepc <= (jump_flag == `JUMP_ENA) ? (jump_addr)
                                                           : instr_addr_i;
                    $display("CLINT: Saving MEPC = %h for ECALL", saved_mepc);  // 调试输出
                    
                    case (instr)
                        32'h00000073:  cause <= 32'd11;  // ECALL
                        32'h00100073:  cause <= 32'd3;   // EBREAK
                        default:       cause <= 32'd10;  // 未定义指令异常
                    endcase
                end else if (int_state == S_INT_ASYNC_ASSERT) begin
                    // 异步中断：保存PC作为返回地址
                    csr_state  <= S_CSR_MEPC;
                    saved_mepc <= instr_addr_i;
                    cause      <= 32'h80000004;  // 定时器中断
                end else if (int_state == S_INT_MRET) begin
                    // MRET：恢复mstatus
                    csr_state <= S_CSR_MSTATUS_MRET;
                end
            end
            S_CSR_MEPC:         csr_state <= S_CSR_MSTATUS;
            S_CSR_MSTATUS:      csr_state <= S_CSR_MCAUSE;
            S_CSR_MCAUSE:       csr_state <= S_CSR_IDLE;
            S_CSR_MSTATUS_MRET: csr_state <= S_CSR_IDLE;
            default:            csr_state <= S_CSR_IDLE;
        endcase
    end
end

//—— 写 CSR & 发起中断（时序逻辑） ——//
always @(posedge clk) begin
    // 默认清零
    we         <= `WR_DISA;
    waddr      <= `ZERO_WORD;
    raddr      <= `ZERO_WORD;
    data_o     <= `ZERO_WORD;
    int_assert <= `INT_NONE;
    int_addr   <= `ZERO_WORD;

    if (rst != `RST_ENA) begin
        case (csr_state)
            S_CSR_MEPC: begin
                we    <= `WR_ENA;
                waddr <= {20'b0, `CSR_MEPC};
                data_o<= saved_mepc;
            end
            S_CSR_MSTATUS: begin
                we    <= `WR_ENA;
                waddr <= {20'b0, `CSR_MSTATUS};
                // 清除 MIE 位
                data_o<= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
            end
            S_CSR_MCAUSE: begin
                we    <= `WR_ENA;
                waddr <= {20'b0, `CSR_MCAUSE};
                data_o<= cause;
            end
            S_CSR_MSTATUS_MRET: begin
                we    <= `WR_ENA;
                waddr <= {20'b0, `CSR_MSTATUS};
                // 恢复 MIE 位
                data_o<= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
            end
            default: ;
        endcase
        // 写完 MCAUSE 后，发起中断跳转
        if (csr_state == S_CSR_MCAUSE) begin
            int_assert <= `INT_ASSERT;
            int_addr   <= csr_mtvec;
        // 写完 MSTATUS_MRET 后，发起返回跳转
        end else if (csr_state == S_CSR_MSTATUS_MRET) begin
            int_assert <= `INT_ASSERT;
            int_addr   <= csr_mepc;
        end
    end
end

endmodule
