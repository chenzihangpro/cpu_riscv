// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu May 15 15:22:16 2025
// Host        : sasathreena running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ IROM_sim_netlist.v
// Design      : IROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "IROM,dist_mem_gen_v8_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dist_mem_gen_v8_0_14,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_dist_mem_gen_v8_0_14 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 9760)
`pragma protect data_block
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
hwCXFaAh4QWtuPPXYw==
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
