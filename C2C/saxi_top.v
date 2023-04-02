//------------------------------------------------------------------------------
// SAXI TOPMODEL
//------------------------------------------------------------------------------
// SAXI TOP ÉÇÉWÉÖÅ[Éã
// (1) SlaveAXI Top I/F
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : saxi_top.v
// Module         : SAXI_TOP
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module SAXI_TOP # (
					parameter	S_ID_BITS		=	8,		// 
					parameter	S_ADR_BITS		=	64,		// 
					parameter	S_LEN_BITS		=	8,		// 
					parameter	S_DATA_BITS		=	256,	// 
					parameter	ADR_FIFO_WORD	=	8,		// 
					parameter	DAT_FIFO_WORD	=	8,		// 
					parameter	RW_ORDER		=	0		// 
				) (
					MUX_CLK,								// 
					S_CLK,									// 
					S_RESET_N,								// 
					S_AWID,									// 
					S_AWADDR,								// 
					S_AWLEN,								// 
					S_AWSIZE,								// 
					S_AWBURST,								// 
					S_AWLOCK,								// 
					S_AWCACHE,								// 
					S_AWPROT,								// 
					S_AWQOS,								// 
					S_AWUSER,								// 
					S_AWVALID,								// 
					S_AWREADY,								// 
					S_WDATA,								// 
					S_WSTRB,								// 
					S_WLAST,								// 
					S_WVALID,								// 
					S_WREADY,								// 
					S_BID,									// 
					S_BRESP,								// 
					S_BVALID,								// 
					S_BREADY,								// 
					S_ARID,									// 
					S_ARADDR,								// 
					S_ARLEN,								// 
					S_ARSIZE,								// 
					S_ARBURST,								// 
					S_ARLOCK,								// 
					S_ARCACHE,								// 
					S_ARPROT,								// 
					S_ARQOS,								// 
					S_ARUSER,								// 
					S_ARVALID,								// 
					S_ARREADY,								// 
					S_RID,									// 
					S_RDATA,								// 
					S_RRESP,								// 
					S_RLAST,								// 
					S_RVALID,								// 
					S_RREADY,								// 

					S_WADR_FIFO_EMPTY,						// 
					S_WADR_FIFO_RDEN,						// 
					S_WADR_FIFO_RDATA,						// 
					S_WDAT_FIFO_EMPTY,						// 
					S_WDAT_FIFO_RDEN,						// 
                    S_WDAT_FIFO_RDATA,						// 

					S_RADR_FIFO_EMPTY,						// 
					S_RADR_FIFO_RDEN,						// 
					S_RADR_FIFO_RDATA,						// 
					S_RDAT_FIFO_FULL,						// 
					S_RDAT_FIFO_WREN,						// 
                    S_RDAT_FIFO_WDATA						// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input							MUX_CLK;				// 
	input							S_CLK;					// 
	input							S_RESET_N;				// 
	input	[S_ID_BITS-1:0]			S_AWID;					// 
	input	[S_ADR_BITS-1:0]		S_AWADDR;				// 
	input	[S_LEN_BITS-1:0]		S_AWLEN;				// 
	input	[2:0]					S_AWSIZE;				// 
	input	[1:0]					S_AWBURST;				// 
	input	[1:0]					S_AWLOCK;				// 
	input	[3:0]					S_AWCACHE;				// 
	input	[2:0]					S_AWPROT;				// 
	input	[3:0]					S_AWQOS;				// 
	input							S_AWUSER;				// 
	input							S_AWVALID;				// 
	output							S_AWREADY;				// 
	input	[S_DATA_BITS-1:0]		S_WDATA;				// 
	input	[S_DATA_BITS/8-1:0]		S_WSTRB;				// 
	input							S_WLAST;				// 
	input							S_WVALID;				// 
	output							S_WREADY;				// 
	output	[S_ID_BITS-1:0]			S_BID;					// 
	output	[1:0]					S_BRESP;				// 
	output							S_BVALID;				// 
	input							S_BREADY;				// 
	input	[S_ID_BITS-1:0]			S_ARID;					// 
	input	[S_ADR_BITS-1:0]		S_ARADDR;				// 
	input	[S_LEN_BITS-1:0]		S_ARLEN;				// 
	input	[2:0]					S_ARSIZE;				// 
	input	[1:0]					S_ARBURST;				// 
	input	[1:0]					S_ARLOCK;				// 
	input	[3:0]					S_ARCACHE;				// 
	input	[2:0]					S_ARPROT;				// 
	input	[3:0]					S_ARQOS;				// 
	input							S_ARUSER;				// 
	input							S_ARVALID;				// 
	output							S_ARREADY;				// 
	output	[S_ID_BITS-1:0]			S_RID;					// 
	output	[S_DATA_BITS-1:0]		S_RDATA;				// 
	output	[1:0]					S_RRESP;				// 
	output							S_RLAST;				// 
	output							S_RVALID;				// 
	input							S_RREADY;				// 

	output							S_WADR_FIFO_EMPTY;		// 
	input							S_WADR_FIFO_RDEN;		// 
	output	[127:0]					S_WADR_FIFO_RDATA;		// 
	output							S_WDAT_FIFO_EMPTY;		// 
	input							S_WDAT_FIFO_RDEN;		// 
	output	[577:0]					S_WDAT_FIFO_RDATA;		// 

	output							S_RADR_FIFO_EMPTY;		// 
	input							S_RADR_FIFO_RDEN;		// 
	output	[127:0]					S_RADR_FIFO_RDATA;		// 
	output							S_RDAT_FIFO_FULL;		// 
	input							S_RDAT_FIFO_WREN;		// 
	input	[577:0]					S_RDAT_FIFO_WDATA;		// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire							s_wadr_fifo_full;		// 
	wire							s_wadr_fifo_empty_mot;	// 
	wire							s_wadr_fifo_wren;		// 
	wire	[127:0]					s_wadr_fifo_wdata;		// 
	wire							s_wdat_fifo_full;		// 
	wire							s_wdat_fifo_wren;		// 
	wire	[577:0]					s_wdat_fifo_wdata;		// 

	wire							s_radr_fifo_full;		// 
	wire							s_radr_fifo_empty_mot;	// 
	wire							s_radr_fifo_wren;		// 
	wire	[127:0]					s_radr_fifo_wdata;		// 
	wire							s_rdat_fifo_empty;		// 
	wire							s_rdat_fifo_rden;		// 
	wire	[577:0]					s_rdat_fifo_rdata;		// 

	wire							s_acc_bit;				// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

ACC_CTRL	inst_acc_ctrl(
					.RESET_N				(S_RESET_N),
					.WCLK					(S_CLK),
					.RCLK					(MUX_CLK),
					.WR_WREN				(s_wadr_fifo_wren),
					.RD_WREN				(s_radr_fifo_wren),
					.WR_RDEN				(S_WADR_FIFO_RDEN),
					.RD_RDEN				(S_RADR_FIFO_RDEN),
					.ACC_BIT				(s_acc_bit)
	);



WR_IN	#	( 
					.S_ID_BITS				(S_ID_BITS),
					.S_ADR_BITS				(S_ADR_BITS),
					.S_LEN_BITS				(S_LEN_BITS),
					.S_DATA_BITS			(S_DATA_BITS),
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_wr_in (
					.S_CLK					(S_CLK),
					.S_RESET_N				(S_RESET_N),
					.S_AWID					(S_AWID),
					.S_AWADDR				(S_AWADDR),
					.S_AWLEN				(S_AWLEN),
					.S_AWSIZE				(S_AWSIZE),
					.S_AWBURST				(S_AWBURST),
					.S_AWLOCK				(S_AWLOCK),
					.S_AWCACHE				(S_AWCACHE),
					.S_AWPROT				(S_AWPROT),
					.S_AWQOS				(S_AWQOS),
					.S_AWUSER				(S_AWUSER),
					.S_AWVALID				(S_AWVALID),
					.S_AWREADY				(S_AWREADY),
					.S_WDATA				(S_WDATA),
					.S_WSTRB				(S_WSTRB),
					.S_WLAST				(S_WLAST),
					.S_WVALID				(S_WVALID),
					.S_WREADY				(S_WREADY),
					.S_BID					(S_BID),
					.S_BRESP				(S_BRESP),
					.S_BVALID				(S_BVALID),
					.S_BREADY				(S_BREADY),

					.WADR_FIFO_FULL			(s_wadr_fifo_full),
					.WADR_FIFO_WREN			(s_wadr_fifo_wren),
					.WADR_FIFO_WDATA		(s_wadr_fifo_wdata[127:0]),

					.WDAT_FIFO_FULL			(s_wdat_fifo_full),
					.WDAT_FIFO_WREN			(s_wdat_fifo_wren),
					.WDAT_FIFO_WDATA		(s_wdat_fifo_wdata[577:0])
	);

FIFO_128BXNW	#	(
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_wr_addr_fifo (
					.RST_N					(S_RESET_N),
					.WCLK					(S_CLK),
					.WREN					(s_wadr_fifo_wren),
					.WDATA					(s_wadr_fifo_wdata[127:0]),
					.FULL					(s_wadr_fifo_full),
					.RCLK					(MUX_CLK),
					.RDEN					(S_WADR_FIFO_RDEN),
					.RDATA					(S_WADR_FIFO_RDATA[127:0]),
					.EMPTY					(s_wadr_fifo_empty_mot)
	);

FIFO_578BXNW	#	(
					.FIFO_WORD				(DAT_FIFO_WORD)
				) inst_wr_data_fifo (
					.RST_N					(S_RESET_N),
					.WCLK					(S_CLK),
					.WREN					(s_wdat_fifo_wren),
					.WDATA					(s_wdat_fifo_wdata[577:0]),
					.FULL					(s_wdat_fifo_full),
					.RCLK					(MUX_CLK),
					.RDEN					(S_WDAT_FIFO_RDEN),
					.RDATA					(S_WDAT_FIFO_RDATA[577:0]),
					.EMPTY					(S_WDAT_FIFO_EMPTY)
	);



RD_IN	#	( 
					.S_ID_BITS				(S_ID_BITS),
					.S_ADR_BITS				(S_ADR_BITS),
					.S_LEN_BITS				(S_LEN_BITS),
					.S_DATA_BITS			(S_DATA_BITS),
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_rd_in (
					.S_CLK					(S_CLK),
					.S_RESET_N				(S_RESET_N),
					.S_ARID					(S_ARID),
					.S_ARADDR				(S_ARADDR),
					.S_ARLEN				(S_ARLEN),
					.S_ARSIZE				(S_ARSIZE),
					.S_ARBURST				(S_ARBURST),
					.S_ARLOCK				(S_ARLOCK),
					.S_ARCACHE				(S_ARCACHE),
					.S_ARPROT				(S_ARPROT),
					.S_ARQOS				(S_ARQOS),
					.S_ARUSER				(S_ARUSER),
					.S_ARVALID				(S_ARVALID),
					.S_ARREADY				(S_ARREADY),
					.S_RID					(S_RID),
					.S_RDATA				(S_RDATA),
					.S_RRESP				(S_RRESP),
					.S_RLAST				(S_RLAST),
					.S_RVALID				(S_RVALID),
					.S_RREADY				(S_RREADY),

					.RADR_FIFO_FULL			(s_radr_fifo_full),
					.RADR_FIFO_WREN			(s_radr_fifo_wren),
					.RADR_FIFO_WDATA		(s_radr_fifo_wdata[127:0]),

					.RDAT_FIFO_EMPTY		(s_rdat_fifo_empty),
					.RDAT_FIFO_RDEN			(s_rdat_fifo_rden),
					.RDAT_FIFO_RDATA		(s_rdat_fifo_rdata[577:0])
	);

FIFO_128BXNW	#	(
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_rd_addr_fifo (
					.RST_N					(S_RESET_N),
					.WCLK					(S_CLK),
					.WREN					(s_radr_fifo_wren),
					.WDATA					(s_radr_fifo_wdata[127:0]),
					.FULL					(s_radr_fifo_full),
					.RCLK					(MUX_CLK),
					.RDEN					(S_RADR_FIFO_RDEN),
					.RDATA					(S_RADR_FIFO_RDATA[127:0]),
					.EMPTY					(s_radr_fifo_empty_mot)
	);

FIFO_578BXNW	#	(
					.FIFO_WORD				(DAT_FIFO_WORD)
				) inst_rd_data_fifo (
					.RST_N					(S_RESET_N),
					.WCLK					(MUX_CLK),
					.WREN					(S_RDAT_FIFO_WREN),
					.WDATA					(S_RDAT_FIFO_WDATA[577:0]),
					.FULL					(S_RDAT_FIFO_FULL),
					.RCLK					(S_CLK),
					.RDEN					(s_rdat_fifo_rden),
					.RDATA					(s_rdat_fifo_rdata[577:0]),
					.EMPTY					(s_rdat_fifo_empty)
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		S_WADR_FIFO_EMPTY			=		( RW_ORDER == 1'b0 )  ? s_wadr_fifo_empty_mot :
													( s_acc_bit == 1'b1 ) ? s_wadr_fifo_empty_mot : 1'b1;

	assign		S_RADR_FIFO_EMPTY			=		( RW_ORDER == 1'b0 )  ? s_radr_fifo_empty_mot :
													( s_acc_bit == 1'b0 ) ? s_radr_fifo_empty_mot : 1'b1;


endmodule

