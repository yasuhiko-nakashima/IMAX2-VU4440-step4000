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


// IP VLNV: xilinx.com:module_ref:emax6:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_emax6_0_0 (
  ACLK,
  ARESETN,
  axi_s_arvalid,
  axi_s_arready,
  axi_s_araddr,
  axi_s_arlen,
  axi_s_arsize,
  axi_s_arburst,
  axi_s_arcache,
  axi_s_arprot,
  axi_s_arid,
  axi_s_rvalid,
  axi_s_rready,
  axi_s_rlast,
  axi_s_rdata,
  axi_s_rresp,
  axi_s_rid,
  axi_s_awvalid,
  axi_s_awready,
  axi_s_awaddr,
  axi_s_awlen,
  axi_s_awsize,
  axi_s_awburst,
  axi_s_awcache,
  axi_s_awprot,
  axi_s_awid,
  axi_s_wvalid,
  axi_s_wready,
  axi_s_wlast,
  axi_s_wdata,
  axi_s_wstrb,
  axi_s_bvalid,
  axi_s_bready,
  axi_s_bresp,
  axi_s_bid,
  axi_m_arvalid,
  axi_m_arready,
  axi_m_araddr,
  axi_m_arlen,
  axi_m_arsize,
  axi_m_arburst,
  axi_m_arcache,
  axi_m_arprot,
  axi_m_arid,
  axi_m_rvalid,
  axi_m_rready,
  axi_m_rlast,
  axi_m_rdata,
  axi_m_rresp,
  axi_m_rid,
  axi_m_awvalid,
  axi_m_awready,
  axi_m_awaddr,
  axi_m_awlen,
  axi_m_awsize,
  axi_m_awburst,
  axi_m_awcache,
  axi_m_awprot,
  axi_m_awid,
  axi_m_wvalid,
  axi_m_wready,
  axi_m_wlast,
  axi_m_wdata,
  axi_m_wstrb,
  axi_m_bvalid,
  axi_m_bready,
  axi_m_bresp,
  axi_m_bid,
  next_linkup
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF axi_m:axi_s, ASSOCIATED_RESET ARESETN, FREQ_HZ 150000000, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ACLK CLK" *)
input wire ACLK;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ARESETN RST" *)
input wire ARESETN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARVALID" *)
input wire axi_s_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARREADY" *)
output wire axi_s_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARADDR" *)
input wire [39 : 0] axi_s_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARLEN" *)
input wire [7 : 0] axi_s_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARSIZE" *)
input wire [2 : 0] axi_s_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARBURST" *)
input wire [1 : 0] axi_s_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARCACHE" *)
input wire [3 : 0] axi_s_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARPROT" *)
input wire [2 : 0] axi_s_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s ARID" *)
input wire [15 : 0] axi_s_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RVALID" *)
output wire axi_s_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RREADY" *)
input wire axi_s_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RLAST" *)
output wire axi_s_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RDATA" *)
output wire [255 : 0] axi_s_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RRESP" *)
output wire [1 : 0] axi_s_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s RID" *)
output wire [15 : 0] axi_s_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWVALID" *)
input wire axi_s_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWREADY" *)
output wire axi_s_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWADDR" *)
input wire [39 : 0] axi_s_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWLEN" *)
input wire [7 : 0] axi_s_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWSIZE" *)
input wire [2 : 0] axi_s_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWBURST" *)
input wire [1 : 0] axi_s_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWCACHE" *)
input wire [3 : 0] axi_s_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWPROT" *)
input wire [2 : 0] axi_s_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s AWID" *)
input wire [15 : 0] axi_s_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s WVALID" *)
input wire axi_s_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s WREADY" *)
output wire axi_s_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s WLAST" *)
input wire axi_s_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s WDATA" *)
input wire [255 : 0] axi_s_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s WSTRB" *)
input wire [31 : 0] axi_s_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s BVALID" *)
output wire axi_s_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s BREADY" *)
input wire axi_s_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s BRESP" *)
output wire [1 : 0] axi_s_bresp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_s, DATA_WIDTH 256, PROTOCOL AXI4, FREQ_HZ 150000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, NUM_READ_THREADS 1, NUM\
_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_s BID" *)
output wire [15 : 0] axi_s_bid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARVALID" *)
output wire axi_m_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARREADY" *)
input wire axi_m_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARADDR" *)
output wire [39 : 0] axi_m_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARLEN" *)
output wire [7 : 0] axi_m_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARSIZE" *)
output wire [2 : 0] axi_m_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARBURST" *)
output wire [1 : 0] axi_m_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARCACHE" *)
output wire [3 : 0] axi_m_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARPROT" *)
output wire [2 : 0] axi_m_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m ARID" *)
output wire [15 : 0] axi_m_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RVALID" *)
input wire axi_m_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RREADY" *)
output wire axi_m_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RLAST" *)
input wire axi_m_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RDATA" *)
input wire [255 : 0] axi_m_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RRESP" *)
input wire [1 : 0] axi_m_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m RID" *)
input wire [15 : 0] axi_m_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWVALID" *)
output wire axi_m_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWREADY" *)
input wire axi_m_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWADDR" *)
output wire [39 : 0] axi_m_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWLEN" *)
output wire [7 : 0] axi_m_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWSIZE" *)
output wire [2 : 0] axi_m_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWBURST" *)
output wire [1 : 0] axi_m_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWCACHE" *)
output wire [3 : 0] axi_m_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWPROT" *)
output wire [2 : 0] axi_m_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m AWID" *)
output wire [15 : 0] axi_m_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m WVALID" *)
output wire axi_m_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m WREADY" *)
input wire axi_m_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m WLAST" *)
output wire axi_m_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m WDATA" *)
output wire [255 : 0] axi_m_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m WSTRB" *)
output wire [31 : 0] axi_m_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m BVALID" *)
input wire axi_m_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m BREADY" *)
output wire axi_m_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m BRESP" *)
input wire [1 : 0] axi_m_bresp;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_m, DATA_WIDTH 256, PROTOCOL AXI4, FREQ_HZ 150000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN design_1_clk_150m_buff_0_IBUF_OUT, NUM_READ_THREADS 1, NUM\
_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_m BID" *)
input wire [15 : 0] axi_m_bid;
input wire next_linkup;

  emax6 inst (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .axi_s_arvalid(axi_s_arvalid),
    .axi_s_arready(axi_s_arready),
    .axi_s_araddr(axi_s_araddr),
    .axi_s_arlen(axi_s_arlen),
    .axi_s_arsize(axi_s_arsize),
    .axi_s_arburst(axi_s_arburst),
    .axi_s_arcache(axi_s_arcache),
    .axi_s_arprot(axi_s_arprot),
    .axi_s_arid(axi_s_arid),
    .axi_s_rvalid(axi_s_rvalid),
    .axi_s_rready(axi_s_rready),
    .axi_s_rlast(axi_s_rlast),
    .axi_s_rdata(axi_s_rdata),
    .axi_s_rresp(axi_s_rresp),
    .axi_s_rid(axi_s_rid),
    .axi_s_awvalid(axi_s_awvalid),
    .axi_s_awready(axi_s_awready),
    .axi_s_awaddr(axi_s_awaddr),
    .axi_s_awlen(axi_s_awlen),
    .axi_s_awsize(axi_s_awsize),
    .axi_s_awburst(axi_s_awburst),
    .axi_s_awcache(axi_s_awcache),
    .axi_s_awprot(axi_s_awprot),
    .axi_s_awid(axi_s_awid),
    .axi_s_wvalid(axi_s_wvalid),
    .axi_s_wready(axi_s_wready),
    .axi_s_wlast(axi_s_wlast),
    .axi_s_wdata(axi_s_wdata),
    .axi_s_wstrb(axi_s_wstrb),
    .axi_s_bvalid(axi_s_bvalid),
    .axi_s_bready(axi_s_bready),
    .axi_s_bresp(axi_s_bresp),
    .axi_s_bid(axi_s_bid),
    .axi_m_arvalid(axi_m_arvalid),
    .axi_m_arready(axi_m_arready),
    .axi_m_araddr(axi_m_araddr),
    .axi_m_arlen(axi_m_arlen),
    .axi_m_arsize(axi_m_arsize),
    .axi_m_arburst(axi_m_arburst),
    .axi_m_arcache(axi_m_arcache),
    .axi_m_arprot(axi_m_arprot),
    .axi_m_arid(axi_m_arid),
    .axi_m_rvalid(axi_m_rvalid),
    .axi_m_rready(axi_m_rready),
    .axi_m_rlast(axi_m_rlast),
    .axi_m_rdata(axi_m_rdata),
    .axi_m_rresp(axi_m_rresp),
    .axi_m_rid(axi_m_rid),
    .axi_m_awvalid(axi_m_awvalid),
    .axi_m_awready(axi_m_awready),
    .axi_m_awaddr(axi_m_awaddr),
    .axi_m_awlen(axi_m_awlen),
    .axi_m_awsize(axi_m_awsize),
    .axi_m_awburst(axi_m_awburst),
    .axi_m_awcache(axi_m_awcache),
    .axi_m_awprot(axi_m_awprot),
    .axi_m_awid(axi_m_awid),
    .axi_m_wvalid(axi_m_wvalid),
    .axi_m_wready(axi_m_wready),
    .axi_m_wlast(axi_m_wlast),
    .axi_m_wdata(axi_m_wdata),
    .axi_m_wstrb(axi_m_wstrb),
    .axi_m_bvalid(axi_m_bvalid),
    .axi_m_bready(axi_m_bready),
    .axi_m_bresp(axi_m_bresp),
    .axi_m_bid(axi_m_bid),
    .next_linkup(next_linkup)
  );
endmodule
