// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:C2C_SLAVE_TOP:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_C2C_SLAVE_TOP_0_0 (
  S_AXI_CLK,
  S_AXI_RESET_N,
  S_AXI_AWID,
  S_AXI_AWADDR,
  S_AXI_AWLEN,
  S_AXI_AWSIZE,
  S_AXI_AWBURST,
  S_AXI_AWLOCK,
  S_AXI_AWCACHE,
  S_AXI_AWPROT,
  S_AXI_AWQOS,
  S_AXI_AWUSER,
  S_AXI_AWVALID,
  S_AXI_AWREADY,
  S_AXI_WDATA,
  S_AXI_WSTRB,
  S_AXI_WLAST,
  S_AXI_WVALID,
  S_AXI_WREADY,
  S_AXI_BID,
  S_AXI_BRESP,
  S_AXI_BVALID,
  S_AXI_BREADY,
  S_AXI_ARID,
  S_AXI_ARADDR,
  S_AXI_ARLEN,
  S_AXI_ARSIZE,
  S_AXI_ARBURST,
  S_AXI_ARLOCK,
  S_AXI_ARCACHE,
  S_AXI_ARPROT,
  S_AXI_ARQOS,
  S_AXI_ARUSER,
  S_AXI_ARVALID,
  S_AXI_ARREADY,
  S_AXI_RID,
  S_AXI_RDATA,
  S_AXI_RRESP,
  S_AXI_RLAST,
  S_AXI_RVALID,
  S_AXI_RREADY,
  AURORA_CLK,
  AURORA_RESET_N,
  HARD_ERR,
  SOFT_ERR,
  CH_UP,
  LANE_UP,
  LINK_UP,
  POWER_DOWN,
  LOOPBACK,
  TX_TDATA,
  TX_TLAST,
  TX_TKEEP,
  TX_TVALID,
  TX_TREADY,
  RX_TDATA,
  RX_TLAST,
  RX_TKEEP,
  RX_TVALID
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_CLK, ASSOCIATED_BUSIF S_AXI, FREQ_HZ 150000000, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_CLK CLK" *)
input wire S_AXI_CLK;
input wire S_AXI_RESET_N;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWID" *)
input wire [15 : 0] S_AXI_AWID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *)
input wire [39 : 0] S_AXI_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLEN" *)
input wire [7 : 0] S_AXI_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWSIZE" *)
input wire [2 : 0] S_AXI_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWBURST" *)
input wire [1 : 0] S_AXI_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLOCK" *)
input wire [1 : 0] S_AXI_AWLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWCACHE" *)
input wire [3 : 0] S_AXI_AWCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *)
input wire [2 : 0] S_AXI_AWPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWQOS" *)
input wire [3 : 0] S_AXI_AWQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWUSER" *)
input wire S_AXI_AWUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *)
input wire S_AXI_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *)
output wire S_AXI_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *)
input wire [255 : 0] S_AXI_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *)
input wire [31 : 0] S_AXI_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WLAST" *)
input wire S_AXI_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *)
input wire S_AXI_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *)
output wire S_AXI_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BID" *)
output wire [15 : 0] S_AXI_BID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *)
output wire [1 : 0] S_AXI_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *)
output wire S_AXI_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *)
input wire S_AXI_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARID" *)
input wire [15 : 0] S_AXI_ARID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *)
input wire [39 : 0] S_AXI_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARLEN" *)
input wire [7 : 0] S_AXI_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARSIZE" *)
input wire [2 : 0] S_AXI_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARBURST" *)
input wire [1 : 0] S_AXI_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARLOCK" *)
input wire [1 : 0] S_AXI_ARLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARCACHE" *)
input wire [3 : 0] S_AXI_ARCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARPROT" *)
input wire [2 : 0] S_AXI_ARPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARQOS" *)
input wire [3 : 0] S_AXI_ARQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARUSER" *)
input wire S_AXI_ARUSER;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *)
input wire S_AXI_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *)
output wire S_AXI_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RID" *)
output wire [15 : 0] S_AXI_RID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *)
output wire [255 : 0] S_AXI_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *)
output wire [1 : 0] S_AXI_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RLAST" *)
output wire S_AXI_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *)
output wire S_AXI_RVALID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, DATA_WIDTH 256, PROTOCOL AXI4, FREQ_HZ 150000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 1, ARUSER_WIDTH 1, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, NUM_READ_THREADS 1, NUM\
_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *)
input wire S_AXI_RREADY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME AURORA_CLK, FREQ_HZ 78125000, PHASE 0, CLK_DOMAIN design_1_aurora_64b66b_0_0_user_clk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 AURORA_CLK CLK" *)
input wire AURORA_CLK;
input wire AURORA_RESET_N;
input wire HARD_ERR;
input wire SOFT_ERR;
input wire CH_UP;
input wire [7 : 0] LANE_UP;
output wire LINK_UP;
output wire POWER_DOWN;
output wire [2 : 0] LOOPBACK;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX TDATA" *)
output wire [511 : 0] TX_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX TLAST" *)
output wire TX_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX TKEEP" *)
output wire [63 : 0] TX_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX TVALID" *)
output wire TX_TVALID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME TX, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 78125000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX TREADY" *)
input wire TX_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TDATA" *)
input wire [511 : 0] RX_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TLAST" *)
input wire RX_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TKEEP" *)
input wire [63 : 0] RX_TKEEP;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RX, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 78125000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX TVALID" *)
input wire RX_TVALID;

  C2C_SLAVE_TOP inst (
    .S_AXI_CLK(S_AXI_CLK),
    .S_AXI_RESET_N(S_AXI_RESET_N),
    .S_AXI_AWID(S_AXI_AWID),
    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWLEN(S_AXI_AWLEN),
    .S_AXI_AWSIZE(S_AXI_AWSIZE),
    .S_AXI_AWBURST(S_AXI_AWBURST),
    .S_AXI_AWLOCK(S_AXI_AWLOCK),
    .S_AXI_AWCACHE(S_AXI_AWCACHE),
    .S_AXI_AWPROT(S_AXI_AWPROT),
    .S_AXI_AWQOS(S_AXI_AWQOS),
    .S_AXI_AWUSER(S_AXI_AWUSER),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WLAST(S_AXI_WLAST),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),
    .S_AXI_BID(S_AXI_BID),
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),
    .S_AXI_ARID(S_AXI_ARID),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARLEN(S_AXI_ARLEN),
    .S_AXI_ARSIZE(S_AXI_ARSIZE),
    .S_AXI_ARBURST(S_AXI_ARBURST),
    .S_AXI_ARLOCK(S_AXI_ARLOCK),
    .S_AXI_ARCACHE(S_AXI_ARCACHE),
    .S_AXI_ARPROT(S_AXI_ARPROT),
    .S_AXI_ARQOS(S_AXI_ARQOS),
    .S_AXI_ARUSER(S_AXI_ARUSER),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RID(S_AXI_RID),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RLAST(S_AXI_RLAST),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),
    .AURORA_CLK(AURORA_CLK),
    .AURORA_RESET_N(AURORA_RESET_N),
    .HARD_ERR(HARD_ERR),
    .SOFT_ERR(SOFT_ERR),
    .CH_UP(CH_UP),
    .LANE_UP(LANE_UP),
    .LINK_UP(LINK_UP),
    .POWER_DOWN(POWER_DOWN),
    .LOOPBACK(LOOPBACK),
    .TX_TDATA(TX_TDATA),
    .TX_TLAST(TX_TLAST),
    .TX_TKEEP(TX_TKEEP),
    .TX_TVALID(TX_TVALID),
    .TX_TREADY(TX_TREADY),
    .RX_TDATA(RX_TDATA),
    .RX_TLAST(RX_TLAST),
    .RX_TKEEP(RX_TKEEP),
    .RX_TVALID(RX_TVALID)
  );
endmodule
