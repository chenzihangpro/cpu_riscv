 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
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


module rom(

    input wire clk,
    input wire rst,

    input wire we_i,                   // write enable
    input wire[`MemAddrBus] addr_i,    // addr
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,             // 字节选择信号

    output reg[`MemBus] data_o         // read data

    );

    reg[`MemBus] _rom[0:`RomNum - 1];


    always @ (posedge clk) begin
        if (we_i == `WriteEnable) begin
            if (sel_i[0]) _rom[addr_i[31:2]][7:0] <= data_i[7:0];
            if (sel_i[1]) _rom[addr_i[31:2]][15:8] <= data_i[15:8];
            if (sel_i[2]) _rom[addr_i[31:2]][23:16] <= data_i[23:16];
            if (sel_i[3]) _rom[addr_i[31:2]][31:24] <= data_i[31:24];
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            // 读取整个字，让MEM阶段根据字节选择信号进行处理
            data_o = _rom[addr_i[31:2]];
        end
    end

endmodule
