`include "defines.v"

// CSR寄存器模块
module csr_reg(

    clk,
    rst,
    we,                        
    raddr,
    waddr,
    data_i,          
    clint_we,
    clint_raddr, 
    clint_waddr,
    clint_data_i,
    global_int_en,
    clint_data_o,
    clint_csr_mtvec,
    clint_csr_mepc,
    clint_csr_mstatus,
    data_o

    );

    input wire clk,
    input wire rst,

    //来自执行模块
    input wire we,                        // ex模块写寄存器标志
    input wire[`MEM_ADDR_BUS] raddr,        // ex模块读寄存器地址
    input wire[`MEM_ADDR_BUS] waddr,        // ex模块写寄存器地址
    input wire[`REG_BUS] data_i,             // ex模块写寄存器数据

    //来自中断管理，仲裁模块
    input wire clint_we,                  // clint模块写寄存器标志
    input wire[`MEM_ADDR_BUS] clint_raddr,  // clint模块读寄存器地址
    input wire[`MEM_ADDR_BUS] clint_waddr,  // clint模块写寄存器地址
    input wire[`REG_BUS] clint_data_i,       // clint模块写寄存器数据

    output wire global_int_en,            // 全局中断使能标志

    //发往中断管理，仲裁模块
    output reg[`REG_BUS] clint_data_o,       // clint模块读寄存器数据
    output wire[`REG_BUS] clint_csr_mtvec,   // mtvec
    output wire[`REG_BUS] clint_csr_mepc,    // mepc
    output wire[`REG_BUS] clint_csr_mstatus, // mstatus

    // to ex
    output reg[`REG_BUS] data_o              // ex模块读寄存器数据

    reg[`DOUBLE_REG_BUS] cycle;
    reg[`REG_BUS] mtvec;
    reg[`REG_BUS] mcause;
    reg[`REG_BUS] mepc;
    reg[`REG_BUS] mie;
    reg[`REG_BUS] mstatus;
    reg[`REG_BUS] mscratch;

    assign global_int_en = (mstatus[3] == 1'b1)? `TRUE: `FALSE;

    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;

    // 循环计数器
    // 复位撤销后就一直计数
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            cycle <= {`ZERO_WORD, `ZERO_WORD};
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    // 写寄存器
    // 写寄存器操作
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            mtvec <= `ZERO_WORD;
            mcause <= `ZERO_WORD;
            mepc <= `ZERO_WORD;
            mie <= `ZERO_WORD;
            mstatus <= `ZERO_WORD;
            mscratch <= `ZERO_WORD;
        end else begin
            // 优先响应ex模块的写操作
            if (we == `WR_ENA) begin
                case (waddr[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= data_i;
                    end
                    `CSR_MIE: begin
                        mie <= data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= data_i;
                    end
                    default: begin

                    end
                endcase
            // clint模块写操作
            end else if (clint_we == `WR_ENA) begin
                case (clint_waddr[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= clint_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= clint_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= clint_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= clint_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= clint_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= clint_data_i;
                    end
                    default: begin

                    end
                endcase
            end
        end
    end

    // 读寄存器
    // ex模块读CSR寄存器
    always @ (*) begin
        if ((waddr[11:0] == raddr[11:0]) && (we == `WR_ENA)) begin
            data_o = data_i;
        end else begin
            case (raddr[11:0])
                `CSR_CYCLE: begin
                    data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    data_o = mcause;
                end
                `CSR_MEPC: begin
                    data_o = mepc;
                end
                `CSR_MIE: begin
                    data_o = mie;
                end
                `CSR_MSTATUS: begin
                    data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    data_o = mscratch;
                end
                default: begin
                    data_o = `ZERO_WORD;
                end
            endcase
        end
    end

    // 读寄存器
    // clint模块读CSR寄存器
    always @ (*) begin
        if ((clint_waddr[11:0] == clint_raddr[11:0]) && (clint_we == `WR_ENA)) begin
            clint_data_o = clint_data_i;
        end else begin
            case (clint_raddr_i[11:0])
                `CSR_CYCLE: begin
                    clint_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    clint_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    clint_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_data_o = mcause;
                end
                `CSR_MEPC: begin
                    clint_data_o = mepc;
                end
                `CSR_MIE: begin
                    clint_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    clint_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    clint_data_o = mscratch;
                end
                default: begin
                    clint_data_o = `ZERO_WORD;
                end
            endcase
        end
    end

endmodule
