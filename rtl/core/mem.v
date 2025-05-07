`include "defines.v"

module mem(
    input  wire                   rst,
    
    // 来自 EX/MEM 流水线寄存器
    input  wire [`INSTR_BUS]       instr_i,
    input  wire [`INSTR_ADDR_BUS]  instr_addr_i,
    input  wire                   reg_wr_i,
    input  wire [`REG_ADDR_BUS]    reg_waddr_i,
    input  wire [`REG_BUS]         reg_wdata_i,
    input  wire                   csr_wr_i,
    input  wire [`MEM_ADDR_BUS]    csr_waddr_i,
    input  wire [`REG_BUS]         csr_wdata_i,
    input  wire [`MEM_ADDR_BUS]    mem_addr_i,
    input  wire                   mem_wr_i,
    input  wire [`MEM_BUS]         mem_wdata_i,
    input  wire                   mem_req_i,
    
    // 来自总线/内存的读取数据
    input  wire [`MEM_BUS]         mem_rdata_i,
    
    // 输出到总线/内存
    output reg  [`MEM_BUS]         mem_wdata_o,
    output reg  [`MEM_ADDR_BUS]    mem_addr_o,
    output wire                   mem_wr_o,
    output wire                   mem_req_o,
    
    // 输出到 MEM/WB 流水线寄存器
    output reg  [`INSTR_BUS]       instr_o,
    output reg  [`INSTR_ADDR_BUS]  instr_addr_o,
    output reg                    reg_wr_o,
    output reg  [`REG_ADDR_BUS]    reg_waddr_o,
    output reg  [`REG_BUS]         reg_wdata_o,
    output reg                    csr_wr_o,
    output reg  [`MEM_ADDR_BUS]    csr_waddr_o,
    output reg  [`REG_BUS]         csr_wdata_o,
    
    // 流水线控制信号
    output reg                    hold_flag_o
);

    // 指令解析
    wire [6:0] opcode = instr_i[6:0];
    wire [2:0] func3 = instr_i[14:12];
    
    // 内存读取相关信号
    wire [1:0] mem_addr_index = mem_addr_i[1:0];  // 内存地址低2位，用于字节选择
    
    // 直接转发内存访问请求
    assign mem_wr_o = mem_wr_i;
    assign mem_req_o = mem_req_i;
    
    // 默认不需要暂停流水线
    always @(*) begin
        hold_flag_o = `HOLD_DISA;
    end
    
    // 处理内存读写
    always @(*) begin
        // 默认值传递
        instr_o = instr_i;
        instr_addr_o = instr_addr_i;
        reg_wr_o = reg_wr_i;
        reg_waddr_o = reg_waddr_i;
        reg_wdata_o = reg_wdata_i;
        csr_wr_o = csr_wr_i;
        csr_waddr_o = csr_waddr_i;
        csr_wdata_o = csr_wdata_i;
        mem_addr_o = mem_addr_i;
        mem_wdata_o = mem_wdata_i;
        
        // 只处理内存加载指令的数据
        if (opcode == `INSTR_TYPE_L && mem_req_i == `RIB_REQ) begin
            case (func3)
                `INSTR_LB: begin  // 字节加载，符号扩展
                    case (mem_addr_index)
                        2'b00: reg_wdata_o = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                        2'b01: reg_wdata_o = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                        2'b10: reg_wdata_o = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                        2'b11: reg_wdata_o = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                    endcase
                end
                `INSTR_LH: begin  // 半字加载，符号扩展
                    case (mem_addr_index[1])
                        1'b0: reg_wdata_o = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                        1'b1: reg_wdata_o = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                    endcase
                end
                `INSTR_LW: begin  // 字加载
                    reg_wdata_o = mem_rdata_i;
                end
                `INSTR_LBU: begin  // 字节加载，无符号扩展
                    case (mem_addr_index)
                        2'b00: reg_wdata_o = {24'h0, mem_rdata_i[7:0]};
                        2'b01: reg_wdata_o = {24'h0, mem_rdata_i[15:8]};
                        2'b10: reg_wdata_o = {24'h0, mem_rdata_i[23:16]};
                        2'b11: reg_wdata_o = {24'h0, mem_rdata_i[31:24]};
                    endcase
                end
                `INSTR_LHU: begin  // 半字加载，无符号扩展
                    case (mem_addr_index[1])
                        1'b0: reg_wdata_o = {16'h0, mem_rdata_i[15:0]};
                        1'b1: reg_wdata_o = {16'h0, mem_rdata_i[31:16]};
                    endcase
                end
                default: begin
                    reg_wdata_o = reg_wdata_i;
                end
            endcase
        end
    end

endmodule