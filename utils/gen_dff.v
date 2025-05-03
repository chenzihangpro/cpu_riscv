`include "../core/defines"
//流水线寄存器生成模块
module gen_pipe_dff #(
    parameter DW = 32
) (
    input  wire              clk,
    input  wire              rst,
    input  wire              hold_en,   // =1 时输出 def_val，否则每拍转 din→qout
    input  wire [DW-1:0]     def_val,
    input  wire [DW-1:0]     din,
    output reg  [DW-1:0]     qout
);
    always @(posedge clk) begin
        if (rst == `RST_ENA || hold_en)  // rst=0(有效) 或 flush=1
            qout <= def_val;
        else
            qout <= din;
    end
endmodule

// 复位后输出为0的触发器
module gen_rst_0_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b0}};
        end else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule

// 复位后输出为1的触发器
module gen_rst_1_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b1}};
        end else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule

// 复位后输出为默认值的触发器
module gen_rst_def_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,
    input wire[DW-1:0] def_val,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= def_val;
        end else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule

// 带使能端、复位后输出为0的触发器
module gen_en_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire en,
    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b0}};
        end else if (en == 1'b1) begin
            qout_r <= din;
        end
    end

    assign qout = qout_r;

