//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3.1 (lin64) Build 2489853 Tue Mar 26 04:18:30 MDT 2019
//Date        : Thu Mar 30 11:15:33 2023
//Host        : cad104.naist.jp running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=14,numReposBlks=14,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=5,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (CLK_150M_clk_n,
    CLK_150M_clk_p,
    CLK_78M_clk_n,
    CLK_78M_clk_p,
    EXT_RESET,
    GT_DIFF_REFCLK0_clk_n,
    GT_DIFF_REFCLK0_clk_p,
    GT_DIFF_REFCLK1_clk_n,
    GT_DIFF_REFCLK1_clk_p,
    GT_SERIAL_RX0_rxn,
    GT_SERIAL_RX0_rxp,
    GT_SERIAL_RX1_rxn,
    GT_SERIAL_RX1_rxp,
    GT_SERIAL_TX0_txn,
    GT_SERIAL_TX0_txp,
    GT_SERIAL_TX1_txn,
    GT_SERIAL_TX1_txp,
    HEART_BEAT,
    LINK_UP0,
    LINK_UP1,
    MAIN_RESET_N);
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 CLK_150M CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_150M, CAN_DEBUG false, FREQ_HZ 150000000" *) input [0:0]CLK_150M_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 CLK_150M CLK_P" *) input [0:0]CLK_150M_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 CLK_78M CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK_78M, CAN_DEBUG false, FREQ_HZ 78125000" *) input [0:0]CLK_78M_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 CLK_78M CLK_P" *) input [0:0]CLK_78M_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.EXT_RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.EXT_RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input EXT_RESET;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 GT_DIFF_REFCLK0 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME GT_DIFF_REFCLK0, CAN_DEBUG false, FREQ_HZ 156250000" *) input GT_DIFF_REFCLK0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 GT_DIFF_REFCLK0 CLK_P" *) input GT_DIFF_REFCLK0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 GT_DIFF_REFCLK1 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME GT_DIFF_REFCLK1, CAN_DEBUG false, FREQ_HZ 156250000" *) input GT_DIFF_REFCLK1_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 GT_DIFF_REFCLK1 CLK_P" *) input GT_DIFF_REFCLK1_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX:1.0 GT_SERIAL_RX0 RXN" *) input [0:7]GT_SERIAL_RX0_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX:1.0 GT_SERIAL_RX0 RXP" *) input [0:7]GT_SERIAL_RX0_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX:1.0 GT_SERIAL_RX1 RXN" *) input [0:7]GT_SERIAL_RX1_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX:1.0 GT_SERIAL_RX1 RXP" *) input [0:7]GT_SERIAL_RX1_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX:1.0 GT_SERIAL_TX0 TXN" *) output [0:7]GT_SERIAL_TX0_txn;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX:1.0 GT_SERIAL_TX0 TXP" *) output [0:7]GT_SERIAL_TX0_txp;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX:1.0 GT_SERIAL_TX1 TXN" *) output [0:7]GT_SERIAL_TX1_txn;
  (* X_INTERFACE_INFO = "xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX:1.0 GT_SERIAL_TX1 TXP" *) output [0:7]GT_SERIAL_TX1_txp;
  output HEART_BEAT;
  output LINK_UP0;
  output LINK_UP1;
  input MAIN_RESET_N;

  wire C2C_MASTER_TOP_0_LINK_UP;
  wire [2:0]C2C_MASTER_TOP_0_LOOPBACK;
  wire [39:0]C2C_MASTER_TOP_0_M_AXI_ARADDR;
  wire [1:0]C2C_MASTER_TOP_0_M_AXI_ARBURST;
  wire [3:0]C2C_MASTER_TOP_0_M_AXI_ARCACHE;
  wire [15:0]C2C_MASTER_TOP_0_M_AXI_ARID;
  wire [7:0]C2C_MASTER_TOP_0_M_AXI_ARLEN;
  wire [2:0]C2C_MASTER_TOP_0_M_AXI_ARPROT;
  wire C2C_MASTER_TOP_0_M_AXI_ARREADY;
  wire [2:0]C2C_MASTER_TOP_0_M_AXI_ARSIZE;
  wire C2C_MASTER_TOP_0_M_AXI_ARVALID;
  wire [39:0]C2C_MASTER_TOP_0_M_AXI_AWADDR;
  wire [1:0]C2C_MASTER_TOP_0_M_AXI_AWBURST;
  wire [3:0]C2C_MASTER_TOP_0_M_AXI_AWCACHE;
  wire [15:0]C2C_MASTER_TOP_0_M_AXI_AWID;
  wire [7:0]C2C_MASTER_TOP_0_M_AXI_AWLEN;
  wire [2:0]C2C_MASTER_TOP_0_M_AXI_AWPROT;
  wire C2C_MASTER_TOP_0_M_AXI_AWREADY;
  wire [2:0]C2C_MASTER_TOP_0_M_AXI_AWSIZE;
  wire C2C_MASTER_TOP_0_M_AXI_AWVALID;
  wire [15:0]C2C_MASTER_TOP_0_M_AXI_BID;
  wire C2C_MASTER_TOP_0_M_AXI_BREADY;
  wire [1:0]C2C_MASTER_TOP_0_M_AXI_BRESP;
  wire C2C_MASTER_TOP_0_M_AXI_BVALID;
  wire [255:0]C2C_MASTER_TOP_0_M_AXI_RDATA;
  wire [15:0]C2C_MASTER_TOP_0_M_AXI_RID;
  wire C2C_MASTER_TOP_0_M_AXI_RLAST;
  wire C2C_MASTER_TOP_0_M_AXI_RREADY;
  wire [1:0]C2C_MASTER_TOP_0_M_AXI_RRESP;
  wire C2C_MASTER_TOP_0_M_AXI_RVALID;
  wire [255:0]C2C_MASTER_TOP_0_M_AXI_WDATA;
  wire C2C_MASTER_TOP_0_M_AXI_WLAST;
  wire C2C_MASTER_TOP_0_M_AXI_WREADY;
  wire [31:0]C2C_MASTER_TOP_0_M_AXI_WSTRB;
  wire C2C_MASTER_TOP_0_M_AXI_WVALID;
  wire C2C_MASTER_TOP_0_POWER_DOWN;
  wire [511:0]C2C_MASTER_TOP_0_TX_TDATA;
  wire [63:0]C2C_MASTER_TOP_0_TX_TKEEP;
  wire C2C_MASTER_TOP_0_TX_TLAST;
  wire C2C_MASTER_TOP_0_TX_TREADY;
  wire C2C_MASTER_TOP_0_TX_TVALID;
  wire C2C_SLAVE_TOP_0_LINK_UP;
  wire [2:0]C2C_SLAVE_TOP_0_LOOPBACK;
  wire C2C_SLAVE_TOP_0_POWER_DOWN;
  wire [511:0]C2C_SLAVE_TOP_0_TX_TDATA;
  wire [63:0]C2C_SLAVE_TOP_0_TX_TKEEP;
  wire C2C_SLAVE_TOP_0_TX_TLAST;
  wire C2C_SLAVE_TOP_0_TX_TREADY;
  wire C2C_SLAVE_TOP_0_TX_TVALID;
  wire [0:0]CLK_150M_1_CLK_N;
  wire [0:0]CLK_150M_1_CLK_P;
  wire [0:0]CLK_78M_1_CLK_N;
  wire [0:0]CLK_78M_1_CLK_P;
  wire EXT_RESET_1;
  wire GT_DIFF_REFCLK0_1_CLK_N;
  wire GT_DIFF_REFCLK0_1_CLK_P;
  wire GT_DIFF_REFCLK1_1_CLK_N;
  wire GT_DIFF_REFCLK1_1_CLK_P;
  wire [0:7]GT_SERIAL_RX0_1_RXN;
  wire [0:7]GT_SERIAL_RX0_1_RXP;
  wire [0:7]GT_SERIAL_RX1_1_RXN;
  wire [0:7]GT_SERIAL_RX1_1_RXP;
  wire HEARTBEAT_0_HEART_BEAT;
  wire MAIN_RESET_N_1;
  wire RESET_CTRL_0_PERI_RESET_N;
  wire RESET_CTRL_0_PERI_RESET_P;
  wire RESET_CTRL_0_USER_RESET_P;
  wire [0:7]aurora_64b66b_0_GT_SERIAL_TX_TXN;
  wire [0:7]aurora_64b66b_0_GT_SERIAL_TX_TXP;
  wire [511:0]aurora_64b66b_0_USER_DATA_M_AXIS_RX_TDATA;
  wire [63:0]aurora_64b66b_0_USER_DATA_M_AXIS_RX_TKEEP;
  wire aurora_64b66b_0_USER_DATA_M_AXIS_RX_TLAST;
  wire aurora_64b66b_0_USER_DATA_M_AXIS_RX_TVALID;
  wire aurora_64b66b_0_channel_up;
  wire aurora_64b66b_0_hard_err;
  wire [0:7]aurora_64b66b_0_lane_up;
  wire aurora_64b66b_0_soft_err;
  wire aurora_64b66b_0_user_clk_out;
  wire [0:7]aurora_64b66b_1_GT_SERIAL_TX_TXN;
  wire [0:7]aurora_64b66b_1_GT_SERIAL_TX_TXP;
  wire [511:0]aurora_64b66b_1_USER_DATA_M_AXIS_RX_TDATA;
  wire [63:0]aurora_64b66b_1_USER_DATA_M_AXIS_RX_TKEEP;
  wire aurora_64b66b_1_USER_DATA_M_AXIS_RX_TLAST;
  wire aurora_64b66b_1_USER_DATA_M_AXIS_RX_TVALID;
  wire aurora_64b66b_1_channel_up;
  wire aurora_64b66b_1_hard_err;
  wire [0:7]aurora_64b66b_1_lane_up;
  wire aurora_64b66b_1_soft_err;
  wire aurora_64b66b_1_user_clk_out;
  wire [0:0]clk_150m_buff_IBUF_OUT;
  wire [0:0]clk_78m_buff_IBUF_OUT;
  wire [39:0]emax6_0_axi_m_ARADDR;
  wire [1:0]emax6_0_axi_m_ARBURST;
  wire [3:0]emax6_0_axi_m_ARCACHE;
  wire [15:0]emax6_0_axi_m_ARID;
  wire [7:0]emax6_0_axi_m_ARLEN;
  wire [2:0]emax6_0_axi_m_ARPROT;
  wire emax6_0_axi_m_ARREADY;
  wire [2:0]emax6_0_axi_m_ARSIZE;
  wire emax6_0_axi_m_ARVALID;
  wire [39:0]emax6_0_axi_m_AWADDR;
  wire [1:0]emax6_0_axi_m_AWBURST;
  wire [3:0]emax6_0_axi_m_AWCACHE;
  wire [15:0]emax6_0_axi_m_AWID;
  wire [7:0]emax6_0_axi_m_AWLEN;
  wire [2:0]emax6_0_axi_m_AWPROT;
  wire emax6_0_axi_m_AWREADY;
  wire [2:0]emax6_0_axi_m_AWSIZE;
  wire emax6_0_axi_m_AWVALID;
  wire [15:0]emax6_0_axi_m_BID;
  wire emax6_0_axi_m_BREADY;
  wire [1:0]emax6_0_axi_m_BRESP;
  wire emax6_0_axi_m_BVALID;
  wire [255:0]emax6_0_axi_m_RDATA;
  wire [15:0]emax6_0_axi_m_RID;
  wire emax6_0_axi_m_RLAST;
  wire emax6_0_axi_m_RREADY;
  wire [1:0]emax6_0_axi_m_RRESP;
  wire emax6_0_axi_m_RVALID;
  wire [255:0]emax6_0_axi_m_WDATA;
  wire emax6_0_axi_m_WLAST;
  wire emax6_0_axi_m_WREADY;
  wire [31:0]emax6_0_axi_m_WSTRB;
  wire emax6_0_axi_m_WVALID;
  wire [0:0]util_ds_buf_0_BUFG_O;
  wire [0:0]util_ds_buf_1_BUFG_O;
  wire [0:0]util_ds_buf_2_BUFG_O;
  wire [0:0]util_ds_buf_3_BUFG_O;
  wire [0:0]xlconstant_0_dout;

  assign CLK_150M_1_CLK_N = CLK_150M_clk_n[0];
  assign CLK_150M_1_CLK_P = CLK_150M_clk_p[0];
  assign CLK_78M_1_CLK_N = CLK_78M_clk_n[0];
  assign CLK_78M_1_CLK_P = CLK_78M_clk_p[0];
  assign EXT_RESET_1 = EXT_RESET;
  assign GT_DIFF_REFCLK0_1_CLK_N = GT_DIFF_REFCLK0_clk_n;
  assign GT_DIFF_REFCLK0_1_CLK_P = GT_DIFF_REFCLK0_clk_p;
  assign GT_DIFF_REFCLK1_1_CLK_N = GT_DIFF_REFCLK1_clk_n;
  assign GT_DIFF_REFCLK1_1_CLK_P = GT_DIFF_REFCLK1_clk_p;
  assign GT_SERIAL_RX0_1_RXN = GT_SERIAL_RX0_rxn[0:7];
  assign GT_SERIAL_RX0_1_RXP = GT_SERIAL_RX0_rxp[0:7];
  assign GT_SERIAL_RX1_1_RXN = GT_SERIAL_RX1_rxn[0:7];
  assign GT_SERIAL_RX1_1_RXP = GT_SERIAL_RX1_rxp[0:7];
  assign GT_SERIAL_TX0_txn[0:7] = aurora_64b66b_1_GT_SERIAL_TX_TXN;
  assign GT_SERIAL_TX0_txp[0:7] = aurora_64b66b_1_GT_SERIAL_TX_TXP;
  assign GT_SERIAL_TX1_txn[0:7] = aurora_64b66b_0_GT_SERIAL_TX_TXN;
  assign GT_SERIAL_TX1_txp[0:7] = aurora_64b66b_0_GT_SERIAL_TX_TXP;
  assign HEART_BEAT = HEARTBEAT_0_HEART_BEAT;
  assign LINK_UP0 = C2C_MASTER_TOP_0_LINK_UP;
  assign LINK_UP1 = C2C_SLAVE_TOP_0_LINK_UP;
  assign MAIN_RESET_N_1 = MAIN_RESET_N;
  design_1_C2C_MASTER_TOP_0_0 C2C_MASTER_TOP_0
       (.AURORA_CLK(util_ds_buf_3_BUFG_O),
        .AURORA_RESET_N(RESET_CTRL_0_PERI_RESET_N),
        .CH_UP(aurora_64b66b_1_channel_up),
        .HARD_ERR(aurora_64b66b_1_hard_err),
        .LANE_UP({aurora_64b66b_1_lane_up[0],aurora_64b66b_1_lane_up[1],aurora_64b66b_1_lane_up[2],aurora_64b66b_1_lane_up[3],aurora_64b66b_1_lane_up[4],aurora_64b66b_1_lane_up[5],aurora_64b66b_1_lane_up[6],aurora_64b66b_1_lane_up[7]}),
        .LINK_UP(C2C_MASTER_TOP_0_LINK_UP),
        .LOOPBACK(C2C_MASTER_TOP_0_LOOPBACK),
        .M_AXI_ARADDR(C2C_MASTER_TOP_0_M_AXI_ARADDR),
        .M_AXI_ARBURST(C2C_MASTER_TOP_0_M_AXI_ARBURST),
        .M_AXI_ARCACHE(C2C_MASTER_TOP_0_M_AXI_ARCACHE),
        .M_AXI_ARID(C2C_MASTER_TOP_0_M_AXI_ARID),
        .M_AXI_ARLEN(C2C_MASTER_TOP_0_M_AXI_ARLEN),
        .M_AXI_ARPROT(C2C_MASTER_TOP_0_M_AXI_ARPROT),
        .M_AXI_ARREADY(C2C_MASTER_TOP_0_M_AXI_ARREADY),
        .M_AXI_ARSIZE(C2C_MASTER_TOP_0_M_AXI_ARSIZE),
        .M_AXI_ARVALID(C2C_MASTER_TOP_0_M_AXI_ARVALID),
        .M_AXI_AWADDR(C2C_MASTER_TOP_0_M_AXI_AWADDR),
        .M_AXI_AWBURST(C2C_MASTER_TOP_0_M_AXI_AWBURST),
        .M_AXI_AWCACHE(C2C_MASTER_TOP_0_M_AXI_AWCACHE),
        .M_AXI_AWID(C2C_MASTER_TOP_0_M_AXI_AWID),
        .M_AXI_AWLEN(C2C_MASTER_TOP_0_M_AXI_AWLEN),
        .M_AXI_AWPROT(C2C_MASTER_TOP_0_M_AXI_AWPROT),
        .M_AXI_AWREADY(C2C_MASTER_TOP_0_M_AXI_AWREADY),
        .M_AXI_AWSIZE(C2C_MASTER_TOP_0_M_AXI_AWSIZE),
        .M_AXI_AWVALID(C2C_MASTER_TOP_0_M_AXI_AWVALID),
        .M_AXI_BID(C2C_MASTER_TOP_0_M_AXI_BID),
        .M_AXI_BREADY(C2C_MASTER_TOP_0_M_AXI_BREADY),
        .M_AXI_BRESP(C2C_MASTER_TOP_0_M_AXI_BRESP),
        .M_AXI_BVALID(C2C_MASTER_TOP_0_M_AXI_BVALID),
        .M_AXI_CLK(util_ds_buf_1_BUFG_O),
        .M_AXI_RDATA(C2C_MASTER_TOP_0_M_AXI_RDATA),
        .M_AXI_RESET_N(RESET_CTRL_0_PERI_RESET_N),
        .M_AXI_RID(C2C_MASTER_TOP_0_M_AXI_RID),
        .M_AXI_RLAST(C2C_MASTER_TOP_0_M_AXI_RLAST),
        .M_AXI_RREADY(C2C_MASTER_TOP_0_M_AXI_RREADY),
        .M_AXI_RRESP(C2C_MASTER_TOP_0_M_AXI_RRESP),
        .M_AXI_RVALID(C2C_MASTER_TOP_0_M_AXI_RVALID),
        .M_AXI_WDATA(C2C_MASTER_TOP_0_M_AXI_WDATA),
        .M_AXI_WLAST(C2C_MASTER_TOP_0_M_AXI_WLAST),
        .M_AXI_WREADY(C2C_MASTER_TOP_0_M_AXI_WREADY),
        .M_AXI_WSTRB(C2C_MASTER_TOP_0_M_AXI_WSTRB),
        .M_AXI_WVALID(C2C_MASTER_TOP_0_M_AXI_WVALID),
        .POWER_DOWN(C2C_MASTER_TOP_0_POWER_DOWN),
        .RX_TDATA(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TDATA),
        .RX_TKEEP(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TKEEP),
        .RX_TLAST(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TLAST),
        .RX_TVALID(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TVALID),
        .SOFT_ERR(aurora_64b66b_1_soft_err),
        .TX_TDATA(C2C_MASTER_TOP_0_TX_TDATA),
        .TX_TKEEP(C2C_MASTER_TOP_0_TX_TKEEP),
        .TX_TLAST(C2C_MASTER_TOP_0_TX_TLAST),
        .TX_TREADY(C2C_MASTER_TOP_0_TX_TREADY),
        .TX_TVALID(C2C_MASTER_TOP_0_TX_TVALID));
  design_1_C2C_SLAVE_TOP_0_0 C2C_SLAVE_TOP_0
       (.AURORA_CLK(util_ds_buf_2_BUFG_O),
        .AURORA_RESET_N(RESET_CTRL_0_PERI_RESET_N),
        .CH_UP(aurora_64b66b_0_channel_up),
        .HARD_ERR(aurora_64b66b_0_hard_err),
        .LANE_UP({aurora_64b66b_0_lane_up[0],aurora_64b66b_0_lane_up[1],aurora_64b66b_0_lane_up[2],aurora_64b66b_0_lane_up[3],aurora_64b66b_0_lane_up[4],aurora_64b66b_0_lane_up[5],aurora_64b66b_0_lane_up[6],aurora_64b66b_0_lane_up[7]}),
        .LINK_UP(C2C_SLAVE_TOP_0_LINK_UP),
        .LOOPBACK(C2C_SLAVE_TOP_0_LOOPBACK),
        .POWER_DOWN(C2C_SLAVE_TOP_0_POWER_DOWN),
        .RX_TDATA(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TDATA),
        .RX_TKEEP(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TKEEP),
        .RX_TLAST(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TLAST),
        .RX_TVALID(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TVALID),
        .SOFT_ERR(aurora_64b66b_0_soft_err),
        .S_AXI_ARADDR(emax6_0_axi_m_ARADDR),
        .S_AXI_ARBURST(emax6_0_axi_m_ARBURST),
        .S_AXI_ARCACHE(emax6_0_axi_m_ARCACHE),
        .S_AXI_ARID(emax6_0_axi_m_ARID),
        .S_AXI_ARLEN(emax6_0_axi_m_ARLEN),
        .S_AXI_ARLOCK({1'b0,1'b0}),
        .S_AXI_ARPROT(emax6_0_axi_m_ARPROT),
        .S_AXI_ARQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_ARREADY(emax6_0_axi_m_ARREADY),
        .S_AXI_ARSIZE(emax6_0_axi_m_ARSIZE),
        .S_AXI_ARUSER(1'b0),
        .S_AXI_ARVALID(emax6_0_axi_m_ARVALID),
        .S_AXI_AWADDR(emax6_0_axi_m_AWADDR),
        .S_AXI_AWBURST(emax6_0_axi_m_AWBURST),
        .S_AXI_AWCACHE(emax6_0_axi_m_AWCACHE),
        .S_AXI_AWID(emax6_0_axi_m_AWID),
        .S_AXI_AWLEN(emax6_0_axi_m_AWLEN),
        .S_AXI_AWLOCK({1'b0,1'b0}),
        .S_AXI_AWPROT(emax6_0_axi_m_AWPROT),
        .S_AXI_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_AWREADY(emax6_0_axi_m_AWREADY),
        .S_AXI_AWSIZE(emax6_0_axi_m_AWSIZE),
        .S_AXI_AWUSER(1'b0),
        .S_AXI_AWVALID(emax6_0_axi_m_AWVALID),
        .S_AXI_BID(emax6_0_axi_m_BID),
        .S_AXI_BREADY(emax6_0_axi_m_BREADY),
        .S_AXI_BRESP(emax6_0_axi_m_BRESP),
        .S_AXI_BVALID(emax6_0_axi_m_BVALID),
        .S_AXI_CLK(util_ds_buf_1_BUFG_O),
        .S_AXI_RDATA(emax6_0_axi_m_RDATA),
        .S_AXI_RESET_N(RESET_CTRL_0_PERI_RESET_N),
        .S_AXI_RID(emax6_0_axi_m_RID),
        .S_AXI_RLAST(emax6_0_axi_m_RLAST),
        .S_AXI_RREADY(emax6_0_axi_m_RREADY),
        .S_AXI_RRESP(emax6_0_axi_m_RRESP),
        .S_AXI_RVALID(emax6_0_axi_m_RVALID),
        .S_AXI_WDATA(emax6_0_axi_m_WDATA),
        .S_AXI_WLAST(emax6_0_axi_m_WLAST),
        .S_AXI_WREADY(emax6_0_axi_m_WREADY),
        .S_AXI_WSTRB(emax6_0_axi_m_WSTRB),
        .S_AXI_WVALID(emax6_0_axi_m_WVALID),
        .TX_TDATA(C2C_SLAVE_TOP_0_TX_TDATA),
        .TX_TKEEP(C2C_SLAVE_TOP_0_TX_TKEEP),
        .TX_TLAST(C2C_SLAVE_TOP_0_TX_TLAST),
        .TX_TREADY(C2C_SLAVE_TOP_0_TX_TREADY),
        .TX_TVALID(C2C_SLAVE_TOP_0_TX_TVALID));
  design_1_HEARTBEAT_0_0 HEARTBEAT_0
       (.CLK(util_ds_buf_0_BUFG_O),
        .HEART_BEAT(HEARTBEAT_0_HEART_BEAT),
        .RESET_N(RESET_CTRL_0_PERI_RESET_N));
  design_1_RESET_CTRL_0_0 RESET_CTRL_0
       (.DCM_LOCKED(xlconstant_0_dout),
        .EXT_RESET(EXT_RESET_1),
        .MAIN_CLK(util_ds_buf_1_BUFG_O),
        .MAIN_RESET_N(MAIN_RESET_N_1),
        .PERI_RESET_N(RESET_CTRL_0_PERI_RESET_N),
        .PERI_RESET_P(RESET_CTRL_0_PERI_RESET_P),
        .USER_RESET_P(RESET_CTRL_0_USER_RESET_P));
  design_1_aurora_64b66b_0_0 aurora_64b66b_0
       (.channel_up(aurora_64b66b_0_channel_up),
        .gt_refclk1_n(GT_DIFF_REFCLK1_1_CLK_N),
        .gt_refclk1_p(GT_DIFF_REFCLK1_1_CLK_P),
        .gt_rxcdrovrden_in(C2C_SLAVE_TOP_0_POWER_DOWN),
        .hard_err(aurora_64b66b_0_hard_err),
        .init_clk(util_ds_buf_0_BUFG_O),
        .lane_up(aurora_64b66b_0_lane_up),
        .loopback(C2C_SLAVE_TOP_0_LOOPBACK),
        .m_axi_rx_tdata(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TDATA),
        .m_axi_rx_tkeep(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TKEEP),
        .m_axi_rx_tlast(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TLAST),
        .m_axi_rx_tvalid(aurora_64b66b_0_USER_DATA_M_AXIS_RX_TVALID),
        .pma_init(RESET_CTRL_0_USER_RESET_P),
        .power_down(C2C_SLAVE_TOP_0_POWER_DOWN),
        .reset_pb(RESET_CTRL_0_PERI_RESET_P),
        .rxn(GT_SERIAL_RX1_1_RXN),
        .rxp(GT_SERIAL_RX1_1_RXP),
        .s_axi_tx_tdata(C2C_SLAVE_TOP_0_TX_TDATA),
        .s_axi_tx_tkeep(C2C_SLAVE_TOP_0_TX_TKEEP),
        .s_axi_tx_tlast(C2C_SLAVE_TOP_0_TX_TLAST),
        .s_axi_tx_tready(C2C_SLAVE_TOP_0_TX_TREADY),
        .s_axi_tx_tvalid(C2C_SLAVE_TOP_0_TX_TVALID),
        .soft_err(aurora_64b66b_0_soft_err),
        .txn(aurora_64b66b_0_GT_SERIAL_TX_TXN),
        .txp(aurora_64b66b_0_GT_SERIAL_TX_TXP),
        .user_clk_out(aurora_64b66b_0_user_clk_out));
  design_1_aurora_64b66b_1_0 aurora_64b66b_1
       (.channel_up(aurora_64b66b_1_channel_up),
        .gt_refclk1_n(GT_DIFF_REFCLK0_1_CLK_N),
        .gt_refclk1_p(GT_DIFF_REFCLK0_1_CLK_P),
        .gt_rxcdrovrden_in(C2C_MASTER_TOP_0_POWER_DOWN),
        .hard_err(aurora_64b66b_1_hard_err),
        .init_clk(util_ds_buf_0_BUFG_O),
        .lane_up(aurora_64b66b_1_lane_up),
        .loopback(C2C_MASTER_TOP_0_LOOPBACK),
        .m_axi_rx_tdata(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TDATA),
        .m_axi_rx_tkeep(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TKEEP),
        .m_axi_rx_tlast(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TLAST),
        .m_axi_rx_tvalid(aurora_64b66b_1_USER_DATA_M_AXIS_RX_TVALID),
        .pma_init(RESET_CTRL_0_USER_RESET_P),
        .power_down(C2C_MASTER_TOP_0_POWER_DOWN),
        .reset_pb(RESET_CTRL_0_PERI_RESET_P),
        .rxn(GT_SERIAL_RX0_1_RXN),
        .rxp(GT_SERIAL_RX0_1_RXP),
        .s_axi_tx_tdata(C2C_MASTER_TOP_0_TX_TDATA),
        .s_axi_tx_tkeep(C2C_MASTER_TOP_0_TX_TKEEP),
        .s_axi_tx_tlast(C2C_MASTER_TOP_0_TX_TLAST),
        .s_axi_tx_tready(C2C_MASTER_TOP_0_TX_TREADY),
        .s_axi_tx_tvalid(C2C_MASTER_TOP_0_TX_TVALID),
        .soft_err(aurora_64b66b_1_soft_err),
        .txn(aurora_64b66b_1_GT_SERIAL_TX_TXN),
        .txp(aurora_64b66b_1_GT_SERIAL_TX_TXP),
        .user_clk_out(aurora_64b66b_1_user_clk_out));
  design_1_clk_150m_buff_0 clk_150m_buff
       (.IBUF_DS_N(CLK_150M_1_CLK_N),
        .IBUF_DS_P(CLK_150M_1_CLK_P),
        .IBUF_OUT(clk_150m_buff_IBUF_OUT));
  design_1_clk_78m_buff_0 clk_78m_buff
       (.IBUF_DS_N(CLK_78M_1_CLK_N),
        .IBUF_DS_P(CLK_78M_1_CLK_P),
        .IBUF_OUT(clk_78m_buff_IBUF_OUT));
  design_1_emax6_0_0 emax6_0
       (.ACLK(util_ds_buf_1_BUFG_O),
        .ARESETN(RESET_CTRL_0_PERI_RESET_N),
        .axi_m_araddr(emax6_0_axi_m_ARADDR),
        .axi_m_arburst(emax6_0_axi_m_ARBURST),
        .axi_m_arcache(emax6_0_axi_m_ARCACHE),
        .axi_m_arid(emax6_0_axi_m_ARID),
        .axi_m_arlen(emax6_0_axi_m_ARLEN),
        .axi_m_arprot(emax6_0_axi_m_ARPROT),
        .axi_m_arready(emax6_0_axi_m_ARREADY),
        .axi_m_arsize(emax6_0_axi_m_ARSIZE),
        .axi_m_arvalid(emax6_0_axi_m_ARVALID),
        .axi_m_awaddr(emax6_0_axi_m_AWADDR),
        .axi_m_awburst(emax6_0_axi_m_AWBURST),
        .axi_m_awcache(emax6_0_axi_m_AWCACHE),
        .axi_m_awid(emax6_0_axi_m_AWID),
        .axi_m_awlen(emax6_0_axi_m_AWLEN),
        .axi_m_awprot(emax6_0_axi_m_AWPROT),
        .axi_m_awready(emax6_0_axi_m_AWREADY),
        .axi_m_awsize(emax6_0_axi_m_AWSIZE),
        .axi_m_awvalid(emax6_0_axi_m_AWVALID),
        .axi_m_bid(emax6_0_axi_m_BID),
        .axi_m_bready(emax6_0_axi_m_BREADY),
        .axi_m_bresp(emax6_0_axi_m_BRESP),
        .axi_m_bvalid(emax6_0_axi_m_BVALID),
        .axi_m_rdata(emax6_0_axi_m_RDATA),
        .axi_m_rid(emax6_0_axi_m_RID),
        .axi_m_rlast(emax6_0_axi_m_RLAST),
        .axi_m_rready(emax6_0_axi_m_RREADY),
        .axi_m_rresp(emax6_0_axi_m_RRESP),
        .axi_m_rvalid(emax6_0_axi_m_RVALID),
        .axi_m_wdata(emax6_0_axi_m_WDATA),
        .axi_m_wlast(emax6_0_axi_m_WLAST),
        .axi_m_wready(emax6_0_axi_m_WREADY),
        .axi_m_wstrb(emax6_0_axi_m_WSTRB),
        .axi_m_wvalid(emax6_0_axi_m_WVALID),
        .axi_s_araddr(C2C_MASTER_TOP_0_M_AXI_ARADDR),
        .axi_s_arburst(C2C_MASTER_TOP_0_M_AXI_ARBURST),
        .axi_s_arcache(C2C_MASTER_TOP_0_M_AXI_ARCACHE),
        .axi_s_arid(C2C_MASTER_TOP_0_M_AXI_ARID),
        .axi_s_arlen(C2C_MASTER_TOP_0_M_AXI_ARLEN),
        .axi_s_arprot(C2C_MASTER_TOP_0_M_AXI_ARPROT),
        .axi_s_arready(C2C_MASTER_TOP_0_M_AXI_ARREADY),
        .axi_s_arsize(C2C_MASTER_TOP_0_M_AXI_ARSIZE),
        .axi_s_arvalid(C2C_MASTER_TOP_0_M_AXI_ARVALID),
        .axi_s_awaddr(C2C_MASTER_TOP_0_M_AXI_AWADDR),
        .axi_s_awburst(C2C_MASTER_TOP_0_M_AXI_AWBURST),
        .axi_s_awcache(C2C_MASTER_TOP_0_M_AXI_AWCACHE),
        .axi_s_awid(C2C_MASTER_TOP_0_M_AXI_AWID),
        .axi_s_awlen(C2C_MASTER_TOP_0_M_AXI_AWLEN),
        .axi_s_awprot(C2C_MASTER_TOP_0_M_AXI_AWPROT),
        .axi_s_awready(C2C_MASTER_TOP_0_M_AXI_AWREADY),
        .axi_s_awsize(C2C_MASTER_TOP_0_M_AXI_AWSIZE),
        .axi_s_awvalid(C2C_MASTER_TOP_0_M_AXI_AWVALID),
        .axi_s_bid(C2C_MASTER_TOP_0_M_AXI_BID),
        .axi_s_bready(C2C_MASTER_TOP_0_M_AXI_BREADY),
        .axi_s_bresp(C2C_MASTER_TOP_0_M_AXI_BRESP),
        .axi_s_bvalid(C2C_MASTER_TOP_0_M_AXI_BVALID),
        .axi_s_rdata(C2C_MASTER_TOP_0_M_AXI_RDATA),
        .axi_s_rid(C2C_MASTER_TOP_0_M_AXI_RID),
        .axi_s_rlast(C2C_MASTER_TOP_0_M_AXI_RLAST),
        .axi_s_rready(C2C_MASTER_TOP_0_M_AXI_RREADY),
        .axi_s_rresp(C2C_MASTER_TOP_0_M_AXI_RRESP),
        .axi_s_rvalid(C2C_MASTER_TOP_0_M_AXI_RVALID),
        .axi_s_wdata(C2C_MASTER_TOP_0_M_AXI_WDATA),
        .axi_s_wlast(C2C_MASTER_TOP_0_M_AXI_WLAST),
        .axi_s_wready(C2C_MASTER_TOP_0_M_AXI_WREADY),
        .axi_s_wstrb(C2C_MASTER_TOP_0_M_AXI_WSTRB),
        .axi_s_wvalid(C2C_MASTER_TOP_0_M_AXI_WVALID),
        .next_linkup(C2C_SLAVE_TOP_0_LINK_UP));
  design_1_util_ds_buf_0_0 util_ds_buf_0
       (.BUFG_I(clk_78m_buff_IBUF_OUT),
        .BUFG_O(util_ds_buf_0_BUFG_O));
  design_1_util_ds_buf_1_0 util_ds_buf_1
       (.BUFG_I(clk_150m_buff_IBUF_OUT),
        .BUFG_O(util_ds_buf_1_BUFG_O));
  design_1_util_ds_buf_2_0 util_ds_buf_2
       (.BUFG_I(aurora_64b66b_0_user_clk_out),
        .BUFG_O(util_ds_buf_2_BUFG_O));
  design_1_util_ds_buf_3_0 util_ds_buf_3
       (.BUFG_I(aurora_64b66b_1_user_clk_out),
        .BUFG_O(util_ds_buf_3_BUFG_O));
  design_1_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
