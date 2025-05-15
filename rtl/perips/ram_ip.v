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

    // 为实现字节写入，我们需要添加一个两阶段的读-修改-写操作
    // 第一个周期读取，第二个周期根据读取的数据和字节选择写回
    
    // 状态定义
    localparam STATE_IDLE = 1'b0;
    localparam STATE_WRITE = 1'b1;
    
    // 状态和控制寄存器
    reg state;
    reg[`MemAddrBus] addr_r;
    reg[`MemBus] data_r;
    reg[3:0] sel_r;
    reg we_r;
    
    // 数据寄存器
    reg[`MemBus] mem_data;
    
    // IP核输出数据连线
    wire[`MemBus] ip_data_o;
    
    // 状态机控制逻辑
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            state <= STATE_IDLE;
            addr_r <= `ZeroWord;
            data_r <= `ZeroWord;
            sel_r <= 4'b0000;
            we_r <= `WriteDisable;
            mem_data <= `ZeroWord;
        end else begin
            case (state)
                STATE_IDLE: begin
                    // 如果是字节写入请求，需要先读取当前内存内容
                    if (we_i && (sel_i != 4'b1111) && (|sel_i)) begin
                        state <= STATE_WRITE;
                        addr_r <= addr_i;
                        data_r <= data_i;
                        sel_r <= sel_i;
                        we_r <= we_i;
                        mem_data <= ip_data_o; // 保存当前读取的数据
                    end
                end
                
                STATE_WRITE: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
    
    // 写数据和写使能信号
    reg[`MemBus] write_data;
    reg write_enable;
    
    // 组合写数据和控制逻辑
    always @(*) begin
        if (state == STATE_WRITE) begin
            // 处于写入阶段，根据字节选择信号合并数据
            write_data = mem_data;
            if (sel_r[0]) write_data[7:0] = data_r[7:0];
            if (sel_r[1]) write_data[15:8] = data_r[15:8];
            if (sel_r[2]) write_data[23:16] = data_r[23:16];
            if (sel_r[3]) write_data[31:24] = data_r[31:24];
            write_enable = `WriteEnable;
        end else if (we_i && (sel_i == 4'b1111)) begin
            // 全字写入，直接使用输入数据
            write_data = data_i;
            write_enable = we_i;
        end else begin
            // 其他情况不写入
            write_data = `ZeroWord;
            write_enable = `WriteDisable;
        end
    end
    
    // IP存储器地址选择
    wire[13:0] mem_addr;
    assign mem_addr = (state == STATE_WRITE) ? addr_r[15:2] : addr_i[15:2];
    
    // 实例化DRAM IP核 (可读写存储器)
    DRAM u_dram (
        .a(mem_addr),          // 根据状态选择地址
        .d(write_data),        // 写入数据
        .clk(clk),             // 时钟输入
        .we(write_enable),     // 写使能信号
        .spo(ip_data_o)        // 输出数据
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