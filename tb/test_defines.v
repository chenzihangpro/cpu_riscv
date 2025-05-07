`ifndef TEST_DEFINES_V
`define TEST_DEFINES_V

// 测试常量
`define CLK_PERIOD 10  // 10ns时钟周期（100MHz）
`define SIM_TIME 1_000_000  // 仿真总时长（ns）

// 测试程序路径
`define TEST_PROG_PATH "./tests/hex/"

// 测试类型
`define UNIT_TEST    1
`define PIPELINE_TEST 2
`define INSTRUCTION_TEST 3
`define EXCEPTION_TEST 4
`define SOC_TEST 5

// 当前测试类型
`define CURRENT_TEST `INSTRUCTION_TEST

`endif