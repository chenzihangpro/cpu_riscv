//处理器核顶层模块
module top_cpu(

    input wire clk,
    input wire rst,

    output wire[`MEM_ADDR_BUS] rib_ex_addr_o,    // 读、写外设的地址
    input wire[`MEM_BUS] rib_ex_data_i,         // 从外设读取的数据
    output wire[`MEM_BUS] rib_ex_data_o,        // 写入外设的数据
    output wire rib_ex_req_o,                  // 访问外设请求
    output wire rib_ex_we_o,                   // 写外设标志

    output wire[`MEM_ADDR_BUS] rib_pc_addr_o,    // 取指地址
    input wire[`MEM_BUS] rib_pc_data_i,         // 取到的指令内容

    input wire[`REG_ADDR_BUS] jtag_reg_addr_i,   // jtag模块读、写寄存器的地址
    input wire[`REG_BUS] jtag_reg_data_i,       // jtag模块写寄存器数据
    input wire jtag_reg_we_i,                  // jtag模块写寄存器标志
    output wire[`REG_BUS] jtag_reg_data_o,      // jtag模块读取到的寄存器数据

    input wire rib_hold_flag_i,                // 总线暂停标志
    input wire jtag_halt_flag_i,               // jtag暂停标志
    input wire jtag_reset_flag_i,              // jtag复位PC标志

    input wire[`INT_BUS] int_i                 // 中断信号

    );

    // pc_reg模块输出信号
	wire[`INSTR_ADDR_BUS] pc_pc_o;

    // if_id模块输出信号
	wire[`INSTR_BUS] if_inst_o;
    wire[`INSTR_ADDR_BUS] if_inst_addr_o;
    wire[`INSTR_BUS] if_int_flag_o;

    // id模块输出信号
    wire[`REG_ADDR_BUS] id_reg1_raddr_o;
    wire[`REG_ADDR_BUS] id_reg2_raddr_o;
    wire[`INSTR_BUS] id_inst_o;
    wire[`INSTR_ADDR_BUS] id_inst_addr_o;
    wire[`REG_BUS] id_reg1_rdata_o;
    wire[`REG_BUS] id_reg2_rdata_o;
    wire id_reg_we_o;
    wire[`REG_ADDR_BUS] id_reg_waddr_o;
    wire[`MEM_ADDR_BUS] id_csr_raddr_o;
    wire id_csr_we_o;
    wire[`REG_BUS] id_csr_rdata_o;
    wire[`MEM_ADDR_BUS] id_csr_waddr_o;
    wire[`MEM_ADDR_BUS] id_op1_o;
    wire[`MEM_ADDR_BUS] id_op2_o;
    wire[`MEM_ADDR_BUS] id_op1_jump_o;
    wire[`MEM_ADDR_BUS] id_op2_jump_o;

    // id_ex模块输出信号
    wire[`INSTR_BUS] ie_inst_o;
    wire[`INSTR_ADDR_BUS] ie_inst_addr_o;
    wire ie_reg_we_o;
    wire[`REG_ADDR_BUS] ie_reg_waddr_o;
    wire[`REG_BUS] ie_reg1_rdata_o;
    wire[`REG_BUS] ie_reg2_rdata_o;
    wire ie_csr_we_o;
    wire[`MEM_ADDR_BUS] ie_csr_waddr_o;
    wire[`REG_BUS] ie_csr_rdata_o;
    wire[`MEM_ADDR_BUS] ie_op1_o;
    wire[`MEM_ADDR_BUS] ie_op2_o;
    wire[`MEM_ADDR_BUS] ie_op1_jump_o;
    wire[`MEM_ADDR_BUS] ie_op2_jump_o;

    // ex模块输出信号
    wire[`MEM_BUS] ex_mem_wdata_o;
    wire[`MEM_ADDR_BUS] ex_mem_raddr_o;
    wire[`MEM_ADDR_BUS] ex_mem_waddr_o;
    wire ex_mem_we_o;
    wire ex_mem_req_o;
    wire[`REG_BUS] ex_reg_wdata_o;
    wire ex_reg_we_o;
    wire[`REG_ADDR_BUS] ex_reg_waddr_o;
    wire ex_hold_flag_o;
    wire ex_jump_flag_o;
    wire[`INSTR_ADDR_BUS] ex_jump_addr_o;
    wire ex_div_start_o;
    wire[`REG_BUS] ex_div_dividend_o;
    wire[`REG_BUS] ex_div_divisor_o;
    wire[2:0] ex_div_op_o;
    wire[`REG_ADDR_BUS] ex_div_reg_waddr_o;
    wire[`REG_BUS] ex_csr_wdata_o;
    wire ex_csr_we_o;
    wire[`MEM_ADDR_BUS] ex_csr_waddr_o;

    // regs模块输出信号
    wire[`REG_BUS] regs_rdata1_o;
    wire[`REG_BUS] regs_rdata2_o;

    // csr_reg模块输出信号
    wire[`REG_BUS] csr_data_o;
    wire[`REG_BUS] csr_clint_data_o;
    wire csr_global_int_en_o;
    wire[`REG_BUS] csr_clint_csr_mtvec;
    wire[`REG_BUS] csr_clint_csr_mepc;
    wire[`REG_BUS] csr_clint_csr_mstatus;

    // ctrl模块输出信号
    wire[`Hold_Flag_Bus] ctrl_hold_flag_o;
    wire ctrl_jump_flag_o;
    wire[`INSTR_ADDR_BUS] ctrl_jump_addr_o;


    // clint模块输出信号
    wire clint_we_o;
    wire[`MEM_ADDR_BUS] clint_waddr_o;
    wire[`MEM_ADDR_BUS] clint_raddr_o;
    wire[`REG_BUS] clint_data_o;
    wire[`INSTR_ADDR_BUS] clint_int_addr_o;
    wire clint_int_assert_o;
    wire clint_hold_flag_o;


    assign rib_ex_addr_o = (ex_mem_we_o == `WriteEnable)? ex_mem_waddr_o: ex_mem_raddr_o;
    assign rib_ex_data_o = ex_mem_wdata_o;
    assign rib_ex_req_o = ex_mem_req_o;
    assign rib_ex_we_o = ex_mem_we_o;

    assign rib_pc_addr_o = pc_pc_o;


    // pc_reg模块例化
    pc u_pc(
        .clk(clk),
        .rst(rst),
        .jtag_reset_flag_i(jtag_reset_flag_i),
        .pc_out(pc_pc_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .jump_flag_i(ctrl_jump_flag_o),
        .jump_addr_i(ctrl_jump_addr_o)
    );

    // ctrl模块例化
    ctrl u_ctrl(
        .rst(rst),
        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .hold_flag_ex(ex_hold_flag_o),
        .hold_flag_rib(rib_hold_flag_i),
        .hold_flag_o(ctrl_hold_flag_o),
        .hold_flag_clint(clint_hold_flag_o),
        .jump_flag_o(ctrl_jump_flag_o),
        .jump_addr_o(ctrl_jump_addr_o),
        .jtag_halt_flag(jtag_halt_flag_i)
    );

    // regs模块例化
    common_regs u_common_regs(
        .clk(clk),
        .rst(rst),
        .wr_i(ex_reg_we_o),
        .waddr_i(ex_reg_waddr_o),
        .wdata_i(ex_reg_wdata_o),
        .raddr1_i(id_reg1_raddr_o),
        .rdata1_o(regs_rdata1_o),
        .raddr2_i(id_reg2_raddr_o),
        .rdata2_o(regs_rdata2_o),
        .jtag_wr_i(jtag_reg_we_i),
        .jtag_addr_i(jtag_reg_addr_i),
        .jtag_data_i(jtag_reg_data_i),
        .jtag_data_o(jtag_reg_data_o)
    );

    // csr_reg模块例化
    csr_reg u_csr_reg(
        .clk(clk),
        .rst(rst),
        .we_i(ex_csr_we_o),
        .raddr_i(id_csr_raddr_o),
        .waddr_i(ex_csr_waddr_o),
        .data_i(ex_csr_wdata_o),
        .data_o(csr_data_o),
        .global_int_en_o(csr_global_int_en_o),
        .clint_we_i(clint_we_o),
        .clint_raddr_i(clint_raddr_o),
        .clint_waddr_i(clint_waddr_o),
        .clint_data_i(clint_data_o),
        .clint_data_o(csr_clint_data_o),
        .clint_csr_mtvec(csr_clint_csr_mtvec),
        .clint_csr_mepc(csr_clint_csr_mepc),
        .clint_csr_mstatus(csr_clint_csr_mstatus)
    );

    // if_id模块例化
    if_id u_if_id(
        .clk(clk),
        .rst(rst),
        .instr_i(rib_pc_data_i),
        .instr_addr_i(pc_pc_o),
        .int_flag_i(int_i),
        .int_flag_o(if_int_flag_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .instr_o(if_inst_o),
        .instr_addr_o(if_inst_addr_o)
    );

    // id模块例化
    id u_id(
        .rst(rst),
        .instr_i(if_inst_o),
        .instr_addr_i(if_inst_addr_o),
        .reg1_rdata_i(regs_rdata1_o),
        .reg2_rdata_i(regs_rdata2_o),
        .ex_jump_flag_i(ex_jump_flag_o),
        .reg1_raddr_o(id_reg1_raddr_o),
        .reg2_raddr_o(id_reg2_raddr_o),
        .instr_o(id_inst_o),
        .instr_addr_o(id_inst_addr_o),
        .reg1_rdata_o(id_reg1_rdata_o),
        .reg2_rdata_o(id_reg2_rdata_o),
        .reg_wr_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        .op1_o(id_op1_o),
        .op2_o(id_op2_o),
        .op1_jump_o(id_op1_jump_o),
        .op2_jump_o(id_op2_jump_o),
        .csr_rdata_i(csr_data_o),
        .csr_raddr_o(id_csr_raddr_o),
        .csr_wr_o(id_csr_we_o),
        .csr_rdata_o(id_csr_rdata_o),
        .csr_waddr_o(id_csr_waddr_o)
    );

    // id_ex模块例化
    id_ex u_id_ex(
        .clk(clk),
        .rst(rst),
        .instr_i(id_inst_o),
        .instr_addr_i(id_inst_addr_o),
        .reg_wr_i(id_reg_we_o),
        .reg_waddr_i(id_reg_waddr_o),
        .reg1_rdata_i(id_reg1_rdata_o),
        .reg2_rdata_i(id_reg2_rdata_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .instr_o(ie_inst_o),
        .instr_addr_o(ie_inst_addr_o),
        .reg_wr_o(ie_reg_we_o),
        .reg_waddr_o(ie_reg_waddr_o),
        .reg1_rdata_o(ie_reg1_rdata_o),
        .reg2_rdata_o(ie_reg2_rdata_o),
        .op1_i(id_op1_o),
        .op2_i(id_op2_o),
        .op1_jump_i(id_op1_jump_o),
        .op2_jump_i(id_op2_jump_o),
        .op1_o(ie_op1_o),
        .op2_o(ie_op2_o),
        .op1_jump_o(ie_op1_jump_o),
        .op2_jump_o(ie_op2_jump_o),
        .csr_wr_i(id_csr_we_o),
        .csr_waddr_i(id_csr_waddr_o),
        .csr_rdata_i(id_csr_rdata_o),
        .csr_wr_o(ie_csr_we_o),
        .csr_waddr_o(ie_csr_waddr_o),
        .csr_rdata_o(ie_csr_rdata_o)
    );

    // ex模块例化
    ex u_ex(
        .rst(rst),
        .instr_i(ie_inst_o),
        .instr_addr_i(ie_inst_addr_o),
        .reg_wr_i(ie_reg_we_o),
        .reg_waddr_i(ie_reg_waddr_o),
        .reg1_rdata_i(ie_reg1_rdata_o),
        .reg2_rdata_i(ie_reg2_rdata_o),
        .op1_i(ie_op1_o),
        .op2_i(ie_op2_o),
        .op1_jump_i(ie_op1_jump_o),
        .op2_jump_i(ie_op2_jump_o),
        .mem_rdata_i(rib_ex_data_i),
        .mem_wdata_o(ex_mem_wdata_o),
        .mem_raddr_o(ex_mem_raddr_o),
        .mem_waddr_o(ex_mem_waddr_o),
        .mem_wr_o(ex_mem_we_o),
        .mem_req_o(ex_mem_req_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .reg_wr_o(ex_reg_we_o),
        .reg_waddr_o(ex_reg_waddr_o),
        .hold_flag_o(ex_hold_flag_o),
        .jump_flag_o(ex_jump_flag_o),
        .jump_addr_o(ex_jump_addr_o),
        .int_assert_i(clint_int_assert_o),
        .int_addr_i(clint_int_addr_o),
        .csr_wr_i(ie_csr_we_o),
        .csr_waddr_i(ie_csr_waddr_o),
        .csr_rdata_i(ie_csr_rdata_o),
        .csr_wdata_o(ex_csr_wdata_o),
        .csr_wr_o(ex_csr_we_o),
        .csr_waddr_o(ex_csr_waddr_o)
    );


    // clint模块例化
    clint u_clint(
        .clk(clk),
        .rst(rst),
        .int_flag_i(if_int_flag_o),
        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),
        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .div_started_i(ex_div_start_o),
        .data_i(csr_clint_data_o),
        .csr_mtvec(csr_clint_csr_mtvec),
        .csr_mepc(csr_clint_csr_mepc),
        .csr_mstatus(csr_clint_csr_mstatus),
        .we_o(clint_we_o),
        .waddr_o(clint_waddr_o),
        .raddr_o(clint_raddr_o),
        .data_o(clint_data_o),
        .hold_flag_o(clint_hold_flag_o),
        .global_int_en_i(csr_global_int_en_o),
        .int_addr_o(clint_int_addr_o),
        .int_assert_o(clint_int_assert_o)
    );

endmodule
