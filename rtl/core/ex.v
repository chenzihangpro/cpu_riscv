`include "defines.v"

module ex(
    rst,
    instr_i,
    instr_addr_i,
    reg_wr_i,       //写通用寄存器标志信号
    reg_waddr_i,    //写通用寄存器地址
    reg1_rdata_i,   //通用寄存器1输入数据
    reg2_rdata_i,
    csr_wr_i,       //写CSR寄存器标志信号
    csr_waddr_i,
    csr_rdata_i,
    int_assert_i,   //中断发生标志
    int_addr_i,     //中断跳转地址
    op1_i,          //源操作数1
    op2_i,
    op1_jump_i,     //跳转操作数1
    op2_jump_i,
    
    mem_rdata_i,    //内存输入数据
    
    mem_wdata_o,    //写内存数据
    mem_raddr_o,    //读内存地址
    mem_waddr_o,    //写内存地址
    mem_wr_o,       //写内存标志信号
    mem_req_o,      //请求访问内存标志
    
    reg_wdata_o,    //写通用寄存器数据
    reg_wr_o,       //写通用寄存器标志信号
    reg_waddr_o,    //写通用寄存器地址
    
    csr_wdata_o,    //写CSR寄存器数据
    csr_wr_o,       //写CSR寄存器标志信号
    csr_waddr_o,    //写CSR寄存器地址
    
    hold_flag_o,    //暂停标志
    jump_flag_o,    //跳转标志
    jump_addr_o,    //跳转目标地址
    
    instr_o,        //传递指令信息到下一级
    instr_addr_o
);
    input wire rst;
    input wire[`INSTR_BUS] instr_i;
    input wire[`INSTR_ADDR_BUS] instr_addr_i;
    input wire[`REG_ADDR_BUS] reg_waddr_i;
    input wire reg_wr_i;
    input wire[`REG_BUS] reg1_rdata_i;
    input wire[`REG_BUS] reg2_rdata_i;
    input wire csr_wr_i;
    input wire[`MEM_ADDR_BUS] csr_waddr_i;
    input wire[`REG_BUS] csr_rdata_i;
    input wire int_assert_i;
    input wire[`INSTR_ADDR_BUS] int_addr_i;
    input wire[`MEM_ADDR_BUS] op1_i;
    input wire[`MEM_ADDR_BUS] op2_i;
    input wire[`MEM_ADDR_BUS] op1_jump_i;
    input wire[`MEM_ADDR_BUS] op2_jump_i;
    input wire[`MEM_BUS] mem_rdata_i;
    
    output reg[`MEM_BUS] mem_wdata_o;
    output reg[`MEM_ADDR_BUS] mem_raddr_o;
    output reg[`MEM_ADDR_BUS] mem_waddr_o;
    output wire mem_wr_o;
    output wire mem_req_o;
    output wire[`REG_BUS] reg_wdata_o;
    output wire reg_wr_o;
    output wire[`REG_ADDR_BUS] reg_waddr_o;
    output reg[`REG_BUS] csr_wdata_o;
    output wire csr_wr_o;
    output wire[`MEM_ADDR_BUS] csr_waddr_o;
    output wire hold_flag_o;
    output wire jump_flag_o;
    output wire[`INSTR_ADDR_BUS] jump_addr_o;

    output reg  [`INSTR_BUS]       instr_o;
    output reg  [`INSTR_ADDR_BUS]  instr_addr_o;
    
    wire[1:0] mem_raddr_index;      //内存读地址的低2位索引，决定读哪个字节
    wire[1:0] mem_waddr_index;
    wire[31:0] sr_shift;            //sra算术右移结果
    wire[31:0] sri_shift;           //srai立即数算术右移结果
    wire[31:0] sr_shift_mask;       //右移掩码，与右移结果位与清除无效位
    wire[31:0] sri_shift_mask;
    wire[31:0] op1_add_op2_res;     //操作数1和操作数2相加的结果
    wire[31:0] op1_jump_add_op2_jump_res;    //两个跳转操作数相加的结果
    wire[31:0] reg1_data_invert;    //reg1数据取反（用于负数运算即减法）
    wire[31:0] reg2_data_invert;
    wire op1_ge_op2_signed;         //有符号数比较，标志op1>=op2，用于比较操作
    wire op1_ge_op2_unsigned;       //无符号数比较
    wire op1_eq_op2;                //op1和op1相等标志信号
    wire[6:0] opcode;               //指令中的7位操作码
    wire[2:0] func3;                //指令中的3位功能码
    wire[6:0] func7;                //指令中的7位功能码
    wire[4:0] rd;                   //指令中的目的寄存器地址
    wire[4:0] uimm;                 //指令中的无符号立即数
    reg[`REG_BUS] reg_wdata;        //存储写入寄存器的运算结果
    reg reg_wr;                     //存储写标志信号
    reg[`REG_ADDR_BUS] reg_waddr;   //存储写入寄存器的地址
    //流水线控制信号
    reg hold_flag;                  //流水线暂停信号
    reg jump_flag;                  //跳转标志信号
    reg[`INSTR_ADDR_BUS] jump_addr; //跳转目标地址
    reg mem_wr;                     //内存写使能信号
    reg mem_req;                    //访问内存请求信号
    
    assign opcode = instr_i[6:0];
    assign func3 = instr_i[14:12];
    assign func7 = instr_i[31:25];
    assign rd = instr_i[11:7];
    assign uimm = instr_i[19:15];
    /***********************TODO 重新设计移位器以达到更好的性能*******************/
    assign sr_shift = reg1_rdata_i >>reg2_rdata_i[4:0];
    assign sri_shift = reg1_rdata_i >> instr_i[24:20];
    assign sr_shift_mask = 32'hffffffff >> reg2_rdata_i[4:0];
    assign sri_shift_mask = 32'hffffffff >> instr_i[24:20];
    /***********************TODO 重新设计加法器以达到更好的性能********************/
    assign op1_add_op2_res = op1_i + op2_i;
    assign op1_jump_add_op2_jump_res = op1_jump_i + op2_jump_i;
    //用系统函数$signed表示有符号数
    assign op1_ge_op2_signed = $signed(op1_i) >= $signed(op2_i);
    
    assign op1_ge_op2_unsigned = op1_i >= op2_i;
    assign op1_eq_op2 = (op1_i == op2_i);
    //内存读地址低2位索引
    //从地址x[rs1]+符号位扩展（offset）读取一个字节，经符号扩展后写入x[rd]
    assign mem_raddr_index = (reg1_rdata_i + {{20{instr_i[31]}},instr_i[31:20]}) & 2'b11;
    assign mem_waddr_index = (reg1_rdata_i + {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]}) & 2'b11;
    
    assign reg_wdata_o = reg_wdata;
    //响应中断时不写寄存器
    assign reg_wr_o = (int_assert_i == `INT_ASSERT)? `WR_DISA: reg_wr;
    assign reg_waddr_o = reg_waddr;
    //响应中断不写内存
    assign mem_wr_o = (int_assert_i == `INT_ASSERT)? `WR_DISA: mem_wr;
    //响应中断不向总线请求访问内存
    /***********************这里需要改，tiny用的是自定义的rib总线，要改为axi总线****************/
    assign mem_req_o = (int_assert_i == `INT_ASSERT)? `RIB_NREQ: mem_req;
    assign jump_flag_o = jump_flag;
    assign hold_flag_o = hold_flag;
    assign jump_addr_o = (int_assert_i == `INT_ASSERT)? int_addr_i: jump_addr;
    //响应中断不写CSR寄存器
    assign csr_wr_o = (int_assert_i == `INT_ASSERT)? `WR_DISA: csr_wr_i;
    assign csr_waddr_o = csr_waddr_i;
    
    always @(*) begin
        instr_o = instr_i;         // 默认传递指令到下一阶段
        instr_addr_o = instr_addr_i; // 默认传递指令地址到下一阶段
    end
    
    //执行
    always@(*)begin
        reg_wr = reg_wr_i;
        reg_waddr = reg_waddr_i;
        mem_req = `RIB_NREQ;
        csr_wdata_o = `ZERO_WORD;
        
        case(opcode)
            `INSTR_TYPE_I:begin
                case(func3)
                    `INSTR_ADDI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        reg_wdata = op1_add_op2_res;
                    end
                    //有符号数比较：op1<op2向rd写入1，否则写入0
                    `INSTR_SLTI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = {32{(~op1_ge_op2_signed)}}&32'h1;
                    end
                    //无符号数比较：op1<op2向rd写入1，否则写入0
                    `INSTR_SLTU:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = {32{(~op1_ge_op2_unsigned)}}&32'h1;
                    end
                    //异或运算
                    `INSTR_XORI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i ^ op2_i;
                    end
                    //或
                    `INSTR_ORI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i | op2_i;
                    end
                    //与
                    `INSTR_ANDI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i & op2_i;
                    end
                    //逻辑左移
                    `INSTR_SLLI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = reg1_rdata_i << instr_i[24:20];
                    end
                    //逻辑右移
                    `INSTR_SRI:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        //srai和srli
                        if(instr_i[30] == 1'b1)begin
                            reg_wdata = (sri_shift & sri_shift_mask) | ({32{reg1_rdata_i[31]}}&(~sri_shift_mask));
                        end else begin
                            reg_wdata = reg1_rdata_i >> instr_i[24:20];
                        end
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            `INSTR_TYPE_R:begin
                case(func3)
                    `INSTR_ADD_SUB:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        //add和sub
                        if(instr_i[30] == 1'b0) begin
                            reg_wdata = op1_add_op2_res;
                        end else begin
                            reg_wdata = op1_i - op2_i;
                        end
                        /**************************************TODO 设计高性能减法器**********************************/
                    end
                    //逻辑左移
                    `INSTR_SLL:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i << op2_i[4:0];
                    end
                    //SLT:OP1<OP2则置位
                    `INSTR_SLT:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = {32{(~op1_ge_op2_signed)}}&32'h1;
                    end
                    //
                    `INSTR_SLTU:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = {32{(~op1_ge_op2_unsigned)}}&32'h1;
                    end
                    `INSTR_XOR:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i ^ op2_i;
                    end
                    `INSTR_SR:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        //srl和sra
                        //sra:将x[rs1]右移x[rs2]位，空位用x[rs1]最高位填充
                        /**************************************这个mask信号还是没看懂****************************/
                        if(instr_i[30] == 1'b1)begin
                            reg_wdata = (sr_shift & sr_shift_mask) | ({32{reg1_rdata_i[31]}} & (~sr_shift_mask));
                        end else begin
                            reg_wdata = reg1_rdata_i >> reg2_rdata_i[4:0];
                        end
                    end
                    `INSTR_OR:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i | op2_i;
                    end
                    `INSTR_AND:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = op1_i & op2_i;
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            `INSTR_TYPE_L:begin
                case(func3)
                    // 字节加载
                    `INSTR_LB, `INSTR_LH, `INSTR_LW, `INSTR_LBU, `INSTR_LHU:begin
                        // 在五级流水线的EX阶段，只计算内存地址并请求访问内存
                        // 不再处理内存数据的读取和符号扩展(移到MEM阶段)
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        
                        // 生成内存读请求
                        mem_wdata_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_req = `RIB_REQ;
                        mem_raddr_o = op1_add_op2_res;  // 计算内存地址: rs1 + offset
                        
                        // 传递给MEM阶段的寄存器写信息
                        reg_wdata = `ZERO_WORD;  // 寄存器写数据在MEM阶段确定，这里只传递
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_raddr_o = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            `INSTR_TYPE_S:begin
                case(func3)
                    /*********************************始终没有看懂，sb指令不是指定读低八位吗，为什么tiny要用索引选择字节**************************/
                    //存字节
                    `INSTR_SB:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_req = `RIB_REQ;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        case(mem_waddr_index)
                            2'b00:begin
                                mem_wdata_o = {mem_rdata_i[31:8],reg2_rdata_i[7:0]};
                            end
                            2'b01:begin
                                mem_wdata_o = {mem_rdata_i[31:16],reg2_rdata_i[7:0],mem_rdata_i[7:0]};
                            end
                            2'b10:begin
                                mem_wdata_o = {mem_rdata_i[31:24],reg2_rdata_i[7:0],mem_rdata_i[15:0]};
                            end
                            default:begin
                                mem_wdata_o = {reg2_rdata_i[7:0],mem_rdata_i[23:0]};
                            end
                        endcase
                    end
                    `INSTR_SH:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_req = `RIB_REQ;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        if(mem_waddr_index == 2'b00)begin
                            mem_wdata_o = {mem_rdata_i[31:16],reg2_rdata_i[15:0]};
                        end else begin
                            mem_wdata_o = {reg2_rdata_i[15:0],mem_rdata_i[15:0]};
                        end
                    end
                    `INSTR_SW:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_req = `RIB_REQ;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        mem_wdata_o = reg2_rdata_i;
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_raddr_o = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            `INSTR_TYPE_B:begin
                case(func3)
                    //相等时分支
                    `INSTR_BEQ:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = op1_eq_op2 & `JUMP_ENA;
                        jump_addr = {32{op1_eq_op2}} & op1_jump_add_op2_jump_res;
                    end
                    //不相等时分支
                    `INSTR_BNE:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = (~op1_eq_op2) & `JUMP_ENA;
                        jump_addr = {32{(~op1_eq_op2)}} & op1_jump_add_op2_jump_res;
                    end
                    //有符号小于时分支
                    `INSTR_BLT:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = (~op1_ge_op2_signed) & `JUMP_ENA;
                        jump_addr = {32{(~op1_ge_op2_signed)}} & op1_jump_add_op2_jump_res;
                    end
                    //有符号大于时分支
                    `INSTR_BGE:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = (op1_ge_op2_signed) & `JUMP_ENA;
                        jump_addr = {32{(op1_ge_op2_signed)}} & op1_jump_add_op2_jump_res;
                    end
                    //无符号
                    `INSTR_BLTU:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = (~op1_ge_op2_unsigned) & `JUMP_ENA;
                        jump_addr = {32{(~op1_ge_op2_unsigned)}} & op1_jump_add_op2_jump_res;
                    end
                    `INSTR_BGEU:begin
                        hold_flag = `HOLD_DISA;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                        jump_flag = (op1_ge_op2_unsigned) & `JUMP_ENA;
                        jump_addr = {32{(op1_ge_op2_unsigned)}} & op1_jump_add_op2_jump_res;
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        mem_raddr_o = `ZERO_WORD;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            //跳转并链接
            `INSTR_JAL,`INSTR_JALR:begin
                hold_flag = `HOLD_DISA;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                jump_addr = op1_jump_add_op2_jump_res;
                jump_flag = `JUMP_ENA;
                reg_wdata = op1_add_op2_res;
            end
            //
            `INSTR_LUI,`INSTR_AUIPC:begin
                hold_flag = `HOLD_DISA;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                jump_addr = `ZERO_WORD;
                jump_flag = `JUMP_DISA;
                reg_wdata = op1_add_op2_res;
            end
            //
            `INSTR_NOP_OP:begin
                hold_flag = `HOLD_DISA;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                jump_addr = `ZERO_WORD;
                jump_flag = `JUMP_DISA;
                reg_wdata = `ZERO_WORD;
            end
            //
            `INSTR_FENCE:begin
                hold_flag = `HOLD_DISA;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                jump_addr = `ZERO_WORD;
                jump_flag = `JUMP_ENA;
                reg_wdata = op1_add_op2_res;
            end
            //
            `INSTR_CSR:begin
                hold_flag = `HOLD_DISA;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                jump_addr = `ZERO_WORD;
                jump_flag = `JUMP_DISA;
                case(func3)
                    `INSTR_CSRRW:begin
                        csr_wdata_o = reg1_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    `INSTR_CSRRS:begin
                        csr_wdata_o = reg1_rdata_i | csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    `INSTR_CSRRC:begin
                        csr_wdata_o = csr_rdata_i & (~reg1_rdata_i);
                        reg_wdata = csr_rdata_i;
                    end
                    `INSTR_CSRRWI:begin
                        csr_wdata_o = {27'h0,uimm};
                        reg_wdata = csr_rdata_i;
                    end
                    `INSTR_CSRRSI:begin
                        csr_wdata_o = {27'h0,uimm} | csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    `INSTR_CSRRCI:begin
                        csr_wdata_o = (~{27'h0,uimm}) & csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    default:begin
                        jump_flag = `JUMP_DISA;
                        hold_flag = `HOLD_DISA;
                        jump_addr = `ZERO_WORD;
                        mem_wdata_o = `ZERO_WORD;
                        mem_raddr_o = `ZERO_WORD;
                        mem_waddr_o = `ZERO_WORD;
                        mem_wr = `WR_DISA;
                        reg_wdata = `ZERO_WORD;
                    end
                endcase
            end
            default:begin
                jump_flag = `JUMP_DISA;
                hold_flag = `HOLD_DISA;
                jump_addr = `ZERO_WORD;
                mem_wdata_o = `ZERO_WORD;
                mem_raddr_o = `ZERO_WORD;
                mem_waddr_o = `ZERO_WORD;
                mem_wr = `WR_DISA;
                reg_wdata = `ZERO_WORD;
            end
        endcase
    end
endmodule
            