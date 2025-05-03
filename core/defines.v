`define RST_ENA 1'b0
`define RST_DISA 1'b1
`define CPU_RST_ADDR 32'b0
`define HOLD_ENA 1'b1
`define HOLD_DISA 1'b0
`define JUMP_ENA 1'b1
`define JUMP_DISA 1'b0
`define WR_ENA 1'b1
`define WR_DISA 1'b0

`define ZERO_REG 5'h0           //空寄存器地址
`define ZERO_WORD 32'b0         //32位空字段

`define HOLD_FLAG_BUS 2:0       //流水线暂停标志
`define HOLD_IF 3'b010          //IF流水线暂停的条件
`define HOLD_ID 3'b011


`define INT_FLAG_BUS 7:0
`define INT_NONE 8'h0
`define INT_ASSERT 1'b1

`define INSTR_BUS 31:0
`define INSTR_ADDR_BUS 31:0

`define REG_ADDR_BUS 4:0
`define REG_BUS 31:0
`define REG_NUM 32

`define MEM_ADDR_BUS 31:0
`define MEM_BUS 31:0
`define MEM_NUM 4096

`define ROM_NUM 4096
/****************************总线****************************/
`define RIB_NREQ 1'b0
`define RIB_REQ 1'b1
/*****************************id****************************/

//I型指令
`define INSTR_TYPE_I 7'b0010011
`define INSTR_ADDI 3'b000
`define INSTR_SLTI 3'b010
`define INSTR_SLTIU 3'b011
`define INSTR_XORI 3'b100
`define INSTR_ORI 3'b110
`define INSTR_ANDI 3'b111
`define INSTR_SLLI 3'b001
`define INSTR_SRI 3'b101
//R型指令
`define INSTR_TYPE_R 7'b0110011
`define INSTR_ADD_SUB 3'b000
`define INSTR_SLL 3'b001
`define INSTR_SLT 3'b010
`define INSTR_SLTU 3'b011
`define INSTR_XOR 3'b100
`define INSTR_SR 3'b101
`define INSTR_OR 3'b110
`define INSTR_AND 3'b111
//L型指令
`define INSTR_TYPE_L 7'b0000011
`define INSTR_LB 3'b000
`define INSTR_LH 3'b001
`define INSTR_LW 3'b010
`define INSTR_LBU 3'b100
`define INSTR_LHU 3'b101
//S型指令
`define INSTR_TYPE_S 7'b0100011
`define INSTR_SB 3'b000
`define INSTR_SH 3'b001
`define INSTR_SW 3'b010
//B型指令
`define INSTR_TYPE_B 7'b1100011
`define INSTR_BEQ 3'b000
`define INSTR_BNE 3'b001
`define INSTR_BLT 3'b100
`define INSTR_BGE 3'b101
`define INSTR_BLTU 3'b110
`define INSTR_BGEU 3'b111
//jal指令
`define INSTR_JAL 7'b1101111
`define INSTR_JALR 7'b1100111
//lui
`define INSTR_LUI 7'b0110111
//auipc
`define INSTR_AUIPC 7'b0010111
//NOP 不执行任何操作，只执行PC递增
`define INSTR_NOP_OP 7'b0000001
`define INSTR_NO_OPERATION 32'h00000001 //不进行任何操作的指令
//fence
`define INSTR_FENCE 7'b0001111
//ecall ebreak
`define INSTR_ECALL 32'h73
`define INSTR_EBREAK 32'h00100073
//CSR操作指令
`define INSTR_CSR 7'b1110011
`define INSTR_CSRRW 3'b001
`define INSTR_CSRRS 3'b010
`define INSTR_CSRRC 3'b011
`define INSTR_CSRRWI 3'b101
`define INSTR_CSRRSI 3'b110
`define INSTR_CSRRCI 3'b111

/*****************************ctrl****************************/
`define HOLD_NONE 3'b000
`define HOLD_PC 3'b001

/*****************************csr****************************/
`define CSR_CYCLE   12'hc00
`define CSR_CYCLEH  12'hc80
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MIE     12'h304
`define CSR_MSTATUS 12'h300
`define CSR_MSCRATCH 12'h340

/*****************************clint****************************/
`define INT_BUS 7:0
`define INT_RET 8'hff
`define INT_TIMER0 8'b00000001
`define INT_TIMER0_ENTRY_ADDR 32'h4
`define INT_ASSERT 1'b1
`define INT_DEASSERT 1'b0
/*****************************add some defines****************************/
`define DOUBLE_REG_BUS 63:0
`define TRUE 1'b1
`define FALSE 1'b0





