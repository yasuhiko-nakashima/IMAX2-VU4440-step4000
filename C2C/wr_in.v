//------------------------------------------------------------------------------
// WR_IN MODEL
//------------------------------------------------------------------------------
// WR_IN モジュール
// (1) ライト入力処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : wr_in.v
// Module         : WR_IN
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module WR_IN # ( 
					parameter	S_ID_BITS		=	8,		// 
					parameter	S_ADR_BITS		=	64,		// 
					parameter	S_LEN_BITS		=	8,		// 
					parameter	S_DATA_BITS		=	256,	// 
					parameter	FIFO_WORD		=	8		// 
				) (
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

					WADR_FIFO_FULL,							// 
					WADR_FIFO_WREN,							// 
					WADR_FIFO_WDATA,						// 

					WDAT_FIFO_FULL,							// 
					WDAT_FIFO_WREN,							// 
					WDAT_FIFO_WDATA							// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input								S_CLK;				// 
	input								S_RESET_N;			// 
	input	[S_ID_BITS-1:0]				S_AWID;				// 
	input	[S_ADR_BITS-1:0]			S_AWADDR;			// 
	input	[S_LEN_BITS-1:0]			S_AWLEN;			// 
	input	[2:0]						S_AWSIZE;			// 
	input	[1:0]						S_AWBURST;			// 
	input	[1:0]						S_AWLOCK;			// 
	input	[3:0]						S_AWCACHE;			// 
	input	[2:0]						S_AWPROT;			// 
	input	[3:0]						S_AWQOS;			// 
	input								S_AWUSER;			// 
	input								S_AWVALID;			// 
	input	[S_DATA_BITS-1:0]			S_WDATA;			// 
	input	[S_DATA_BITS/8-1:0]			S_WSTRB;			// 
	input								S_WLAST;			// 
	input								S_WVALID;			// 
	input								S_BREADY;			// 
	output								S_AWREADY;			// 
	output								S_WREADY;			// 
	output	[S_ID_BITS-1:0]				S_BID;				// 
	output	[1:0]						S_BRESP;			// 
	output								S_BVALID;			// 
	input								WADR_FIFO_FULL;		// 
	output								WADR_FIFO_WREN;		// 
	output	[127:0]						WADR_FIFO_WDATA;	// 
	input								WDAT_FIFO_FULL;		// 
	output								WDAT_FIFO_WREN;		// 
	output	[577:0]						WDAT_FIFO_WDATA;	// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire							s_wid_fifo_wren;		// 
	wire	[15:0]					s_wid_fifo_wdata;		// 
	wire							s_wid_fifo_full;		// 
	wire							s_wid_fifo_rden;		// 
	wire	[15:0]					s_wid_fifo_rdata;		// 
	wire							s_wid_fifo_empty;		// 
	wire	[127:0]					s_wr_adr_fifo_wdata;	// 
	wire	[63:0]					s_addr_in;				// 
	wire	[63:0]					s_addr_mask;			// 
	wire	[2:0]					s_s_awsize;				// 
	wire							s_wr_adr_fifo_wren;		// 
	wire							s_wready;				// 
	wire	[3:0]					s_wcnt_max;				// 
	wire							s_wr_dat_fifo_wren;		// 
	wire	[577:0]					s_wr_dat_fifo_wdata;	// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg								sr_awready;				// 
	reg		[3:0]					sr_wcnt;				// 
	reg		[577:0]					sr_wr_dat_fifo_wdata;	// 
	reg		[1:0]					sr_bresp;				// 
	reg		[S_ID_BITS-1:0]			sr_bid;					// 
	reg								sr_bvalid;				// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

FIFO_16BXNW	#	(
					.FIFO_WORD				(FIFO_WORD)
				) inst_wr_addr_fifo (
					.RST_N					(S_RESET_N),
					.CLK					(S_CLK),
					.WREN					(s_wid_fifo_wren),
					.WDATA					(s_wid_fifo_wdata[15:0]),
					.FULL					(s_wid_fifo_full),
					.RDEN					(s_wid_fifo_rden),
					.RDATA					(s_wid_fifo_rdata[15:0]),
					.EMPTY					(s_wid_fifo_empty)
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		S_AWREADY					=		sr_awready;
	assign		S_WREADY					=		s_wready;
	assign		S_BID[S_ID_BITS-1:0]		=		sr_bid[S_ID_BITS-1:0];
	assign		S_BRESP[1:0]				=		sr_bresp[1:0];
	assign		S_BVALID					=		sr_bvalid;

	assign		WADR_FIFO_WREN				=		s_wr_adr_fifo_wren;
	assign		WADR_FIFO_WDATA[127:0]		=		s_wr_adr_fifo_wdata[127:0];
	assign		WDAT_FIFO_WREN				=		s_wr_dat_fifo_wren;
	assign		WDAT_FIFO_WDATA[577:0]		=		s_wr_dat_fifo_wdata[577:0];


//------------------------------------------------------------------------------
// アドレスフェーズ制御部
//------------------------------------------------------------------------------

	// アドレスレディ信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_awready		<=		1'b0;
		end else if( S_AWVALID == 1'b1 && WADR_FIFO_FULL == 1'b0
					&& sr_awready == 1'b0 && s_wid_fifo_full == 1'b0 )begin
			sr_awready		<=		1'b1;
		end else begin
			sr_awready		<=		1'b0;
		end
	end

	// アドレスフェーズ入力情報信号 //
	assign	s_wr_adr_fifo_wdata[127:112]	=		{ 13'd0, s_s_awsize[2:0] };								// 127 - 112
	assign	s_wr_adr_fifo_wdata[111:96]		=		{ {16-S_ID_BITS{1'b0}}, S_AWID[S_ID_BITS-1:0] };		// 111 -  96
	assign	s_wr_adr_fifo_wdata[95:80]		=		{ {16-S_LEN_BITS{1'b0}}, S_AWLEN[S_LEN_BITS-1:0] };		//  95 -  80
	assign	s_wr_adr_fifo_wdata[79:72]		=		{ S_AWBURST[1:0], S_AWLOCK[1:0], S_AWCACHE[3:0] };		//  79 -  72
	assign	s_wr_adr_fifo_wdata[71:64]		=		{ S_AWPROT[2:0], S_AWQOS[3:0], S_AWUSER };				//  71 -  64
	assign	s_wr_adr_fifo_wdata[63:0]		=		{ {64-S_ADR_BITS{1'b0}}, s_addr_in[S_ADR_BITS-1:0] };	//  63 -  00

	// アドレスマスク処理信号 //
	assign		s_addr_in[S_ADR_BITS-1:0	]=		S_AWADDR[S_ADR_BITS-1:0] & s_addr_mask[S_ADR_BITS-1:0];

	assign		s_addr_mask[63:0]			=		( S_DATA_BITS == 512 ) ? 64'hFFFF_FFFF_FFFF_FFC0 :
													( S_DATA_BITS == 256 ) ? 64'hFFFF_FFFF_FFFF_FFE0 :
													( S_DATA_BITS == 128 ) ? 64'hFFFF_FFFF_FFFF_FFF0 :
													( S_DATA_BITS ==  64 ) ? 64'hFFFF_FFFF_FFFF_FFF8 :
													( S_DATA_BITS ==  32 ) ? 64'hFFFF_FFFF_FFFF_FFFC : 64'hFFFF_FFFF_FFFF_FFFF;

	// データサイズ信号 //
	assign		s_s_awsize[2:0]				=		( S_DATA_BITS ==   8 ) ? 3'b000 :
													( S_DATA_BITS ==  16 ) ? 3'b001 :
													( S_DATA_BITS ==  32 ) ? 3'b010 :
													( S_DATA_BITS ==  64 ) ? 3'b011 :
													( S_DATA_BITS == 128 ) ? 3'b100 :
													( S_DATA_BITS == 256 ) ? 3'b101 :
													( S_DATA_BITS == 512 ) ? 3'b110 : 3'b111;

	// ライトアドレスFIFOライトイネーブル信号 //
	assign		s_wr_adr_fifo_wren			=		( S_AWVALID == 1'b1 && sr_awready == 1'b1 ) ? 1'b1 : 1'b0;

	// ライトID-FIFOライトイネーブル信号 //
	assign		s_wid_fifo_wren				=		( S_AWVALID == 1'b1 && sr_awready == 1'b1 ) ? 1'b1 : 1'b0;

	// ライトID-FIFOライトデータ信号 //
	assign		s_wid_fifo_wdata[15:0]		=		{ {16-S_ID_BITS{1'b0}}, S_AWID[S_ID_BITS-1:0] };



//------------------------------------------------------------------------------
// データフェーズ制御部
//------------------------------------------------------------------------------

	// データレディ信号 //
	assign		s_wready					=		( S_WLAST == 1'b0 && sr_wcnt[3:0] == s_wcnt_max[3:0] && s_wid_fifo_empty == 1'b0 && WDAT_FIFO_FULL == 1'b0) ? 1'b1 :
													( S_WLAST == 1'b0 && sr_wcnt[3:0] != s_wcnt_max[3:0] && s_wid_fifo_empty == 1'b0 )                          ? 1'b1 :
													( S_WLAST == 1'b1 && WDAT_FIFO_FULL == 1'b0 && s_wid_fifo_empty == 1'b0 && sr_bvalid == 1'b0 )              ? 1'b1 : 1'b0;

	// データカウントMAX信号 //
	assign		s_wcnt_max[3:0]				=		( S_DATA_BITS == 512 ) ? 4'b0000 :
													( S_DATA_BITS == 256 ) ? 4'b0001 :
													( S_DATA_BITS == 128 ) ? 4'b0011 :
													( S_DATA_BITS ==  64 ) ? 4'b0111 : 4'b1111;

	// データカウント信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_wcnt[3:0]		<=		4'b0000;
		end else if( S_WVALID == 1'b1 && s_wready == 1'b1 )begin
			if( S_WLAST == 1'b1 )begin
				sr_wcnt[3:0]		<=		4'b0000;
			end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] )begin
				sr_wcnt[3:0]		<=		4'b0000;
			end else begin
				sr_wcnt[3:0]		<=		sr_wcnt[3:0] + 4'b0001;
 			end
		end
	end

	// WR_FIFOライトイネーブル信号 //
	assign		s_wr_dat_fifo_wren			=		( S_WVALID == 1'b1 && s_wready == 1'b1 && S_WLAST == 1'b1 )                 ? 1'b1 :
													( S_WVALID == 1'b1 && s_wready == 1'b1 && sr_wcnt[3:0] == s_wcnt_max[3:0] ) ? 1'b1 : 1'b0;

	// WR_FIFOライトデータ信号 //
	assign		s_wr_dat_fifo_wdata[577:0]	=		( S_DATA_BITS == 512 )                            ? { 1'b0, S_WLAST,        S_WSTRB[S_DATA_BITS/8-1:0],                                        S_WDATA[S_DATA_BITS-1:0] }                              :
													( S_DATA_BITS == 256 && sr_wcnt[0] == 1'b0 )      ? { 1'b0, S_WLAST, 32'd0, S_WSTRB[S_DATA_BITS/8-1:0],                                        256'd0,                   S_WDATA[S_DATA_BITS-1:0] }    :
													( S_DATA_BITS == 256 && sr_wcnt[0] == 1'b1 )      ? { 1'b0, S_WLAST,        S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[543:512],         S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[255:0] } :
													( S_DATA_BITS == 128 && sr_wcnt[1:0] == 2'b00 )   ? { 1'b0, S_WLAST, 48'd0, S_WSTRB[S_DATA_BITS/8-1:0],                                384'd0, S_WDATA[S_DATA_BITS-1:0] }                              :
													( S_DATA_BITS == 128 && sr_wcnt[1:0] == 2'b01 )   ? { 1'b0, S_WLAST, 32'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[527:512], 256'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[127:0] } :
													( S_DATA_BITS == 128 && sr_wcnt[1:0] == 2'b10 )   ? { 1'b0, S_WLAST, 16'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[543:512], 128'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[255:0] } :
													( S_DATA_BITS == 128 && sr_wcnt[1:0] == 2'b11 )   ? { 1'b0, S_WLAST,        S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[559:512],         S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[383:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b000 )  ? { 1'b0, S_WLAST, 56'd0, S_WSTRB[S_DATA_BITS/8-1:0],                                448'd0, S_WDATA[S_DATA_BITS-1:0] }                          :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b001 )  ? { 1'b0, S_WLAST, 48'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[519:512], 384'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[63:0] }  :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b010 )  ? { 1'b0, S_WLAST, 40'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[527:512], 320'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[127:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b011 )  ? { 1'b0, S_WLAST, 32'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[535:512], 256'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[191:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b100 )  ? { 1'b0, S_WLAST, 24'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[543:512], 192'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[255:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b101 )  ? { 1'b0, S_WLAST, 16'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[551:512], 128'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[319:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b110 )  ? { 1'b0, S_WLAST,  8'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[559:512],  64'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[383:0] } :
													( S_DATA_BITS ==  64 && sr_wcnt[2:0] == 3'b111 )  ? { 1'b0, S_WLAST,        S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[567:512],         S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[447:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0000 ) ? { 1'b0, S_WLAST, 60'd0, S_WSTRB[S_DATA_BITS/8-1:0],                                480'd0, S_WDATA[S_DATA_BITS-1:0] }                              :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0001 ) ? { 1'b0, S_WLAST, 56'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[515:512], 448'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[31:0] }  :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0010 ) ? { 1'b0, S_WLAST, 52'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[519:512], 416'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[63:0] }  :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0011 ) ? { 1'b0, S_WLAST, 48'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[523:512], 384'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[95:0] }  :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0100 ) ? { 1'b0, S_WLAST, 44'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[527:512], 352'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[127:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0101 ) ? { 1'b0, S_WLAST, 40'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[531:512], 320'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[159:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0110 ) ? { 1'b0, S_WLAST, 36'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[535:512], 288'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[191:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b0111 ) ? { 1'b0, S_WLAST, 32'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[539:512], 256'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[223:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1000 ) ? { 1'b0, S_WLAST, 28'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[543:512], 224'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[255:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1001 ) ? { 1'b0, S_WLAST, 24'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[547:512], 192'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[287:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1010 ) ? { 1'b0, S_WLAST, 20'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[551:512], 160'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[319:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1011 ) ? { 1'b0, S_WLAST, 16'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[555:512], 128'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[351:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1100 ) ? { 1'b0, S_WLAST, 12'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[559:512],  96'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[383:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1101 ) ? { 1'b0, S_WLAST,  8'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[563:512],  64'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[415:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1110 ) ? { 1'b0, S_WLAST,  4'd0, S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[567:512],  32'd0, S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[447:0] } :
													( S_DATA_BITS ==  32 && sr_wcnt[3:0] == 4'b1111 ) ? { 1'b0, S_WLAST,        S_WSTRB[S_DATA_BITS/8-1:0], sr_wr_dat_fifo_wdata[571:512],         S_WDATA[S_DATA_BITS-1:0], sr_wr_dat_fifo_wdata[479:0] } : 578'd0;

	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_wr_dat_fifo_wdata[577:0]		<=		578'd0;
		end else if( S_WVALID == 1'b1 && s_wready == 1'b1 )begin
			sr_wr_dat_fifo_wdata[577:0]		<=		s_wr_dat_fifo_wdata[577:0];
		end
	end



//------------------------------------------------------------------------------
// BIDフェーズ制御部
//------------------------------------------------------------------------------

	// BIDデータ信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_bresp[1:0]				<=		2'b00;
			sr_bid[S_ID_BITS-1:0]		<=		{S_ID_BITS{1'b0}};
		end else if( S_BREADY == 1'b1 && sr_bvalid == 1'b1 )begin
			sr_bresp[1:0]				<=		2'b00;
			sr_bid[S_ID_BITS-1:0]		<=		{S_ID_BITS{1'b0}};
		end else if( S_WVALID == 1'b1 && S_WLAST == 1'b1
					&& s_wready == 1'b1 )begin
			sr_bresp[1:0]				<=		2'b00;
			sr_bid[S_ID_BITS-1:0]		<=		s_wid_fifo_rdata[S_ID_BITS-1:0];
		end
	end

	// BIDデータ有効信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_bvalid		<=		1'b0;
		end else if( S_BREADY == 1'b1 && sr_bvalid == 1'b1 )begin
			sr_bvalid		<=		1'b0;
		end else if( S_WVALID == 1'b1 && S_WLAST == 1'b1
					&& s_wready == 1'b1 )begin
			sr_bvalid		<=		1'b1;
		end
	end

	// ライトID-FIFOライトイネーブル信号 //
	assign		s_wid_fifo_rden				=		( S_WVALID == 1'b1 && S_WLAST == 1'b1 && s_wready == 1'b1 ) ? 1'b1 : 1'b0;



endmodule

