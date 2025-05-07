`include "defines.v"

// CSR 寄存器模块
module csr_reg(
    input  wire              clk,
    input  wire              rst,
    // 来自 EX 阶段写操作
    input  wire              we,
    input  wire [`MEM_ADDR_BUS] raddr,
    input  wire [`MEM_ADDR_BUS] waddr,
    input  wire [`REG_BUS]      data_i,
    // 来自 CLINT 写操作
    input  wire              clint_we,
    input  wire [`MEM_ADDR_BUS] clint_raddr,
    input  wire [`MEM_ADDR_BUS] clint_waddr,
    input  wire [`REG_BUS]      clint_data_i,
    // 输出：全局中断使能
    output wire              global_int_en,
    // 发往 CLINT 的读数据 & CSR 快照
    output reg  [`REG_BUS]      clint_data_o,
    output wire [`REG_BUS]      clint_csr_mtvec,
    output wire [`REG_BUS]      clint_csr_mepc,
    output wire [`REG_BUS]      clint_csr_mstatus,
    // 发往 EX 阶段的读数据
    output reg  [`REG_BUS]      data_o
);

    // CSR 寄存器组声明
    reg [`DOUBLE_REG_BUS] cycle;
    reg [`REG_BUS]         mtvec, mcause, mepc, mie, mstatus, mscratch;

    // 全局中断使能：取 mstatus[3]
    assign global_int_en      = mstatus[3];
    assign clint_csr_mtvec    = mtvec;
    assign clint_csr_mepc     = mepc;
    assign clint_csr_mstatus  = mstatus;

    //—— 循环计数，复位后清零 ——//
    always @(posedge clk) begin
        if (rst == `RST_ENA)
            cycle <= {`ZERO_WORD, `ZERO_WORD};
        else
            cycle <= cycle + 1'b1;
    end

    //—— 写操作（EX 优先，CLINT 其次） ——//
    always @(posedge clk) begin
        if (rst == `RST_ENA) begin
            // 复位时清空所有 CSR
            mtvec    <= `ZERO_WORD;
            mcause   <= `ZERO_WORD;
            mepc     <= `ZERO_WORD;
            mie      <= `ZERO_WORD;
            mstatus  <= `ZERO_WORD;
            mscratch <= `ZERO_WORD;
        end
        else begin
            if (we == `WR_ENA) begin
                case (waddr[11:0])
                    `CSR_MTVEC:    mtvec    <= data_i;
                    `CSR_MCAUSE:   mcause   <= data_i;
                    `CSR_MEPC:     mepc     <= data_i;
                    `CSR_MIE:      mie      <= data_i;
                    `CSR_MSTATUS:  mstatus  <= data_i;
                    `CSR_MSCRATCH: mscratch <= data_i;
                    default: ;
                endcase
            end
            else if (clint_we == `WR_ENA) begin
                case (clint_waddr[11:0])
                    `CSR_MTVEC:    mtvec    <= clint_data_i;
                    `CSR_MCAUSE:   mcause   <= clint_data_i;
                    `CSR_MEPC:     mepc     <= clint_data_i;
                    `CSR_MIE:      mie      <= clint_data_i;
                    `CSR_MSTATUS:  mstatus  <= clint_data_i;
                    `CSR_MSCRATCH: mscratch <= clint_data_i;
                    default: ;
                endcase
            end
        end
    end

    //—— EX 模块读 CSR ——//
    always @(*) begin
        // 写后转发
        if (we == `WR_ENA && waddr[11:0] == raddr[11:0])
            data_o = data_i;
        else begin
            case (raddr[11:0])
                `CSR_CYCLE:   data_o = cycle[31:0];
                `CSR_CYCLEH:  data_o = cycle[63:32];
                `CSR_MTVEC:   data_o = mtvec;
                `CSR_MCAUSE:  data_o = mcause;
                `CSR_MEPC:    data_o = mepc;
                `CSR_MIE:     data_o = mie;
                `CSR_MSTATUS: data_o = mstatus;
                `CSR_MSCRATCH:data_o = mscratch;
                default:      data_o = `ZERO_WORD;
            endcase
        end
    end

    //—— CLINT 模块读 CSR ——//
    always @(*) begin
        if (clint_we == `WR_ENA && clint_waddr[11:0] == clint_raddr[11:0])
            clint_data_o = clint_data_i;
        else begin
            case (clint_raddr[11:0])
                `CSR_CYCLE:   clint_data_o = cycle[31:0];
                `CSR_CYCLEH:  clint_data_o = cycle[63:32];
                `CSR_MTVEC:   clint_data_o = mtvec;
                `CSR_MCAUSE:  clint_data_o = mcause;
                `CSR_MEPC:    clint_data_o = mepc;
                `CSR_MIE:     clint_data_o = mie;
                `CSR_MSTATUS: clint_data_o = mstatus;
                `CSR_MSCRATCH:clint_data_o = mscratch;
                default:      clint_data_o = `ZERO_WORD;
            endcase
        end
    end

endmodule
