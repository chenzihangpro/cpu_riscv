`include "../core/defines.v"
module rom(
    input wire clk,
    input wire rst,
    input wire[`MEM_ADDR_BUS] addr_i,
    output reg[`MEM_BUS] data_o
);
    reg[`MEM_BUS] rom[0:`ROM_NUM - 1];
    initial begin
        $readmemh("rom_init.hex", rom);  // º”‘ÿ÷∏¡Ó≥Ã–Ú
    end
    always @(*) begin
        if (rst == `RST_ENA) begin
            data_o = `ZERO_WORD;
        end else begin
            data_o = rom[addr_i[31:2]];
        end
    end
endmodule
