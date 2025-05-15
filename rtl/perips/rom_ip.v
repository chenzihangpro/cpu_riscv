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

// ROM模块 - 使用Vivado Distributed Memory Generator IP核
module rom(

    input wire clk,
    input wire rst,

    input wire we_i,                   // write enable
    input wire[`MemAddrBus] addr_i,    // addr
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,             // 字节选择信号

    output reg[`MemBus] data_o         // read data

    );

    // IP核输出和地址连线
    wire[`MemBus] ip_data_o;
    
    // 实例化IROM IP核 (只读存储器)
    IROM u_irom (
        .a(addr_i[15:2]),      // 输入14位地址线 [13:0]，从处理器地址的[15:2]映射，支持64KB(16384个字)
        .spo(ip_data_o)        // 输出32位指令数据
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