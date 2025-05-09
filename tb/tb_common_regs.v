`include "test_defines.v"
`include "../rtl/core/defines.v"

module common_regs_tb;
    // �ź�����
    reg clk;
    reg rst;
    reg wr_i;
    reg [`REG_ADDR_BUS] waddr_i;
    reg [`REG_BUS] wdata_i;
    reg jtag_wr_i;
    reg [`REG_ADDR_BUS] jtag_addr_i;
    reg [`REG_BUS] jtag_data_i;
    reg [`REG_ADDR_BUS] raddr1_i;
    reg [`REG_ADDR_BUS] raddr2_i;
    wire [`REG_BUS] rdata1_o;
    wire [`REG_BUS] rdata2_o;
    wire [`REG_BUS] jtag_data_o;
    
    // ʵ��������ģ��
    common_regs u_regs(
        .clk(clk),
        .rst(rst),
        .wr_i(wr_i),
        .waddr_i(waddr_i),
        .wdata_i(wdata_i),
        .jtag_wr_i(jtag_wr_i),
        .jtag_addr_i(jtag_addr_i),
        .jtag_data_i(jtag_data_i),
        .raddr1_i(raddr1_i),
        .raddr2_i(raddr2_i),
        .rdata1_o(rdata1_o),
        .rdata2_o(rdata2_o),
        .jtag_data_o(jtag_data_o)
    );
    
    // ʱ������
    initial begin
        clk = 0;
        forever #(`CLK_PERIOD/2) clk = ~clk;
    end
    
    // ��������
    initial begin
        // ��ʼ��
        rst = `RST_ENA;
        wr_i = `WR_DISA;
        waddr_i = 0;
        wdata_i = 0;
        jtag_wr_i = `WR_DISA;
        jtag_addr_i = 0;
        jtag_data_i = 0;
        raddr1_i = 0;
        raddr2_i = 0;
        
        // ��λ
        #20;
        rst = `RST_DISA;
        #20;
        
        // ����1: ������д
        waddr_i = 5;
        wdata_i = 32'h12345678;
        wr_i = `WR_ENA;
        #10;
        wr_i = `WR_DISA;
        raddr1_i = 5;
        #10;
        if(rdata1_o == 32'h12345678)
            $display("����1ͨ��: д��Ͷ�ȡ�Ĵ���r5�ɹ�");
        else
            $error("����1ʧ��: Ԥ��r5=%h, ʵ��=%h", 32'h12345678, rdata1_o);
        
        // ����2: д���ת��
        waddr_i = 6;
        wdata_i = 32'hABCDEF01;
        wr_i = `WR_ENA;
        raddr1_i = 6;
        #1; // ��ʱ�ӱ���֮ǰ���
        if(rdata1_o == 32'hABCDEF01)
            $display("����2ͨ��: д���ת���ɹ�");
        else
            $error("����2ʧ��: Ԥ��ת��ֵ=%h, ʵ��=%h", 32'hABCDEF01, rdata1_o);
        
        // ����3: x0�Ĵ�����Ϊ0
        waddr_i = 0;
        wdata_i = 32'h12345678;
        wr_i = `WR_ENA;
        #10;
        wr_i = `WR_DISA;
        raddr1_i = 0;
        #10;
        if(rdata1_o == 32'h0)
            $display("����3ͨ��: x0�Ĵ�����Ϊ0");
        else
            $error("����3ʧ��: x0�Ĵ���ֵ=%h, ӦΪ0", rdata1_o);
        
        // ����4: JTAG�ӿڶ�д
        jtag_addr_i = 10;
        jtag_data_i = 32'h55AA55AA;
        jtag_wr_i = `WR_ENA;
        #10;
        jtag_wr_i = `WR_DISA;
        raddr1_i = 10;
        #10;
        if(rdata1_o == 32'h55AA55AA)
            $display("����4ͨ��: JTAGд�Ĵ����ɹ�");
        else
            $error("����4ʧ��: Ԥ��r10=%h, ʵ��=%h", 32'h55AA55AA, rdata1_o);
        
        #100;
        $display("�Ĵ����������");
        $finish;
    end
endmodule