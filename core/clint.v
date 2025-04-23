`include "defines.v"


// core local interruptor module
// 核心中断管理、仲裁模块
module clint(

    clk,
    rst,
    int_flag,
    instr,
    instr_addr_i,
    jump_flag,
    jump_addr,
    hold_flag_i,
    data_i,
    csr_mtvec,
    csr_mepc,
    csr_mstatus,
    global_int_en,
    hold_flag_o,
    we,
    waddr,
    raddr,
    data_o,
    int_addr,
    int_assert

    );

    input wire clk,
    input wire rst,

    //来自核心core
    input wire[`INT_BUS] int_flag,         // 中断输入信号

    //来自译码模块
    input wire[`INSTR_BUS] instr,             // 指令内容
    input wire[`INSTR_ADDR_BUS] instr_addr_i,    // 指令地址

    //来自执行模块
    input wire jump_flag,
    input wire[`INSTR_ADDR_BUS] jump_addr,

    //来自控制模块
    input wire[`HOLD_FLAG_BUS] hold_flag_i,  // 流水线暂停标志

    //来自CSR中断控制，仲裁模块
    input wire[`REG_BUS] data_i,              // CSR寄存器输入数据
    input wire[`REG_BUS] csr_mtvec,           // mtvec寄存器
    input wire[`REG_BUS] csr_mepc,            // mepc寄存器
    input wire[`REG_BUS] csr_mstatus,         // mstatus寄存器

    input wire global_int_en,              // 全局中断使能标志

    // to ctrl
    output wire hold_flag_o,                 // 流水线暂停标志

    // to csr_reg
    output reg we,                         // 写CSR寄存器标志
    output reg[`MEM_ADDR_BUS] waddr,         // 写CSR寄存器地址
    output reg[`MEM_ADDR_BUS] raddr,         // 读CSR寄存器地址
    output reg[`REG_BUS] data_o,              // 写CSR寄存器数据

    // to ex
    output reg[`INSTR_ADDR_BUS] int_addr,     // 中断入口地址
    output reg int_assert                  // 中断标志

    // 中断状态定义
    localparam S_INT_IDLE            = 4'b0001;
    localparam S_INT_SYNC_ASSERT     = 4'b0010;
    localparam S_INT_ASYNC_ASSERT    = 4'b0100;
    localparam S_INT_MRET            = 4'b1000;

    // 写CSR寄存器状态定义
    localparam S_CSR_IDLE            = 5'b00001;
    localparam S_CSR_MSTATUS         = 5'b00010;
    localparam S_CSR_MEPC            = 5'b00100;
    localparam S_CSR_MSTATUS_MRET    = 5'b01000;
    localparam S_CSR_MCAUSE          = 5'b10000;

    reg[3:0] int_state;
    reg[4:0] csr_state;
    reg[`INSTR_ADDR_BUS] instr_addr;
    reg[31:0] cause;


    assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? `HOLD_ENA: `HOLD_DISA;


    // 中断仲裁逻辑
    always @ (*) begin
        if (rst == `RST_ENA) begin
            int_state = S_INT_IDLE;
        end else begin
            if (int_flag != `INT_NONE && global_int_en == `TRUE) begin
                int_state = S_INT_ASYNC_ASSERT;
            end else if (instr == `INST_MRET) begin
                int_state = S_INT_MRET;
            end else begin
                int_state = S_INT_IDLE;
            end
        end
    end

    // 写CSR寄存器状态切换
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            csr_state <= S_CSR_IDLE;
            cause <= `ZERO_WORD;
            instr_addr <= `ZERO_WORD;
        end else begin
            case (csr_state)
                S_CSR_IDLE: begin
                    // 同步中断
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        // 在中断处理函数里会将中断返回地址加4
                        if (jump_flag == `JUMP_ENA) begin
                            instr_addr <= jump_addr - 4'h4;
                        end else begin
                            instr_addr <= instr_addr_i;
                        end
                        case (instr)
                            `INST_ECALL: begin
                                cause <= 32'd11;
                            end
                            `INST_EBREAK: begin
                                cause <= 32'd3;
                            end
                            default: begin
                                cause <= 32'd10;
                            end
                        endcase
                    // 异步中断
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // 定时器中断
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        if (jump_flag == `JUMP_ENA) begin
                            instr_addr <= jump_addr;
                        end else begin
                            instr_addr <= instr_addr_i;
                        end
                    // 中断返回
                    end else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                S_CSR_MCAUSE: begin
                    csr_state <= S_CSR_IDLE;
                end
                S_CSR_MSTATUS_MRET: begin
                    csr_state <= S_CSR_IDLE;
                end
                default: begin
                    csr_state <= S_CSR_IDLE;
                end
            endcase
        end
    end

    // 发出中断信号前，先写几个CSR寄存器
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            we <= `WR_DISA;
            waddr <= `ZERO_WORD;
            data_o <= `ZERO_WORD;
        end else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                S_CSR_MEPC: begin
                    we <= `WR_ENA;
                    waddr <= {20'h0, `CSR_MEPC};
                    data_o <= instr_addr;
                end
                // 写中断产生的原因
                S_CSR_MCAUSE: begin
                    we <= `WR_ENA;
                    waddr <= {20'h0, `CSR_MCAUSE};
                    data_o <= cause;
                end
                // 关闭全局中断
                S_CSR_MSTATUS: begin
                    we <= `WR_ENA;
                    waddr <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    we <= `WR_ENA;
                    waddr <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    we <= `WR_DISA;
                    waddr <= `ZERO_WORD;
                    data_o <= `ZERO_WORD;
                end
            endcase
        end
    end

    // 发出中断信号给ex模块
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            int_assert <= `INT_DEASSERT;
            int_addr <= `ZERO_WORD;
        end else begin
            case (csr_state)
                // 发出中断进入信号.写完mcause寄存器才能发
                S_CSR_MCAUSE: begin
                    int_assert <= `INT_ASSERT;
                    int_addr <= csr_mtvec;
                end
                // 发出中断返回信号
                S_CSR_MSTATUS_MRET: begin
                    int_assert <= `INT_ASSERT;
                    int_addr <= csr_mepc;
                end
                default: begin
                    int_assert <= `INT_DEASSERT;
                    int_addr <= `ZERO_WORD;
                end
            endcase
        end
    end

endmodule