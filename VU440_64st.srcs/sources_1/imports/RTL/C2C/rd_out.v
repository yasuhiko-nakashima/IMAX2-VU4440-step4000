//------------------------------------------------------------------------------
// RD_OUT MODEL
//------------------------------------------------------------------------------
// RD_OUT モジュール
// (1) リード出力処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : rd_out.v
// Module         : RD_OUT
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module RD_OUT # ( 
					parameter	M_ID_BITS		=	8,		// 
					parameter	M_ADR_BITS		=	64,		// 
					parameter	M_LEN_BITS		=	8,		// 
					parameter	M_DATA_BITS		=	256,	// 
					parameter	MLT_OUT_EN		=	0,		// 
					parameter	FIFO_WORD		=	8		// 
				) (
					M_CLK,									// 
					M_RESET_N,								// 
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

					RADR_FIFO_EMPTY,						// 
					RADR_FIFO_RDEN,							// 
					RADR_FIFO_RDATA,						// 

					RDAT_FIFO_FULL,							// 
					RDAT_FIFO_WREN,							// 
					RDAT_FIFO_WDATA,						// 

					RACC_MASK								// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input								M_CLK;				// 
	input								M_RESET_N;			// 
	output	[M_ID_BITS-1:0]				M_ARID;				// 
	output	[M_ADR_BITS-1:0]			M_ARADDR;			// 
	output	[M_LEN_BITS-1:0]			M_ARLEN;			// 
	output	[2:0]						M_ARSIZE;			// 
	output	[1:0]						M_ARBURST;			// 
	output	[1:0]						M_ARLOCK;			// 
	output	[3:0]						M_ARCACHE;			// 
	output	[2:0]						M_ARPROT;			// 
	output	[3:0]						M_ARQOS;			// 
	output								M_ARUSER;			// 
	output								M_ARVALID;			// 
	input								M_ARREADY;			// 
	input	[M_ID_BITS-1:0]				M_RID;				// 
	input	[M_DATA_BITS-1:0]			M_RDATA;			// 
	input	[1:0]						M_RRESP;			// 
	input								M_RLAST;			// 
	input								M_RVALID;			// 
	output								M_RREADY;			// 

	input								RADR_FIFO_EMPTY;	// 
	output								RADR_FIFO_RDEN;		// 
	input	[127:0]						RADR_FIFO_RDATA;	// 

	input								RDAT_FIFO_FULL;		// 
	output								RDAT_FIFO_WREN;		// 
	output	[577:0]						RDAT_FIFO_WDATA;	// 

	output								RACC_MASK;			// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire								s_racc_fifo_wren;	// 
	wire	[20:0]						s_racc_fifo_wdata;	// 
	wire								s_racc_fifo_full;	// 
	wire								s_racc_fifo_rden;	// 
	wire	[20:0]						s_racc_fifo_rdata;	// 
	wire								s_racc_fifo_empty;	// 
	wire								s_rd_adr_fifo_rden;	// 
	wire	[15:0]						s_len_max_512;		// 
	wire	[15:0]						s_len_max_256;		// 
	wire	[15:0]						s_len_max_128;		// 
	wire	[15:0]						s_len_max_64;		// 
	wire	[15:0]						s_len_max_32;		// 
	wire	[2:0]						s_arsize;			// 
	wire	[3:0]						s_addr_chk;			// 
	wire	[15:0]						s_loop_cnt;			// 
	wire								s_rd_dat_fifo_wren;	// 
	wire								s_fifo_wren;		// 
	wire	[577:0]						s_rd_dat_fifo_wdata;// 
	wire								s_rlast;			// 
	wire	[3:0]						s_rcnt_max;			// 
	wire	[577:0]						s_fifo_wdata;		// 
	wire	[577:0]						s_wdata_change;		// 
	wire	[511:0]						s_wdata_sel0;		// 
	wire	[511:0]						s_wdata_sel1;		// 
	wire	[577:512]					s_wdata_sel2;		// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg									sr_rd_adr_cycle;	// 
	reg									sr_rd_dat_cycle;	// 
	reg		[3:0]						sr_rd_adr_state;	// 
	reg		[3:0]						sr_rd_dat_state;	// 
	reg		[15:0]						sr_len_max;			// 
	reg		[15:0]						sr_len_max_512;		// 
	reg									sr_racc_mask;		// 
	reg									sr_arvalid;			// 
	reg		[M_ID_BITS-1:0]				sr_arid;			// 
	reg		[M_ADR_BITS-1:0]			sr_araddr;			// 
	reg		[1:0]						sr_arburst;			// 
	reg		[1:0]						sr_arlock;			// 
	reg		[3:0]						sr_arcache;			// 
	reg		[2:0]						sr_arprot;			// 
	reg		[3:0]						sr_arqos;			// 
	reg									sr_aruser;			// 
	reg		[2:0]						sr_arsize;			// 
	reg		[M_LEN_BITS-1:0]			sr_arlen;			// 
	reg		[127:0]						sr_acc_status;		// 
	reg		[63:0]						sr_addr_cnt;		// 
	reg									sr_len_add;			// 
	reg		[15:0]						sr_data_trans_cnt;	// 
	reg		[4:0]						sr_racc;			// 
	reg		[15:0]						sr_rlen512_cnt;		// 
	reg									sr_fifo_wr_mask;	// 
	reg		[3:0]						sr_rcnt;			// 
	reg									sr_rready;			// 
	reg		[577:0]						sr_rd_fifo_wdata;	// 
	reg		[511:0]						sr_fifo_wdata;		// 
	reg		[511:0]						sr_wdata_change;	// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
	`define 	RD_ADR_INIT				4'b0000				// INITステート
	`define 	RD_ADR_RD				4'b0001				// アドレスリードステート
	`define 	RD_ADR_CAL				4'b0010				// アドレス演算ステート
	`define 	RD_ADR_ST				4'b0011				// アドレススタートステート
	`define 	RD_ADR_CHK				4'b0100				// アドレスチェックステート
	`define 	RD_ADR_WAIT				4'b0101				// アドレスウエイトステート
	`define 	RD_ADR_END				4'b0110				// 終了ステート

	`define 	RD_DAT_INIT				4'b1000				// INITステート
	`define 	RD_DAT_CHK				4'b1001				// データチェックステート
	`define 	RD_DAT_WR_WAIT			4'b1010				// データウエイトステート
	`define 	RD_DAT_LAST_WAIT		4'b1011				// ライトラストウエイトステート
	`define 	RD_DAT_LAST				4'b1100				// ライトラストステート
	`define 	RD_DAT_END				4'b1101				// 終了ステート


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

FIFO_21BXNW	#	(
					.FIFO_WORD				(FIFO_WORD)
				) inst_rd_addr_fifo (
					.RST_N					(M_RESET_N),
					.CLK					(M_CLK),
					.WREN					(s_racc_fifo_wren),
					.WDATA					(s_racc_fifo_wdata[20:0]),
					.FULL					(s_racc_fifo_full),
					.RDEN					(s_racc_fifo_rden),
					.RDATA					(s_racc_fifo_rdata[20:0]),
					.EMPTY					(s_racc_fifo_empty)
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------

	assign		M_ARID[M_ID_BITS-1:0]			=		sr_arid[M_ID_BITS-1:0];
	assign		M_ARADDR[M_ADR_BITS-1:0]		=		sr_araddr[M_ADR_BITS-1:0];
	assign		M_ARLEN[M_LEN_BITS-1:0]			=		sr_arlen[M_LEN_BITS-1:0];
	assign		M_ARSIZE[2:0]					=		sr_arsize[2:0];
	assign		M_ARBURST[1:0]					=		sr_arburst[1:0];
	assign		M_ARLOCK[1:0]					=		sr_arlock[1:0];
	assign		M_ARCACHE[3:0]					=		sr_arcache[3:0];
	assign		M_ARPROT[2:0]					=		sr_arprot[2:0];
	assign		M_ARQOS[3:0]					=		sr_arqos[3:0];
	assign		M_ARUSER						=		sr_aruser;
	assign		M_ARVALID						=		sr_arvalid;
	assign		M_RREADY						=		sr_rready;

	assign		RADR_FIFO_RDEN					=		s_rd_adr_fifo_rden;

	assign		RDAT_FIFO_WREN					=		s_rd_dat_fifo_wren;
	assign		RDAT_FIFO_WDATA[577:0]			=		s_rd_dat_fifo_wdata[577:0];

	assign		RACC_MASK						=		sr_racc_mask;


//------------------------------------------------------------------------------
// リードステート制御部
//------------------------------------------------------------------------------

	// リードステート切替信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rd_adr_cycle		<=		1'b1;
			sr_rd_dat_cycle		<=		1'b0;
		end else if( MLT_OUT_EN == 1'b1 )begin
			sr_rd_adr_cycle		<=		1'b1;
			sr_rd_dat_cycle		<=		1'b1;
		end else begin
			if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
				&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1
				&& sr_rd_adr_cycle == 1'b1 )begin
				sr_rd_adr_cycle		<=		1'b0;
			end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
						&& M_RVALID == 1'b1 && sr_rready == 1'b1
						&& M_RLAST == 1'b1 && RDAT_FIFO_FULL == 1'b0
						&& ~( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 ))begin
				sr_rd_adr_cycle		<=		1'b1;
			end else if( sr_rd_dat_state[3:0] == `RD_DAT_LAST_WAIT
						&& ~( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 )
						&& RDAT_FIFO_FULL == 1'b0 )begin
				sr_rd_adr_cycle		<=		1'b1;
			end else if( sr_rd_dat_state[3:0] == `RD_DAT_LAST
						&& RDAT_FIFO_FULL == 1'b0 )begin
				sr_rd_adr_cycle		<=		1'b1;
			end
			if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
				&& M_RVALID == 1'b1 && sr_rready == 1'b1
				&& M_RLAST == 1'b1 && RDAT_FIFO_FULL == 1'b0
				&& ~( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 ))begin
				sr_rd_dat_cycle		<=		1'b0;
			end else if( sr_rd_dat_state[3:0] == `RD_DAT_LAST_WAIT
						&& ~( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 )
						&& RDAT_FIFO_FULL == 1'b0 )begin
				sr_rd_dat_cycle		<=		1'b0;
			end else if( sr_rd_dat_state[3:0] == `RD_DAT_LAST
						&& RDAT_FIFO_FULL == 1'b0 )begin
				sr_rd_dat_cycle		<=		1'b0;
			end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
						&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1
						&& sr_rd_adr_cycle == 1'b1 )begin
				sr_rd_dat_cycle		<=		1'b1;
			end
		end
	end

	// リードアドレスステート //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rd_adr_state[3:0]		<=		`RD_ADR_INIT;
		end else begin
			case ( sr_rd_adr_state[3:0] )
				`RD_ADR_INIT		:	if( RADR_FIFO_EMPTY == 1'b0 && s_racc_fifo_full == 1'b0 )begin
											sr_rd_adr_state[3:0]		<=		`RD_ADR_RD;
										end else begin
											sr_rd_adr_state[3:0]		<=		`RD_ADR_INIT;
										end

				`RD_ADR_RD		:	sr_rd_adr_state[3:0]		<=		`RD_ADR_CAL;
				`RD_ADR_CAL		:	sr_rd_adr_state[3:0]		<=		`RD_ADR_ST;
				`RD_ADR_ST		:	if( sr_rd_adr_cycle == 1'b1 )begin
										sr_rd_adr_state[3:0]		<=		`RD_ADR_CHK;
									end else begin
										sr_rd_adr_state[3:0]		<=		`RD_ADR_ST;
									end
				`RD_ADR_CHK		:	if( M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
										if( s_loop_cnt[15:0] != 16'h0000 )begin
											if(  s_racc_fifo_full == 1'b0 )begin
												sr_rd_adr_state[3:0]		<=		`RD_ADR_ST;
											end else begin
												sr_rd_adr_state[3:0]		<=		`RD_ADR_WAIT;
											end
										end else begin
											sr_rd_adr_state[3:0]		<=		`RD_ADR_END;
										end
									end else begin
										sr_rd_adr_state[3:0]		<=		`RD_ADR_CHK;
									end
				`RD_ADR_WAIT	:	if( s_racc_fifo_full == 1'b0 )begin
										sr_rd_adr_state[3:0]		<=		`RD_ADR_ST;
									end else begin
										sr_rd_adr_state[3:0]		<=		`RD_ADR_WAIT;
									end
				`RD_ADR_END		:	sr_rd_adr_state[3:0]		<=		`RD_ADR_INIT;
				default			:	sr_rd_adr_state[3:0]		<=		`RD_ADR_INIT;
			endcase
		end
	end

	// リードデータステート //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rd_dat_state[3:0]		<=		`RD_DAT_INIT;
		end else begin
			case ( sr_rd_dat_state[3:0] )
				`RD_DAT_INIT		:	if( sr_rd_dat_cycle == 1'b1 && s_racc_fifo_empty == 1'b0 )begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_CHK;
										end else begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_INIT;
										end
				`RD_DAT_CHK			:	if( M_RVALID == 1'b1 && sr_rready == 1'b1 )begin
											if( M_RLAST == 1'b1 )begin
												if( RDAT_FIFO_FULL == 1'b1 )begin
													sr_rd_dat_state[3:0]		<=		`RD_DAT_LAST_WAIT;
												end else if( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 )begin
													sr_rd_dat_state[3:0]		<=		`RD_DAT_LAST;
												end else begin
													sr_rd_dat_state[3:0]		<=		`RD_DAT_END;
												end
											end else if( sr_rcnt[3:0] == s_rcnt_max[3:0] )begin
												if( RDAT_FIFO_FULL == 1'b1 )begin
													sr_rd_dat_state[3:0]		<=		`RD_DAT_WR_WAIT;
												end else begin
													sr_rd_dat_state[3:0]		<=		`RD_DAT_CHK;
												end
											end else begin
												sr_rd_dat_state[3:0]		<=		`RD_DAT_CHK;
											end
										end else begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_CHK;
										end
				`RD_DAT_WR_WAIT		:	if( RDAT_FIFO_FULL == 1'b0 )begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_CHK;
										end else begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_WR_WAIT;
										end
				`RD_DAT_LAST_WAIT	:	if( RDAT_FIFO_FULL == 1'b0 )begin
											if( sr_racc[4] == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 )begin
												sr_rd_dat_state[3:0]		<=		`RD_DAT_LAST;
											end else begin
												sr_rd_dat_state[3:0]		<=		`RD_DAT_END;
											end
										end else begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_LAST_WAIT;
										end
				`RD_DAT_LAST		:	if( RDAT_FIFO_FULL == 1'b0 )begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_END;
										end else begin
											sr_rd_dat_state[3:0]		<=		`RD_DAT_LAST;
										end
				`RD_DAT_END			:	sr_rd_dat_state[3:0]		<=		`RD_DAT_INIT;
				default				:	sr_rd_dat_state[3:0]		<=		`RD_DAT_INIT;
			endcase
		end
	end



//------------------------------------------------------------------------------
// アドレスフェーズ制御部
//------------------------------------------------------------------------------

	// RD_ADR_FIFOリードイネーブル信号 //
	assign		s_rd_adr_fifo_rden				=		( sr_rd_adr_state[3:0] == `RD_ADR_RD ) ? 1'b1 : 1'b0;

	// RD_ACC_FIFOライトイネーブル信号 //
	assign		s_racc_fifo_wren				=		( sr_rd_adr_cycle == 1'b1 && sr_rd_adr_state[3:0] == `RD_ADR_ST ) ? 1'b1 : 1'b0;

	// RD_ACC_FIFOライトデータ信号 //
	assign		s_racc_fifo_wdata[20:0]			=		{ sr_len_max_512[15:0], ( s_loop_cnt[15:0] == 16'h0000 ), sr_acc_status[3:0] };

	// データLENカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_len_max[15:0]		<=		16'h0000;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			if( M_DATA_BITS == 512 )begin
				sr_len_max[15:0]		<=		s_len_max_512[15:0];
			end else if( M_DATA_BITS == 256 )begin
				sr_len_max[15:0]		<=		s_len_max_256[15:0];
			end else if( M_DATA_BITS == 128 )begin
				sr_len_max[15:0]		<=		s_len_max_128[15:0];
			end else if( M_DATA_BITS == 64 )begin
				sr_len_max[15:0]		<=		s_len_max_64[15:0];
			end else if( M_DATA_BITS == 32 )begin
				sr_len_max[15:0]		<=		s_len_max_32[15:0];
			end else begin
				sr_len_max[15:0]		<=		16'h0000;
			end
		end
	end
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_len_max_512[15:0]		<=		16'h0000;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			sr_len_max_512[15:0]		<=		s_len_max_512[15:0];
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			if( M_DATA_BITS == 512 )begin
				if( sr_len_max_512[15:0] >= 16'h0100 )begin
					sr_len_max_512[15:0]		<=		sr_len_max_512[15:0] - 16'h0100;
				end else begin
					sr_len_max_512[15:0]		<=		16'h0000;
				end
			end else if( M_DATA_BITS == 256 )begin
				if( sr_len_max_512[15:0] >= 16'h0080 )begin
					sr_len_max_512[15:0]		<=		sr_len_max_512[15:0] - 16'h0080;
				end else begin
					sr_len_max_512[15:0]		<=		16'h0000;
				end
			end else if( M_DATA_BITS == 128 )begin
				if( sr_len_max_512[15:0] >= 16'h0040 )begin
					sr_len_max_512[15:0]		<=		sr_len_max_512[15:0] - 16'h0040;
				end else begin
					sr_len_max_512[15:0]		<=		16'h0000;
				end
			end else if( M_DATA_BITS == 64 )begin
				if( sr_len_max_512[15:0] >= 16'h0020 )begin
					sr_len_max_512[15:0]		<=		sr_len_max_512[15:0] - 16'h0020;
				end else begin
					sr_len_max_512[15:0]		<=		16'h0000;
				end
			end else if( M_DATA_BITS == 32 )begin
				if( sr_len_max_512[15:0] >= 16'h0010 )begin
					sr_len_max_512[15:0]		<=		sr_len_max_512[15:0] - 16'h0010;
				end else begin
					sr_len_max_512[15:0]		<=		16'h0000;
				end
			end
		end
	end

	assign		s_len_max_512[15:0]				=		( RADR_FIFO_RDATA[114:112] == 3'b110 ) ? RADR_FIFO_RDATA[95:80]             :
														( RADR_FIFO_RDATA[114:112] == 3'b101 ) ? { 1'b0,    RADR_FIFO_RDATA[95:81] } :
														( RADR_FIFO_RDATA[114:112] == 3'b100 ) ? { 2'b00,   RADR_FIFO_RDATA[95:82] } :
														( RADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 3'b000,  RADR_FIFO_RDATA[95:83] } :
														( RADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 4'b0000, RADR_FIFO_RDATA[95:84] } : 16'd0;

	assign		s_len_max_256[15:0]				=		( RADR_FIFO_RDATA[114:112] == 3'b110 ) ? { RADR_FIFO_RDATA[94:80], 1'b1 }   :
														( RADR_FIFO_RDATA[114:112] == 3'b101 ) ? RADR_FIFO_RDATA[95:80]             :
														( RADR_FIFO_RDATA[114:112] == 3'b100 ) ? { 1'b0,   RADR_FIFO_RDATA[95:81] } :
														( RADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 2'b00,  RADR_FIFO_RDATA[95:82] } :
														( RADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 3'b000, RADR_FIFO_RDATA[95:83] } : 16'd0;

	assign		s_len_max_128[15:0]				=		( RADR_FIFO_RDATA[114:112] == 3'b110 ) ? { RADR_FIFO_RDATA[93:80], 2'b11 } :
														( RADR_FIFO_RDATA[114:112] == 3'b101 ) ? { RADR_FIFO_RDATA[94:80], 1'b1 }  :
														( RADR_FIFO_RDATA[114:112] == 3'b100 ) ? RADR_FIFO_RDATA[95:80]            :
														( RADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 1'b0,  RADR_FIFO_RDATA[95:81] } :
														( RADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 2'b00, RADR_FIFO_RDATA[95:82] } : 16'd0;

	assign		s_len_max_64[15:0]				=		( RADR_FIFO_RDATA[114:112] == 3'b110 ) ? { RADR_FIFO_RDATA[92:80], 3'b111 } :
														( RADR_FIFO_RDATA[114:112] == 3'b101 ) ? { RADR_FIFO_RDATA[93:80], 2'b11 }  :
														( RADR_FIFO_RDATA[114:112] == 3'b100 ) ? { RADR_FIFO_RDATA[94:80], 1'b1 }   :
														( RADR_FIFO_RDATA[114:112] == 3'b011 ) ? RADR_FIFO_RDATA[95:80]             :
														( RADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 1'b0, RADR_FIFO_RDATA[95:81] }   : 16'd0;

	assign		s_len_max_32[15:0]				=		( RADR_FIFO_RDATA[114:112] == 3'b110 ) ? { RADR_FIFO_RDATA[91:80], 4'b1111 } :
														( RADR_FIFO_RDATA[114:112] == 3'b101 ) ? { RADR_FIFO_RDATA[92:80], 3'b111 }  :
														( RADR_FIFO_RDATA[114:112] == 3'b100 ) ? { RADR_FIFO_RDATA[93:80], 2'b11 }   :
														( RADR_FIFO_RDATA[114:112] == 3'b011 ) ? { RADR_FIFO_RDATA[94:80], 1'b1 }    :
														( RADR_FIFO_RDATA[114:112] == 3'b010 ) ? RADR_FIFO_RDATA[95:80]              : 16'd0;

	// アクセスマスク信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_racc_mask		<=		1'b0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1
					&& s_loop_cnt[15:0] == 16'h0000 )begin
			sr_racc_mask		<=		1'b0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			sr_racc_mask		<=		1'b1;
		end
	end

	// アドレス有効信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_arvalid		<=		1'b0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			sr_arvalid		<=		1'b0;
		end else if( sr_rd_adr_cycle == 1'b1
					&& sr_rd_adr_state[3:0] == `RD_ADR_ST )begin
			sr_arvalid		<=		1'b1;
		end
	end

	// データサイズ信号 //
	assign		s_arsize[2:0]					=		( M_DATA_BITS ==   8 ) ? 3'b000 :
														( M_DATA_BITS ==  16 ) ? 3'b001 :
														( M_DATA_BITS ==  32 ) ? 3'b010 :
														( M_DATA_BITS ==  64 ) ? 3'b011 :
														( M_DATA_BITS == 128 ) ? 3'b100 :
														( M_DATA_BITS == 256 ) ? 3'b101 :
														( M_DATA_BITS == 512 ) ? 3'b110 : 3'b111;

	// 各種別信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_arid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_araddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_arburst[1:0]					<=		2'b00;
			sr_arlock[1:0]					<=		2'b00;
			sr_arcache[3:0]					<=		4'b0000;
			sr_arprot[2:0]					<=		3'b000;
			sr_arqos[3:0]					<=		4'b0000;
			sr_aruser						<=		1'b0;
			sr_arsize[2:0]					<=		3'b000;
		end else if( MLT_OUT_EN == 1'b1
					&& sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			sr_arid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_araddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_arburst[1:0]					<=		2'b00;
			sr_arlock[1:0]					<=		2'b00;
			sr_arcache[3:0]					<=		4'b0000;
			sr_arprot[2:0]					<=		3'b000;
			sr_arqos[3:0]					<=		4'b0000;
			sr_aruser						<=		1'b0;
			sr_arsize[2:0]					<=		3'b000;
		end else if( MLT_OUT_EN == 1'b0
					&& sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1
					&& M_RLAST == 1'b1 )begin
			sr_arid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_araddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_arburst[1:0]					<=		2'b00;
			sr_arlock[1:0]					<=		2'b00;
			sr_arcache[3:0]					<=		4'b0000;
			sr_arprot[2:0]					<=		3'b000;
			sr_arqos[3:0]					<=		4'b0000;
			sr_aruser						<=		1'b0;
			sr_arsize[2:0]					<=		3'b000;
		end else if( sr_rd_adr_cycle == 1'b1
					&& sr_rd_adr_state[3:0] == `RD_ADR_ST )begin
			sr_arid[M_ID_BITS-1:0]			<=		sr_acc_status[M_ID_BITS+96-1:96];
			sr_araddr[M_ADR_BITS-1:0]		<=		sr_addr_cnt[M_ADR_BITS-1:0];
			sr_arburst[1:0]					<=		sr_acc_status[79:78];
			sr_arlock[1:0]					<=		sr_acc_status[77:76];
			sr_arcache[3:0]					<=		sr_acc_status[75:72];
			sr_arprot[2:0]					<=		sr_acc_status[71:69];
			sr_arqos[3:0]					<=		sr_acc_status[68:65];
			sr_aruser						<=		sr_acc_status[64];
			sr_arsize[2:0]					<=		s_arsize[2:0];
		end
	end

	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_arlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( MLT_OUT_EN == 1'b1
					&& sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			sr_arlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( MLT_OUT_EN == 1'b0
					&& sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1
					&& M_RLAST == 1'b1 )begin
			sr_arlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( sr_rd_adr_cycle == 1'b1
					&& sr_rd_adr_state[3:0] == `RD_ADR_ST )begin
			if( s_loop_cnt[15:0] != 16'h0000 )begin
				sr_arlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b1}};
			end else begin
				sr_arlen[M_LEN_BITS-1:0]		<=		sr_data_trans_cnt[M_LEN_BITS-1:0];
			end
		end
	end

	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_acc_status[127:0]		<=		128'd0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_END )begin
			sr_acc_status[127:0]		<=		128'd0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			sr_acc_status[127:0]		<=		{ RADR_FIFO_RDATA[127:4], s_addr_chk[3:0] };
		end
	end

	// アドレスチェック信号 //
	assign		s_addr_chk[3:0]					=		( M_DATA_BITS == 512 ) ? RADR_FIFO_RDATA[5:2]           :
														( M_DATA_BITS == 256 ) ? { 1'b0, RADR_FIFO_RDATA[4:2] } :
														( M_DATA_BITS == 128 ) ? { 2'b0, RADR_FIFO_RDATA[3:2] } :
														( M_DATA_BITS ==  64 ) ? { 3'b0, RADR_FIFO_RDATA[2] }   : 4'b0000;

	// アドレスカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_addr_cnt[63:0]		<=		64'd0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			sr_addr_cnt[63:0]		<=		{ {64-M_ADR_BITS{1'b0}}, RADR_FIFO_RDATA[M_ADR_BITS-1:0] };
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			if( M_DATA_BITS == 512 )begin
				sr_addr_cnt[63:0]		<=		sr_addr_cnt[63:0] + ( { {58-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}}, 6'b11_1111 } + 64'd1 );
			end else if( M_DATA_BITS == 256 )begin
				sr_addr_cnt[63:0]		<=		sr_addr_cnt[63:0] + ( { {59-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}}, 5'b1_1111 }  + 64'd1 );
			end else if( M_DATA_BITS == 128 )begin
				sr_addr_cnt[63:0]		<=		sr_addr_cnt[63:0] + ( { {60-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}}, 4'b1111 }    + 64'd1 );
			end else if( M_DATA_BITS == 64 )begin
				sr_addr_cnt[63:0]		<=		sr_addr_cnt[63:0] + ( { {61-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}}, 3'b111 }     + 64'd1 );
			end else begin
				sr_addr_cnt[63:0]		<=		sr_addr_cnt[63:0] + ( { {62-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}}, 2'b11 }      + 64'd1 );
			end
		end
	end

	// データ転送ループ回数信号 //
	assign		s_loop_cnt[15:0]				=		{ {16-M_LEN_BITS{1'b0}}, sr_data_trans_cnt[15:M_LEN_BITS] };

	// LEN+1検出信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_len_add		<=		1'b0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_END )begin
			sr_len_add		<=		1'b0;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_RD )begin
			if( M_DATA_BITS == 512 )begin
				casex( { RADR_FIFO_RDATA[114:112], RADR_FIFO_RDATA[5:2], RADR_FIFO_RDATA[83:80] } )
					11'b110_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 512Bit
					11'b101_1xxx_xxx1	:	sr_len_add		<=		1'b1;		// 256Bit
					11'b100_01xx_xx11	:	sr_len_add		<=		1'b1;		// 128Bit
					11'b100_10xx_xx1x	:	sr_len_add		<=		1'b1;		// 128Bit
					11'b100_11xx_xx01	:	sr_len_add		<=		1'b1;		// 128Bit
					11'b100_11xx_xx1x	:	sr_len_add		<=		1'b1;		// 128Bit
					11'b011_001x_x111	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_010x_x11x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_011x_x11x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_011x_x101	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_100x_x1xx	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_101x_x1xx	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_101x_x011	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_110x_x1xx	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_110x_x01x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_111x_x1xx	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_111x_x01x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_111x_x001	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b010_0001_1111	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0010_111x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0011_111x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0011_1101	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0100_11xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0101_11xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0101_1011	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0110_11xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0110_101x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0111_11xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0111_101x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_0111_1001	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1000_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1001_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1001_0111	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1010_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1010_011x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1011_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1011_011x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1011_0101	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1100_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1100_01xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1101_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1101_01xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1101_xx11	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1110_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1110_01xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1110_001x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1111_1xxx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1111_01xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1111_001x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_1111_0001	:	sr_len_add		<=		1'b1;		// 32Bit
					default				:	sr_len_add		<=		1'b0;		// 
				endcase
			end else if( M_DATA_BITS == 256 )begin
				casex( { RADR_FIFO_RDATA[114:112], RADR_FIFO_RDATA[5:2], RADR_FIFO_RDATA[83:80] } )
					11'b110_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 512Bit
					11'b101_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 256Bit
					11'b100_x1xx_xxx1	:	sr_len_add		<=		1'b1;		// 128Bit
					11'b011_x01x_xx11	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_x10x_xx1x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_x11x_xx1x	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b011_x11x_xx01	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b010_x001_x111	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x010_x11x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x011_x11x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x011_x101	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x100_x1xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x101_x1xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x101_x011	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x110_x1xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x110_x01x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x111_x1xx	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x111_x01x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_x111_x001	:	sr_len_add		<=		1'b1;		// 32Bit
					default				:	sr_len_add		<=		1'b0;		// 
				endcase
			end else if( M_DATA_BITS == 128 )begin
				casex( { RADR_FIFO_RDATA[114:112], RADR_FIFO_RDATA[5:2], RADR_FIFO_RDATA[83:80] } )
					11'b110_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 512Bit
					11'b101_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 256Bit
					11'b100_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 128Bit
					11'b011_xx1x_xxx1	:	sr_len_add		<=		1'b1;		// 64Bit
					11'b010_xx01_xx11	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_xx10_xx1x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_xx11_xx1x	:	sr_len_add		<=		1'b1;		// 32Bit
					11'b010_xx11_xx01	:	sr_len_add		<=		1'b1;		// 32Bit
					default				:	sr_len_add		<=		1'b0;		// 
				endcase
			end else if( M_DATA_BITS == 64 )begin
				casex( { RADR_FIFO_RDATA[114:112], RADR_FIFO_RDATA[5:2], RADR_FIFO_RDATA[83:80] } )
					11'b110_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 512Bit
					11'b101_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 256Bit
					11'b100_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 128Bit
					11'b011_xxxx_xxxx	:	sr_len_add		<=		1'b0;		// 64Bit
					11'b010_xxx1_xxx1	:	sr_len_add		<=		1'b1;		// 32Bit
					default				:	sr_len_add		<=		1'b0;		// 
				endcase
			end else begin
				sr_len_add		<=		1'b0;
			end
		end
	end

	// データ転送数カウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_data_trans_cnt[15:0]		<=		16'h0000;
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CAL )begin
			if( sr_len_add == 1'b1 )begin
				sr_data_trans_cnt[15:0]		<=		sr_len_max[15:0] + 16'h0001;
			end else begin
				sr_data_trans_cnt[15:0]		<=		sr_len_max[15:0];
			end
		end else if( sr_rd_adr_state[3:0] == `RD_ADR_CHK
					&& M_ARREADY == 1'b1 && sr_arvalid == 1'b1 )begin
			if( sr_data_trans_cnt[15:0] >= ( { {16-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}} } + 16'h0001 ))begin
				sr_data_trans_cnt[15:0]		<=		sr_data_trans_cnt[15:0] - { {16-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}} } - 16'h0001;
			end else begin
				sr_data_trans_cnt[15:0]		<=		16'h0000;
			end
		end
	end


//------------------------------------------------------------------------------
// データフェーズ制御部
//------------------------------------------------------------------------------

	// RD_ACC_FIFOリードイネーブル信号 //
	assign		s_racc_fifo_rden				=		( sr_rd_dat_cycle == 1'b1 && sr_rd_dat_state[3:0] == `RD_DAT_INIT && s_racc_fifo_empty == 1'b0 ) ? 1'b1 : 1'b0;

	// データステータス保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_racc[4:0]		<=		5'b0_0000;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT
					&& s_racc_fifo_empty == 1'b0 )begin
			sr_racc[4:0]		<=		s_racc_fifo_rdata[4:0];
		end
	end

	// データLENカウンタ信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rlen512_cnt[15:0]		<=		16'h0000;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT
					&& s_racc_fifo_empty == 1'b0 )begin
			sr_rlen512_cnt[15:0]		<=		s_racc_fifo_rdata[20:5];
		end else if( s_rd_dat_fifo_wren == 1'b1 && sr_rlen512_cnt[15:0] != 16'h0000 )begin
			sr_rlen512_cnt[15:0]		<=		sr_rlen512_cnt[15:0] - 16'h0001;
		end
	end

	// RD_DAT_FIFOライトネーブル信号 //
	assign		s_rd_dat_fifo_wren				=		( sr_racc[3:0] == 4'b0000 )                                                  ? s_fifo_wren :
														( sr_racc[3:0] != 4'b0000 && ( sr_fifo_wr_mask == 1'b1 || M_RLAST == 1'b1 )) ? s_fifo_wren : 1'b0;

	assign		s_fifo_wren						=		( sr_rd_dat_state[3:0] == `RD_DAT_CHK && RDAT_FIFO_FULL == 1'b0
															&& M_RVALID == 1'b1 && sr_rready == 1'b1 && ( sr_rcnt[3:0] == s_rcnt_max[3:0] || M_RLAST == 1'b1 )) ? 1'b1 :
														( sr_rd_dat_state[3:0] == `RD_DAT_WR_WAIT && RDAT_FIFO_FULL == 1'b0 )                                   ? 1'b1 :
														( sr_rd_dat_state[3:0] == `RD_DAT_LAST_WAIT && RDAT_FIFO_FULL == 1'b0 )                                 ? 1'b1 :
														( sr_rd_dat_state[3:0] == `RD_DAT_LAST && RDAT_FIFO_FULL == 1'b0 )                                      ? 1'b1 : 1'b0;

	// RD_DAT_FIFOライトデータ信号 //
	assign		s_rd_dat_fifo_wdata[577:0]		=		( sr_rd_dat_state[3:0] == `RD_DAT_LAST )           ? { 2'b01, sr_rd_fifo_wdata[575:512], s_wdata_change[511:0] } :
														( sr_rd_dat_state[3:0] == `RD_DAT_WR_WAIT
															|| sr_rd_dat_state[3:0] == `RD_DAT_LAST_WAIT ) ? sr_rd_fifo_wdata[577:0]                                     : s_wdata_change[577:0];

	// RD_FIFOライトイネーブルマスク信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_fifo_wr_mask		<=		1'b0;
		end else if( sr_racc[3:0] == 4'b0000 )begin
			sr_fifo_wr_mask		<=		1'b0;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT )begin
			sr_fifo_wr_mask		<=		1'b0;
		end else if( s_fifo_wren == 1'b1 )begin
			sr_fifo_wr_mask		<=		1'b1;
		end
	end

	// データLAST信号 //
	assign		s_rlast							=		( sr_racc[4] == 1'b0 )                                  ? 1'b0 :
														( M_RLAST == 1'b1 && sr_rlen512_cnt[15:0] == 16'h0000 ) ? 1'b1 : 1'b0;

	// データカウントMAX信号 //
	assign		s_rcnt_max[3:0]					=		( M_DATA_BITS == 512 ) ? 4'b0000 :
														( M_DATA_BITS == 256 ) ? 4'b0001 :
														( M_DATA_BITS == 128 ) ? 4'b0011 :
														( M_DATA_BITS ==  64 ) ? 4'b0111 : 4'b1111;

	// データカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rcnt[3:0]		<=		4'b0000;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_INIT )begin
			sr_rcnt[3:0]		<=		4'b0000;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK )begin
			if( M_RVALID == 1'b1 && sr_rready == 1'b1 )begin
				if( sr_rcnt[3:0] == s_rcnt_max[3:0] )begin
					sr_rcnt[3:0]		<=		4'b0000;
				end else begin
					sr_rcnt[3:0]		<=		sr_rcnt[3:0] + 4'b0001;
 				end
			end
		end
	end

	// データレディ信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rready		<=		1'b0;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1
					&& M_RLAST == 1'b1 )begin
			sr_rready		<=		1'b0;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1
					&& sr_rcnt[3:0] == s_rcnt_max[3:0]
					&& RDAT_FIFO_FULL == 1'b1 )begin
			sr_rready		<=		1'b0;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_WR_WAIT
					&& RDAT_FIFO_FULL == 1'b0 )begin
			sr_rready		<=		1'b1;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT
					&& s_racc_fifo_empty == 1'b0 )begin
			sr_rready		<=		1'b1;
		end
	end

	// RD_FIFOライトデータ保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_rd_fifo_wdata[577:0]		<=		578'd0;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT )begin
			sr_rd_fifo_wdata[577:0]		<=		578'd0;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1
					&& ( sr_rcnt[3:0] == s_rcnt_max[3:0] || M_RLAST == 1'b1 ))begin
			sr_rd_fifo_wdata[577:0]		<=		s_wdata_change[577:0];
		end
	end

	// FIFOライトデータ信号 //
	assign		s_fifo_wdata[577:0]		=		( M_DATA_BITS == 512 )                            ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], M_RDATA[M_DATA_BITS-1:0] }                                                                                    :
												( M_DATA_BITS == 256 && sr_rcnt[0] == 1'b0 )      ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], {M_DATA_BITS{1'b0}}, M_RDATA[M_DATA_BITS-1:0] }                                                               :
												( M_DATA_BITS == 256 && sr_rcnt[0] == 1'b1 )      ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0],                      M_RDATA[M_DATA_BITS-1:0],  sr_fifo_wdata[M_DATA_BITS-1:0] }                              :
												( M_DATA_BITS == 128 && sr_rcnt[1:0] == 2'b00 )   ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], {M_DATA_BITS*3{1'b0}},                          M_RDATA[M_DATA_BITS-1:0] }                                    :
												( M_DATA_BITS == 128 && sr_rcnt[1:0] == 2'b01 )   ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*4-1:M_DATA_BITS*2],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*1-1:0] }  :
												( M_DATA_BITS == 128 && sr_rcnt[1:0] == 2'b10 )   ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*4-1:M_DATA_BITS*3],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*2-1:0] }  :
												( M_DATA_BITS == 128 && sr_rcnt[1:0] == 2'b11 )   ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0],                                                 M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*3-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b000 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], {M_DATA_BITS*7{1'b0}},                          M_RDATA[M_DATA_BITS-1:0] }                                    :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b001 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*2],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*1-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b010 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*3],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*2-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b011 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*4],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*3-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b100 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*5],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*4-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b101 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*6],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*5-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b110 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:M_DATA_BITS*7],   M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*6-1:0] }  :
												( M_DATA_BITS ==  64 && sr_rcnt[2:0] == 3'b111 )  ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0],                                                 M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*7-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0000 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], {M_DATA_BITS*15{1'b0}},                         M_RDATA[M_DATA_BITS-1:0] }                                    :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0001 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*2],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*1-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0010 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*3],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*2-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0011 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*4],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*3-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0100 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*5],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*4-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0101 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*6],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*5-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0110 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*7],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*6-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b0111 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*8],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*7-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1000 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*9],  M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*8-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1001 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*10], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*9-1:0] }  :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1010 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*11], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*10-1:0] } :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1011 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*12], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*11-1:0] } :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1100 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*13], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*12-1:0] } :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1101 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*14], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*13-1:0] } :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1110 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*16-1:M_DATA_BITS*15], M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*14-1:0] } :
												( M_DATA_BITS ==  32 && sr_rcnt[3:0] == 4'b1111 ) ? { 1'b0, s_rlast, {62-M_ID_BITS{1'b0}}, M_RRESP[1:0], M_RID[M_ID_BITS-1:0],                                                 M_RDATA[M_DATA_BITS-1:0], sr_fifo_wdata[M_DATA_BITS*15-1:0] } : 578'd0;

	// FIFOライトデータ保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_fifo_wdata[511:0]		<=		512'd0;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT )begin
			sr_fifo_wdata[511:0]		<=		512'd0;
		end else if( sr_rd_dat_state[3:0] == `RD_DAT_CHK
					&& M_RVALID == 1'b1 && sr_rready == 1'b1 )begin
			sr_fifo_wdata[511:0]		<=		s_fifo_wdata[511:0];
		end
	end

	// データ変換信号 //
	assign		s_wdata_change[577:0]	=		( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0000 ) ? s_fifo_wdata[577:0]                                                   :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0001 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[ 31:0], s_wdata_sel0[511:32]  } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0010 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[ 63:0], s_wdata_sel0[511:64]  } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0011 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[ 95:0], s_wdata_sel0[511:96]  } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0100 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[127:0], s_wdata_sel0[511:128] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0101 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[159:0], s_wdata_sel0[511:160] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0110 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[191:0], s_wdata_sel0[511:192] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b0111 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[223:0], s_wdata_sel0[511:224] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1000 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[255:0], s_wdata_sel0[511:256] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1001 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[287:0], s_wdata_sel0[511:288] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1010 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[319:0], s_wdata_sel0[511:320] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1011 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[351:0], s_wdata_sel0[511:352] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1100 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[383:0], s_wdata_sel0[511:384] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1101 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[415:0], s_wdata_sel0[511:416] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1110 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[447:0], s_wdata_sel0[511:448] } :
												( M_DATA_BITS == 512 && sr_racc[3:0] == 4'b1111 ) ? { s_wdata_sel2[577:512], s_wdata_sel1[479:0], s_wdata_sel0[511:480] } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b000 )  ? s_fifo_wdata[577:0]                                                   :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b001 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[ 31:0], s_wdata_sel0[511:32]  } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b010 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[ 63:0], s_wdata_sel0[511:64]  } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b011 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[ 95:0], s_wdata_sel0[511:96]  } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b100 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[127:0], s_wdata_sel0[511:128] } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b101 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[159:0], s_wdata_sel0[511:160] } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b110 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[191:0], s_wdata_sel0[511:192] } :
												( M_DATA_BITS == 256 && sr_racc[2:0] == 3'b111 )  ? { s_wdata_sel2[577:512], s_wdata_sel1[223:0], s_wdata_sel0[511:224] } :
												( M_DATA_BITS == 128 && sr_racc[1:0] == 2'b00 )   ? s_fifo_wdata[577:0]                                                   :
												( M_DATA_BITS == 128 && sr_racc[1:0] == 2'b01 )   ? { s_wdata_sel2[577:512], s_wdata_sel1[ 31:0], s_wdata_sel0[511:32]  } :
												( M_DATA_BITS == 128 && sr_racc[1:0] == 2'b10 )   ? { s_wdata_sel2[577:512], s_wdata_sel1[ 63:0], s_wdata_sel0[511:64]  } :
												( M_DATA_BITS == 128 && sr_racc[1:0] == 2'b11 )   ? { s_wdata_sel2[577:512], s_wdata_sel1[ 95:0], s_wdata_sel0[511:96]  } :
												( M_DATA_BITS ==  64 && sr_racc[0]   == 1'b0 )    ? s_fifo_wdata[577:0]                                                   :
												( M_DATA_BITS ==  64 && sr_racc[0]   == 1'b1 )    ? { s_wdata_sel2[577:512], s_wdata_sel1[ 31:0], s_wdata_sel0[511:32]  } :
												                                                      s_fifo_wdata[577:0];

	assign		s_wdata_sel0[511:0]		=		( sr_fifo_wr_mask == 1'b0 ) ? s_fifo_wdata[511:0] : sr_wdata_change[511:0];

	assign		s_wdata_sel1[511:0]		=		( sr_fifo_wr_mask == 1'b1 ) ? s_fifo_wdata[511:0]  : 512'd0;

	assign		s_wdata_sel2[577:512]	=		s_fifo_wdata[577:512];

	// データ変換保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wdata_change[511:0]		<=		512'd0;
		end else if( sr_rd_dat_cycle == 1'b1
					&& sr_rd_dat_state[3:0] == `RD_DAT_INIT )begin
			sr_wdata_change[511:0]		<=		512'd0;
		end else if( s_fifo_wren == 1'b1 )begin
			if( sr_rd_dat_state[3:0] == `RD_DAT_WR_WAIT
				|| sr_rd_dat_state[3:0] == `RD_DAT_LAST_WAIT )begin
				sr_wdata_change[511:0]		<=		sr_fifo_wdata[511:0];
			end else begin
				sr_wdata_change[511:0]		<=		s_fifo_wdata[511:0];
			end
		end
	end



endmodule

