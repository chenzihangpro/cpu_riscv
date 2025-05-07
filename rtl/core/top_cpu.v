`include "defines.v"

module top_cpu(
    input  wire                  clk,
    input  wire                  rst,
    
    // 指令总线接口
    output wire [`MEM_ADDR_BUS]  rib_pc_addr_o,
    input  wire [`MEM_BUS]       rib_pc_data_i,
    
    // 数据总线接口
    output wire [`MEM_ADDR_BUS]  rib_ex_addr_o,
    input  wire [`MEM_BUS]       rib_ex_data_i,
    output wire [`MEM_BUS]       rib_ex_data_o,
    output wire                  rib_ex_req_o,
    output wire                  rib_ex_we_o,
    
    // JTAG接口
    input  wire [`REG_ADDR_BUS]  jtag_reg_addr_i,
    input  wire [`REG_BUS]       jtag_reg_data_i,
    input  wire                  jtag_reg_we_i,
    output wire [`REG_BUS]       jtag_reg_data_o,
    input  wire                  jtag_halt_flag_i,
    input  wire                  jtag_reset_flag_i,
    
    // 中断信号
    input  wire [`INT_BUS]       int_i
);

    // PC寄存器输出
    wire [`INSTR_ADDR_BUS]       pc_pc_o;
    
    // IF/ID流水线寄存器信号
    wire [`INSTR_ADDR_BUS]       if_pc_o;
    wire [`INSTR_BUS]            if_inst_o;
    wire [`INSTR_ADDR_BUS]       id_pc_i;
    wire [`INSTR_BUS]            id_inst_i;
    wire [`INT_BUS]              id_int_flag_i;
    
    // ID阶段信号
    wire [`REG_ADDR_BUS]         id_reg1_raddr_o;
    wire [`REG_ADDR_BUS]         id_reg2_raddr_o;
    wire [`REG_BUS]              id_reg1_rdata_i;
    wire [`REG_BUS]              id_reg2_rdata_i;
    wire                         id_reg_wr_o;
    wire [`REG_ADDR_BUS]         id_reg_waddr_o;
    wire                         id_csr_wr_o;
    wire [`CSR_ADDR_BUS]         id_csr_raddr_o;
    wire [`CSR_ADDR_BUS]         id_csr_waddr_o;
    wire [`REG_BUS]              id_csr_rdata_i;
    wire [`REG_BUS]              id_op1_o;
    wire [`REG_BUS]              id_op2_o;
    wire [`REG_BUS]              id_op1_jump_o;
    wire [`REG_BUS]              id_op2_jump_o;
    wire [`INSTR_ADDR_BUS]       id_inst_addr_o;
    wire [`INSTR_BUS]            id_inst_o;
    wire [`REG_BUS]              id_reg1_rdata_o;
    wire [`REG_BUS]              id_reg2_rdata_o;
    wire [`REG_BUS]              id_csr_rdata_o;
    
    // 加载冒险检测信号
    wire                         id_load_hazard_o;
    
    // ID/EX流水线寄存器信号
    wire [`INSTR_ADDR_BUS]       ex_inst_addr_i;
    wire [`INSTR_BUS]            ex_inst_i;
    wire                         ex_reg_wr_i;
    wire [`REG_ADDR_BUS]         ex_reg_waddr_i;
    wire [`REG_BUS]              ex_reg1_rdata_i;
    wire [`REG_BUS]              ex_reg2_rdata_i;
    wire                         ex_csr_wr_i;
    wire [`CSR_ADDR_BUS]         ex_csr_waddr_i;
    wire [`REG_BUS]              ex_csr_rdata_i;
    wire [`REG_BUS]              ex_op1_i;
    wire [`REG_BUS]              ex_op2_i;
    wire [`REG_BUS]              ex_op1_jump_i;
    wire [`REG_BUS]              ex_op2_jump_i;
    
    // EX阶段信号
    wire                         ex_jump_flag_o;
    wire [`INSTR_ADDR_BUS]       ex_jump_addr_o;
    wire                         ex_hold_flag_o;
    wire [`REG_BUS]              ex_reg_wdata_o;
    wire                         ex_reg_wr_o;
    wire [`REG_ADDR_BUS]         ex_reg_waddr_o;
    wire [`REG_BUS]              ex_csr_wdata_o;
    wire                         ex_csr_wr_o;
    wire [`CSR_ADDR_BUS]         ex_csr_waddr_o;
    wire [`MEM_ADDR_BUS]         ex_mem_addr_o;
    wire                         ex_mem_wr_o;
    wire [`MEM_BUS]              ex_mem_wdata_o;
    wire                         ex_mem_req_o;
    wire [`INSTR_BUS]            ex_inst_o;
    wire [`INSTR_ADDR_BUS]       ex_inst_addr_o;
    
    // EX/MEM流水线寄存器信号
    wire [`INSTR_ADDR_BUS]       mem_inst_addr_i;
    wire [`INSTR_BUS]            mem_inst_i;
    wire                         mem_reg_wr_i;
    wire [`REG_ADDR_BUS]         mem_reg_waddr_i;
    wire [`REG_BUS]              mem_reg_wdata_i;
    wire                         mem_csr_wr_i;
    wire [`CSR_ADDR_BUS]         mem_csr_waddr_i;
    wire [`REG_BUS]              mem_csr_wdata_i;
    wire [`MEM_ADDR_BUS]         mem_mem_addr_i;
    wire                         mem_mem_wr_i;
    wire [`MEM_BUS]              mem_mem_wdata_i;
    wire                         mem_mem_req_i;
    
    // MEM阶段信号
    wire                         mem_hold_flag_o;
    wire [`MEM_ADDR_BUS]         mem_mem_addr_o;
    wire                         mem_mem_wr_o;
    wire [`MEM_BUS]              mem_mem_wdata_o;
    wire                         mem_mem_req_o;
    wire [`REG_BUS]              mem_reg_wdata_o;
    wire                         mem_reg_wr_o;
    wire [`REG_ADDR_BUS]         mem_reg_waddr_o;
    wire [`REG_BUS]              mem_csr_wdata_o;
    wire                         mem_csr_wr_o;
    wire [`CSR_ADDR_BUS]         mem_csr_waddr_o;
    wire [`INSTR_BUS]            mem_inst_o;
    wire [`INSTR_ADDR_BUS]       mem_inst_addr_o;
    
    // MEM/WB流水线寄存器信号
    wire [`INSTR_ADDR_BUS]       wb_inst_addr_i;
    wire [`INSTR_BUS]            wb_inst_i;
    wire                         wb_reg_wr_i;
    wire [`REG_ADDR_BUS]         wb_reg_waddr_i;
    wire [`REG_BUS]              wb_reg_wdata_i;
    wire                         wb_csr_wr_i;
    wire [`CSR_ADDR_BUS]         wb_csr_waddr_i;
    wire [`REG_BUS]              wb_csr_wdata_i;
    
    // WB阶段信号
    wire                         wb_reg_wr_o;
    wire [`REG_ADDR_BUS]         wb_reg_waddr_o;
    wire [`REG_BUS]              wb_reg_wdata_o;
    wire                         wb_csr_wr_o;
    wire [`CSR_ADDR_BUS]         wb_csr_waddr_o;
    wire [`REG_BUS]              wb_csr_wdata_o;
    
    // CTRL模块信号
    wire [`HOLD_FLAG_BUS]        ctrl_hold_flag_o;
    wire                         ctrl_jump_flag_o;
    wire [`INSTR_ADDR_BUS]       ctrl_jump_addr_o;
    
    // CSR寄存器信号
    wire                         csr_global_int_en_o;
    wire [`REG_BUS]              csr_clint_data_o;
    wire [`REG_BUS]              csr_clint_csr_mtvec;
    wire [`REG_BUS]              csr_clint_csr_mepc;
    wire [`REG_BUS]              csr_clint_csr_mstatus;
    
    // CLINT模块信号
    wire                         clint_hold_flag_o;
    wire                         clint_int_assert_o;
    wire [`INSTR_ADDR_BUS]       clint_int_addr_o;
    wire                         clint_csr_we_o;
    wire [`CSR_ADDR_BUS]         clint_csr_waddr_o;
    wire [`CSR_ADDR_BUS]         clint_csr_raddr_o;
    wire [`REG_BUS]              clint_csr_wdata_o;

    // PC模块实例化
    pc u_pc(
        .clk                     (clk),
        .rst                     (rst),
        .jump_flag               (ctrl_jump_flag_o),
        .jump_addr               (ctrl_jump_addr_o),
        .hold_flag               (ctrl_hold_flag_o),
        .jtag_rst_flag           (jtag_reset_flag_i),
        .pc_out                  (pc_pc_o)
    );
    
    // IF/ID流水线寄存器实例化
    if_id u_if_id(
        .clk                     (clk),
        .rst                     (rst),
        .instr_i                 (rib_pc_data_i),
        .instr_addr_i            (pc_pc_o),
        .hold_flag               (ctrl_hold_flag_o),
        .int_flag_i              (int_i),
        .instr_o                 (id_inst_i),
        .instr_addr_o            (id_pc_i),
        .int_flag_o              (id_int_flag_i)
    );
    
    // 通用寄存器模块实例化
    common_regs u_regs(
        .clk                     (clk),
        .rst                     (rst),
        .wr_i                    (wb_reg_wr_o),
        .waddr_i                 (wb_reg_waddr_o),
        .wdata_i                 (wb_reg_wdata_o),
        .jtag_wr_i               (jtag_reg_we_i),
        .jtag_addr_i             (jtag_reg_addr_i),
        .jtag_data_i             (jtag_reg_data_i),
        .raddr1_i                (id_reg1_raddr_o),
        .raddr2_i                (id_reg2_raddr_o),
        .rdata1_o                (id_reg1_rdata_i),
        .rdata2_o                (id_reg2_rdata_i),
        .jtag_data_o             (jtag_reg_data_o)
    );
    
    // ID模块实例化
    id u_id(
        .rst                     (rst),
        .instr_i                 (id_inst_i),
        .instr_addr_i            (id_pc_i),
        .reg1_rdata_i            (id_reg1_rdata_i),
        .reg2_rdata_i            (id_reg2_rdata_i),
        .csr_rdata_i             (id_csr_rdata_i),
        .jump_flag_i             (ctrl_jump_flag_o),
        .ex_reg_wr_i             (ex_reg_wr_o),
        .ex_reg_waddr_i          (ex_reg_waddr_o),
        .ex_reg_wdata_i          (ex_reg_wdata_o),
        .ex_opcode_i             (ex_inst_o[6:0]),
        .mem_reg_wr_i            (mem_reg_wr_o),
        .mem_reg_waddr_i         (mem_reg_waddr_o),
        .mem_reg_wdata_i         (mem_reg_wdata_o),
        .wb_reg_wr_i             (wb_reg_wr_o),
        .wb_reg_waddr_i          (wb_reg_waddr_o),
        .wb_reg_wdata_i          (wb_reg_wdata_o),
        .reg1_raddr_o            (id_reg1_raddr_o),
        .reg2_raddr_o            (id_reg2_raddr_o),
        .csr_raddr_o             (id_csr_raddr_o),
        .op1_o                   (id_op1_o),
        .op2_o                   (id_op2_o),
        .op1_jump_o              (id_op1_jump_o),
        .op2_jump_o              (id_op2_jump_o),
        .instr_o                 (id_inst_o),
        .instr_addr_o            (id_inst_addr_o),
        .reg1_rdata_o            (id_reg1_rdata_o),
        .reg2_rdata_o            (id_reg2_rdata_o),
        .reg_wr_o                (id_reg_wr_o),
        .reg_waddr_o             (id_reg_waddr_o),
        .csr_wr_o                (id_csr_wr_o),
        .csr_rdata_o             (id_csr_rdata_o),
        .csr_waddr_o             (id_csr_waddr_o),
        .load_hazard_o           (id_load_hazard_o)
    );
    
    // ID/EX流水线寄存器实例化
    id_ex u_id_ex(
        .clk                     (clk),
        .rst                     (rst),
        .instr_i                 (id_inst_o),
        .instr_addr_i            (id_inst_addr_o),
        .reg_wr_i                (id_reg_wr_o),
        .reg_waddr_i             (id_reg_waddr_o),
        .reg1_rdata_i            (id_reg1_rdata_o),
        .reg2_rdata_i            (id_reg2_rdata_o),
        .csr_wr_i                (id_csr_wr_o),
        .csr_waddr_i             (id_csr_waddr_o),
        .csr_rdata_i             (id_csr_rdata_o),
        .op1_i                   (id_op1_o),
        .op2_i                   (id_op2_o),
        .op1_jump_i              (id_op1_jump_o),
        .op2_jump_i              (id_op2_jump_o),
        .hold_flag_i             (ctrl_hold_flag_o),
        .instr_o                 (ex_inst_i),
        .instr_addr_o            (ex_inst_addr_i),
        .reg_wr_o                (ex_reg_wr_i),
        .reg_waddr_o             (ex_reg_waddr_i),
        .reg1_rdata_o            (ex_reg1_rdata_i),
        .reg2_rdata_o            (ex_reg2_rdata_i),
        .csr_wr_o                (ex_csr_wr_i),
        .csr_waddr_o             (ex_csr_waddr_i),
        .csr_rdata_o             (ex_csr_rdata_i),
        .op1_o                   (ex_op1_i),
        .op2_o                   (ex_op2_i),
        .op1_jump_o              (ex_op1_jump_i),
        .op2_jump_o              (ex_op2_jump_i)
    );
    
    // EX模块实例化
    ex u_ex(
        .rst                     (rst),
        .instr_i                 (ex_inst_i),
        .instr_addr_i            (ex_inst_addr_i),
        .reg_wr_i                (ex_reg_wr_i),
        .reg_waddr_i             (ex_reg_waddr_i),
        .reg1_rdata_i            (ex_reg1_rdata_i),
        .reg2_rdata_i            (ex_reg2_rdata_i),
        .csr_wr_i                (ex_csr_wr_i),
        .csr_waddr_i             (ex_csr_waddr_i),
        .csr_rdata_i             (ex_csr_rdata_i),
        .int_assert_i            (clint_int_assert_o),
        .int_addr_i              (clint_int_addr_o),
        .op1_i                   (ex_op1_i),
        .op2_i                   (ex_op2_i),
        .op1_jump_i              (ex_op1_jump_i),
        .op2_jump_i              (ex_op2_jump_i),
        .mem_rdata_i             (rib_ex_data_i),
        .mem_wdata_o             (ex_mem_wdata_o),
        .mem_raddr_o             (ex_mem_addr_o),
        .mem_waddr_o             (ex_mem_addr_o),
        .mem_wr_o                (ex_mem_wr_o),
        .mem_req_o               (ex_mem_req_o),
        .reg_wdata_o             (ex_reg_wdata_o),
        .reg_wr_o                (ex_reg_wr_o),
        .reg_waddr_o             (ex_reg_waddr_o),
        .csr_wdata_o             (ex_csr_wdata_o),
        .csr_wr_o                (ex_csr_wr_o),
        .csr_waddr_o             (ex_csr_waddr_o),
        .hold_flag_o             (ex_hold_flag_o),
        .jump_flag_o             (ex_jump_flag_o),
        .jump_addr_o             (ex_jump_addr_o),
        .instr_o                 (ex_inst_o),
        .instr_addr_o            (ex_inst_addr_o)
    );
    
    // EX/MEM流水线寄存器实例化
    ex_mem u_ex_mem(
        .clk                     (clk),
        .rst                     (rst),
        .instr_i                 (ex_inst_o),
        .instr_addr_i            (ex_inst_addr_o),
        .reg_wr_i                (ex_reg_wr_o),
        .reg_waddr_i             (ex_reg_waddr_o),
        .reg_wdata_i             (ex_reg_wdata_o),
        .csr_wr_i                (ex_csr_wr_o),
        .csr_waddr_i             (ex_csr_waddr_o),
        .csr_wdata_i             (ex_csr_wdata_o),
        .mem_addr_i              (ex_mem_addr_o),
        .mem_wr_i                (ex_mem_wr_o),
        .mem_wdata_i             (ex_mem_wdata_o),
        .mem_req_i               (ex_mem_req_o),
        .hold_flag_i             (ctrl_hold_flag_o),
        .instr_o                 (mem_inst_i),
        .instr_addr_o            (mem_inst_addr_i),
        .reg_wr_o                (mem_reg_wr_i),
        .reg_waddr_o             (mem_reg_waddr_i),
        .reg_wdata_o             (mem_reg_wdata_i),
        .csr_wr_o                (mem_csr_wr_i),
        .csr_waddr_o             (mem_csr_waddr_i),
        .csr_wdata_o             (mem_csr_wdata_i),
        .mem_addr_o              (mem_mem_addr_i),
        .mem_wr_o                (mem_mem_wr_i),
        .mem_wdata_o             (mem_mem_wdata_i),
        .mem_req_o               (mem_mem_req_i)
    );
    
    // MEM模块实例化
    mem u_mem(
        .rst                     (rst),
        .instr_i                 (mem_inst_i),
        .instr_addr_i            (mem_inst_addr_i),
        .reg_wr_i                (mem_reg_wr_i),
        .reg_waddr_i             (mem_reg_waddr_i),
        .reg_wdata_i             (mem_reg_wdata_i),
        .csr_wr_i                (mem_csr_wr_i),
        .csr_waddr_i             (mem_csr_waddr_i),
        .csr_wdata_i             (mem_csr_wdata_i),
        .mem_addr_i              (mem_mem_addr_i),
        .mem_wr_i                (mem_mem_wr_i),
        .mem_wdata_i             (mem_mem_wdata_i),
        .mem_req_i               (mem_mem_req_i),
        .mem_rdata_i             (rib_ex_data_i),
        .mem_wdata_o             (mem_mem_wdata_o),
        .mem_addr_o              (mem_mem_addr_o),
        .mem_wr_o                (mem_mem_wr_o),
        .mem_req_o               (mem_mem_req_o),
        .instr_o                 (mem_inst_o),
        .instr_addr_o            (mem_inst_addr_o),
        .reg_wr_o                (mem_reg_wr_o),
        .reg_waddr_o             (mem_reg_waddr_o),
        .reg_wdata_o             (mem_reg_wdata_o),
        .csr_wr_o                (mem_csr_wr_o),
        .csr_waddr_o             (mem_csr_waddr_o),
        .csr_wdata_o             (mem_csr_wdata_o),
        .hold_flag_o             (mem_hold_flag_o)
    );
    
    // MEM/WB流水线寄存器实例化
    mem_wb u_mem_wb(
        .clk                     (clk),
        .rst                     (rst),
        .instr_i                 (mem_inst_o),
        .instr_addr_i            (mem_inst_addr_o),
        .reg_wr_i                (mem_reg_wr_o),
        .reg_waddr_i             (mem_reg_waddr_o),
        .reg_wdata_i             (mem_reg_wdata_o),
        .csr_wr_i                (mem_csr_wr_o),
        .csr_waddr_i             (mem_csr_waddr_o),
        .csr_wdata_i             (mem_csr_wdata_o),
        .hold_flag_i             (ctrl_hold_flag_o),
        .instr_o                 (wb_inst_i),
        .instr_addr_o            (wb_inst_addr_i),
        .reg_wr_o                (wb_reg_wr_i),
        .reg_waddr_o             (wb_reg_waddr_i),
        .reg_wdata_o             (wb_reg_wdata_i),
        .csr_wr_o                (wb_csr_wr_i),
        .csr_waddr_o             (wb_csr_waddr_i),
        .csr_wdata_o             (wb_csr_wdata_i)
    );
    
    // WB模块实例化
    wb u_wb(
        .rst                     (rst),
        .instr_i                 (wb_inst_i),
        .instr_addr_i            (wb_inst_addr_i),
        .reg_wr_i                (wb_reg_wr_i),
        .reg_waddr_i             (wb_reg_waddr_i),
        .reg_wdata_i             (wb_reg_wdata_i),
        .csr_wr_i                (wb_csr_wr_i),
        .csr_waddr_i             (wb_csr_waddr_i),
        .csr_wdata_i             (wb_csr_wdata_i),
        .reg_wr_o                (wb_reg_wr_o),
        .reg_waddr_o             (wb_reg_waddr_o),
        .reg_wdata_o             (wb_reg_wdata_o),
        .csr_wr_o                (wb_csr_wr_o),
        .csr_waddr_o             (wb_csr_waddr_o),
        .csr_wdata_o             (wb_csr_wdata_o)
    );
    
    // CSR寄存器模块实例化
    csr_reg u_csr(
        .clk                     (clk),
        .rst                     (rst),
        .we                      (wb_csr_wr_o),
        .raddr                   (id_csr_raddr_o),
        .waddr                   (wb_csr_waddr_o),
        .data_i                  (wb_csr_wdata_o),
        .clint_we                (clint_csr_we_o),
        .clint_raddr             (clint_csr_raddr_o),
        .clint_waddr             (clint_csr_waddr_o),
        .clint_data_i            (clint_csr_wdata_o),
        .global_int_en           (csr_global_int_en_o),
        .clint_data_o            (csr_clint_data_o),
        .clint_csr_mtvec         (csr_clint_csr_mtvec),
        .clint_csr_mepc          (csr_clint_csr_mepc),
        .clint_csr_mstatus       (csr_clint_csr_mstatus),
        .data_o                  (id_csr_rdata_i)
    );
    
    // CLINT模块实例化
    clint u_clint(
        .clk                     (clk),
        .rst                     (rst),
        .int_flag                (id_int_flag_i),
        .instr                   (id_inst_i),
        .instr_addr_i            (id_pc_i),
        .jump_flag               (ex_jump_flag_o),
        .jump_addr               (ex_jump_addr_o),
        .hold_flag_i             (ctrl_hold_flag_o),
        .csr_mtvec               (csr_clint_csr_mtvec),
        .csr_mepc                (csr_clint_csr_mepc),
        .csr_mstatus             (csr_clint_csr_mstatus),
        .global_int_en           (csr_global_int_en_o),
        .hold_flag_o             (clint_hold_flag_o),
        .we                      (clint_csr_we_o),
        .waddr                   (clint_csr_waddr_o),
        .raddr                   (clint_csr_raddr_o),
        .data_o                  (clint_csr_wdata_o),
        .int_addr                (clint_int_addr_o),
        .int_assert              (clint_int_assert_o)
    );
    
    // CTRL模块实例化
    ctrl u_ctrl(
        .rst                     (rst),
        .jump_flag_i             (ex_jump_flag_o),
        .jump_addr_i             (ex_jump_addr_o),
        .hold_flag_ex            (ex_hold_flag_o),
        .hold_flag_mem           (mem_hold_flag_o),
        .hold_flag_rib           (1'b0), // 需要根据总线情况修改
        .jtag_halt_flag          (jtag_halt_flag_i),
        .hold_flag_clint         (clint_hold_flag_o),
        .hold_flag_id            (id_load_hazard_o),
        .hold_flag_o             (ctrl_hold_flag_o),
        .jump_flag_o             (ctrl_jump_flag_o),
        .jump_addr_o             (ctrl_jump_addr_o)
    );
    
    // 总线信号连接
    assign rib_pc_addr_o = pc_pc_o;
    assign rib_ex_addr_o = mem_mem_addr_o;
    assign rib_ex_data_o = mem_mem_wdata_o;
    assign rib_ex_req_o = mem_mem_req_o;
    assign rib_ex_we_o = mem_mem_wr_o;

endmodule