//------------------------------------------------------------------------------
// VU440_TOP MODEL
//------------------------------------------------------------------------------
// VU440 TOP モジュール
// (1) VU440トップ
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : vu440_top.v
// Module         : VU440_TOP
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module VU440_TOP (
					RESET,									// 
					EXT_RESET,								// 
					CLK_78M_CLK_N,							// 
					CLK_78M_CLK_P,							// 
					CLK_150M_CLK_N,							// 
					CLK_150M_CLK_P,							// 
					GT_DIFF_REFCLK0_CLK_N,					// 
					GT_DIFF_REFCLK0_CLK_P,					// 
					GT_DIFF_REFCLK1_CLK_N,					// 
					GT_DIFF_REFCLK1_CLK_P,					// 
					GT_SERIAL_RX0_RXN,						// 
					GT_SERIAL_RX0_RXP,						// 
					GT_SERIAL_RX1_RXN,						// 
					GT_SERIAL_RX1_RXP,						// 
					GT_SERIAL_TX0_TXN,						// 
					GT_SERIAL_TX0_TXP,						// 
					GT_SERIAL_TX1_TXN,						// 
					GT_SERIAL_TX1_TXP,						// 
					LED										// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input							RESET;					// 
	input							EXT_RESET;				// 
	input							CLK_78M_CLK_N;			// 
	input							CLK_78M_CLK_P;			// 
	input							CLK_150M_CLK_N;			// 
	input							CLK_150M_CLK_P;			// 
	input							GT_DIFF_REFCLK0_CLK_N;	// 
	input							GT_DIFF_REFCLK0_CLK_P;	// 
	input							GT_DIFF_REFCLK1_CLK_N;	// 
	input							GT_DIFF_REFCLK1_CLK_P;	// 
	input	[7:0]					GT_SERIAL_RX0_RXN;		// 
	input	[7:0]					GT_SERIAL_RX0_RXP;		// 
	input	[7:0]					GT_SERIAL_RX1_RXN;		// 
	input	[7:0]					GT_SERIAL_RX1_RXP;		// 
	output	[7:0]					GT_SERIAL_TX0_TXN;		// 
	output	[7:0]					GT_SERIAL_TX0_TXP;		// 
	output	[7:0]					GT_SERIAL_TX1_TXN;		// 
	output	[7:0]					GT_SERIAL_TX1_TXP;		// 
	output	[2:0]					LED;					// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

design_1_wrapper		inst_design_1_wrapper (
					.MAIN_RESET_N				(1'b1),
					.EXT_RESET					(~EXT_RESET),
					.CLK_78M_clk_n				(CLK_78M_CLK_N),
					.CLK_78M_clk_p				(CLK_78M_CLK_P),
					.CLK_150M_clk_n				(CLK_150M_CLK_N),
					.CLK_150M_clk_p				(CLK_150M_CLK_P),
					.GT_DIFF_REFCLK0_clk_n		(GT_DIFF_REFCLK0_CLK_N),
					.GT_DIFF_REFCLK0_clk_p		(GT_DIFF_REFCLK0_CLK_P),
					.GT_DIFF_REFCLK1_clk_n		(GT_DIFF_REFCLK1_CLK_N),
					.GT_DIFF_REFCLK1_clk_p		(GT_DIFF_REFCLK1_CLK_P),
					.GT_SERIAL_RX0_rxn			(GT_SERIAL_RX0_RXN[7:0]),
					.GT_SERIAL_RX0_rxp			(GT_SERIAL_RX0_RXP[7:0]),
					.GT_SERIAL_RX1_rxn			(GT_SERIAL_RX1_RXN[7:0]),
					.GT_SERIAL_RX1_rxp			(GT_SERIAL_RX1_RXP[7:0]),
					.GT_SERIAL_TX0_txn			(GT_SERIAL_TX0_TXN[7:0]),
					.GT_SERIAL_TX0_txp			(GT_SERIAL_TX0_TXP[7:0]),
					.GT_SERIAL_TX1_txn			(GT_SERIAL_TX1_TXN[7:0]),
					.GT_SERIAL_TX1_txp			(GT_SERIAL_TX1_TXP[7:0]),
					.LINK_UP0					(LED[0]),
					.LINK_UP1					(LED[1]),
					.HEART_BEAT					(LED[2])
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------



endmodule

