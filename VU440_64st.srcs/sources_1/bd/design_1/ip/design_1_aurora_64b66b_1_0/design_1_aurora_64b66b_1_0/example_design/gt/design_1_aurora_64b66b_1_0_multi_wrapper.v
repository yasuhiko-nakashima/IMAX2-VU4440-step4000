 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2014 Xilinx, Inc. All rights reserved.
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
 //
 ////////////////////////////////////////////////////////////////////////////////
 // Design Name: design_1_aurora_64b66b_1_0_MULTI_GT
 //

 // Multi GT wrapper for ultrascale series

 `timescale 1ns / 1ps
 `define DLY #1

   (* core_generation_info = "design_1_aurora_64b66b_1_0,aurora_64b66b_v11_2_6,{c_aurora_lanes=8,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=2,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=3,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=4,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=5,c_gt_loc_6=6,c_gt_loc_7=7,c_gt_loc_8=8,c_gt_loc_9=X,c_lane_width=4,c_line_rate=5.0,c_gt_type=GTHE3,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156.25,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
 module design_1_aurora_64b66b_1_0_MULTI_GT
 (
    // GT reset module interface ports starts
    input           gtwiz_reset_all_in                ,
    input           gtwiz_reset_clk_freerun_in        ,
    input           gtwiz_reset_tx_pll_and_datapath_in,
    input           gtwiz_reset_tx_datapath_in        ,
    input           gtwiz_reset_rx_pll_and_datapath_in,
    input           gtwiz_reset_rx_datapath_in        ,
    input           gtwiz_reset_rx_data_good_in       ,

    output          gtwiz_reset_rx_cdr_stable_out     ,
    output          gtwiz_reset_tx_done_out           ,
    output          gtwiz_reset_rx_done_out           ,

    // GT reset module interface ports ends
    output          fabric_pcs_reset                  ,
    output          bufg_gt_clr_out             ,
    input           gtwiz_userclk_tx_active_out       ,

    output          userclk_rx_active_out             ,

    //____________________________CHANNEL PORTS________________________________
    //------------------------------- CPLL Ports -------------------------------
    //------------------------ Channel - Clocking Ports ------------------------
     output [7:0]         gt_cplllock,

    input           gt0_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt0_drpaddr,
    input           gt0_drp_clk_in,
    input  [15:0]   gt0_drpdi,
    output [15:0]   gt0_drpdo,
    input           gt0_drpen,
    output          gt0_drprdy,
    input           gt0_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt0_rxusrclk_out,
    output          gt0_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt0_txusrclk_in,
    input           gt0_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    input  [23:0]       gt_loopback,
    //------------------- RX Initialization and Reset Ports --------------------
    input  [7:0]         gt_eyescanreset,
    input  [7:0]         gt_rxpolarity,
    //------------------------ RX Margin Analysis Ports ------------------------
    output [7:0]         gt_eyescandataerror,
    input  [7:0]         gt_eyescantrigger,
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt0_rxcdrovrden_in,
    input  [7:0]         gt_rxcdrhold,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt0_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt0_gthrxn_in,
    input                                           gt0_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    output  [23:0]      gt_rxbufstatus,
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    input   [7:0]        gt_rxdfelpmreset,
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt0_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt0_rxdatavalid_out,
    output [1:0]                                    gt0_rxheader_out,
    output                                          gt0_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt0_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    input  [7:0]         gt_rxlpmen,
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    input  [7:0]         gt_gtrxreset,
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    output [7:0]         gt_rxresetdone,
    //---------------------- TX Configurable Driver Ports ----------------------
    input  [39:0]       gt_txpostcursor,
    //------------------- TX Initialization and Reset Ports --------------------
    input  [7:0]         gt_gttxreset,

    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt0_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    input   [31:0]      gt_txdiffctrl,
    output [135:0]      gt_dmonitorout,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt0_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt0_gthtxn_out,
    output                                           gt0_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt0_txoutclk_out,
    output                                           gt0_txoutclkfabric_out,
    output                                           gt0_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt0_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt1_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt1_drpaddr,
    input           gt1_drp_clk_in,
    input  [15:0]   gt1_drpdi,
    output [15:0]   gt1_drpdo,
    input           gt1_drpen,
    output          gt1_drprdy,
    input           gt1_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt1_rxusrclk_out,
    output          gt1_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt1_txusrclk_in,
    input           gt1_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt1_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt1_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt1_gthrxn_in,
    input                                           gt1_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt1_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt1_rxdatavalid_out,
    output [1:0]                                    gt1_rxheader_out,
    output                                          gt1_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt1_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt1_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt1_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt1_gthtxn_out,
    output                                           gt1_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt1_txoutclk_out,
    output                                           gt1_txoutclkfabric_out,
    output                                           gt1_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt1_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt2_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt2_drpaddr,
    input           gt2_drp_clk_in,
    input  [15:0]   gt2_drpdi,
    output [15:0]   gt2_drpdo,
    input           gt2_drpen,
    output          gt2_drprdy,
    input           gt2_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt2_rxusrclk_out,
    output          gt2_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt2_txusrclk_in,
    input           gt2_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt2_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt2_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt2_gthrxn_in,
    input                                           gt2_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt2_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt2_rxdatavalid_out,
    output [1:0]                                    gt2_rxheader_out,
    output                                          gt2_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt2_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt2_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt2_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt2_gthtxn_out,
    output                                           gt2_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt2_txoutclk_out,
    output                                           gt2_txoutclkfabric_out,
    output                                           gt2_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt2_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt3_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt3_drpaddr,
    input           gt3_drp_clk_in,
    input  [15:0]   gt3_drpdi,
    output [15:0]   gt3_drpdo,
    input           gt3_drpen,
    output          gt3_drprdy,
    input           gt3_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt3_rxusrclk_out,
    output          gt3_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt3_txusrclk_in,
    input           gt3_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt3_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt3_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt3_gthrxn_in,
    input                                           gt3_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt3_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt3_rxdatavalid_out,
    output [1:0]                                    gt3_rxheader_out,
    output                                          gt3_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt3_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt3_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt3_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt3_gthtxn_out,
    output                                           gt3_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt3_txoutclk_out,
    output                                           gt3_txoutclkfabric_out,
    output                                           gt3_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt3_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt4_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt4_drpaddr,
    input           gt4_drp_clk_in,
    input  [15:0]   gt4_drpdi,
    output [15:0]   gt4_drpdo,
    input           gt4_drpen,
    output          gt4_drprdy,
    input           gt4_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt4_rxusrclk_out,
    output          gt4_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt4_txusrclk_in,
    input           gt4_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt4_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt4_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt4_gthrxn_in,
    input                                           gt4_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt4_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt4_rxdatavalid_out,
    output [1:0]                                    gt4_rxheader_out,
    output                                          gt4_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt4_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt4_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt4_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt4_gthtxn_out,
    output                                           gt4_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt4_txoutclk_out,
    output                                           gt4_txoutclkfabric_out,
    output                                           gt4_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt4_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt5_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt5_drpaddr,
    input           gt5_drp_clk_in,
    input  [15:0]   gt5_drpdi,
    output [15:0]   gt5_drpdo,
    input           gt5_drpen,
    output          gt5_drprdy,
    input           gt5_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt5_rxusrclk_out,
    output          gt5_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt5_txusrclk_in,
    input           gt5_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt5_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt5_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt5_gthrxn_in,
    input                                           gt5_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt5_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt5_rxdatavalid_out,
    output [1:0]                                    gt5_rxheader_out,
    output                                          gt5_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt5_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt5_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt5_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt5_gthtxn_out,
    output                                           gt5_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt5_txoutclk_out,
    output                                           gt5_txoutclkfabric_out,
    output                                           gt5_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt5_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt6_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt6_drpaddr,
    input           gt6_drp_clk_in,
    input  [15:0]   gt6_drpdi,
    output [15:0]   gt6_drpdo,
    input           gt6_drpen,
    output          gt6_drprdy,
    input           gt6_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt6_rxusrclk_out,
    output          gt6_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt6_txusrclk_in,
    input           gt6_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt6_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt6_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt6_gthrxn_in,
    input                                           gt6_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt6_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt6_rxdatavalid_out,
    output [1:0]                                    gt6_rxheader_out,
    output                                          gt6_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt6_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt6_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt6_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt6_gthtxn_out,
    output                                           gt6_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt6_txoutclk_out,
    output                                           gt6_txoutclkfabric_out,
    output                                           gt6_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt6_txsequence_in,
    //------------------------ Channel - Clocking Ports ------------------------

    input           gt7_gtrefclk0_in,
    //-------------------------- Channel - DRP Ports  --------------------------
 
    input  [8:0]    gt7_drpaddr,
    input           gt7_drp_clk_in,
    input  [15:0]   gt7_drpdi,
    output [15:0]   gt7_drpdo,
    input           gt7_drpen,
    output          gt7_drprdy,
    input           gt7_drpwe,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output          gt7_rxusrclk_out,
    output          gt7_rxusrclk2_out,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input           gt7_txusrclk_in,
    input           gt7_txusrclk2_in,
    //----------------------------- Loopback Ports -----------------------------
    //----------------------- Receive Ports - CDR Ports ------------------------
    input                                           gt7_rxcdrovrden_in,
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    output  [31:0]                                  gt7_rxdata_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input                                           gt7_gthrxn_in,
    input                                           gt7_gthrxp_in,
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output                                          gt7_rxoutclk_out,
    //-------------------- Receive Ports - RX Gearbox Ports --------------------
    output                                          gt7_rxdatavalid_out,
    output [1:0]                                    gt7_rxheader_out,
    output                                          gt7_rxheadervalid_out,
    //------------------- Receive Ports - RX Gearbox Ports  --------------------
    input                                           gt7_rxgearboxslip_in,
    //---------------- Receive Ports - RX Margin Analysis ports ----------------
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input  [1:0]    gt7_txheader_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input  [63:0]                                    gt7_txdata_in,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output                                           gt7_gthtxn_out,
    output                                           gt7_gthtxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output                                           gt7_txoutclk_out,
    output                                           gt7_txoutclkfabric_out,
    output                                           gt7_txoutclkpcs_out,
    //---------------  ---- Transmit Ports - TX Gearbox Ports --------------------
    input  [6:0]                                     gt7_txsequence_in,
    //--------------- Transmit Ports - TX Polarity Control Ports ---------------
    input  [7:0]         gt_txpolarity,
    input  [7:0]         gt_txinhibit,
    input  [127:0]  gt_pcsrsvdin,
    input  [7:0]         gt_txpmareset,
    input  [7:0]         gt_txpcsreset,
    input  [7:0]         gt_rxpcsreset,
    input  [7:0]         gt_rxbufreset,
    output [7:0]         gt_rxpmaresetdone,
    input  [39:0]       gt_txprecursor,
    input  [31:0]       gt_txprbssel,
    input  [31:0]       gt_rxprbssel,
    input  [7:0]         gt_txprbsforceerr,
    output [7:0]         gt_rxprbserr,
    input  [7:0]         gt_rxprbscntreset,
    output [15:0]       gt_txbufstatus,
    input  [7:0]         gt_rxpmareset,
    input  [23:0]       gt_rxrate,
    //----------- GT POWERGOOD STATUS Port -----------
    output [7:0]         gt_powergood,
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    output [7:0]         gt_txresetdone

 );

 //***************************** Wire Declarations *****************************
     // Ground and VCC signals
     wire                    tied_to_ground_i;
     wire    [280:0]         tied_to_ground_vec_i;
     wire                    tied_to_vcc_i;
 //********************************* Main Body of Code**************************
     //-------------------------  Static signal Assigments ---------------------
     assign tied_to_ground_i          = 1'b0;
     assign tied_to_ground_vec_i      = 281'd0;
     assign tied_to_vcc_i             = 1'b1;

// wire definition starts
    wire                                            gtwiz_userclk_tx_active_out_i;   

    wire  [7 : 0] gtrefclk0_in      ;

    wire  [7 : 0] cplllock_out      ;

    //--------------------------------------------------------------------------

 
    wire  [71 : 0 ] drpaddr_in;
    wire  [7 : 0 ] drpclk_in;
    wire  [127 : 0 ] drpdi_in  ;
    wire  [127 : 0 ] drpdo_out ;
    wire  [7 : 0 ] drpen_in  ;
    wire  [7 : 0 ] drprdy_out;
    wire  [7 : 0 ] drpwe_in  ;

    wire  [23 : 0 ] loopback_in;

    wire  [15 : 0 ] rxstartofseq_out;

    wire  [7 : 0 ] eyescanreset_in;
    wire  [7 : 0 ] rxpolarity_in  ;

    wire  [7 : 0 ] eyescandataerror_out;
    wire  [7 : 0 ] eyescantrigger_in   ;

    wire  [7 : 0 ] rxcdrovrden_in;
    wire  [7 : 0 ] rxcdrhold_in  ;
    wire  [255: 0 ] gtwiz_userdata_rx_out;
 
    wire  [7 : 0 ] gthrxn_in     ;
    wire  [7 : 0 ] gthrxp_in     ;
    wire  [23 : 0 ] rxbufstatus_out    ;//
    wire  [7 : 0 ] rxdfelpmreset_in   ;//
    wire  [7 : 0 ] rxoutclk_out       ;//
    wire  [15 : 0 ] rxdatavalid_out  ;//
    wire  [47 : 0 ] rxheader_out       ;//
    wire  [15 : 0 ] rxheadervalid_out  ;//
    wire  [7 : 0 ] rxgearboxslip_in   ;//
    wire  [7 : 0 ] rxlpmen_in         ;//
    wire  [7 : 0 ] gtrxreset_in       ;//
    wire  [7 : 0 ] rxresetdone_out    ;//
    wire  [39 : 0 ] txpostcursor_in    ;//
    wire  [7 : 0 ] gttxreset_in       ;//
    //wire  [7 : 0 ] txuserrdy_in     ;
    wire  [47 : 0 ] txheader_in        ;//
    wire  [31 : 0 ] txdiffctrl_in      ;//
    wire  [511 : 0 ] gtwiz_userdata_tx_in;//
 
    wire  [7 : 0 ] gthtxn_out         ;//
    wire  [7 : 0 ] gthtxp_out         ;//
 
    wire  [7 : 0 ] txoutclk_out       ;//
    wire  [7 : 0 ] txoutclkfabric_out ;//
    wire  [7 : 0 ] txoutclkpcs_out    ;//

    wire  [55 : 0 ] txsequence_in      ;//
    wire  [7 : 0 ] txpolarity_in      ;//
    wire  [7 : 0 ] txinhibit_in      ;//
    wire  [7 : 0 ] txpmareset_in      ;//
    wire  [7 : 0 ] txpcsreset_in      ;//
    wire  [7 : 0 ] rxpcsreset_in      ;//
    wire  [7 : 0 ] rxbufreset_in      ;//
    wire  [7 : 0 ] rxpmaresetdone_out ;//
    wire  [39 : 0 ] txprecursor_in     ;//
    wire  [31 : 0 ] txprbssel_in       ;//
    wire  [31 : 0 ] rxprbssel_in       ;//
    wire  [7 : 0 ] txprbsforceerr_in  ;//
    wire  [7 : 0 ] rxprbserr_out      ;//
    wire  [7 : 0 ] rxprbscntreset_in  ;//
    wire  [127 : 0 ] pcsrsvdin_in       ;//
 
    wire  [135 : 0 ] dmonitorout_out    ;//
 
    wire  [15 : 0 ] txbufstatus_out    ;//
    wire  [7 : 0 ] rxpmareset_in      ;//
    wire  [23 : 0 ] rxrate_in          ;//
    wire  [7 : 0 ] txresetdone_out    ;//
    wire  [7 : 0 ] txusrclk_in        ;
    wire  [7 : 0 ] txusrclk2_in       ;
    wire  [7 : 0 ] rxusrclk_in        ;
    wire  [7 : 0 ] rxusrclk2_in       ;

    reg   [9:0] fabric_pcs_rst_extend_cntr      = 10'b0; // 10 bit counter
    reg   [7:0] usrclk_rx_active_in_extend_cntr = 8'b0 ; // 8 bit counter
    reg   [7:0] usrclk_tx_active_in_extend_cntr = 8'b0 ; // 8 bit counter

    wire  [7 : 0 ] txpmaresetdone_out;

    wire  [7 : 0 ] txpmaresetdone_int;
    wire  [7 : 0 ] rxpmaresetdone_int;
    wire  [7 : 0 ] gtpowergood_out;

    reg   gtwiz_userclk_rx_reset_in_r=1'b0;

    // Clocking module is outside of GT.
    wire gtwiz_userclk_tx_active_in;
    wire gtwiz_userclk_rx_active_in;

    wire gtwiz_userclk_rx_usrclk2_out;// signals from Rx clocking module
    wire gtwiz_userclk_rx_usrclk_out; // signals from Rx clocking module

    wire gtwiz_userclk_tx_usrclk2_out;// signals from Tx clocking module
    //wire gtwiz_userclk_tx_usrclk_out; // signals from Tx clocking module

    wire gtwiz_userclk_tx_reset_in  ;
    wire gtwiz_userclk_rx_reset_in  ;

// wire definition ends

// assignment starts
    //--------------------------------------------------------------------------
     
    // Power good assignment
    assign gt_powergood = gtpowergood_out;   
     
    //--------------------------------------------------------------------------
    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[0]        = gt0_gtrefclk0_in     ;

    assign gt_cplllock[0]         = cplllock_out[0]      ;


    // DRP interface for GT channel starts
    assign gt0_drpdo        = drpdo_out[15 : 0];
    assign gt0_drprdy       = drprdy_out[0];

 
    assign drpaddr_in[8 : 0] = gt0_drpaddr;
    assign drpclk_in[0]         = gt0_drp_clk_in;
    assign drpdi_in[15 : 0] = gt0_drpdi;
    assign drpen_in[0]          = gt0_drpen  ;
    assign drpwe_in[0]          = gt0_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[6 : 0] = gt0_txsequence_in;

    assign gt0_rxdata_out       = gtwiz_userdata_rx_out[31 : 0];
    assign gt_rxbufstatus[2 : 0]  = rxbufstatus_out[2 : 0];
    assign gt0_rxheader_out     = rxheader_out[1 : 0];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[2 : 0]     = gt_loopback[2 : 0];
    assign txpostcursor_in[4 : 0] = gt_txpostcursor[4 : 0];
    assign txheader_in[5 : 0]     = {4'b0, gt0_txheader_in[1:0]};
    assign txdiffctrl_in[3 : 0]   = gt_txdiffctrl[3 : 0];
    assign gtwiz_userdata_tx_in[63 : 0] = gt0_txdata_in;
    assign txprecursor_in[4 : 0] = gt_txprecursor[4 : 0];
    assign txprbssel_in[3 : 0]   = gt_txprbssel[3 : 0];
    assign rxprbssel_in[3 : 0]   = gt_rxprbssel[3 : 0];


 
    assign gt_dmonitorout[16 : 0] = dmonitorout_out[16 : 0];
 
    assign gt_txbufstatus[1 : 0]   = txbufstatus_out[1 : 0];


    assign eyescanreset_in[0]           = gt_eyescanreset[0]  ;
    assign rxpolarity_in[0]             = gt_rxpolarity[0]   ;
    assign eyescantrigger_in[0]         = gt_eyescantrigger[0];
    assign rxcdrovrden_in[0]            = gt0_rxcdrovrden_in   ;
    assign rxcdrhold_in[0]              = gt_rxcdrhold[0]     ;
 
    assign gthrxn_in[0]                 = gt0_gthrxn_in        ;
    assign gthrxp_in[0]                 = gt0_gthrxp_in        ;
 
    assign rxdfelpmreset_in[0]          = gt_rxdfelpmreset[0] ;
    assign txpolarity_in[0]             = gt_txpolarity[0]    ;
    assign txinhibit_in[0]              = gt_txinhibit[0]    ;
    assign pcsrsvdin_in[15 : 0] = gt_pcsrsvdin[15 : 0];
    assign txpmareset_in[0]             = gt_txpmareset[0]    ;
    assign txpcsreset_in[0]             = gt_txpcsreset[0]    ;
    assign rxpcsreset_in[0]             = gt_rxpcsreset[0]    ;
    assign rxbufreset_in[0]             = gt_rxbufreset[0]    ;
    assign rxgearboxslip_in[0]          = gt0_rxgearboxslip_in ;
    assign rxlpmen_in[0]                = gt_rxlpmen[0]       ;
    assign gtrxreset_in[0]              = gt_gtrxreset[0]     ;
    assign gttxreset_in[0]              = gt_gttxreset[0]     ;
    assign txprbsforceerr_in[0]         = gt_txprbsforceerr[0];
    assign rxprbscntreset_in[0]         = gt_rxprbscntreset[0];

    assign gt_eyescandataerror[0]       = eyescandataerror_out[0];
    assign gt_rxprbserr[0]              = rxprbserr_out[0]     ;
    assign gt0_rxoutclk_out             = rxoutclk_out[0]      ;
    assign gt0_rxdatavalid_out          = rxdatavalid_out[0];

    assign gt0_rxheadervalid_out        = rxheadervalid_out[0] ;
    assign gt_rxresetdone[0]           = rxresetdone_out[0]   ;
 
    assign gt0_gthtxn_out               = gthtxn_out[0]        ;
    assign gt0_gthtxp_out               = gthtxp_out[0]        ;
 
    assign gt0_txoutclk_out             = txoutclk_out[0]      ;
    assign gt0_txoutclkfabric_out       = txoutclkfabric_out[0];
    assign gt0_txoutclkpcs_out          = txoutclkpcs_out[0]   ;
    assign gt_rxpmaresetdone[0]         = rxpmaresetdone_out[0];
    assign gt_txresetdone[0]           = txresetdone_out[0]   ;


    assign rxpmareset_in[0]             = gt_rxpmareset[0];
    assign rxrate_in[2 : 0] = gt_rxrate[2 : 0];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[0]              = gt0_txusrclk2_in;
    assign txusrclk_in[0]               = gt0_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[0]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[0]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt0_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt0_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[1]        = gt1_gtrefclk0_in     ;

    assign gt_cplllock[1]         = cplllock_out[1]      ;


    // DRP interface for GT channel starts
    assign gt1_drpdo        = drpdo_out[31 : 16];
    assign gt1_drprdy       = drprdy_out[1];

 
    assign drpaddr_in[17 : 9] = gt1_drpaddr;
    assign drpclk_in[1]         = gt1_drp_clk_in;
    assign drpdi_in[31 : 16] = gt1_drpdi;
    assign drpen_in[1]          = gt1_drpen  ;
    assign drpwe_in[1]          = gt1_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[13 : 7] = gt1_txsequence_in;

    assign gt1_rxdata_out       = gtwiz_userdata_rx_out[63 : 32];
    assign gt_rxbufstatus[5 : 3]  = rxbufstatus_out[5 : 3];
    assign gt1_rxheader_out     = rxheader_out[7 : 6];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[5 : 3]     = gt_loopback[5 : 3];
    assign txpostcursor_in[9 : 5] = gt_txpostcursor[9 : 5];
    assign txheader_in[11 : 6]     = {4'b0, gt1_txheader_in[1:0]};
    assign txdiffctrl_in[7 : 4]   = gt_txdiffctrl[7 : 4];
    assign gtwiz_userdata_tx_in[127 : 64] = gt1_txdata_in;
    assign txprecursor_in[9 : 5] = gt_txprecursor[9 : 5];
    assign txprbssel_in[7 : 4]   = gt_txprbssel[7 : 4];
    assign rxprbssel_in[7 : 4]   = gt_rxprbssel[7 : 4];


 
    assign gt_dmonitorout[33 : 17] = dmonitorout_out[33 : 17];
 
    assign gt_txbufstatus[3 : 2]   = txbufstatus_out[3 : 2];


    assign eyescanreset_in[1]           = gt_eyescanreset[1]  ;
    assign rxpolarity_in[1]             = gt_rxpolarity[1]   ;
    assign eyescantrigger_in[1]         = gt_eyescantrigger[1];
    assign rxcdrovrden_in[1]            = gt1_rxcdrovrden_in   ;
    assign rxcdrhold_in[1]              = gt_rxcdrhold[1]     ;
 
    assign gthrxn_in[1]                 = gt1_gthrxn_in        ;
    assign gthrxp_in[1]                 = gt1_gthrxp_in        ;
 
    assign rxdfelpmreset_in[1]          = gt_rxdfelpmreset[1] ;
    assign txpolarity_in[1]             = gt_txpolarity[1]    ;
    assign txinhibit_in[1]              = gt_txinhibit[1]    ;
    assign pcsrsvdin_in[31 : 16] = gt_pcsrsvdin[31 : 16];
    assign txpmareset_in[1]             = gt_txpmareset[1]    ;
    assign txpcsreset_in[1]             = gt_txpcsreset[1]    ;
    assign rxpcsreset_in[1]             = gt_rxpcsreset[1]    ;
    assign rxbufreset_in[1]             = gt_rxbufreset[1]    ;
    assign rxgearboxslip_in[1]          = gt1_rxgearboxslip_in ;
    assign rxlpmen_in[1]                = gt_rxlpmen[1]       ;
    assign gtrxreset_in[1]              = gt_gtrxreset[1]     ;
    assign gttxreset_in[1]              = gt_gttxreset[1]     ;
    assign txprbsforceerr_in[1]         = gt_txprbsforceerr[1];
    assign rxprbscntreset_in[1]         = gt_rxprbscntreset[1];

    assign gt_eyescandataerror[1]       = eyescandataerror_out[1];
    assign gt_rxprbserr[1]              = rxprbserr_out[1]     ;
    assign gt1_rxoutclk_out             = rxoutclk_out[1]      ;
    assign gt1_rxdatavalid_out          = rxdatavalid_out[2];

    assign gt1_rxheadervalid_out        = rxheadervalid_out[2] ;
    assign gt_rxresetdone[1]           = rxresetdone_out[1]   ;
 
    assign gt1_gthtxn_out               = gthtxn_out[1]        ;
    assign gt1_gthtxp_out               = gthtxp_out[1]        ;
 
    assign gt1_txoutclk_out             = txoutclk_out[1]      ;
    assign gt1_txoutclkfabric_out       = txoutclkfabric_out[1];
    assign gt1_txoutclkpcs_out          = txoutclkpcs_out[1]   ;
    assign gt_rxpmaresetdone[1]         = rxpmaresetdone_out[1];
    assign gt_txresetdone[1]           = txresetdone_out[1]   ;


    assign rxpmareset_in[1]             = gt_rxpmareset[1];
    assign rxrate_in[5 : 3] = gt_rxrate[5 : 3];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[1]              = gt1_txusrclk2_in;
    assign txusrclk_in[1]               = gt1_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[1]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[1]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt1_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt1_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[2]        = gt2_gtrefclk0_in     ;

    assign gt_cplllock[2]         = cplllock_out[2]      ;


    // DRP interface for GT channel starts
    assign gt2_drpdo        = drpdo_out[47 : 32];
    assign gt2_drprdy       = drprdy_out[2];

 
    assign drpaddr_in[26 : 18] = gt2_drpaddr;
    assign drpclk_in[2]         = gt2_drp_clk_in;
    assign drpdi_in[47 : 32] = gt2_drpdi;
    assign drpen_in[2]          = gt2_drpen  ;
    assign drpwe_in[2]          = gt2_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[20 : 14] = gt2_txsequence_in;

    assign gt2_rxdata_out       = gtwiz_userdata_rx_out[95 : 64];
    assign gt_rxbufstatus[8 : 6]  = rxbufstatus_out[8 : 6];
    assign gt2_rxheader_out     = rxheader_out[13 : 12];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[8 : 6]     = gt_loopback[8 : 6];
    assign txpostcursor_in[14 : 10] = gt_txpostcursor[14 : 10];
    assign txheader_in[17 : 12]     = {4'b0, gt2_txheader_in[1:0]};
    assign txdiffctrl_in[11 : 8]   = gt_txdiffctrl[11 : 8];
    assign gtwiz_userdata_tx_in[191 : 128] = gt2_txdata_in;
    assign txprecursor_in[14 : 10] = gt_txprecursor[14 : 10];
    assign txprbssel_in[11 : 8]   = gt_txprbssel[11 : 8];
    assign rxprbssel_in[11 : 8]   = gt_rxprbssel[11 : 8];


 
    assign gt_dmonitorout[50 : 34] = dmonitorout_out[50 : 34];
 
    assign gt_txbufstatus[5 : 4]   = txbufstatus_out[5 : 4];


    assign eyescanreset_in[2]           = gt_eyescanreset[2]  ;
    assign rxpolarity_in[2]             = gt_rxpolarity[2]   ;
    assign eyescantrigger_in[2]         = gt_eyescantrigger[2];
    assign rxcdrovrden_in[2]            = gt2_rxcdrovrden_in   ;
    assign rxcdrhold_in[2]              = gt_rxcdrhold[2]     ;
 
    assign gthrxn_in[2]                 = gt2_gthrxn_in        ;
    assign gthrxp_in[2]                 = gt2_gthrxp_in        ;
 
    assign rxdfelpmreset_in[2]          = gt_rxdfelpmreset[2] ;
    assign txpolarity_in[2]             = gt_txpolarity[2]    ;
    assign txinhibit_in[2]              = gt_txinhibit[2]    ;
    assign pcsrsvdin_in[47 : 32] = gt_pcsrsvdin[47 : 32];
    assign txpmareset_in[2]             = gt_txpmareset[2]    ;
    assign txpcsreset_in[2]             = gt_txpcsreset[2]    ;
    assign rxpcsreset_in[2]             = gt_rxpcsreset[2]    ;
    assign rxbufreset_in[2]             = gt_rxbufreset[2]    ;
    assign rxgearboxslip_in[2]          = gt2_rxgearboxslip_in ;
    assign rxlpmen_in[2]                = gt_rxlpmen[2]       ;
    assign gtrxreset_in[2]              = gt_gtrxreset[2]     ;
    assign gttxreset_in[2]              = gt_gttxreset[2]     ;
    assign txprbsforceerr_in[2]         = gt_txprbsforceerr[2];
    assign rxprbscntreset_in[2]         = gt_rxprbscntreset[2];

    assign gt_eyescandataerror[2]       = eyescandataerror_out[2];
    assign gt_rxprbserr[2]              = rxprbserr_out[2]     ;
    assign gt2_rxoutclk_out             = rxoutclk_out[2]      ;
    assign gt2_rxdatavalid_out          = rxdatavalid_out[4];

    assign gt2_rxheadervalid_out        = rxheadervalid_out[4] ;
    assign gt_rxresetdone[2]           = rxresetdone_out[2]   ;
 
    assign gt2_gthtxn_out               = gthtxn_out[2]        ;
    assign gt2_gthtxp_out               = gthtxp_out[2]        ;
 
    assign gt2_txoutclk_out             = txoutclk_out[2]      ;
    assign gt2_txoutclkfabric_out       = txoutclkfabric_out[2];
    assign gt2_txoutclkpcs_out          = txoutclkpcs_out[2]   ;
    assign gt_rxpmaresetdone[2]         = rxpmaresetdone_out[2];
    assign gt_txresetdone[2]           = txresetdone_out[2]   ;


    assign rxpmareset_in[2]             = gt_rxpmareset[2];
    assign rxrate_in[8 : 6] = gt_rxrate[8 : 6];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[2]              = gt2_txusrclk2_in;
    assign txusrclk_in[2]               = gt2_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[2]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[2]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt2_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt2_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[3]        = gt3_gtrefclk0_in     ;

    assign gt_cplllock[3]         = cplllock_out[3]      ;


    // DRP interface for GT channel starts
    assign gt3_drpdo        = drpdo_out[63 : 48];
    assign gt3_drprdy       = drprdy_out[3];

 
    assign drpaddr_in[35 : 27] = gt3_drpaddr;
    assign drpclk_in[3]         = gt3_drp_clk_in;
    assign drpdi_in[63 : 48] = gt3_drpdi;
    assign drpen_in[3]          = gt3_drpen  ;
    assign drpwe_in[3]          = gt3_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[27 : 21] = gt3_txsequence_in;

    assign gt3_rxdata_out       = gtwiz_userdata_rx_out[127 : 96];
    assign gt_rxbufstatus[11 : 9]  = rxbufstatus_out[11 : 9];
    assign gt3_rxheader_out     = rxheader_out[19 : 18];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[11 : 9]     = gt_loopback[11 : 9];
    assign txpostcursor_in[19 : 15] = gt_txpostcursor[19 : 15];
    assign txheader_in[23 : 18]     = {4'b0, gt3_txheader_in[1:0]};
    assign txdiffctrl_in[15 : 12]   = gt_txdiffctrl[15 : 12];
    assign gtwiz_userdata_tx_in[255 : 192] = gt3_txdata_in;
    assign txprecursor_in[19 : 15] = gt_txprecursor[19 : 15];
    assign txprbssel_in[15 : 12]   = gt_txprbssel[15 : 12];
    assign rxprbssel_in[15 : 12]   = gt_rxprbssel[15 : 12];


 
    assign gt_dmonitorout[67 : 51] = dmonitorout_out[67 : 51];
 
    assign gt_txbufstatus[7 : 6]   = txbufstatus_out[7 : 6];


    assign eyescanreset_in[3]           = gt_eyescanreset[3]  ;
    assign rxpolarity_in[3]             = gt_rxpolarity[3]   ;
    assign eyescantrigger_in[3]         = gt_eyescantrigger[3];
    assign rxcdrovrden_in[3]            = gt3_rxcdrovrden_in   ;
    assign rxcdrhold_in[3]              = gt_rxcdrhold[3]     ;
 
    assign gthrxn_in[3]                 = gt3_gthrxn_in        ;
    assign gthrxp_in[3]                 = gt3_gthrxp_in        ;
 
    assign rxdfelpmreset_in[3]          = gt_rxdfelpmreset[3] ;
    assign txpolarity_in[3]             = gt_txpolarity[3]    ;
    assign txinhibit_in[3]              = gt_txinhibit[3]    ;
    assign pcsrsvdin_in[63 : 48] = gt_pcsrsvdin[63 : 48];
    assign txpmareset_in[3]             = gt_txpmareset[3]    ;
    assign txpcsreset_in[3]             = gt_txpcsreset[3]    ;
    assign rxpcsreset_in[3]             = gt_rxpcsreset[3]    ;
    assign rxbufreset_in[3]             = gt_rxbufreset[3]    ;
    assign rxgearboxslip_in[3]          = gt3_rxgearboxslip_in ;
    assign rxlpmen_in[3]                = gt_rxlpmen[3]       ;
    assign gtrxreset_in[3]              = gt_gtrxreset[3]     ;
    assign gttxreset_in[3]              = gt_gttxreset[3]     ;
    assign txprbsforceerr_in[3]         = gt_txprbsforceerr[3];
    assign rxprbscntreset_in[3]         = gt_rxprbscntreset[3];

    assign gt_eyescandataerror[3]       = eyescandataerror_out[3];
    assign gt_rxprbserr[3]              = rxprbserr_out[3]     ;
    assign gt3_rxoutclk_out             = rxoutclk_out[3]      ;
    assign gt3_rxdatavalid_out          = rxdatavalid_out[6];

    assign gt3_rxheadervalid_out        = rxheadervalid_out[6] ;
    assign gt_rxresetdone[3]           = rxresetdone_out[3]   ;
 
    assign gt3_gthtxn_out               = gthtxn_out[3]        ;
    assign gt3_gthtxp_out               = gthtxp_out[3]        ;
 
    assign gt3_txoutclk_out             = txoutclk_out[3]      ;
    assign gt3_txoutclkfabric_out       = txoutclkfabric_out[3];
    assign gt3_txoutclkpcs_out          = txoutclkpcs_out[3]   ;
    assign gt_rxpmaresetdone[3]         = rxpmaresetdone_out[3];
    assign gt_txresetdone[3]           = txresetdone_out[3]   ;


    assign rxpmareset_in[3]             = gt_rxpmareset[3];
    assign rxrate_in[11 : 9] = gt_rxrate[11 : 9];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[3]              = gt3_txusrclk2_in;
    assign txusrclk_in[3]               = gt3_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[3]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[3]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt3_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt3_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[4]        = gt4_gtrefclk0_in     ;

    assign gt_cplllock[4]         = cplllock_out[4]      ;


    // DRP interface for GT channel starts
    assign gt4_drpdo        = drpdo_out[79 : 64];
    assign gt4_drprdy       = drprdy_out[4];

 
    assign drpaddr_in[44 : 36] = gt4_drpaddr;
    assign drpclk_in[4]         = gt4_drp_clk_in;
    assign drpdi_in[79 : 64] = gt4_drpdi;
    assign drpen_in[4]          = gt4_drpen  ;
    assign drpwe_in[4]          = gt4_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[34 : 28] = gt4_txsequence_in;

    assign gt4_rxdata_out       = gtwiz_userdata_rx_out[159 : 128];
    assign gt_rxbufstatus[14 : 12]  = rxbufstatus_out[14 : 12];
    assign gt4_rxheader_out     = rxheader_out[25 : 24];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[14 : 12]     = gt_loopback[14 : 12];
    assign txpostcursor_in[24 : 20] = gt_txpostcursor[24 : 20];
    assign txheader_in[29 : 24]     = {4'b0, gt4_txheader_in[1:0]};
    assign txdiffctrl_in[19 : 16]   = gt_txdiffctrl[19 : 16];
    assign gtwiz_userdata_tx_in[319 : 256] = gt4_txdata_in;
    assign txprecursor_in[24 : 20] = gt_txprecursor[24 : 20];
    assign txprbssel_in[19 : 16]   = gt_txprbssel[19 : 16];
    assign rxprbssel_in[19 : 16]   = gt_rxprbssel[19 : 16];


 
    assign gt_dmonitorout[84 : 68] = dmonitorout_out[84 : 68];
 
    assign gt_txbufstatus[9 : 8]   = txbufstatus_out[9 : 8];


    assign eyescanreset_in[4]           = gt_eyescanreset[4]  ;
    assign rxpolarity_in[4]             = gt_rxpolarity[4]   ;
    assign eyescantrigger_in[4]         = gt_eyescantrigger[4];
    assign rxcdrovrden_in[4]            = gt4_rxcdrovrden_in   ;
    assign rxcdrhold_in[4]              = gt_rxcdrhold[4]     ;
 
    assign gthrxn_in[4]                 = gt4_gthrxn_in        ;
    assign gthrxp_in[4]                 = gt4_gthrxp_in        ;
 
    assign rxdfelpmreset_in[4]          = gt_rxdfelpmreset[4] ;
    assign txpolarity_in[4]             = gt_txpolarity[4]    ;
    assign txinhibit_in[4]              = gt_txinhibit[4]    ;
    assign pcsrsvdin_in[79 : 64] = gt_pcsrsvdin[79 : 64];
    assign txpmareset_in[4]             = gt_txpmareset[4]    ;
    assign txpcsreset_in[4]             = gt_txpcsreset[4]    ;
    assign rxpcsreset_in[4]             = gt_rxpcsreset[4]    ;
    assign rxbufreset_in[4]             = gt_rxbufreset[4]    ;
    assign rxgearboxslip_in[4]          = gt4_rxgearboxslip_in ;
    assign rxlpmen_in[4]                = gt_rxlpmen[4]       ;
    assign gtrxreset_in[4]              = gt_gtrxreset[4]     ;
    assign gttxreset_in[4]              = gt_gttxreset[4]     ;
    assign txprbsforceerr_in[4]         = gt_txprbsforceerr[4];
    assign rxprbscntreset_in[4]         = gt_rxprbscntreset[4];

    assign gt_eyescandataerror[4]       = eyescandataerror_out[4];
    assign gt_rxprbserr[4]              = rxprbserr_out[4]     ;
    assign gt4_rxoutclk_out             = rxoutclk_out[4]      ;
    assign gt4_rxdatavalid_out          = rxdatavalid_out[8];

    assign gt4_rxheadervalid_out        = rxheadervalid_out[8] ;
    assign gt_rxresetdone[4]           = rxresetdone_out[4]   ;
 
    assign gt4_gthtxn_out               = gthtxn_out[4]        ;
    assign gt4_gthtxp_out               = gthtxp_out[4]        ;
 
    assign gt4_txoutclk_out             = txoutclk_out[4]      ;
    assign gt4_txoutclkfabric_out       = txoutclkfabric_out[4];
    assign gt4_txoutclkpcs_out          = txoutclkpcs_out[4]   ;
    assign gt_rxpmaresetdone[4]         = rxpmaresetdone_out[4];
    assign gt_txresetdone[4]           = txresetdone_out[4]   ;


    assign rxpmareset_in[4]             = gt_rxpmareset[4];
    assign rxrate_in[14 : 12] = gt_rxrate[14 : 12];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[4]              = gt4_txusrclk2_in;
    assign txusrclk_in[4]               = gt4_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[4]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[4]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt4_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt4_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[5]        = gt5_gtrefclk0_in     ;

    assign gt_cplllock[5]         = cplllock_out[5]      ;


    // DRP interface for GT channel starts
    assign gt5_drpdo        = drpdo_out[95 : 80];
    assign gt5_drprdy       = drprdy_out[5];

 
    assign drpaddr_in[53 : 45] = gt5_drpaddr;
    assign drpclk_in[5]         = gt5_drp_clk_in;
    assign drpdi_in[95 : 80] = gt5_drpdi;
    assign drpen_in[5]          = gt5_drpen  ;
    assign drpwe_in[5]          = gt5_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[41 : 35] = gt5_txsequence_in;

    assign gt5_rxdata_out       = gtwiz_userdata_rx_out[191 : 160];
    assign gt_rxbufstatus[17 : 15]  = rxbufstatus_out[17 : 15];
    assign gt5_rxheader_out     = rxheader_out[31 : 30];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[17 : 15]     = gt_loopback[17 : 15];
    assign txpostcursor_in[29 : 25] = gt_txpostcursor[29 : 25];
    assign txheader_in[35 : 30]     = {4'b0, gt5_txheader_in[1:0]};
    assign txdiffctrl_in[23 : 20]   = gt_txdiffctrl[23 : 20];
    assign gtwiz_userdata_tx_in[383 : 320] = gt5_txdata_in;
    assign txprecursor_in[29 : 25] = gt_txprecursor[29 : 25];
    assign txprbssel_in[23 : 20]   = gt_txprbssel[23 : 20];
    assign rxprbssel_in[23 : 20]   = gt_rxprbssel[23 : 20];


 
    assign gt_dmonitorout[101 : 85] = dmonitorout_out[101 : 85];
 
    assign gt_txbufstatus[11 : 10]   = txbufstatus_out[11 : 10];


    assign eyescanreset_in[5]           = gt_eyescanreset[5]  ;
    assign rxpolarity_in[5]             = gt_rxpolarity[5]   ;
    assign eyescantrigger_in[5]         = gt_eyescantrigger[5];
    assign rxcdrovrden_in[5]            = gt5_rxcdrovrden_in   ;
    assign rxcdrhold_in[5]              = gt_rxcdrhold[5]     ;
 
    assign gthrxn_in[5]                 = gt5_gthrxn_in        ;
    assign gthrxp_in[5]                 = gt5_gthrxp_in        ;
 
    assign rxdfelpmreset_in[5]          = gt_rxdfelpmreset[5] ;
    assign txpolarity_in[5]             = gt_txpolarity[5]    ;
    assign txinhibit_in[5]              = gt_txinhibit[5]    ;
    assign pcsrsvdin_in[95 : 80] = gt_pcsrsvdin[95 : 80];
    assign txpmareset_in[5]             = gt_txpmareset[5]    ;
    assign txpcsreset_in[5]             = gt_txpcsreset[5]    ;
    assign rxpcsreset_in[5]             = gt_rxpcsreset[5]    ;
    assign rxbufreset_in[5]             = gt_rxbufreset[5]    ;
    assign rxgearboxslip_in[5]          = gt5_rxgearboxslip_in ;
    assign rxlpmen_in[5]                = gt_rxlpmen[5]       ;
    assign gtrxreset_in[5]              = gt_gtrxreset[5]     ;
    assign gttxreset_in[5]              = gt_gttxreset[5]     ;
    assign txprbsforceerr_in[5]         = gt_txprbsforceerr[5];
    assign rxprbscntreset_in[5]         = gt_rxprbscntreset[5];

    assign gt_eyescandataerror[5]       = eyescandataerror_out[5];
    assign gt_rxprbserr[5]              = rxprbserr_out[5]     ;
    assign gt5_rxoutclk_out             = rxoutclk_out[5]      ;
    assign gt5_rxdatavalid_out          = rxdatavalid_out[10];

    assign gt5_rxheadervalid_out        = rxheadervalid_out[10] ;
    assign gt_rxresetdone[5]           = rxresetdone_out[5]   ;
 
    assign gt5_gthtxn_out               = gthtxn_out[5]        ;
    assign gt5_gthtxp_out               = gthtxp_out[5]        ;
 
    assign gt5_txoutclk_out             = txoutclk_out[5]      ;
    assign gt5_txoutclkfabric_out       = txoutclkfabric_out[5];
    assign gt5_txoutclkpcs_out          = txoutclkpcs_out[5]   ;
    assign gt_rxpmaresetdone[5]         = rxpmaresetdone_out[5];
    assign gt_txresetdone[5]           = txresetdone_out[5]   ;


    assign rxpmareset_in[5]             = gt_rxpmareset[5];
    assign rxrate_in[17 : 15] = gt_rxrate[17 : 15];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[5]              = gt5_txusrclk2_in;
    assign txusrclk_in[5]               = gt5_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[5]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[5]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt5_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt5_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[6]        = gt6_gtrefclk0_in     ;

    assign gt_cplllock[6]         = cplllock_out[6]      ;


    // DRP interface for GT channel starts
    assign gt6_drpdo        = drpdo_out[111 : 96];
    assign gt6_drprdy       = drprdy_out[6];

 
    assign drpaddr_in[62 : 54] = gt6_drpaddr;
    assign drpclk_in[6]         = gt6_drp_clk_in;
    assign drpdi_in[111 : 96] = gt6_drpdi;
    assign drpen_in[6]          = gt6_drpen  ;
    assign drpwe_in[6]          = gt6_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[48 : 42] = gt6_txsequence_in;

    assign gt6_rxdata_out       = gtwiz_userdata_rx_out[223 : 192];
    assign gt_rxbufstatus[20 : 18]  = rxbufstatus_out[20 : 18];
    assign gt6_rxheader_out     = rxheader_out[37 : 36];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[20 : 18]     = gt_loopback[20 : 18];
    assign txpostcursor_in[34 : 30] = gt_txpostcursor[34 : 30];
    assign txheader_in[41 : 36]     = {4'b0, gt6_txheader_in[1:0]};
    assign txdiffctrl_in[27 : 24]   = gt_txdiffctrl[27 : 24];
    assign gtwiz_userdata_tx_in[447 : 384] = gt6_txdata_in;
    assign txprecursor_in[34 : 30] = gt_txprecursor[34 : 30];
    assign txprbssel_in[27 : 24]   = gt_txprbssel[27 : 24];
    assign rxprbssel_in[27 : 24]   = gt_rxprbssel[27 : 24];


 
    assign gt_dmonitorout[118 : 102] = dmonitorout_out[118 : 102];
 
    assign gt_txbufstatus[13 : 12]   = txbufstatus_out[13 : 12];


    assign eyescanreset_in[6]           = gt_eyescanreset[6]  ;
    assign rxpolarity_in[6]             = gt_rxpolarity[6]   ;
    assign eyescantrigger_in[6]         = gt_eyescantrigger[6];
    assign rxcdrovrden_in[6]            = gt6_rxcdrovrden_in   ;
    assign rxcdrhold_in[6]              = gt_rxcdrhold[6]     ;
 
    assign gthrxn_in[6]                 = gt6_gthrxn_in        ;
    assign gthrxp_in[6]                 = gt6_gthrxp_in        ;
 
    assign rxdfelpmreset_in[6]          = gt_rxdfelpmreset[6] ;
    assign txpolarity_in[6]             = gt_txpolarity[6]    ;
    assign txinhibit_in[6]              = gt_txinhibit[6]    ;
    assign pcsrsvdin_in[111 : 96] = gt_pcsrsvdin[111 : 96];
    assign txpmareset_in[6]             = gt_txpmareset[6]    ;
    assign txpcsreset_in[6]             = gt_txpcsreset[6]    ;
    assign rxpcsreset_in[6]             = gt_rxpcsreset[6]    ;
    assign rxbufreset_in[6]             = gt_rxbufreset[6]    ;
    assign rxgearboxslip_in[6]          = gt6_rxgearboxslip_in ;
    assign rxlpmen_in[6]                = gt_rxlpmen[6]       ;
    assign gtrxreset_in[6]              = gt_gtrxreset[6]     ;
    assign gttxreset_in[6]              = gt_gttxreset[6]     ;
    assign txprbsforceerr_in[6]         = gt_txprbsforceerr[6];
    assign rxprbscntreset_in[6]         = gt_rxprbscntreset[6];

    assign gt_eyescandataerror[6]       = eyescandataerror_out[6];
    assign gt_rxprbserr[6]              = rxprbserr_out[6]     ;
    assign gt6_rxoutclk_out             = rxoutclk_out[6]      ;
    assign gt6_rxdatavalid_out          = rxdatavalid_out[12];

    assign gt6_rxheadervalid_out        = rxheadervalid_out[12] ;
    assign gt_rxresetdone[6]           = rxresetdone_out[6]   ;
 
    assign gt6_gthtxn_out               = gthtxn_out[6]        ;
    assign gt6_gthtxp_out               = gthtxp_out[6]        ;
 
    assign gt6_txoutclk_out             = txoutclk_out[6]      ;
    assign gt6_txoutclkfabric_out       = txoutclkfabric_out[6];
    assign gt6_txoutclkpcs_out          = txoutclkpcs_out[6]   ;
    assign gt_rxpmaresetdone[6]         = rxpmaresetdone_out[6];
    assign gt_txresetdone[6]           = txresetdone_out[6]   ;


    assign rxpmareset_in[6]             = gt_rxpmareset[6];
    assign rxrate_in[20 : 18] = gt_rxrate[20 : 18];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[6]              = gt6_txusrclk2_in;
    assign txusrclk_in[6]               = gt6_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[6]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[6]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt6_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt6_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;

    //--------- Port interface for the $lane for Aurora core and Ultrscale GT --
    assign gtrefclk0_in[7]        = gt7_gtrefclk0_in     ;

    assign gt_cplllock[7]         = cplllock_out[7]      ;


    // DRP interface for GT channel starts
    assign gt7_drpdo        = drpdo_out[127 : 112];
    assign gt7_drprdy       = drprdy_out[7];

 
    assign drpaddr_in[71 : 63] = gt7_drpaddr;
    assign drpclk_in[7]         = gt7_drp_clk_in;
    assign drpdi_in[127 : 112] = gt7_drpdi;
    assign drpen_in[7]          = gt7_drpen  ;
    assign drpwe_in[7]          = gt7_drpwe  ;
    // DRP interface for GT channel ends

    assign txsequence_in[55 : 49] = gt7_txsequence_in;

    assign gt7_rxdata_out       = gtwiz_userdata_rx_out[255 : 224];
    assign gt_rxbufstatus[23 : 21]  = rxbufstatus_out[23 : 21];
    assign gt7_rxheader_out     = rxheader_out[43 : 42];// connect only  the 2 bits of this signal (out of 6 bits)

    assign loopback_in[23 : 21]     = gt_loopback[23 : 21];
    assign txpostcursor_in[39 : 35] = gt_txpostcursor[39 : 35];
    assign txheader_in[47 : 42]     = {4'b0, gt7_txheader_in[1:0]};
    assign txdiffctrl_in[31 : 28]   = gt_txdiffctrl[31 : 28];
    assign gtwiz_userdata_tx_in[511 : 448] = gt7_txdata_in;
    assign txprecursor_in[39 : 35] = gt_txprecursor[39 : 35];
    assign txprbssel_in[31 : 28]   = gt_txprbssel[31 : 28];
    assign rxprbssel_in[31 : 28]   = gt_rxprbssel[31 : 28];


 
    assign gt_dmonitorout[135 : 119] = dmonitorout_out[135 : 119];
 
    assign gt_txbufstatus[15 : 14]   = txbufstatus_out[15 : 14];


    assign eyescanreset_in[7]           = gt_eyescanreset[7]  ;
    assign rxpolarity_in[7]             = gt_rxpolarity[7]   ;
    assign eyescantrigger_in[7]         = gt_eyescantrigger[7];
    assign rxcdrovrden_in[7]            = gt7_rxcdrovrden_in   ;
    assign rxcdrhold_in[7]              = gt_rxcdrhold[7]     ;
 
    assign gthrxn_in[7]                 = gt7_gthrxn_in        ;
    assign gthrxp_in[7]                 = gt7_gthrxp_in        ;
 
    assign rxdfelpmreset_in[7]          = gt_rxdfelpmreset[7] ;
    assign txpolarity_in[7]             = gt_txpolarity[7]    ;
    assign txinhibit_in[7]              = gt_txinhibit[7]    ;
    assign pcsrsvdin_in[127 : 112] = gt_pcsrsvdin[127 : 112];
    assign txpmareset_in[7]             = gt_txpmareset[7]    ;
    assign txpcsreset_in[7]             = gt_txpcsreset[7]    ;
    assign rxpcsreset_in[7]             = gt_rxpcsreset[7]    ;
    assign rxbufreset_in[7]             = gt_rxbufreset[7]    ;
    assign rxgearboxslip_in[7]          = gt7_rxgearboxslip_in ;
    assign rxlpmen_in[7]                = gt_rxlpmen[7]       ;
    assign gtrxreset_in[7]              = gt_gtrxreset[7]     ;
    assign gttxreset_in[7]              = gt_gttxreset[7]     ;
    assign txprbsforceerr_in[7]         = gt_txprbsforceerr[7];
    assign rxprbscntreset_in[7]         = gt_rxprbscntreset[7];

    assign gt_eyescandataerror[7]       = eyescandataerror_out[7];
    assign gt_rxprbserr[7]              = rxprbserr_out[7]     ;
    assign gt7_rxoutclk_out             = rxoutclk_out[7]      ;
    assign gt7_rxdatavalid_out          = rxdatavalid_out[14];

    assign gt7_rxheadervalid_out        = rxheadervalid_out[14] ;
    assign gt_rxresetdone[7]           = rxresetdone_out[7]   ;
 
    assign gt7_gthtxn_out               = gthtxn_out[7]        ;
    assign gt7_gthtxp_out               = gthtxp_out[7]        ;
 
    assign gt7_txoutclk_out             = txoutclk_out[7]      ;
    assign gt7_txoutclkfabric_out       = txoutclkfabric_out[7];
    assign gt7_txoutclkpcs_out          = txoutclkpcs_out[7]   ;
    assign gt_rxpmaresetdone[7]         = rxpmaresetdone_out[7];
    assign gt_txresetdone[7]           = txresetdone_out[7]   ;


    assign rxpmareset_in[7]             = gt_rxpmareset[7];
    assign rxrate_in[23 : 21] = gt_rxrate[23 : 21];

    // clock module output clocks assignment to GT clock input pins
    // for Tx path
    assign txusrclk2_in[7]              = gt7_txusrclk2_in;
    assign txusrclk_in[7]               = gt7_txusrclk_in;

    // for Rx path, this will be connected to GT Rx clock inputs again
    assign rxusrclk2_in[7]              = gtwiz_userclk_rx_usrclk2_out;
    assign rxusrclk_in[7]               = gtwiz_userclk_rx_usrclk_out ;

    // for Rx path, this will be connected outside of this module in WRAPPER logic
    assign gt7_rxusrclk2_out            = gtwiz_userclk_rx_usrclk2_out;
    assign gt7_rxusrclk_out             = gtwiz_userclk_rx_usrclk_out;



//------------------------------------------------------------------------------
// Rx is needed in below conditions
// duplex, Rx only, RX/TX simplex
    // Ultrascale GT RX clocking module in outside of the GT
  wire gtwiz_userclk_rx_active_out;
     design_1_aurora_64b66b_1_0_ultrascale_rx_userclk
     #(
      // parameter declaration
            .P_CONTENTS                     (0),
            .P_FREQ_RATIO_SOURCE_TO_USRCLK  (1),
            .P_FREQ_RATIO_USRCLK_TO_USRCLK2 (1)
      )
    ultrascale_rx_userclk
     (
      // port declaration
            .gtwiz_reset_clk_freerun_in     (gtwiz_reset_clk_freerun_in  ), 
            .gtwiz_userclk_rx_srcclk_in     (rxoutclk_out[4]), // input  wire
            .gtwiz_userclk_rx_reset_in      (gtwiz_userclk_rx_reset_in_r   ), // input  wire
            .gtwiz_userclk_rx_usrclk_out    (gtwiz_userclk_rx_usrclk_out ), // output wire
            .gtwiz_userclk_rx_usrclk2_out   (gtwiz_userclk_rx_usrclk2_out), // output wire
            .gtwiz_userclk_rx_active_out    (gtwiz_userclk_rx_active_out )  // output reg  = 1'b0
     );
//------------------------------------------------------------------------------

//--- fabric_pcs_reset reset extension counter based upon the stable clock
    //connect output of main clocking module (user clock) here
    assign gtwiz_userclk_tx_usrclk2_out = txusrclk2_in[0];

//--- synchronizing to usrclk2
//design_1_aurora_64b66b_1_0_rst_sync # 
//   ( 
//       .c_mtbf_stages (3) 
//   )u_rst_gtwiz_userclk_tx_active_out 
//   ( 
//       .prmry_in     (gtwiz_userclk_tx_active_out), 
//       .scndry_aclk  (gtwiz_userclk_tx_usrclk2_out), 
//       .scndry_out   (gtwiz_userclk_tx_active_out_i) 
//   ); 
assign  gtwiz_userclk_tx_active_out_i = gtwiz_userclk_tx_active_out;

    always @(posedge gtwiz_userclk_tx_usrclk2_out, negedge gtwiz_userclk_tx_active_out_i)
    begin
        if (!gtwiz_userclk_tx_active_out_i) // deactive counter when tx_active is not present
               fabric_pcs_rst_extend_cntr   <=   10'b0;
        else if (!fabric_pcs_rst_extend_cntr[9])  // when tx active is asserted, extend with 10 bit counter
                fabric_pcs_rst_extend_cntr  <=   fabric_pcs_rst_extend_cntr + 1'b1;
        end


  assign fabric_pcs_reset   = !fabric_pcs_rst_extend_cntr[9];
//--- fabric_pcs_reset reset extension counter ends

//------------------------------------------------------------------------------
//--- gtwiz_userclk_tx_active_in delay extension counter based upon the stable tx clock
// 8-bit counter

    always @(posedge gtwiz_userclk_tx_usrclk2_out, negedge gtwiz_userclk_tx_active_out_i)
    begin
        if (!gtwiz_userclk_tx_active_out_i) // deactive counter when tx_active is not present
                usrclk_tx_active_in_extend_cntr   <=   8'b0;
        else if (fabric_pcs_rst_extend_cntr[9] &&       // Extended tx active from clock module with 10 bit counter
                 (!usrclk_tx_active_in_extend_cntr[7]))
                usrclk_tx_active_in_extend_cntr   <=   usrclk_tx_active_in_extend_cntr + 1'b1;
        end

  assign userclk_tx_active_out   = usrclk_tx_active_in_extend_cntr[7];
//--- gtwiz_userclk_tx_active_in reset extension counter ends
//------------------------------------------------------------------------------

//--- gtwiz_userclk_rx_active_in delay extension counter based upon the stable Rx clock
// 8-bit counter
    always @(posedge gtwiz_userclk_rx_usrclk2_out, negedge gtwiz_userclk_rx_active_out)
    begin
        if (!gtwiz_userclk_rx_active_out)       // deactive counter when rx_active is not present
                usrclk_rx_active_in_extend_cntr   <=   8'b0;
        else if (gtwiz_userclk_rx_active_out && // Rx clock module is stable
                 (!usrclk_rx_active_in_extend_cntr[7]))
                usrclk_rx_active_in_extend_cntr   <=   usrclk_rx_active_in_extend_cntr + 1'b1;
        end

  assign userclk_rx_active_out   = !usrclk_rx_active_in_extend_cntr[7];
//--- gtwiz_userclk_rx_active_in reset extension counter ends
//------------------------------------------------------------------------------
   // assginment of delayed counters of Tx and Rx active signals to GT ports
   assign gtwiz_userclk_tx_active_in = userclk_tx_active_out;
   //--------------------------------------------------------
   // driving the gtwiz_userclk_rx_active_in different conditions
   // Rx clocking module is included in the design
   assign gtwiz_userclk_rx_active_in = usrclk_rx_active_in_extend_cntr[7];
   //--------------------------------------------------------
//------------------------------------------------------------------------------
//-- txpmaresetdone logic starts

   assign txpmaresetdone_int        = txpmaresetdone_out;

   assign gtwiz_userclk_tx_reset_in = ~(&txpmaresetdone_int);
   assign bufg_gt_clr_out     = ~(&txpmaresetdone_int);
//-- txpmaresetdone logic ends

//-- rxpmaresetdone logic starts
   assign rxpmaresetdone_int        = rxpmaresetdone_out;

   assign gtwiz_userclk_rx_reset_in = ~(&rxpmaresetdone_int);
      always @(posedge gtwiz_reset_clk_freerun_in) 
          gtwiz_userclk_rx_reset_in_r <= `DLY gtwiz_userclk_rx_reset_in;
//-- rxpmaresetdone logic ends

    //-- GT Reference clock assignment

    // decision is made to use cpll only - note the 1 at the end of QPLL, so below changes are needed
    // to be incorporated
    assign cplloutclk_out    = cplloutclk_out;
    assign cplloutrefclk_out = cplloutrefclk_out;


 // dynamic GT instance call
   design_1_aurora_64b66b_1_0_gt design_1_aurora_64b66b_1_0_gt_i
  (
   .cplllock_out(cplllock_out),
   .dmonitorout_out(dmonitorout_out),
   .drpaddr_in(drpaddr_in),
   .drpclk_in(drpclk_in),
   .drpdi_in(drpdi_in),
   .drpdo_out(drpdo_out),
   .drpen_in(drpen_in),
   .drprdy_out(drprdy_out),
   .drpwe_in(drpwe_in),
   .eyescandataerror_out(eyescandataerror_out),
   .eyescanreset_in(eyescanreset_in),
   .eyescantrigger_in(eyescantrigger_in),
   .gthrxn_in(gthrxn_in),
   .gthrxp_in(gthrxp_in),
   .gthtxn_out(gthtxn_out),
   .gthtxp_out(gthtxp_out),
   .gtpowergood_out(gtpowergood_out),
   .gtrefclk0_in(gtrefclk0_in),
   .gtwiz_reset_all_in(gtwiz_reset_all_in),
   .gtwiz_reset_clk_freerun_in(gtwiz_reset_clk_freerun_in),
   .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),
   .gtwiz_reset_rx_datapath_in(gtwiz_reset_rx_datapath_in),
   .gtwiz_reset_rx_done_out(gtwiz_reset_rx_done_out),
   .gtwiz_reset_rx_pll_and_datapath_in(gtwiz_reset_rx_pll_and_datapath_in),
   .gtwiz_reset_tx_datapath_in(gtwiz_reset_tx_datapath_in),
   .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),
   .gtwiz_reset_tx_pll_and_datapath_in(gtwiz_reset_tx_pll_and_datapath_in),
   .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),
   .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),
   .gtwiz_userdata_rx_out(gtwiz_userdata_rx_out),
   .gtwiz_userdata_tx_in(gtwiz_userdata_tx_in),
   .loopback_in(loopback_in),
   .pcsrsvdin_in(pcsrsvdin_in),
   .rxbufreset_in(rxbufreset_in),
   .rxbufstatus_out(rxbufstatus_out),
   .rxcdrhold_in(rxcdrhold_in),
   .rxcdrovrden_in(rxcdrovrden_in),
   .rxdatavalid_out(rxdatavalid_out),
   .rxdfelpmreset_in(rxdfelpmreset_in),
   .rxgearboxslip_in(rxgearboxslip_in),
   .rxheader_out(rxheader_out),
   .rxheadervalid_out(rxheadervalid_out),
   .rxlpmen_in(rxlpmen_in),
   .rxoutclk_out(rxoutclk_out),
   .rxpcsreset_in(rxpcsreset_in),
   .rxpmareset_in(rxpmareset_in),
   .rxpmaresetdone_out(rxpmaresetdone_out),
   .rxpolarity_in(rxpolarity_in),
   .rxprbscntreset_in(rxprbscntreset_in),
   .rxprbserr_out(rxprbserr_out),
   .rxprbssel_in(rxprbssel_in),
   .rxresetdone_out(rxresetdone_out),
   .rxstartofseq_out(rxstartofseq_out),
   .rxusrclk2_in(rxusrclk2_in),
   .rxusrclk_in(rxusrclk_in),
   .txbufstatus_out(txbufstatus_out),
   .txdiffctrl_in(txdiffctrl_in),
   .txheader_in(txheader_in),
   .txinhibit_in(txinhibit_in),
   .txoutclk_out(txoutclk_out),
   .txoutclkfabric_out(txoutclkfabric_out),
   .txoutclkpcs_out(txoutclkpcs_out),
   .txpcsreset_in(txpcsreset_in),
   .txpmareset_in(txpmareset_in),
   .txpmaresetdone_out(txpmaresetdone_out),
   .txpolarity_in(txpolarity_in),
   .txpostcursor_in(txpostcursor_in),
   .txprbsforceerr_in(txprbsforceerr_in),
   .txprbssel_in(txprbssel_in),
   .txprecursor_in(txprecursor_in),
   .txresetdone_out(txresetdone_out),
   .txsequence_in(txsequence_in),
   .txusrclk2_in(txusrclk2_in),
   .txusrclk_in(txusrclk_in)
  );



endmodule
