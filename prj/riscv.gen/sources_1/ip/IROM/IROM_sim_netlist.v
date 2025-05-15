// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu May 15 15:22:17 2025
// Host        : sasathreena running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/gitware/FPGA/origin/tinyriscv/prj/riscv.gen/sources_1/ip/IROM/IROM_sim_netlist.v
// Design      : IROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IROM,dist_mem_gen_v8_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_14,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module IROM
   (a,
    spo);
  input [13:0]a;
  output [31:0]spo;

  wire \<const0> ;
  wire [13:0]a;
  wire [31:0]\^spo ;
  wire [31:0]NLW_U0_dpo_UNCONNECTED;
  wire [31:0]NLW_U0_qdpo_UNCONNECTED;
  wire [31:0]NLW_U0_qspo_UNCONNECTED;
  wire [30:22]NLW_U0_spo_UNCONNECTED;

  assign spo[31] = \^spo [31];
  assign spo[30] = \<const0> ;
  assign spo[29:23] = \^spo [29:23];
  assign spo[22] = \<const0> ;
  assign spo[21:0] = \^spo [21:0];
  GND GND
       (.G(\<const0> ));
  (* C_FAMILY = "virtex7" *) 
  (* C_HAS_D = "0" *) 
  (* C_HAS_DPO = "0" *) 
  (* C_HAS_DPRA = "0" *) 
  (* C_HAS_I_CE = "0" *) 
  (* C_HAS_QDPO = "0" *) 
  (* C_HAS_QDPO_CE = "0" *) 
  (* C_HAS_QDPO_CLK = "0" *) 
  (* C_HAS_QDPO_RST = "0" *) 
  (* C_HAS_QDPO_SRST = "0" *) 
  (* C_HAS_WE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_PIPELINE_STAGES = "0" *) 
  (* C_QCE_JOINED = "0" *) 
  (* C_QUALIFY_WE = "0" *) 
  (* C_REG_DPRA_INPUT = "0" *) 
  (* c_addr_width = "14" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "16384" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_clk = "0" *) 
  (* c_has_qspo = "0" *) 
  (* c_has_qspo_ce = "0" *) 
  (* c_has_qspo_rst = "0" *) 
  (* c_has_qspo_srst = "0" *) 
  (* c_has_spo = "1" *) 
  (* c_mem_init_file = "IROM.mif" *) 
  (* c_parser_type = "1" *) 
  (* c_read_mif = "1" *) 
  (* c_reg_a_d_inputs = "0" *) 
  (* c_sync_enable = "1" *) 
  (* c_width = "32" *) 
  (* is_du_within_envelope = "true" *) 
  IROM_dist_mem_gen_v8_0_14 U0
       (.a(a),
        .clk(1'b0),
        .d({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dpo(NLW_U0_dpo_UNCONNECTED[31:0]),
        .dpra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_ce(1'b1),
        .qdpo(NLW_U0_qdpo_UNCONNECTED[31:0]),
        .qdpo_ce(1'b1),
        .qdpo_clk(1'b0),
        .qdpo_rst(1'b0),
        .qdpo_srst(1'b0),
        .qspo(NLW_U0_qspo_UNCONNECTED[31:0]),
        .qspo_ce(1'b1),
        .qspo_rst(1'b0),
        .qspo_srst(1'b0),
        .spo(\^spo ),
        .we(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
uwBH4JaTzmENPjp1VK18+NmHqz3idKCCPayqakkK6bYDVk0JtRfycJYNxbcnLmlw5yuLTcDXBBKk
FqBPE2n7wWKg9tfz2Y8PrWAvnbsIFMfxBK8sfWUf8PPnz8vUwwMHjbXUWcgCgvtygj/TbB+jcZ8Z
CjYnBZ8tNdKOO1iDLpQ=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ff7o4KDFniNgPFT3cDZtw4HhiKzFbOFtLXtuci0MZhgQ8oZ15BcuowAfxUJXngU8JkWI9cbWKkG8
h/PODwnWEt4eK4VDKRk6Hw3QkZiKAa1N3QupC8D5bR7vJ/+RhJwSayz9t2JpdZaEhKgCgqTcX6oZ
4fCEOmSTUWVob+DXV4UfaMyfVm5VI0wxZ7q0mjFx+pdkt56PuNREX9kH4a9Ma1P0sYo8XaTpANLa
JC6eXOuUQlp40M9F/NL1Xajpys0YfGx8AveMAFEyfRmHZs+NbXmny/79vednrm+FhwtS9LveegmF
NZW9jiiR+9Igeraaz+QXPc6JO/nCDTr4Fuwusg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
enb/INzHPP7GNdz8dyyqgVCJiMs9JXcjMywZXhzPersGm0A258UOUwtOqcF1rO7lnrKwTeWbNFVN
dO3BxXBpzGnYWUqDda208CYV9hTWFhfySQdX58qn1Z8QY5G7KniMCVjaGuPPCfToPOOdbAxR9XUp
XbMr0vrZKWxz8nBhGYc=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
RKZNANfa63/n14iwmSxsB/UeV76BNqjEiYgjlZ2LdFWOArCv6D+jhC4sjGMiaz8GJ8J5kQeiWB0Y
e1+zdHflgzODs6eVC82MlEcfgP0vdDIBn0PP8rVDg5O31eQuJ7n5zn4XJu+vzjpkvJIHKrktAsP4
jg+LRxcTOu0dILImk7Vwgyuwhi8OxNN+jBVbLVxdNj0l5aQMgRZlU/8FVh3u958SH7z/fHnwGaOw
P8QgNv0ZZblWvpxa8TJIwlgVb9354a0eyD9XsKy5VfuUG03nmputxNzUuIUmGtBGCqx+4D4pyCch
j/ixD5iiKRmeKD1/RtGzxmrJap7SAHMuzic1Hw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
OQMD0qoDy+4W8+jfTV63GDTwmjWvJILCTofeYJTZqWc2KhrzQXwVMW48dTyIriC6bA4bmXD5BwcB
W2gGbVUvY1Y1+wEFEwYIC0LiPrJO0DhpM1JhP2vkxnTEwaODiEp5x3XqHgsiys0I2/9mE4z4Hlbl
jzftQ/8sVSYokhMp9eaIHk3HNCSBllv90qeBfH3fOdVI2gA1r/22PktttbkyKji24r7jM5o4aMIc
Sp6u0DCnD2cSPCuCuMW3A9sFRuTKbXiLAeeymFIAXHKYQgWXXOqmbKHrk4GviHQyz31C9d+hm6dh
RMtaCyWnhqo3QE/QxP0TsYk3CgkjDCU+KK/ozA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uV1eryjGs1SHbpKIAk5r3BY2SLKX9RlfGw6gbw/UtzBYt4U7vTBIy+x767ojEcmbGLos8kr8vilV
cnNOnsbu7vOAUIe+1PgpaPaCkv2OTPXaE0tfps6+Q6D3zB6j2a2FE1gRIPOniwAdlIn69jL2tuWD
M2BN1efQhi0lZHuKtTgzBOVXIg+zbTiH2k2kHWThOi6WayoBEny+g88wRi6pUBeB6aW3ezFYNmsl
zeOY9xmt+UhRMcr87DCcZdmjsIk6VrsIKF60y93pM0IoQ56iWpQ2OKZK+Ng9qC+pNHBEYEhiMQFb
kUesHtcFOIS7Ok6S9O9SMgf7lMQFOh9w0L31UA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GM2VxmvaiVBg1DsqOLewt6rcWtfH/Gj1QS7fUSMudF5qJ2fn+TXd8kcCwwrxdcXNXjoVi2As5jmL
yw1/NZreemrkS1YCJJDxmnE8CW2q9/4N4a79kApF1VfD5XdpaULhVn+Eb+jXCQFG+GEEOvnPb0Me
bbfRkfc0DAIWgtG2D81EQ28mg7KAWtsDpdUCi+BKdIAj8RXoTiQbFbiBeT7EiRIrz2PQF9nhQBfF
FjlrCNwDP4hRQJQeZcf/1Pl8SFyKGQb6iVF+VhhCVCunL7VBmzaCOW/gowPM7hRM2dvzmxcgeKfs
dZx/fy2rk1iokUi+3B+Jc6CycMWbHu8EfCh7iQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
NSZoNMCco4gpYPcg8pb9mtee1JxEWDcDzt6wnS0LeSPMi2upLvQXnSQKMvJGGOKStJOcu1eu7x33
4Xa3ApbjbfZ+lgs1PYlyY4V+B2Lio1EEo1uzZVWFrVFvmknOZwj6Gcmj5N/osaiqKaeIw7NTTbyX
HNHOabVsQJ540qnP4u/nzS/h/AQcm0PFLadGZtHJZEzyQDSSdghD/y/OLprdBcInfQDwAxQuJpCy
ExX4lD2WMrCkymNBS9NMH0vYh4kvpYKRO/oHuGcOZVg0p8vfMmz/BJDHuxTcS3FpLT0WxGVcmUIk
cuqKQFiVwwgnW9AfYkbsMrwfl9po2pofaAY2JC5ZTMyO1qEfSu4fxTRJNnDRvW65KkMdJhZFa36p
82hcDlaYvBowndZfMc42Sxt+ZULFDTFN0HT50iteAG1yEvJ9jKBiJla+kDQJB0VD0kj4+k8aBug3
uPKVykvf1/Uaw8NoW591pML42qlh8v1RzAm6aDnPRdsDaCc5Dq9QDPuE

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oRNld8VrAuP/xHUguZzkh8+wROOItnvw1FQUP5KHjxeh8nudEYH2PGefTPsV73QyEruJanGifjCR
m8XHiIxqAY9fk4CAm+2n67YLFUEHjC1Qri9htrL4W5fnj7OIdzcwttvmGEuGOuYOFA98RcnR0jSL
Nyqq5u/eILCh2MiKiELfsBjRv/WckpboJ+gzO1btduECvdBGjsIcjjHiIzPwNSGxnX3G6zG9OiWq
hXP2Jh0Ril7rGbajit90p+gJpDpuLee/aOh0BUXbYYLU0YIXK8bskgMir7D6cfu5oWDKwYH6/YRR
tFjIhRzFsqwjtmaxUnGTZzxsWGazk+uFfHXl7w==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 9696)
`pragma protect data_block
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
d71ZIHLE
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
