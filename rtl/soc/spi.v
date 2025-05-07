`include "../core/defines.v"

// SPI 主控模块
module spi(

    input wire clk,
    input wire rst,

    input wire[`REG_BUS] data_i,
    input wire[`REG_BUS] addr_i,
    input wire we_i,

    output reg[`REG_BUS] data_o,

    output reg spi_mosi,
    input wire spi_miso,
    output wire spi_ss,
    output reg spi_clk

);

    // SPI寄存器地址定义
    localparam SPI_CTRL   = 4'h0;
    localparam SPI_DATA   = 4'h4;
    localparam SPI_STATUS = 4'h8;

    // SPI控制寄存器
    reg[`REG_BUS] spi_ctrl;
    reg[`REG_BUS] spi_data;
    reg[`REG_BUS] spi_status;

    // SPI时钟分频和控制信号
    reg[8:0] clk_cnt;
    reg en;
    reg[4:0] spi_clk_edge_cnt;
    reg spi_clk_edge_level;
    reg[7:0] rdata;
    reg done;
    reg[3:0] bit_index;
    wire[8:0] div_cnt;

    // SPI片选信号和分频计数
    assign spi_ss = ~spi_ctrl[3];
    assign div_cnt = spi_ctrl[15:8];

    // 产生使能信号
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            en <= `FALSE;
        end else begin
            if (spi_ctrl[0] == `TRUE) begin
                en <= `TRUE;
            end else if (done == `TRUE) begin
                en <= `FALSE;
            end
        end
    end

    // 分频计数器
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            clk_cnt <= 9'h0;
        end else if (en == `TRUE) begin
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
        if (rst == `RST_ENA) begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= `FALSE;
        end else if (en == `TRUE) begin
            if (clk_cnt == div_cnt) begin
                if (spi_clk_edge_cnt == 5'd17) begin
                    spi_clk_edge_cnt <= 5'h0;
                    spi_clk_edge_level <= `FALSE;
                end else begin
                    spi_clk_edge_cnt <= spi_clk_edge_cnt + 1'b1;
                    spi_clk_edge_level <= `TRUE;
                end
            end else begin
                spi_clk_edge_level <= `FALSE;
            end
        end else begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= `FALSE;
        end
    end

    // bit传输逻辑
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            spi_clk <= `FALSE;
            rdata <= 8'h0;
            spi_mosi <= `FALSE;
            bit_index <= 4'h0;
        end else begin
            if (en == `TRUE) begin
                if (spi_clk_edge_level == `TRUE) begin
                    case (spi_clk_edge_cnt)
                        1, 3, 5, 7, 9, 11, 13, 15: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == `TRUE) begin
                                spi_mosi <= spi_data[bit_index];
                                bit_index <= bit_index - 1'b1;
                            end else begin
                                rdata <= {rdata[6:0], spi_miso};
                            end
                        end
                        2, 4, 6, 8, 10, 12, 14, 16: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == `TRUE) begin
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
                if (spi_ctrl[2] == `FALSE) begin
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
        if (rst == `RST_ENA) begin
            done <= `FALSE;
        end else begin
            if (en == `TRUE && spi_clk_edge_cnt == 5'd17) begin
                done <= `TRUE;
            end else begin
                done <= `FALSE;
            end
        end
    end

    // 写寄存器
    always @ (posedge clk) begin
        if (rst == `RST_ENA) begin
            spi_ctrl <= `ZERO_WORD;
            spi_data <= `ZERO_WORD;
            spi_status <= `ZERO_WORD;
        end else begin
            spi_status[0] <= en;
            if (we_i == `WR_ENA) begin
                case (addr_i[3:0])
                    SPI_CTRL: spi_ctrl <= data_i;
                    SPI_DATA: spi_data <= data_i;
                endcase
            end else begin
                spi_ctrl[0] <= `FALSE;
                if (done == `TRUE) begin
                    spi_data <= {24'h0, rdata};
                end
            end
        end
    end

    // 读寄存器
    always @ (*) begin
        if (rst == `RST_ENA) begin
            data_o = `ZERO_WORD;
        end else begin
            case (addr_i[3:0])
                SPI_CTRL: data_o = spi_ctrl;
                SPI_DATA: data_o = spi_data;
                SPI_STATUS: data_o = spi_status;
                default: data_o = `ZERO_WORD;
            endcase
        end
    end

endmodule