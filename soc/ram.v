`include "../core/defines.v"
// ram module
module ram(
    input wire clk,
    input wire rst,
    input wire we_i,                     // write enable
    input wire[`MEM_ADDR_BUS] addr_i,    // addr
    input wire[`MEM_BUS] data_i,
    output reg[`MEM_BUS] data_o          // read data
    );
    reg[`MEM_BUS] ram[0:`MEM_NUM - 1];
    //同步写入
    always @ (posedge clk) begin
        if (we_i == `WR_ENA) begin
            ram[addr_i[31:2]] <= data_i;
        end
    end
    //异步复位，异步读取
    always @ (*) begin
        if (rst == `RST_ENA) begin
            data_o = `ZERO_WORD;
        end else begin
            data_o = ram[addr_i[31:2]];
        end
    end
endmodule