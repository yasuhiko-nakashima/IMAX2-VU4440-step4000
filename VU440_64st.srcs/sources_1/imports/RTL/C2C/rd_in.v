//------------------------------------------------------------------------------
// RD_IN MODEL
//------------------------------------------------------------------------------
// RD_IN モジュール
// (1) リード入力処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : rd_in.v
// Module         : RD_IN
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module RD_IN # ( 
					parameter	S_ID_BITS		=	8,		// 
					parameter	S_ADR_BITS		=	64,		// 
					parameter	S_LEN_BITS		=	8,		// 
					parameter	S_DATA_BITS		=	256,	// 
					parameter	FIFO_WORD		=	8		// 
				) (
					S_CLK,									// 
					S_RESET_N,								// 

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

					RADR_FIFO_FULL,							// 
					RADR_FIFO_WREN,							// 
					RADR_FIFO_WDATA,						// 

					RDAT_FIFO_EMPTY,						// 
					RDAT_FIFO_RDEN,							// 
					RDAT_FIFO_RDATA							// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input								S_CLK;				// 
	input								S_RESET_N;			// 
	input	[S_ID_BITS-1:0]				S_ARID;				// 
	input	[S_ADR_BITS-1:0]			S_ARADDR;			// 
	input	[S_LEN_BITS-1:0]			S_ARLEN;			// 
	input	[2:0]						S_ARSIZE;			// 
	input	[1:0]						S_ARBURST;			// 
	input	[1:0]						S_ARLOCK;			// 
	input	[3:0]						S_ARCACHE;			// 
	input	[2:0]						S_ARPROT;			// 
	input	[3:0]						S_ARQOS;			// 
	input								S_ARUSER;			// 
	input								S_ARVALID;			// 
	output								S_ARREADY;			// 
	output	[S_ID_BITS-1:0]				S_RID;				// 
	output	[S_DATA_BITS-1:0]			S_RDATA;			// 
	output	[1:0]						S_RRESP;			// 
	output								S_RLAST;			// 
	output								S_RVALID;			// 
	input								S_RREADY;			// 

	input								RADR_FIFO_FULL;		// 
	output								RADR_FIFO_WREN;		// 
	output	[127:0]						RADR_FIFO_WDATA;	// 

	input								RDAT_FIFO_EMPTY;	// 
	output								RDAT_FIFO_RDEN;		// 
	input	[577:0]						RDAT_FIFO_RDATA;	// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire								s_rlen_fifo_rden;	// 
	wire	[15:0]						s_rlen_fifo_rdata;	// 
	wire								s_rlen_fifo_full;	// 
	wire								s_rlen_fifo_wren;	// 
	wire	[15:0]						s_rlen_fifo_wdata;	// 
	wire								s_rlen_fifo_empty;	// 
	wire	[127:0]						s_rd_adr_fifo_wdata;// 
	wire	[63:0]						s_addr_in;			// 
	wire	[63:0]						s_addr_mask;		// 
	wire	[2:0]						s_s_arsize;			// 
	wire								s_rd_adr_fifo_wren;	// 
	wire								s_rd_dat_fifo_rden;	// 
	wire	[3:0]						s_rcnt_max;			// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg									sr_arready;			// 
	reg		[15:0]						sr_trans_cnt;		// 
	reg		[3:0]						sr_rcnt;			// 
	reg		[1:0]						sr_rresp;			// 
	reg		[S_ID_BITS-1:0]				sr_rid;				// 
	reg									sr_rvalid;			// 
	reg									sr_rlast;			// 
	reg		[S_DATA_BITS-1:0]			sr_rdata;			// 
	reg		[511:0]						sr_rd_dat_fifo_rdata;//
	reg		[3:0]						sr_rd_in_state;		// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
	`define 	RD_IN_INIT			4'b0000					// INITステート
	`define 	RD_IN_DAT_RD_CHK	4'b0001					// データリードチェックステート
	`define 	RD_IN_DAT_CHK		4'b0010					// データチェックステート
	`define 	RD_IN_END			4'b0011					// 終了ステート


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

FIFO_16BXNW	#	(
					.FIFO_WORD				(FIFO_WORD)
				) inst_rd_addr_fifo (
					.RST_N					(S_RESET_N),
					.CLK					(S_CLK),
					.WREN					(s_rlen_fifo_wren),
					.WDATA					(s_rlen_fifo_wdata[15:0]),
					.FULL					(s_rlen_fifo_full),
					.RDEN					(s_rlen_fifo_rden),
					.RDATA					(s_rlen_fifo_rdata[15:0]),
					.EMPTY					(s_rlen_fifo_empty)
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		S_ARREADY					=		sr_arready;
	assign		S_RID[S_ID_BITS-1:0]		=		sr_rid[S_ID_BITS-1:0];
	assign		S_RDATA[S_DATA_BITS-1:0]	=		sr_rdata[S_DATA_BITS-1:0];
	assign		S_RRESP[1:0]				=		sr_rresp[1:0];
	assign		S_RLAST						=		sr_rlast;
	assign		S_RVALID					=		sr_rvalid;

	assign		RADR_FIFO_WREN				=		s_rd_adr_fifo_wren;
	assign		RADR_FIFO_WDATA[127:0]		=		s_rd_adr_fifo_wdata[127:0];

	assign		RDAT_FIFO_RDEN				=		s_rd_dat_fifo_rden;


//------------------------------------------------------------------------------
// アドレスフェーズ制御部
//------------------------------------------------------------------------------

	// アドレスレディ信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_arready		<=		1'b0;
		end else if( S_ARVALID == 1'b1 && RADR_FIFO_FULL == 1'b0
					&& sr_arready == 1'b0 && s_rlen_fifo_full == 1'b0 )begin
			sr_arready		<=		1'b1;
		end else begin
			sr_arready		<=		1'b0;
		end
	end

	// アドレスフェーズ入力情報信号 //
	assign		s_rd_adr_fifo_wdata[127:0]=		{13'd0, s_s_arsize[2:0],							// 127 - 112
												{16-S_ID_BITS{1'b0}}, S_ARID[S_ID_BITS-1:0],		// 111 -  96
												{16-S_LEN_BITS{1'b0}}, S_ARLEN[S_LEN_BITS-1:0],		//  95 -  80
												S_ARBURST[1:0], S_ARLOCK[1:0], S_ARCACHE[3:0],		//  79 -  72
												S_ARPROT[2:0], S_ARQOS[3:0], S_ARUSER,				//  71 -  64
												{64-S_ADR_BITS{1'b0}}, s_addr_in[S_ADR_BITS-1:0] };	//  63 -  00

	// アドレスマスク処理信号 //
	assign		s_addr_in[S_ADR_BITS-1:0]=		S_ARADDR[S_ADR_BITS-1:0] & s_addr_mask[S_ADR_BITS-1:0];

	assign		s_addr_mask[63:0]		=		( S_DATA_BITS == 512 ) ? 64'hFFFF_FFFF_FFFF_FFC0 :
												( S_DATA_BITS == 256 ) ? 64'hFFFF_FFFF_FFFF_FFE0 :
												( S_DATA_BITS == 128 ) ? 64'hFFFF_FFFF_FFFF_FFF0 :
												( S_DATA_BITS ==  64 ) ? 64'hFFFF_FFFF_FFFF_FFF8 :
												( S_DATA_BITS ==  32 ) ? 64'hFFFF_FFFF_FFFF_FFFC : 64'hFFFF_FFFF_FFFF_FFFF;

	// データサイズ信号 //
	assign		s_s_arsize[2:0]			=		( S_DATA_BITS ==   8 ) ? 3'b000 :
												( S_DATA_BITS ==  16 ) ? 3'b001 :
												( S_DATA_BITS ==  32 ) ? 3'b010 :
												( S_DATA_BITS ==  64 ) ? 3'b011 :
												( S_DATA_BITS == 128 ) ? 3'b100 :
												( S_DATA_BITS == 256 ) ? 3'b101 :
												( S_DATA_BITS == 512 ) ? 3'b110 : 3'b111;

	// RD_ADR_FIFOライトイネーブル信号 //
	assign		s_rd_adr_fifo_wren		=		( S_ARVALID == 1'b1 && sr_arready == 1'b1 ) ? 1'b1 : 1'b0;

	// RLEN_FIFOライトイネーブル信号 //
	assign		s_rlen_fifo_wren		=		s_rd_adr_fifo_wren;

	// RLEN_FIFOライトデータ信号 //
	assign		s_rlen_fifo_wdata[15:0]	=		{ {16-S_LEN_BITS{1'b0}}, S_ARLEN[S_LEN_BITS-1:0] };


//------------------------------------------------------------------------------
// データフェーズ制御部
//------------------------------------------------------------------------------

	// RD_DAT_FIFOリードイネーブル信号 //
	assign		s_rd_dat_fifo_rden		=		( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK )                               ? 1'b1 :
												( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK && RDAT_FIFO_EMPTY == 1'b0
													&& S_RREADY == 1'b1 && sr_rvalid == 1'b1 && sr_rlast == 1'b0
													&& sr_trans_cnt[15:0] != 16'h0000 && sr_rcnt[3:0] == s_rcnt_max[3:0] ) ? 1'b1 :
												( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK && RDAT_FIFO_EMPTY == 1'b0
													&& sr_rvalid == 1'b0
													&& sr_trans_cnt[15:0] != 16'h0000 && sr_rcnt[3:0] == 4'b0000 )         ? 1'b1 : 1'b0;

	// RLEN_FIFOリードイネーブル信号 //
	assign		s_rlen_fifo_rden		=		( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK ) ? 1'b1 : 1'b0;

	// トータルデータカウント信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_trans_cnt[15:0]		<=		16'h0000;
		end else if( sr_rd_in_state[3:0] == `RD_IN_INIT )begin
			sr_trans_cnt[15:0]		<=		s_rlen_fifo_rdata[15:0] + 16'h0001;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& S_RREADY == 1'b1 && sr_rvalid == 1'b1 )begin
			if( sr_trans_cnt[15:0] != 16'h0000 )begin
				sr_trans_cnt[15:0]		<=		sr_trans_cnt[15:0] - 16'h0001;
			end
		end
	end

	// データカウントMAX信号 //
	assign		s_rcnt_max[3:0]			=		( S_DATA_BITS == 512 ) ? 4'b0000 :
												( S_DATA_BITS == 256 ) ? 4'b0001 :
												( S_DATA_BITS == 128 ) ? 4'b0011 :
												( S_DATA_BITS ==  64 ) ? 4'b0111 : 4'b1111;

	// データカウント信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rcnt[3:0]		<=		4'b0000;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& S_RREADY == 1'b1 && sr_rvalid == 1'b1 )begin
			if( sr_rlast == 1'b1 )begin
				sr_rcnt[3:0]		<=		4'b0000;
			end else if( sr_rcnt[3:0] == s_rcnt_max[3:0] )begin
				sr_rcnt[3:0]		<=		4'b0000;
			end else begin
				sr_rcnt[3:0]		<=		sr_rcnt[3:0] + 4'b0001;
 			end
		end
	end

	// データレスポンス信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rresp[1:0]		<=		2'b00;
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rresp[1:0]		<=		2'b00;
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rcnt[3:0] == s_rcnt_max[3:0]
					&& RDAT_FIFO_EMPTY == 1'b1
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rresp[1:0]		<=		2'b00;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rvalid == 1'b0
					&& sr_rcnt[3:0] == 4'b0000
					&& RDAT_FIFO_EMPTY == 1'b0 
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rresp[1:0]		<=		RDAT_FIFO_RDATA[S_ID_BITS+512+1:S_ID_BITS+512];
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK )begin
			sr_rresp[1:0]		<=		RDAT_FIFO_RDATA[S_ID_BITS+512+1:S_ID_BITS+512];
		end
	end

	// データID有効信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rid[S_ID_BITS-1:0]		<=		{S_ID_BITS{1'b0}};
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rid[S_ID_BITS-1:0]		<=		{S_ID_BITS{1'b0}};
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rcnt[3:0] == s_rcnt_max[3:0]
					&& RDAT_FIFO_EMPTY == 1'b1
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rid[S_ID_BITS-1:0]		<=		{S_ID_BITS{1'b0}};
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rvalid == 1'b0
					&& sr_rcnt[3:0] == 4'b0000
					&& RDAT_FIFO_EMPTY == 1'b0 
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rid[S_ID_BITS-1:0]		<=		RDAT_FIFO_RDATA[S_ID_BITS+512-1:512];
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK )begin
			sr_rid[S_ID_BITS-1:0]		<=		RDAT_FIFO_RDATA[S_ID_BITS+512-1:512];
		end
	end

	// データ有効信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rvalid		<=		1'b0;
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rvalid		<=		1'b0;
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rcnt[3:0] == s_rcnt_max[3:0]
					&& RDAT_FIFO_EMPTY == 1'b1
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rvalid		<=		1'b0;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rvalid == 1'b0
					&& sr_rcnt[3:0] == 4'b0000
					&& RDAT_FIFO_EMPTY == 1'b0
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rvalid		<=		1'b1;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK )begin
			sr_rvalid		<=		1'b1;
		end
	end

	// ラストデータ信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rlast		<=		1'b0;
		end else if( S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rlast		<=		1'b0;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rvalid == 1'b0
					&& sr_rcnt[3:0] == 4'b0000
					&& RDAT_FIFO_EMPTY == 1'b0
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rlast		<=		1'b1;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rcnt[3:0] == s_rcnt_max[3:0]
					&& S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& RDAT_FIFO_EMPTY == 1'b0
					&& sr_trans_cnt[15:0] == 16'h0002 )begin
			sr_rlast		<=		1'b1;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK
					&& sr_rcnt[3:0] != s_rcnt_max[3:0]
					&& S_RREADY == 1'b1 && sr_rvalid == 1'b1
					&& sr_trans_cnt[15:0] == 16'h0002 )begin
			sr_rlast		<=		1'b1;
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK 
					&& sr_trans_cnt[15:0] == 16'h0001 )begin
			sr_rlast		<=		1'b1;
		end
	end

	// データ信号 //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_RD_CHK )begin
			sr_rdata[S_DATA_BITS-1:0]		<=		RDAT_FIFO_RDATA[S_DATA_BITS-1:0];
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK && sr_rcnt[3:0] == 4'b0000
					&& RDAT_FIFO_EMPTY == 1'b0 && sr_rvalid == 1'b0
					&& sr_trans_cnt[15:0] != 16'h0000 )begin
			sr_rdata[S_DATA_BITS-1:0]		<=		RDAT_FIFO_RDATA[S_DATA_BITS-1:0];
		end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK )begin
			if( S_RREADY == 1'b1 && sr_rvalid == 1'b1 )begin
				if( sr_rlast == 1'b1 )begin
					sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
				end else if( sr_rd_in_state[3:0] == `RD_IN_DAT_CHK && sr_rcnt[3:0] == s_rcnt_max[3:0]
							&& RDAT_FIFO_EMPTY == 1'b0 && sr_trans_cnt[15:0] != 16'h0000 )begin
					sr_rdata[S_DATA_BITS-1:0]		<=		RDAT_FIFO_RDATA[S_DATA_BITS-1:0];
				end else begin
					if( S_DATA_BITS == 512 )begin
						sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
					end else if( S_DATA_BITS == 256 )begin
						case( sr_rcnt[0] )
							1'b0	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*2-1:S_DATA_BITS*1];
							default	:	sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
						endcase
					end else if( S_DATA_BITS == 128 )begin
						case( sr_rcnt[1:0] )
							2'b00	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*2-1:S_DATA_BITS*1];
							2'b01	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*3-1:S_DATA_BITS*2];
							2'b10	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*4-1:S_DATA_BITS*3];
							default	:	sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
						endcase
					end else if( S_DATA_BITS == 64 )begin
						case( sr_rcnt[2:0] )
							3'b000	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*2-1:S_DATA_BITS*1];
							3'b001	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*3-1:S_DATA_BITS*2];
							3'b010	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*4-1:S_DATA_BITS*3];
							3'b011	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*5-1:S_DATA_BITS*4];
							3'b100	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*6-1:S_DATA_BITS*5];
							3'b101	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*7-1:S_DATA_BITS*6];
							3'b110	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*8-1:S_DATA_BITS*7];
							default	:	sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
						endcase
					end else if( S_DATA_BITS == 32 )begin
						case( sr_rcnt[3:0] )
							4'b0000	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*2-1 :S_DATA_BITS*1];
							4'b0001	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*3-1 :S_DATA_BITS*2];
							4'b0010	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*4-1 :S_DATA_BITS*3];
							4'b0011	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*5-1 :S_DATA_BITS*4];
							4'b0100	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*6-1 :S_DATA_BITS*5];
							4'b0101	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*7-1 :S_DATA_BITS*6];
							4'b0110	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*8-1 :S_DATA_BITS*7];
							4'b0111	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*9-1 :S_DATA_BITS*8];
							4'b1000	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*10-1:S_DATA_BITS*9];
							4'b1001	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*11-1:S_DATA_BITS*10];
							4'b1010	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*12-1:S_DATA_BITS*11];
							4'b1011	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*13-1:S_DATA_BITS*12];
							4'b1100	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*14-1:S_DATA_BITS*13];
							4'b1101	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*15-1:S_DATA_BITS*14];
							4'b1110	:	sr_rdata[S_DATA_BITS-1:0]		<=		sr_rd_dat_fifo_rdata[S_DATA_BITS*16-1:S_DATA_BITS*15];
							default	:	sr_rdata[S_DATA_BITS-1:0]		<=		{S_DATA_BITS{1'b0}};
						endcase
					end
				end
			end
		end
	end

	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rd_dat_fifo_rdata[511:0]		<=		512'd0;
		end else if( s_rd_dat_fifo_rden == 1'b1 )begin
			sr_rd_dat_fifo_rdata[511:0]		<=		RDAT_FIFO_RDATA[511:0];
		end
	end

	// データステート //
	always@( posedge S_CLK or negedge S_RESET_N )begin
		if( S_RESET_N == 1'b0 )begin
			sr_rd_in_state[3:0]		<=		`RD_IN_INIT;
		end else begin
			case ( sr_rd_in_state[3:0] )
				`RD_IN_INIT			:	if( RDAT_FIFO_EMPTY == 1'b0 && s_rlen_fifo_empty == 1'b0 )begin
											sr_rd_in_state[3:0]		<=		`RD_IN_DAT_RD_CHK;
										end else begin
											sr_rd_in_state[3:0]		<=		`RD_IN_INIT;
										end

				`RD_IN_DAT_RD_CHK	:	sr_rd_in_state[3:0]		<=		`RD_IN_DAT_CHK;
				`RD_IN_DAT_CHK		:	if( S_RREADY == 1'b1 && sr_rvalid == 1'b1 )begin
											if( sr_trans_cnt[15:0] == 16'h0001 )begin
												sr_rd_in_state[3:0]		<=		`RD_IN_END;
											end else begin
												sr_rd_in_state[3:0]		<=		`RD_IN_DAT_CHK;
											end
										end else begin
											sr_rd_in_state[3:0]		<=		`RD_IN_DAT_CHK;
										end

				`RD_IN_END			:	sr_rd_in_state[3:0]		<=		`RD_IN_INIT;
				default				:	sr_rd_in_state[3:0]		<=		`RD_IN_INIT;
			endcase
		end
	end



endmodule

