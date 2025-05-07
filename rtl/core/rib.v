`include "defines.v"

// RIB 总线模块
// 支持 4 个 Master, 6 个 Slave, 固定优先级仲裁
module rib (
    input  wire               clk,
    input  wire               rst,
    // Master 接口
    input  wire [`MEM_ADDR_BUS] m0_addr_i,
    input  wire [`MEM_BUS]      m0_data_i,
    output reg  [`MEM_BUS]      m0_data_o,
    input  wire               m0_req_i,
    input  wire               m0_we_i,

    input  wire [`MEM_ADDR_BUS] m1_addr_i,
    input  wire [`MEM_BUS]      m1_data_i,
    output reg  [`MEM_BUS]      m1_data_o,
    input  wire               m1_req_i,
    input  wire               m1_we_i,

    input  wire [`MEM_ADDR_BUS] m2_addr_i,
    input  wire [`MEM_BUS]      m2_data_i,
    output reg  [`MEM_BUS]      m2_data_o,
    input  wire               m2_req_i,
    input  wire               m2_we_i,

    input  wire [`MEM_ADDR_BUS] m3_addr_i,
    input  wire [`MEM_BUS]      m3_data_i,
    output reg  [`MEM_BUS]      m3_data_o,
    input  wire               m3_req_i,
    input  wire               m3_we_i,

    // Slave 接口
    output reg  [`MEM_ADDR_BUS] s0_addr_o,
    output reg  [`MEM_BUS]      s0_data_o,
    input  wire [`MEM_BUS]      s0_data_i,
    output reg               s0_we_o,

    output reg  [`MEM_ADDR_BUS] s1_addr_o,
    output reg  [`MEM_BUS]      s1_data_o,
    input  wire [`MEM_BUS]      s1_data_i,
    output reg               s1_we_o,

    output reg  [`MEM_ADDR_BUS] s2_addr_o,
    output reg  [`MEM_BUS]      s2_data_o,
    input  wire [`MEM_BUS]      s2_data_i,
    output reg               s2_we_o,

    output reg  [`MEM_ADDR_BUS] s3_addr_o,
    output reg  [`MEM_BUS]      s3_data_o,
    input  wire [`MEM_BUS]      s3_data_i,
    output reg               s3_we_o,

    output reg  [`MEM_ADDR_BUS] s4_addr_o,
    output reg  [`MEM_BUS]      s4_data_o,
    input  wire [`MEM_BUS]      s4_data_i,
    output reg               s4_we_o,

    output reg  [`MEM_ADDR_BUS] s5_addr_o,
    output reg  [`MEM_BUS]      s5_data_o,
    input  wire [`MEM_BUS]      s5_data_i,
    output reg               s5_we_o,

    // 总线暂停信号
    output reg               hold_flag_o
);

// 参数：Slave 选择码
localparam [3:0] SLAVE_0 = 4'h0,
                  SLAVE_1 = 4'h1,
                  SLAVE_2 = 4'h2,
                  SLAVE_3 = 4'h3,
                  SLAVE_4 = 4'h4,
                  SLAVE_5 = 4'h5;

// 优先级仲裁：3 > 0 > 2 > 1
wire [3:0] req = {m3_req_i, m2_req_i, m1_req_i, m0_req_i};
reg  [1:0] grant;

always @(*) begin
    if (req[3]) begin
        grant       = 2'd3;
        hold_flag_o = `HOLD_ENA;
    end else if (req[0]) begin
        grant       = 2'd0;
        hold_flag_o = `HOLD_ENA;
    end else if (req[2]) begin
        grant       = 2'd2;
        hold_flag_o = `HOLD_ENA;
    end else if (req[1]) begin
        grant       = 2'd1;
        hold_flag_o = `HOLD_ENA;
    end else begin
        grant       = 2'd0;
        hold_flag_o = `HOLD_DISA;
    end
end

// 总线转发逻辑
always @(*) begin
    // 默认所有 Master 返回 0
    m0_data_o = `ZERO_WORD;
    m1_data_o = `ZERO_WORD;
    m2_data_o = `ZERO_WORD;
    m3_data_o = `ZERO_WORD;
    // 默认所有 Slave 禁止写、地址/数据清零
    {s0_we_o, s1_we_o, s2_we_o, s3_we_o, s4_we_o, s5_we_o} = {6{`WR_DISA}};
    s0_addr_o = `ZERO_WORD; 
    s1_addr_o = `ZERO_WORD;
    s2_addr_o = `ZERO_WORD; 
    s3_addr_o = `ZERO_WORD;
    s4_addr_o = `ZERO_WORD; 
    s5_addr_o = `ZERO_WORD;
    
    s0_data_o = `ZERO_WORD; 
    s1_data_o = `ZERO_WORD;
    s2_data_o = `ZERO_WORD; 
    s3_data_o = `ZERO_WORD;
    s4_data_o = `ZERO_WORD; 
    s5_data_o = `ZERO_WORD;

    case (grant)
        2'd0: begin // Master0
            case (m0_addr_i[31:28])
                SLAVE_0: begin s0_we_o = m0_we_i; s0_addr_o = m0_addr_i; s0_data_o = m0_data_i; m0_data_o = s0_data_i; end
                SLAVE_1: begin s1_we_o = m0_we_i; s1_addr_o = m0_addr_i; s1_data_o = m0_data_i; m0_data_o = s1_data_i; end
                SLAVE_2: begin s2_we_o = m0_we_i; s2_addr_o = m0_addr_i; s2_data_o = m0_data_i; m0_data_o = s2_data_i; end
                SLAVE_3: begin s3_we_o = m0_we_i; s3_addr_o = m0_addr_i; s3_data_o = m0_data_i; m0_data_o = s3_data_i; end
                SLAVE_4: begin s4_we_o = m0_we_i; s4_addr_o = m0_addr_i; s4_data_o = m0_data_i; m0_data_o = s4_data_i; end
                SLAVE_5: begin s5_we_o = m0_we_i; s5_addr_o = m0_addr_i; s5_data_o = m0_data_i; m0_data_o = s5_data_i; end
                default: ;
            endcase
        end
        2'd1: begin // Master1
            case (m1_addr_i[31:28])
                SLAVE_0: begin s0_we_o = m1_we_i; s0_addr_o = m1_addr_i; s0_data_o = m1_data_i; m1_data_o = s0_data_i; end
                SLAVE_1: begin s1_we_o = m1_we_i; s1_addr_o = m1_addr_i; s1_data_o = m1_data_i; m1_data_o = s1_data_i; end
                SLAVE_2: begin s2_we_o = m1_we_i; s2_addr_o = m1_addr_i; s2_data_o = m1_data_i; m1_data_o = s2_data_i; end
                SLAVE_3: begin s3_we_o = m1_we_i; s3_addr_o = m1_addr_i; s3_data_o = m1_data_i; m1_data_o = s3_data_i; end
                SLAVE_4: begin s4_we_o = m1_we_i; s4_addr_o = m1_addr_i; s4_data_o = m1_data_i; m1_data_o = s4_data_i; end
                SLAVE_5: begin s5_we_o = m1_we_i; s5_addr_o = m1_addr_i; s5_data_o = m1_data_i; m1_data_o = s5_data_i; end
                default: ;
            endcase
        end
        2'd2: begin // Master2
            case (m2_addr_i[31:28])
                SLAVE_0: begin s0_we_o = m2_we_i; s0_addr_o = m2_addr_i; s0_data_o = m2_data_i; m2_data_o = s0_data_i; end
                SLAVE_1: begin s1_we_o = m2_we_i; s1_addr_o = m2_addr_i; s1_data_o = m2_data_i; m2_data_o = s1_data_i; end
                SLAVE_2: begin s2_we_o = m2_we_i; s2_addr_o = m2_addr_i; s2_data_o = m2_data_i; m2_data_o = s2_data_i; end
                SLAVE_3: begin s3_we_o = m2_we_i; s3_addr_o = m2_addr_i; s3_data_o = m2_data_i; m2_data_o = s3_data_i; end
                SLAVE_4: begin s4_we_o = m2_we_i; s4_addr_o = m2_addr_i; s4_data_o = m2_data_i; m2_data_o = s4_data_i; end
                SLAVE_5: begin s5_we_o = m2_we_i; s5_addr_o = m2_addr_i; s5_data_o = m2_data_i; m2_data_o = s5_data_i; end
                default: ;
            endcase
        end
        2'd3: begin // Master3
            case (m3_addr_i[31:28])
                SLAVE_0: begin s0_we_o = m3_we_i; s0_addr_o = m3_addr_i; s0_data_o = m3_data_i; m3_data_o = s0_data_i; end
                SLAVE_1: begin s1_we_o = m3_we_i; s1_addr_o = m3_addr_i; s1_data_o = m3_data_i; m3_data_o = s1_data_i; end
                SLAVE_2: begin s2_we_o = m3_we_i; s2_addr_o = m3_addr_i; s2_data_o = m3_data_i; m3_data_o = s2_data_i; end
                SLAVE_3: begin s3_we_o = m3_we_i; s3_addr_o = m3_addr_i; s3_data_o = m3_data_i; m3_data_o = s3_data_i; end
                SLAVE_4: begin s4_we_o = m3_we_i; s4_addr_o = m3_addr_i; s4_data_o = m3_data_i; m3_data_o = s4_data_i; end
                SLAVE_5: begin s5_we_o = m3_we_i; s5_addr_o = m3_addr_i; s5_data_o = m3_data_i; m3_data_o = s5_data_i; end
                default: ;
            endcase
        end
    endcase
end

endmodule
