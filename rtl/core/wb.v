/*                                                                      
 Copyright 2023
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "defines.v"

// 写回模块
// 纯组合逻辑电路
module wb(

    input wire rst,

    // 从访存阶段传递过来的信息
    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址
    input wire reg_we_i,                    // 写通用寄存器标志
    input wire[`RegAddrBus] reg_waddr_i,    // 写通用寄存器地址
    input wire[`RegBus] reg_wdata_i,        // 写寄存器数据
    input wire csr_we_i,                    // 写CSR寄存器标志
    input wire[`MemAddrBus] csr_waddr_i,    // 写CSR寄存器地址
    input wire[`RegBus] csr_wdata_i,        // 写CSR寄存器数据
    input wire jump_flag_i,                 // 跳转标志
    input wire[`InstAddrBus] jump_addr_i,   // 跳转目的地址

    // 写回阶段的输出信号
    output wire reg_we_o,                   // 写通用寄存器标志
    output wire[`RegAddrBus] reg_waddr_o,   // 写通用寄存器地址
    output wire[`RegBus] reg_wdata_o,       // 写寄存器数据
    output wire csr_we_o,                   // 写CSR寄存器标志
    output wire[`MemAddrBus] csr_waddr_o,   // 写CSR寄存器地址
    output wire[`RegBus] csr_wdata_o,       // 写CSR寄存器数据
    output wire jump_flag_o,                // 跳转标志
    output wire[`InstAddrBus] jump_addr_o   // 跳转目的地址

    );

    // 写回阶段主要是将寄存器写入信号和数据传递出去
    assign reg_we_o = reg_we_i;
    assign reg_waddr_o = reg_waddr_i;
    assign reg_wdata_o = reg_wdata_i;
    assign csr_we_o = csr_we_i;
    assign csr_waddr_o = csr_waddr_i;
    assign csr_wdata_o = csr_wdata_i;
    assign jump_flag_o = jump_flag_i;
    assign jump_addr_o = jump_addr_i;

endmodule 