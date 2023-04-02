//------------------------------------------------------------------------------
// MAXI TOPMODEL
//------------------------------------------------------------------------------
// MAXI TOP ÉÇÉWÉÖÅ[Éã
// (1) MasterAXI Top I/F
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : maxi_top.v
// Module         : MAXI_TOP
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module MAXI_TOP # (
					parameter	M_ID_BITS		=	8,		// 
					parameter	M_ADR_BITS		=	64,		// 
					parameter	M_LEN_BITS		=	8,		// 
					parameter	M_DATA_BITS		=	256,	// 
					parameter	MLT_OUT_EN		=	0,		// 
					parameter	ADR_FIFO_WORD	=	8,		// 
					parameter	DAT_FIFO_WORD	=	8,		// 
					parameter	RW_ORDER		=	0		// 
				) (
					MUX_CLK,								// 
					M_CLK,									// 
					M_RESET_N,								// 
					M_AWID,									// 
					M_AWADDR,								// 
					M_AWLEN,								// 
					M_AWSIZE,								// 
					M_AWBURST,								// 
					M_AWLOCK,								// 
					M_AWCACHE,								// 
					M_AWPROT,								// 
					M_AWQOS,								// 
					M_AWUSER,								// 
					M_AWVALID,								// 
					M_AWREADY,								// 
					M_WDATA,								// 
					M_WSTRB,								// 
					M_WLAST,								// 
					M_WVALID,								// 
					M_WREADY,								// 
					M_BID,									// 
					M_BRESP,								// 
					M_BVALID,								// 
					M_BREADY,								// 
					M_ARID,									// 
					M_ARADDR,								// 
					M_ARLEN,								// 
					M_ARSIZE,								// 
					M_ARBURST,								// 
					M_ARLOCK,								// 
					M_ARCACHE,								// 
					M_ARPROT,								// 
					M_ARQOS,								// 
					M_ARUSER,								// 
					M_ARVALID,								// 
					M_ARREADY,								// 
					M_RID,									// 
					M_RDATA,								// 
					M_RRESP,								// 
					M_RLAST,								// 
					M_RVALID,								// 
					M_RREADY,								// 

					M_WADR_FIFO_FULL,						// 
					M_WADR_FIFO_WREN,						// 
					M_WADR_FIFO_WDATA,						// 
					M_WDAT_FIFO_FULL,						// 
					M_WDAT_FIFO_WREN,						// 
					M_WDAT_FIFO_WDATA,						// 

					M_RADR_FIFO_FULL,						// 
					M_RADR_FIFO_WREN,						// 
					M_RADR_FIFO_WDATA,						// 
					M_RDAT_FIFO_EMPTY,						// 
					M_RDAT_FIFO_RDEN,						// 
					M_RDAT_FIFO_RDATA						// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input							MUX_CLK;				// 
	input							M_CLK;					// 
	input							M_RESET_N;				// 
	output	[M_ID_BITS-1:0]			M_AWID;					// 
	output	[M_ADR_BITS-1:0]		M_AWADDR;				// 
	output	[M_LEN_BITS-1:0]		M_AWLEN;				// 
	output	[2:0]					M_AWSIZE;				// 
	output	[1:0]					M_AWBURST;				// 
	output	[1:0]					M_AWLOCK;				// 
	output	[3:0]					M_AWCACHE;				// 
	output	[2:0]					M_AWPROT;				// 
	output	[3:0]					M_AWQOS;				// 
	output							M_AWUSER;				// 
	output							M_AWVALID;				// 
	input							M_AWREADY;				// 
	output	[M_DATA_BITS-1:0]		M_WDATA;				// 
	output	[M_DATA_BITS/8-1:0]		M_WSTRB;				// 
	output							M_WLAST;				// 
	output							M_WVALID;				// 
	input							M_WREADY;				// 
	input	[M_ID_BITS-1:0]			M_BID;					// 
	input	[1:0]					M_BRESP;				// 
	input							M_BVALID;				// 
	output							M_BREADY;				// 
	output	[M_ID_BITS-1:0]			M_ARID;					// 
	output	[M_ADR_BITS-1:0]		M_ARADDR;				// 
	output	[M_LEN_BITS-1:0]		M_ARLEN;				// 
	output	[2:0]					M_ARSIZE;				// 
	output	[1:0]					M_ARBURST;				// 
	output	[1:0]					M_ARLOCK;				// 
	output	[3:0]					M_ARCACHE;				// 
	output	[2:0]					M_ARPROT;				// 
	output	[3:0]					M_ARQOS;				// 
	output							M_ARUSER;				// 
	output							M_ARVALID;				// 
	input							M_ARREADY;				// 
	input	[M_ID_BITS-1:0]			M_RID;					// 
	input	[M_DATA_BITS-1:0]		M_RDATA;				// 
	input	[1:0]					M_RRESP;				// 
	input							M_RLAST;				// 
	input							M_RVALID;				// 
	output							M_RREADY;				// 

	output							M_WADR_FIFO_FULL;		// 
	input							M_WADR_FIFO_WREN;		// 
	input	[127:0]					M_WADR_FIFO_WDATA;		// 
	output							M_WDAT_FIFO_FULL;		// 
	input							M_WDAT_FIFO_WREN;		// 
	input	[577:0]					M_WDAT_FIFO_WDATA;		// 

	output							M_RADR_FIFO_FULL;		// 
	input							M_RADR_FIFO_WREN;		// 
	input	[127:0]					M_RADR_FIFO_WDATA;		// 
	output							M_RDAT_FIFO_EMPTY;		// 
	input							M_RDAT_FIFO_RDEN;		// 
	output	[577:0]					M_RDAT_FIFO_RDATA;		// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire							s_wadr_fifo_empty;		// 
	wire							s_wadr_fifo_empty_mot;	// 
	wire							s_wadr_fifo_rden;		// 
	wire	[127:0]					s_wadr_fifo_rdata;		// 
	wire							s_wdat_fifo_empty;		// 
	wire							s_wdat_fifo_rden;		// 
	wire	[577:0]					s_wdat_fifo_rdata;		// 

	wire							s_radr_fifo_empty;		// 
	wire							s_radr_fifo_empty_mot;	// 
	wire							s_radr_fifo_rden;		// 
	wire	[127:0]					s_radr_fifo_rdata;		// 
	wire							s_rdat_fifo_full;		// 
	wire							s_rdat_fifo_wren;		// 
	wire	[577:0]					s_rdat_fifo_wdata;		// 

	wire							s_acc_bit;				// 
	wire							s_racc_mask;			// 
	wire							s_wacc_mask;			// 


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
					.RESET_N				(M_RESET_N),
					.WCLK					(MUX_CLK),
					.RCLK					(M_CLK),
					.WR_WREN				(M_WADR_FIFO_WREN),
					.RD_WREN				(M_RADR_FIFO_WREN),
					.WR_RDEN				(s_wadr_fifo_rden),
					.RD_RDEN				(s_radr_fifo_rden),
					.ACC_BIT				(s_acc_bit)
	);



WR_OUT	#	( 
					.M_ID_BITS				(M_ID_BITS),
					.M_ADR_BITS				(M_ADR_BITS),
					.M_LEN_BITS				(M_LEN_BITS),
					.M_DATA_BITS			(M_DATA_BITS),
					.MLT_OUT_EN				(MLT_OUT_EN),
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_wr_out (
					.M_CLK					(M_CLK),
					.M_RESET_N				(M_RESET_N),
					.M_AWID					(M_AWID),
					.M_AWADDR				(M_AWADDR),
					.M_AWLEN				(M_AWLEN),
					.M_AWSIZE				(M_AWSIZE),
					.M_AWBURST				(M_AWBURST),
					.M_AWLOCK				(M_AWLOCK),
					.M_AWCACHE				(M_AWCACHE),
					.M_AWPROT				(M_AWPROT),
					.M_AWQOS				(M_AWQOS),
					.M_AWUSER				(M_AWUSER),
					.M_AWVALID				(M_AWVALID),
					.M_AWREADY				(M_AWREADY),
					.M_WDATA				(M_WDATA),
					.M_WSTRB				(M_WSTRB),
					.M_WLAST				(M_WLAST),
					.M_WVALID				(M_WVALID),
					.M_WREADY				(M_WREADY),
					.M_BID					(M_BID),
					.M_BRESP				(M_BRESP),
					.M_BVALID				(M_BVALID),
					.M_BREADY				(M_BREADY),

					.WADR_FIFO_EMPTY		(s_wadr_fifo_empty),
					.WADR_FIFO_RDEN			(s_wadr_fifo_rden),
					.WADR_FIFO_RDATA		(s_wadr_fifo_rdata[127:0]),

					.WDAT_FIFO_EMPTY		(s_wdat_fifo_empty),
					.WDAT_FIFO_RDEN			(s_wdat_fifo_rden),
					.WDAT_FIFO_RDATA		(s_wdat_fifo_rdata[577:0]),

					.WACC_MASK				(s_wacc_mask)
	);

FIFO_128BXNW	#	(
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_wr_addr_fifo (
					.RST_N					(M_RESET_N),
					.WCLK					(MUX_CLK),
					.WREN					(M_WADR_FIFO_WREN),
					.WDATA					(M_WADR_FIFO_WDATA[127:0]),
					.FULL					(M_WADR_FIFO_FULL),
					.RCLK					(M_CLK),
					.RDEN					(s_wadr_fifo_rden),
					.RDATA					(s_wadr_fifo_rdata[127:0]),
					.EMPTY					(s_wadr_fifo_empty_mot)
	);

FIFO_578BXNW	#	(
					.FIFO_WORD				(DAT_FIFO_WORD)
				) inst_wr_data_fifo (
					.RST_N					(M_RESET_N),
					.WCLK					(MUX_CLK),
					.WREN					(M_WDAT_FIFO_WREN),
					.WDATA					(M_WDAT_FIFO_WDATA[577:0]),
					.FULL					(M_WDAT_FIFO_FULL),
					.RCLK					(M_CLK),
					.RDEN					(s_wdat_fifo_rden),
					.RDATA					(s_wdat_fifo_rdata[577:0]),
					.EMPTY					(s_wdat_fifo_empty)
	);



RD_OUT	#	( 
					.M_ID_BITS				(M_ID_BITS),
					.M_ADR_BITS				(M_ADR_BITS),
					.M_LEN_BITS				(M_LEN_BITS),
					.M_DATA_BITS			(M_DATA_BITS),
					.MLT_OUT_EN				(MLT_OUT_EN),
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_rd_out (
					.M_CLK					(M_CLK),
					.M_RESET_N				(M_RESET_N),
					.M_ARID					(M_ARID),
					.M_ARADDR				(M_ARADDR),
					.M_ARLEN				(M_ARLEN),
					.M_ARSIZE				(M_ARSIZE),
					.M_ARBURST				(M_ARBURST),
					.M_ARLOCK				(M_ARLOCK),
					.M_ARCACHE				(M_ARCACHE),
					.M_ARPROT				(M_ARPROT),
					.M_ARQOS				(M_ARQOS),
					.M_ARUSER				(M_ARUSER),
					.M_ARVALID				(M_ARVALID),
					.M_ARREADY				(M_ARREADY),
					.M_RID					(M_RID),
					.M_RDATA				(M_RDATA),
					.M_RRESP				(M_RRESP),
					.M_RLAST				(M_RLAST),
					.M_RVALID				(M_RVALID),
					.M_RREADY				(M_RREADY),

					.RADR_FIFO_EMPTY		(s_radr_fifo_empty),
					.RADR_FIFO_RDEN			(s_radr_fifo_rden),
					.RADR_FIFO_RDATA		(s_radr_fifo_rdata[127:0]),

					.RDAT_FIFO_FULL			(s_rdat_fifo_full),
					.RDAT_FIFO_WREN			(s_rdat_fifo_wren),
					.RDAT_FIFO_WDATA		(s_rdat_fifo_wdata[577:0]),

					.RACC_MASK				(s_racc_mask)
	);

FIFO_128BXNW	#	(
					.FIFO_WORD				(ADR_FIFO_WORD)
				) inst_rd_addr_fifo (
					.RST_N					(M_RESET_N),
					.WCLK					(MUX_CLK),
					.WREN					(M_RADR_FIFO_WREN),
					.WDATA					(M_RADR_FIFO_WDATA[127:0]),
					.FULL					(M_RADR_FIFO_FULL),
					.RCLK					(M_CLK),
					.RDEN					(s_radr_fifo_rden),
					.RDATA					(s_radr_fifo_rdata[127:0]),
					.EMPTY					(s_radr_fifo_empty_mot)
	);

FIFO_578BXNW	#	(
					.FIFO_WORD				(DAT_FIFO_WORD)
				) inst_rd_dat_fifo (
					.RST_N					(M_RESET_N),
					.WCLK					(M_CLK),
					.WREN					(s_rdat_fifo_wren),
					.WDATA					(s_rdat_fifo_wdata[577:0]),
					.FULL					(s_rdat_fifo_full),
					.RCLK					(MUX_CLK),
					.RDEN					(M_RDAT_FIFO_RDEN),
					.RDATA					(M_RDAT_FIFO_RDATA[577:0]),
					.EMPTY					(M_RDAT_FIFO_EMPTY)
	);



//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		s_wadr_fifo_empty			=		( RW_ORDER == 1'b0 )                         ? s_wadr_fifo_empty_mot :
													( s_acc_bit == 1'b1 && s_racc_mask == 1'b0 ) ? s_wadr_fifo_empty_mot : 1'b1;

	assign		s_radr_fifo_empty			=		( RW_ORDER == 1'b0 )                         ? s_radr_fifo_empty_mot :
													( s_acc_bit == 1'b0 && s_wacc_mask == 1'b0 ) ? s_radr_fifo_empty_mot : 1'b1;



endmodule

