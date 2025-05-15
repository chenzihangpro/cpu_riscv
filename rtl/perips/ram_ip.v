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

`include "../core/defines.v"

// RAM模块 - 使用Vivado Distributed Memory Generator IP核
module ram(

    input wire clk,
    input wire rst,

    input wire we_i,                   // write enable
    input wire[`MemAddrBus] addr_i,    // addr
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,             // 字节选择信号

    output reg[`MemBus] data_o         // read data

    );

    // 将sel_i字节选择信号转换为IP核的字节写入掩码
    wire we;
    assign we = we_i;
    
    // IP核输出数据连线
    wire[`MemBus] ip_data_o;
    
    // 实例化DRAM IP核 (可读写存储器)
    DRAM u_dram (
        .a(addr_i[15:2]),      // 输入14位地址线 [13:0]，从处理器地址的[15:2]映射，支持64KB(16384个字)
        .d(data_i),            // 输入32位写入数据
        .clk(clk),             // 时钟输入
        .we(we),               // 写使能信号
        .we_mask(sel_i),       // 字节写使能掩码
        .spo(ip_data_o)        // 输出32位读取数据
    );
    
    // 输出数据逻辑
    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            data_o = ip_data_o;
        end
    end

endmodule 