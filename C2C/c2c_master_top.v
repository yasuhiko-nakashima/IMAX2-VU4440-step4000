//------------------------------------------------------------------------------
// C2C_MASTER_TOP TOPMODEL
//------------------------------------------------------------------------------
// C2C MASTER TOP ÉÇÉWÉÖÅ[Éã
// (1) Card to Card Master Top I/F
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : c2c_master_top_top.v
// Module         : C2C_MASTER_TOP
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

`include "c2c_master_common.vh" 

module C2C_MASTER_TOP	(
				input	wire							M_AXI_CLK,			// 
				input	wire							M_AXI_RESET_N,		// 
				output	wire	[`M_ID_BITS-1:0]		M_AXI_AWID,			// 
				output	wire	[`M_ADR_BITS-1:0]		M_AXI_AWADDR,		// 
				output	wire	[`M_LEN_BITS-1:0]		M_AXI_AWLEN,		// 
				output	wire	[2:0]					M_AXI_AWSIZE,		// 
				output	wire	[1:0]					M_AXI_AWBURST,		// 
				output	wire	[1:0]					M_AXI_AWLOCK,		// 
				output	wire	[3:0]					M_AXI_AWCACHE,		// 
				output	wire	[2:0]					M_AXI_AWPROT,		// 
				output	wire	[3:0]					M_AXI_AWQOS,		// 
				output	wire							M_AXI_AWUSER,		// 
				output	wire							M_AXI_AWVALID,		// 
				input	wire							M_AXI_AWREADY,		// 
				output	wire	[`M_DATA_BITS-1:0	]	M_AXI_WDATA,		// 
				output	wire	[`M_DATA_BITS/8-1:0]	M_AXI_WSTRB,		// 
				output	wire							M_AXI_WLAST,		// 
				output	wire							M_AXI_WVALID,		// 
				input	wire							M_AXI_WREADY,		// 
				input	wire	[`M_ID_BITS-1:0]		M_AXI_BID,			// 
				input	wire	[1:0]					M_AXI_BRESP,		// 
				input	wire							M_AXI_BVALID,		// 
				output	wire							M_AXI_BREADY,		// 
				output	wire	[`M_ID_BITS-1:0]		M_AXI_ARID,			// 
				output	wire	[`M_ADR_BITS-1:0]		M_AXI_ARADDR,		// 
				output	wire	[`M_LEN_BITS-1:0]		M_AXI_ARLEN,		// 
				output	wire	[2:0]					M_AXI_ARSIZE,		// 
				output	wire	[1:0]					M_AXI_ARBURST,		// 
				output	wire	[1:0]					M_AXI_ARLOCK,		// 
				output	wire	[3:0]					M_AXI_ARCACHE,		// 
				output	wire	[2:0]					M_AXI_ARPROT,		// 
				output	wire	[3:0]					M_AXI_ARQOS,		// 
				output	wire							M_AXI_ARUSER,		// 
				output	wire							M_AXI_ARVALID,		// 
				input	wire							M_AXI_ARREADY,		// 
				input	wire	[`M_ID_BITS-1:0]		M_AXI_RID,			// 
				input	wire	[`M_DATA_BITS-1:0]		M_AXI_RDATA,		// 
				input	wire	[1:0]					M_AXI_RRESP,		// 
				input	wire							M_AXI_RLAST,		// 
				input	wire							M_AXI_RVALID,		// 
				output	wire							M_AXI_RREADY,		// 

`ifdef DEBUG_EN
				output	wire	[11:0]					M_AXI_PROBE,		// 
`endif

`ifdef DEBUG_EN
				output	wire	[6:0]					TX_PROBE0,			// 
				output	wire	[63:0]					TX_PROBE1,			// 
				output	wire	[511:0]					TX_PROBE2,			// 
				output	wire	[63:0]					TX_PROBE3,			// 
				output	wire	[511:0]					TX_PROBE4,			// 
`endif

				input	wire							AURORA_CLK,			// 
				input	wire							AURORA_RESET_N,		// 
				input	wire							HARD_ERR,			// 
				input	wire							SOFT_ERR,			// 
				input	wire							CH_UP,				// 
				input	wire	[`A_LANE_BITS-1:0]		LANE_UP,			// 
				output	wire							LINK_UP,			// 
				output	wire							POWER_DOWN,			// 
				output	wire	[2:0]					LOOPBACK,			// 
				output	wire	[`A_DATA_BITS-1:0]		TX_TDATA,			// 
				output	wire							TX_TLAST,			// 
				output	wire	[`A_DATA_BITS/8-1:0]	TX_TKEEP,			// 
				output	wire							TX_TVALID,			// 
				input	wire							TX_TREADY,			// 
				input	wire	[`A_DATA_BITS-1:0]		RX_TDATA,			// 
				input	wire							RX_TLAST,			// 
				input	wire	[`A_DATA_BITS/8-1:0]	RX_TKEEP,			// 
				input	wire							RX_TVALID			// 
	);


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire				s_m_wadr_fifo_full;		// 
	wire				s_m_wadr_fifo_wren;		// 
	wire	[127:0]		s_m_wadr_fifo_wdata;	// 
	wire				s_m_wdat_fifo_full;		// 
	wire				s_m_wdat_fifo_wren;		// 
	wire	[577:0]		s_m_wdat_fifo_wdata;	// 
	wire				s_m_radr_fifo_full;		// 
	wire				s_m_radr_fifo_wren;		// 
	wire	[127:0]		s_m_radr_fifo_wdata;	// 
	wire				s_m_rdat_fifo_empty;	// 
	wire				s_m_rdat_fifo_rden;		// 
	wire	[577:0]		s_m_rdat_fifo_rdata;	// 
	wire				s_s_wadr_fifo_empty;	// 
	wire				s_s_wadr_fifo_rden;		// 
	wire	[127:0]		s_s_wadr_fifo_rdata;	// 
	wire				s_s_wdat_fifo_empty;	// 
	wire				s_s_wdat_fifo_rden;		// 
    wire	[577:0]		s_s_wdat_fifo_rdata;	// 
	wire				s_s_radr_fifo_empty;	// 
	wire				s_s_radr_fifo_rden;		// 
	wire	[127:0]		s_s_radr_fifo_rdata;	// 
	wire				s_s_rdat_fifo_full;		// 
	wire				s_s_rdat_fifo_wren;		// 
    wire	[577:0]		s_s_rdat_fifo_wdata;	// 
	wire	[6:0]		s_tx_probe0;			// 
	wire	[63:0]		s_tx_probe1;			// 
	wire	[511:0]		s_tx_probe2;			// 
	wire	[63:0]		s_tx_probe3;			// 
	wire	[511:0]		s_tx_probe4;			// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

AURORA_CTRL # (
					.A_LANE_BITS				(`A_LANE_BITS),
					.A_DATA_BITS				(`A_DATA_BITS),
					.LEN_WORD					(`LEN_WORD),
					.LEN_CNT_BIT				(`LEN_CNT_BIT),
					.BUFF_WORD					(`BUFF_WORD),
					.BUFF_CNT_BIT				(`BUFF_CNT_BIT)
				) inst_aurora_ctrl (
					.AURORA_CLK					(AURORA_CLK),
					.AURORA_RESET_N				(AURORA_RESET_N),

					.FRAME_ERR					(1'b0),
					.HARD_ERR					(HARD_ERR),
					.SOFT_ERR					(SOFT_ERR),
					.CH_UP						(CH_UP),
					.LANE_UP					(LANE_UP[`A_LANE_BITS-1:0]),
					.LINK_UP					(LINK_UP),

					.TX_TDATA					(TX_TDATA[`A_DATA_BITS-1:0]),
					.TX_TLAST					(TX_TLAST),
					.TX_TKEEP					(TX_TKEEP[`A_DATA_BITS/8-1:0]),
					.TX_TVALID					(TX_TVALID),
					.TX_TREADY					(TX_TREADY),
					.RX_TDATA					(RX_TDATA[`A_DATA_BITS-1:0]),
					.RX_TLAST					(RX_TLAST),
					.RX_TKEEP					(RX_TKEEP[`A_DATA_BITS/8-1:0]),
					.RX_TVALID					(RX_TVALID),

					.M_WADR_FIFO_FULL			(s_m_wadr_fifo_full),
					.M_WADR_FIFO_WREN			(s_m_wadr_fifo_wren),
					.M_WADR_FIFO_WDATA			(s_m_wadr_fifo_wdata[127:0]),
					.M_WDAT_FIFO_FULL			(s_m_wdat_fifo_full),
					.M_WDAT_FIFO_WREN			(s_m_wdat_fifo_wren),
					.M_WDAT_FIFO_WDATA			(s_m_wdat_fifo_wdata[577:0]),

					.M_RADR_FIFO_FULL			(s_m_radr_fifo_full),
					.M_RADR_FIFO_WREN			(s_m_radr_fifo_wren),
					.M_RADR_FIFO_WDATA			(s_m_radr_fifo_wdata[127:0]),
					.M_RDAT_FIFO_EMPTY			(s_m_rdat_fifo_empty),
					.M_RDAT_FIFO_RDEN			(s_m_rdat_fifo_rden),
					.M_RDAT_FIFO_RDATA			(s_m_rdat_fifo_rdata[577:0]),

					.S_WADR_FIFO_EMPTY			(s_s_wadr_fifo_empty),
					.S_WADR_FIFO_RDEN			(s_s_wadr_fifo_rden),
					.S_WADR_FIFO_RDATA			(s_s_wadr_fifo_rdata[127:0]),
					.S_WDAT_FIFO_EMPTY			(s_s_wdat_fifo_empty),
					.S_WDAT_FIFO_RDEN			(s_s_wdat_fifo_rden),
                    .S_WDAT_FIFO_RDATA			(s_s_wdat_fifo_rdata[577:0]),

					.S_RADR_FIFO_EMPTY			(s_s_radr_fifo_empty),
					.S_RADR_FIFO_RDEN			(s_s_radr_fifo_rden),
					.S_RADR_FIFO_RDATA			(s_s_radr_fifo_rdata[127:0]),
					.S_RDAT_FIFO_FULL			(s_s_rdat_fifo_full),
					.S_RDAT_FIFO_WREN			(s_s_rdat_fifo_wren),
                    .S_RDAT_FIFO_WDATA			(s_s_rdat_fifo_wdata[577:0]),

					.TX_PROBE0					(s_tx_probe0[6:0]),
					.TX_PROBE1					(s_tx_probe1[63:0]),
					.TX_PROBE2					(s_tx_probe2[511:0]),
					.TX_PROBE3					(s_tx_probe3[63:0]),
					.TX_PROBE4					(s_tx_probe4[511:0])
	);

MAXI_TOP # (
					.M_ID_BITS					(`M_ID_BITS),
					.M_ADR_BITS					(`M_ADR_BITS),
					.M_LEN_BITS					(`M_LEN_BITS),
					.M_DATA_BITS				(`M_DATA_BITS),
					.MLT_OUT_EN					(`MLT_OUT_EN),
					.ADR_FIFO_WORD				(`ADR_FIFO_WORD),
					.DAT_FIFO_WORD				(`DAT_FIFO_WORD),
					.RW_ORDER					(`RW_ORDER)
				) inst_m_top (
					.MUX_CLK					(AURORA_CLK),
					.M_CLK						(M_AXI_CLK),
					.M_RESET_N					(M_AXI_RESET_N),
					.M_AWID						(M_AXI_AWID),
					.M_AWADDR					(M_AXI_AWADDR),
					.M_AWLEN					(M_AXI_AWLEN),
					.M_AWSIZE					(M_AXI_AWSIZE),
					.M_AWBURST					(M_AXI_AWBURST),
					.M_AWLOCK					(M_AXI_AWLOCK),
					.M_AWCACHE					(M_AXI_AWCACHE),
					.M_AWPROT					(M_AXI_AWPROT),
					.M_AWQOS					(M_AXI_AWQOS),
					.M_AWUSER					(M_AXI_AWUSER),
					.M_AWVALID					(M_AXI_AWVALID),
					.M_AWREADY					(M_AXI_AWREADY),
					.M_WDATA					(M_AXI_WDATA),
					.M_WSTRB					(M_AXI_WSTRB),
					.M_WLAST					(M_AXI_WLAST),
					.M_WVALID					(M_AXI_WVALID),
					.M_WREADY					(M_AXI_WREADY),
					.M_BID						(M_AXI_BID),
					.M_BRESP					(M_AXI_BRESP),
					.M_BVALID					(M_AXI_BVALID),
					.M_BREADY					(M_AXI_BREADY),
					.M_ARID						(M_AXI_ARID),
					.M_ARADDR					(M_AXI_ARADDR),
					.M_ARLEN					(M_AXI_ARLEN),
					.M_ARSIZE					(M_AXI_ARSIZE),
					.M_ARBURST					(M_AXI_ARBURST),
					.M_ARLOCK					(M_AXI_ARLOCK),
					.M_ARCACHE					(M_AXI_ARCACHE),
					.M_ARPROT					(M_AXI_ARPROT),
					.M_ARQOS					(M_AXI_ARQOS),
					.M_ARUSER					(M_AXI_ARUSER),
					.M_ARVALID					(M_AXI_ARVALID),
					.M_ARREADY					(M_AXI_ARREADY),
					.M_RID						(M_AXI_RID),
					.M_RDATA					(M_AXI_RDATA),
					.M_RRESP					(M_AXI_RRESP),
					.M_RLAST					(M_AXI_RLAST),
					.M_RVALID					(M_AXI_RVALID),
					.M_RREADY					(M_AXI_RREADY),

					.M_WADR_FIFO_FULL			(s_m_wadr_fifo_full),
					.M_WADR_FIFO_WREN			(s_m_wadr_fifo_wren),
					.M_WADR_FIFO_WDATA			(s_m_wadr_fifo_wdata[127:0]),
					.M_WDAT_FIFO_FULL			(s_m_wdat_fifo_full),
					.M_WDAT_FIFO_WREN			(s_m_wdat_fifo_wren),
					.M_WDAT_FIFO_WDATA			(s_m_wdat_fifo_wdata[577:0]),

					.M_RADR_FIFO_FULL			(s_m_radr_fifo_full),
					.M_RADR_FIFO_WREN			(s_m_radr_fifo_wren),
					.M_RADR_FIFO_WDATA			(s_m_radr_fifo_wdata[127:0]),
					.M_RDAT_FIFO_EMPTY			(s_m_rdat_fifo_empty),
					.M_RDAT_FIFO_RDEN			(s_m_rdat_fifo_rden),
					.M_RDAT_FIFO_RDATA			(s_m_rdat_fifo_rdata[577:0])
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		POWER_DOWN					=		1'b0;
	assign		LOOPBACK					=		3'b000;


`ifdef DEBUG_EN
	assign		TX_PROBE0[6:0]				=		s_tx_probe0[6:0];
	assign		TX_PROBE1[63:0]				=		s_tx_probe1[63:0];
	assign		TX_PROBE2[511:0]			=		s_tx_probe2[511:0];
	assign		TX_PROBE3[63:0]				=		s_tx_probe3[63:0];
	assign		TX_PROBE4[511:0]			=		s_tx_probe4[511:0];
`endif

`ifdef DEBUG_EN
	assign		M_AXI_PROBE[0]				=		M_AXI_ARVALID;
	assign		M_AXI_PROBE[1]				=		M_AXI_ARREADY;
	assign		M_AXI_PROBE[2]				=		M_AXI_RVALID;
	assign		M_AXI_PROBE[3]				=		M_AXI_RREADY;
	assign		M_AXI_PROBE[4]				=		M_AXI_RLAST;
	assign		M_AXI_PROBE[5]				=		M_AXI_AWVALID;
	assign		M_AXI_PROBE[6]				=		M_AXI_AWREADY;
	assign		M_AXI_PROBE[7]				=		M_AXI_WVALID;
	assign		M_AXI_PROBE[8]				=		M_AXI_WREADY;
	assign		M_AXI_PROBE[9]				=		M_AXI_WLAST;
	assign		M_AXI_PROBE[10]				=		M_AXI_BVALID;
	assign		M_AXI_PROBE[11]				=		M_AXI_BREADY;
`endif



	assign		s_s_wadr_fifo_empty			=		1'b1;
	assign		s_s_wadr_fifo_rdata[127:0]	=		128'd0;
	assign		s_s_wdat_fifo_empty			=		1'b1;
	assign		s_s_wdat_fifo_rdata[577:0]	=		578'd0;

	assign		s_s_radr_fifo_empty			=		1'b1;
	assign		s_s_radr_fifo_rdata[127:0]	=		128'd0;
	assign		s_s_rdat_fifo_full			=		1'b0;



endmodule

