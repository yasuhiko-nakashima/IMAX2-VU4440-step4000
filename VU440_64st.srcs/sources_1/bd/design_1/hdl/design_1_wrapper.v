//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3.1 (lin64) Build 2489853 Tue Mar 26 04:18:30 MDT 2019
//Date        : Thu Mar 30 11:15:33 2023
//Host        : cad104.naist.jp running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
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
  input [0:0]CLK_150M_clk_n;
  input [0:0]CLK_150M_clk_p;
  input [0:0]CLK_78M_clk_n;
  input [0:0]CLK_78M_clk_p;
  input EXT_RESET;
  input GT_DIFF_REFCLK0_clk_n;
  input GT_DIFF_REFCLK0_clk_p;
  input GT_DIFF_REFCLK1_clk_n;
  input GT_DIFF_REFCLK1_clk_p;
  input [0:7]GT_SERIAL_RX0_rxn;
  input [0:7]GT_SERIAL_RX0_rxp;
  input [0:7]GT_SERIAL_RX1_rxn;
  input [0:7]GT_SERIAL_RX1_rxp;
  output [0:7]GT_SERIAL_TX0_txn;
  output [0:7]GT_SERIAL_TX0_txp;
  output [0:7]GT_SERIAL_TX1_txn;
  output [0:7]GT_SERIAL_TX1_txp;
  output HEART_BEAT;
  output LINK_UP0;
  output LINK_UP1;
  input MAIN_RESET_N;

  wire [0:0]CLK_150M_clk_n;
  wire [0:0]CLK_150M_clk_p;
  wire [0:0]CLK_78M_clk_n;
  wire [0:0]CLK_78M_clk_p;
  wire EXT_RESET;
  wire GT_DIFF_REFCLK0_clk_n;
  wire GT_DIFF_REFCLK0_clk_p;
  wire GT_DIFF_REFCLK1_clk_n;
  wire GT_DIFF_REFCLK1_clk_p;
  wire [0:7]GT_SERIAL_RX0_rxn;
  wire [0:7]GT_SERIAL_RX0_rxp;
  wire [0:7]GT_SERIAL_RX1_rxn;
  wire [0:7]GT_SERIAL_RX1_rxp;
  wire [0:7]GT_SERIAL_TX0_txn;
  wire [0:7]GT_SERIAL_TX0_txp;
  wire [0:7]GT_SERIAL_TX1_txn;
  wire [0:7]GT_SERIAL_TX1_txp;
  wire HEART_BEAT;
  wire LINK_UP0;
  wire LINK_UP1;
  wire MAIN_RESET_N;

  design_1 design_1_i
       (.CLK_150M_clk_n(CLK_150M_clk_n),
        .CLK_150M_clk_p(CLK_150M_clk_p),
        .CLK_78M_clk_n(CLK_78M_clk_n),
        .CLK_78M_clk_p(CLK_78M_clk_p),
        .EXT_RESET(EXT_RESET),
        .GT_DIFF_REFCLK0_clk_n(GT_DIFF_REFCLK0_clk_n),
        .GT_DIFF_REFCLK0_clk_p(GT_DIFF_REFCLK0_clk_p),
        .GT_DIFF_REFCLK1_clk_n(GT_DIFF_REFCLK1_clk_n),
        .GT_DIFF_REFCLK1_clk_p(GT_DIFF_REFCLK1_clk_p),
        .GT_SERIAL_RX0_rxn(GT_SERIAL_RX0_rxn),
        .GT_SERIAL_RX0_rxp(GT_SERIAL_RX0_rxp),
        .GT_SERIAL_RX1_rxn(GT_SERIAL_RX1_rxn),
        .GT_SERIAL_RX1_rxp(GT_SERIAL_RX1_rxp),
        .GT_SERIAL_TX0_txn(GT_SERIAL_TX0_txn),
        .GT_SERIAL_TX0_txp(GT_SERIAL_TX0_txp),
        .GT_SERIAL_TX1_txn(GT_SERIAL_TX1_txn),
        .GT_SERIAL_TX1_txp(GT_SERIAL_TX1_txp),
        .HEART_BEAT(HEART_BEAT),
        .LINK_UP0(LINK_UP0),
        .LINK_UP1(LINK_UP1),
        .MAIN_RESET_N(MAIN_RESET_N));
endmodule
