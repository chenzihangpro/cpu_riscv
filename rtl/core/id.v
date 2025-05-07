`include "defines.v"

//译码模块
module id(
    rst,
    instr_i,              //指令内容
    instr_addr_i,         //指令地址
    reg1_rdata_i,
    reg2_rdata_i,
    csr_rdata_i,
    jump_flag_i,          //跳转标志
    ex_reg_wr_i,          // 来自EX阶段的前递信号
    ex_reg_waddr_i,       
    ex_reg_wdata_i,
    ex_opcode_i,
    mem_reg_wr_i,         // 来自MEM阶段的前递信号
    mem_reg_waddr_i,
    mem_reg_wdata_i,
    wb_reg_wr_i,          // 来自WB阶段的前递信号
    wb_reg_waddr_i,
    wb_reg_wdata_i,
    reg1_raddr_o,         //读
    reg2_raddr_o,
    csr_raddr_o,          //读CSR寄存器地址
    op1_o,                //操作数1
    op2_o,                //操作数2
    op1_jump_o,           //跳转操作数1
    op2_jump_o,           //跳转操作数2
    instr_o,              //指令内容
    instr_addr_o,         //指令地址
    reg1_rdata_o,         //通用寄存器1数据
    reg2_rdata_o,         //通用寄存器2数据
    reg_wr_o,             //写通用寄存器标志
    reg_waddr_o,          //写通用寄存器地址
    csr_wr_o,             //CSR寄存器写标志
    csr_rdata_o,          //CSR寄存器数据
    csr_waddr_o,          //写CSR寄存器地址
    load_hazard_o         //是否需要暂停流水线（加载冒险）
);
    input wire rst;
    
    input wire[`INSTR_BUS] instr_i;
    input wire[`INSTR_ADDR_BUS] instr_addr_i;
    input wire[`REG_BUS] reg1_rdata_i;
    input wire[`REG_BUS] reg2_rdata_i;
    input wire[`REG_BUS] csr_rdata_i;
    
    input  wire jump_flag_i;
    input  wire                    ex_reg_wr_i;
    input  wire [`REG_ADDR_BUS]    ex_reg_waddr_i;
    input  wire [`REG_BUS]         ex_reg_wdata_i;
    input  wire [6:0]              ex_opcode_i;
    input  wire                    mem_reg_wr_i;
    input  wire [`REG_ADDR_BUS]    mem_reg_waddr_i;
    input  wire [`REG_BUS]         mem_reg_wdata_i;
    input  wire                    wb_reg_wr_i;
    input  wire [`REG_ADDR_BUS]    wb_reg_waddr_i;
    input  wire [`REG_BUS]         wb_reg_wdata_i;
    
    output reg[`REG_ADDR_BUS] reg1_raddr_o;
    output reg[`REG_ADDR_BUS] reg2_raddr_o;
    output reg[`MEM_ADDR_BUS] csr_raddr_o;
    
    output reg[`MEM_ADDR_BUS] op1_o;
    output reg[`MEM_ADDR_BUS] op2_o;
    
    output reg[`MEM_ADDR_BUS] op1_jump_o;
    output reg[`MEM_ADDR_BUS] op2_jump_o;
    
    output reg[`INSTR_BUS] instr_o;
    output reg[`INSTR_ADDR_BUS] instr_addr_o;
    
    output reg[`REG_BUS] reg1_rdata_o;
    output reg[`REG_BUS] reg2_rdata_o;
    
    output reg reg_wr_o;
    output reg[`REG_ADDR_BUS] reg_waddr_o;
    output reg csr_wr_o;
    output reg[`REG_BUS] csr_rdata_o;
    output reg[`MEM_ADDR_BUS] csr_waddr_o;
    
    output reg                    load_hazard_o;
    
    //将输入指令划分为携带信息的段
    wire[6:0] opcode = instr_i[6:0];
    wire[2:0] func3 = instr_i[14:12];
    wire[6:0] func7 = instr_i[31:25];
    wire[4:0] rd = instr_i[11:7];    //目标寄存器
    wire[4:0] rs1 = instr_i[19:15];  //源寄存器1
    wire[4:0] rs2 = instr_i[24:20];  //源寄存器2
    
    // 寄存器地址信号 - 先解码出寄存器地址
    always @(*) begin
        if (rst == `RST_ENA) begin
            reg1_raddr_o = `ZERO_REG;
            reg2_raddr_o = `ZERO_REG;
        end else begin
            case(opcode)
                `INSTR_TYPE_I: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = `ZERO_REG;
                end
                `INSTR_TYPE_R: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = rs2;
                end
                `INSTR_TYPE_L: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = `ZERO_REG;
                end
                `INSTR_TYPE_S: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = rs2;
                end
                `INSTR_TYPE_B: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = rs2;
                end
                `INSTR_JAL: begin
                    reg1_raddr_o = `ZERO_REG;
                    reg2_raddr_o = `ZERO_REG;
                end
                `INSTR_JALR: begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = `ZERO_REG;
                end
                `INSTR_LUI, `INSTR_AUIPC, `INSTR_NOP_OP, `INSTR_FENCE: begin
                    reg1_raddr_o = `ZERO_REG;
                    reg2_raddr_o = `ZERO_REG;
                end
                `INSTR_CSR: begin
                    case(func3)
                        `INSTR_CSRRW, `INSTR_CSRRS, `INSTR_CSRRC: begin
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = `ZERO_REG;
                        end
                        default: begin
                            reg1_raddr_o = `ZERO_REG;
                            reg2_raddr_o = `ZERO_REG;
                        end
                    endcase
                end
                default: begin
                    reg1_raddr_o = `ZERO_REG;
                    reg2_raddr_o = `ZERO_REG;
                end
            endcase
        end
    end
    
    // 前递数据处理 - 基于已解码的寄存器地址应用前递
    reg[`REG_BUS] reg1_data;
    reg[`REG_BUS] reg2_data;
    
    always @(*) begin
        if (rst == `RST_ENA) begin
            reg1_data = `ZERO_WORD;
        end else if (reg1_raddr_o == `ZERO_REG) begin
            reg1_data = `ZERO_WORD;
        end else if (ex_reg_wr_i == `WR_ENA && ex_reg_waddr_i == reg1_raddr_o) begin
            reg1_data = ex_reg_wdata_i;
            $display("ID前递: reg%d使用EX结果 %h", reg1_raddr_o, ex_reg_wdata_i);
        end else if (mem_reg_wr_i == `WR_ENA && mem_reg_waddr_i == reg1_raddr_o) begin
            reg1_data = mem_reg_wdata_i;
            $display("ID前递: reg%d使用MEM结果 %h", reg1_raddr_o, mem_reg_wdata_i);
        end else if (wb_reg_wr_i == `WR_ENA && wb_reg_waddr_i == reg1_raddr_o) begin
            reg1_data = wb_reg_wdata_i;
            $display("ID前递: reg%d使用WB结果 %h", reg1_raddr_o, wb_reg_wdata_i);
        end else begin
            reg1_data = reg1_rdata_i;
        end
    end
    
    always @(*) begin
        if (rst == `RST_ENA) begin
            reg2_data = `ZERO_WORD;
        end else if (reg2_raddr_o == `ZERO_REG) begin
            reg2_data = `ZERO_WORD;
        end else if (ex_reg_wr_i == `WR_ENA && ex_reg_waddr_i == reg2_raddr_o) begin
            reg2_data = ex_reg_wdata_i;
            $display("ID前递: reg%d使用EX结果 %h", reg2_raddr_o, ex_reg_wdata_i);
        end else if (mem_reg_wr_i == `WR_ENA && mem_reg_waddr_i == reg2_raddr_o) begin
            reg2_data = mem_reg_wdata_i;
            $display("ID前递: reg%d使用MEM结果 %h", reg2_raddr_o, mem_reg_wdata_i);
        end else if (wb_reg_wr_i == `WR_ENA && wb_reg_waddr_i == reg2_raddr_o) begin
            reg2_data = wb_reg_wdata_i;
            $display("ID前递: reg%d使用WB结果 %h", reg2_raddr_o, wb_reg_wdata_i);
        end else begin
            reg2_data = reg2_rdata_i;
        end
    end
    
    // 加载冒险检测逻辑
    always @(*) begin
        if (rst == `RST_ENA) begin
            load_hazard_o = `LOAD_HAZARD_DISA;
        end else if (ex_opcode_i == `INSTR_TYPE_L && ex_reg_wr_i == `WR_ENA) begin
            if ((reg1_raddr_o == ex_reg_waddr_i && reg1_raddr_o != `ZERO_REG) || 
                (reg2_raddr_o == ex_reg_waddr_i && reg2_raddr_o != `ZERO_REG)) begin
                load_hazard_o = `LOAD_HAZARD_ENA;
                $display("ID阶段: 检测到加载冒险, ex_waddr=%d", ex_reg_waddr_i);
            end else begin
                load_hazard_o = `LOAD_HAZARD_DISA;
            end
        end else begin
            load_hazard_o = `LOAD_HAZARD_DISA;
        end
    end
    
    // 完整译码逻辑 - 使用前递后的寄存器值
    always @(*) begin
        if (rst == `RST_ENA) begin
            instr_o = `INSTR_NO_OPERATION;
            instr_addr_o = `ZERO_WORD;
            csr_rdata_o = `ZERO_WORD;
            csr_raddr_o = `ZERO_WORD;
            csr_waddr_o = `ZERO_WORD;
            csr_wr_o = `WR_DISA;
            op1_o = `ZERO_WORD;
            op2_o = `ZERO_WORD;
            op1_jump_o = `ZERO_WORD;
            op2_jump_o = `ZERO_WORD;
            reg_wr_o = `WR_DISA;
            reg_waddr_o = `ZERO_REG;
            reg1_rdata_o = `ZERO_WORD;
            reg2_rdata_o = `ZERO_WORD;
        end else begin
            instr_o = instr_i;
            instr_addr_o = instr_addr_i;
            csr_rdata_o = csr_rdata_i;
            reg1_rdata_o = reg1_data;
            reg2_rdata_o = reg2_data;
            
            case(opcode)
                //I型
                `INSTR_TYPE_I:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    case(func3)
                        `INSTR_ADDI,`INSTR_SLTI,`INSTR_SLTIU,`INSTR_XORI,`INSTR_ORI,`INSTR_ANDI,`INSTR_SLLI,`INSTR_SRI:begin
                            reg_wr_o = `WR_ENA;
                            reg_waddr_o = rd;
                            op1_o = reg1_data;
                            op2_o = {{20{instr_i[31]}},instr_i[31:20]};
                        end
                        default:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = `ZERO_WORD;
                            op2_o = `ZERO_WORD;
                        end
                    endcase
                end
                //R型
                `INSTR_TYPE_R:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    if((func7 == 7'b0000000) || (func7 == 7'b0100000))begin
                        case(func3)
                            `INSTR_ADD_SUB,`INSTR_SLL,`INSTR_SLT,`INSTR_SLTU,`INSTR_XOR,`INSTR_SR,`INSTR_OR,`INSTR_AND:begin
                                reg_wr_o = `WR_ENA;
                                reg_waddr_o = rd;
                                op1_o = reg1_data;
                                op2_o = reg2_data;
                            end
                            default:begin
                                reg_wr_o = `WR_DISA;
                                reg_waddr_o = `ZERO_REG;
                                op1_o = `ZERO_WORD;
                                op2_o = `ZERO_WORD;
                            end
                        endcase
                    end else begin
                        reg_wr_o = `WR_DISA;
                        reg_waddr_o = `ZERO_REG;
                        op1_o = `ZERO_WORD;
                        op2_o = `ZERO_WORD;
                    end
                end
                //L型
                `INSTR_TYPE_L:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    case(func3)
                        `INSTR_LB,`INSTR_LH,`INSTR_LW,`INSTR_LBU,`INSTR_LHU:begin
                            reg_wr_o = `WR_ENA;
                            reg_waddr_o = rd;
                            op1_o = reg1_data;
                            op2_o = {{20{instr_i[31]}},instr_i[31:20]};
                        end
                        default:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = `ZERO_WORD;
                            op2_o = `ZERO_WORD;
                        end
                    endcase
                end
                //S型:仅sb,sh,sw
                `INSTR_TYPE_S:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    case(func3)
                        `INSTR_SB,`INSTR_SH,`INSTR_SW:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = reg1_data;
                            op2_o = {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]};
                        end
                        default:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = `ZERO_WORD;
                            op2_o = `ZERO_WORD;
                        end
                    endcase
                end
                //B型:beq,bne,blt,bge,bltu,bgeu
                `INSTR_TYPE_B:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    
                    case(func3)
                        `INSTR_BEQ,`INSTR_BNE,`INSTR_BLT,`INSTR_BGE,`INSTR_BLTU,`INSTR_BGEU:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = reg1_data;
                            op2_o = reg2_data;
                            op1_jump_o = instr_addr_i;
                            op2_jump_o = {{20{instr_i[31]}},instr_i[7],instr_i[30:25],instr_i[11:8],1'b0};
                        end
                        default:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            op1_o = `ZERO_WORD;
                            op2_o = `ZERO_WORD;
                            op1_jump_o = `ZERO_WORD;
                            op2_jump_o = `ZERO_WORD;
                        end
                    endcase
                end
                //jal指令
                `INSTR_JAL:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    
                    reg_wr_o = `WR_ENA;
                    reg_waddr_o = rd;
                    op1_o = instr_addr_i;
                    op2_o = 32'h4;
                    op1_jump_o = instr_addr_i;
                    op2_jump_o = {{12{instr_i[31]}},instr_i[19:12],instr_i[20],instr_i[30:21],1'b0};
                end
                //jalr指令
                `INSTR_JALR:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    
                    reg_wr_o = `WR_ENA;
                    reg_waddr_o = rd;
                    op1_o = instr_addr_i;
                    op2_o = 32'h4;
                    op1_jump_o = reg1_data;
                    op2_jump_o = {{20{instr_i[31]}},instr_i[31:20]};
                end
                //lui指令
                `INSTR_LUI:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    reg_wr_o = `WR_ENA;
                    reg_waddr_o = rd;
                    op1_o = {instr_i[31:12],12'b0};
                    op2_o = `ZERO_WORD;
                end
                //auipc指令
                `INSTR_AUIPC:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    reg_wr_o = `WR_ENA;
                    reg_waddr_o = rd;
                    op1_o = instr_addr_i;
                    op2_o = {instr_i[31:12],12'b0};
                end
                //NOP指令,不执行任何操作，仅做PC递增
                `INSTR_NOP_OP:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    reg_wr_o = `WR_DISA;
                    reg_waddr_o = `ZERO_REG;
                    op1_o = `ZERO_WORD;
                    op2_o = `ZERO_WORD;
                end
                //fence指令
                `INSTR_FENCE:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    
                    reg_wr_o = `WR_DISA;
                    reg_waddr_o = `ZERO_REG;
                    op1_o = `ZERO_WORD;
                    op2_o = `ZERO_WORD;
                    op1_jump_o = instr_addr_i;
                    op2_jump_o = 32'h4;
                end
                //CSR操作指令
                `INSTR_CSR:begin
                    csr_raddr_o = {20'h0,instr_i[31:20]};
                    csr_waddr_o = {20'h0,instr_i[31:20]};
                    op1_o = `ZERO_WORD;
                    op2_o = `ZERO_WORD;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    case(func3)
                        `INSTR_CSRRW,`INSTR_CSRRS,`INSTR_CSRRC:begin
                            reg_wr_o = `WR_ENA;
                            reg_waddr_o = rd;
                            csr_wr_o = `WR_ENA;
                        end
                        `INSTR_CSRRWI,`INSTR_CSRRSI,`INSTR_CSRRCI:begin
                            reg_wr_o = `WR_ENA;
                            reg_waddr_o = rd;
                            csr_wr_o = `WR_ENA;
                        end
                        default:begin
                            reg_wr_o = `WR_DISA;
                            reg_waddr_o = `ZERO_REG;
                            csr_wr_o = `WR_DISA;
                        end
                    endcase
                end
                //ebreak（环境断点）和ecall（环境调用）指令，译码环境无输出
                default:begin
                    csr_raddr_o = `ZERO_WORD;
                    csr_waddr_o = `ZERO_WORD;
                    csr_wr_o = `WR_DISA;
                    op1_jump_o = `ZERO_WORD;
                    op2_jump_o = `ZERO_WORD;
                    
                    reg_wr_o = `WR_DISA;
                    reg_waddr_o = `ZERO_REG;
                    op1_o = `ZERO_WORD;
                    op2_o = `ZERO_WORD;
                end
            endcase
        end
    end
endmodule