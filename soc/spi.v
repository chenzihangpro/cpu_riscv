`include "../core/defines.v"

// SPI 主控模块
module spi(

    input wire clk,
    input wire rst,

    input wire[`RegBus] data_i,
    input wire[`RegBus] addr_i,
    input wire we_i,

    output reg[`RegBus] data_o,

    output reg spi_mosi,
    input wire spi_miso,
    output wire spi_ss,
    output reg spi_clk

);

    localparam SPI_CTRL   = 4'h0;
    localparam SPI_DATA   = 4'h4;
    localparam SPI_STATUS = 4'h8;

    reg[`RegBus] spi_ctrl;
    reg[`RegBus] spi_data;
    reg[`RegBus] spi_status;

    reg[8:0] clk_cnt;
    reg en;
    reg[4:0] spi_clk_edge_cnt;
    reg spi_clk_edge_level;
    reg[7:0] rdata;
    reg done;
    reg[3:0] bit_index;
    wire[8:0] div_cnt;

    assign spi_ss = ~spi_ctrl[3];
    assign div_cnt = spi_ctrl[15:8];

    // 产生使能信号
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            en <= `Disable;
        end else begin
            if (spi_ctrl[0] == `Enable) begin
                en <= `Enable;
            end else if (done == `Enable) begin
                en <= `Disable;
            end
        end
    end

    // 分频计数器
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            clk_cnt <= 9'h0;
        end else if (en == `Enable) begin
            if (clk_cnt == div_cnt) begin
                clk_cnt <= 9'h0;
            end else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end else begin
            clk_cnt <= 9'h0;
        end
    end

    // SPI 时钟沿计数
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= `Disable;
        end else if (en == `Enable) begin
            if (clk_cnt == div_cnt) begin
                if (spi_clk_edge_cnt == 5'd17) begin
                    spi_clk_edge_cnt <= 5'h0;
                    spi_clk_edge_level <= `Disable;
                end else begin
                    spi_clk_edge_cnt <= spi_clk_edge_cnt + 1'b1;
                    spi_clk_edge_level <= `Enable;
                end
            end else begin
                spi_clk_edge_level <= `Disable;
            end
        end else begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= `Disable;
        end
    end

    // bit传输逻辑
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            spi_clk <= `Disable;
            rdata <= 8'h0;
            spi_mosi <= `Disable;
            bit_index <= 4'h0;
        end else begin
            if (en == `Enable) begin
                if (spi_clk_edge_level == `Enable) begin
                    case (spi_clk_edge_cnt)
                        1, 3, 5, 7, 9, 11, 13, 15: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == `Enable) begin
                                spi_mosi <= spi_data[bit_index];
                                bit_index <= bit_index - 1'b1;
                            end else begin
                                rdata <= {rdata[6:0], spi_miso};
                            end
                        end
                        2, 4, 6, 8, 10, 12, 14, 16: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == `Enable) begin
                                rdata <= {rdata[6:0], spi_miso};
                            end else begin
                                spi_mosi <= spi_data[bit_index];
                                bit_index <= bit_index - 1'b1;
                            end
                        end
                        17: begin
                            spi_clk <= spi_ctrl[1];
                        end
                    endcase
                end
            end else begin
                spi_clk <= spi_ctrl[1];
                if (spi_ctrl[2] == `Disable) begin
                    spi_mosi <= spi_data[7];
                    bit_index <= 4'h6;
                end else begin
                    bit_index <= 4'h7;
                end
            end
        end
    end

    // 完成信号
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            done <= `Disable;
        end else begin
            if (en == `Enable && spi_clk_edge_cnt == 5'd17) begin
                done <= `Enable;
            end else begin
                done <= `Disable;
            end
        end
    end

    // 写寄存器
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            spi_ctrl <= `ZeroWord;
            spi_data <= `ZeroWord;
            spi_status <= `ZeroWord;
        end else begin
            spi_status[0] <= en;
            if (we_i == `WriteEnable) begin
                case (addr_i[3:0])
                    SPI_CTRL: spi_ctrl <= data_i;
                    SPI_DATA: spi_data <= data_i;
                endcase
            end else begin
                spi_ctrl[0] <= `Disable;
                if (done == `Enable) begin
                    spi_data <= {24'h0, rdata};
                end
            end
        end
    end

    // 读寄存器
    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o = `ZeroWord;
        end else begin
            case (addr_i[3:0])
                SPI_CTRL: data_o = spi_ctrl;
                SPI_DATA: data_o = spi_data;
                SPI_STATUS: data_o = spi_status;
                default: data_o = `ZeroWord;
            endcase
        end
    end

endmodule
