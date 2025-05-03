`include "../core/defines.v"

module rom(
    input wire clk,
    input wire rst,
    input wire[`MemAddrBus] addr_i,
    output reg[`MemBus] data_o
);

    reg[`MemBus] _rom[0:`RomNum - 1];

    initial begin
        $readmemh("rom_init.hex", _rom);  // º”‘ÿ÷∏¡Ó≥Ã–Ú
    end

    always @(*) begin
        if (rst == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            data_o = _rom[addr_i[31:2]];
        end
    end

endmodule
