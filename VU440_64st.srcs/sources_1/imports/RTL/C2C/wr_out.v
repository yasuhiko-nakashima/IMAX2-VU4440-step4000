//------------------------------------------------------------------------------
// WR_OUT MODEL
//------------------------------------------------------------------------------
// WR_OUT モジュール
// (1) ライト出力処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : wr_out.v
// Module         : WR_OUT
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module WR_OUT # ( 
					parameter	M_ID_BITS		=	8,		// 
					parameter	M_ADR_BITS		=	64,		// 
					parameter	M_LEN_BITS		=	8,		// 
					parameter	M_DATA_BITS		=	256,	// 
					parameter	MLT_OUT_EN		=	0,		// 
					parameter	FIFO_WORD		=	8		// 
				) (
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

					WADR_FIFO_EMPTY,						// 
					WADR_FIFO_RDEN,							// 
					WADR_FIFO_RDATA,						// 

					WDAT_FIFO_EMPTY,						// 
					WDAT_FIFO_RDEN,							// 
					WDAT_FIFO_RDATA,						// 

					WACC_MASK								// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input								M_CLK;				// 
	input								M_RESET_N;			// 
	output	[M_ID_BITS-1:0]				M_AWID;				// 
	output	[M_ADR_BITS-1:0]			M_AWADDR;			// 
	output	[M_LEN_BITS-1:0]			M_AWLEN;			// 
	output	[2:0]						M_AWSIZE;			// 
	output	[1:0]						M_AWBURST;			// 
	output	[1:0]						M_AWLOCK;			// 
	output	[3:0]						M_AWCACHE;			// 
	output	[2:0]						M_AWPROT;			// 
	output	[3:0]						M_AWQOS;			// 
	output								M_AWUSER;			// 
	output								M_AWVALID;			// 
	output	[M_DATA_BITS-1:0]			M_WDATA;			// 
	output	[M_DATA_BITS/8-1:0]			M_WSTRB;			// 
	output								M_WLAST;			// 
	output								M_WVALID;			// 
	output								M_BREADY;			// 
	input								M_AWREADY;			// 
	input								M_WREADY;			// 
	input	[M_ID_BITS-1:0]				M_BID;				// 
	input	[1:0]						M_BRESP;			// 
	input								M_BVALID;			// 

	input								WADR_FIFO_EMPTY;	// 
	output								WADR_FIFO_RDEN;		// 
	input	[127:0]						WADR_FIFO_RDATA;	// 

	input								WDAT_FIFO_EMPTY;	// 
	output								WDAT_FIFO_RDEN;		// 
	input	[577:0]						WDAT_FIFO_RDATA;	// 

	output								WACC_MASK;			// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire								s_wacc_fifo_wren;	// 
	wire	[20:0]						s_wacc_fifo_wdata;	// 
	wire								s_wacc_fifo_full;	// 
	wire								s_wacc_fifo_rden;	// 
	wire	[20:0]						s_wacc_fifo_rdata;	// 
	wire								s_wacc_fifo_empty;	// 
	wire								s_wr_adr_fifo_rden;	// 
	wire	[15:0]						s_wlen_max_512;		// 
	wire	[15:0]						s_wlen_max_256;		// 
	wire	[15:0]						s_wlen_max_128;		// 
	wire	[15:0]						s_wlen_max_64;		// 
	wire	[15:0]						s_wlen_max_32;		// 
	wire	[2:0]						s_awsize;			// 
	wire	[3:0]						s_addr_chk;			// 
	wire	[15:0]						s_loop_cnt;			// 
	wire								s_wr_dat_fifo_rden;	// 
	wire	[3:0]						s_wcnt_max;			// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg									sr_wr_adr_cycle;	// 
	reg									sr_wr_dat_cycle;	// 
	reg		[3:0]						sr_wr_adr_state;	// 
	reg		[3:0]						sr_wr_dat_state;	// 
	reg		[15:0]						sr_wlen_max;		// 
	reg									sr_wacc_mask;		// 
	reg									sr_awvalid;			// 
	reg		[M_ID_BITS-1:0]				sr_awid;			// 
	reg		[M_ADR_BITS-1:0]			sr_awaddr;			// 
	reg		[M_LEN_BITS-1:0]			sr_awlen;			// 
	reg		[2:0]						sr_awsize_mot;		// 
	reg		[1:0]						sr_awburst;			// 
	reg		[1:0]						sr_awlock;			// 
	reg		[3:0]						sr_awcache;			// 
	reg		[2:0]						sr_awprot;			// 
	reg		[3:0]						sr_awqos;			// 
	reg									sr_awuser;			// 
	reg		[2:0]						sr_awsize;			// 
	reg		[127:0]						sr_acc_status;		// 
	reg		[63:0]						sr_addr_cnt;		// 
	reg									sr_len_add;			// 
	reg		[15:0]						sr_data_trans_cnt;	// 
	reg		[4:0]						sr_wacc;			// 
	reg		[15:0]						sr_frame_cnt;		// 
	reg		[3:0]						sr_wcnt;			// 
	reg									sr_wvalid;			// 
	reg									sr_wlast;			// 
	reg		[M_DATA_BITS-1:0]			sr_wdata;			// 
	reg		[M_DATA_BITS/8-1:0]			sr_wstrb;			// 
	reg									sr_bready;			// 
	reg		[577:0]						sr_wdata_change0;	// 
	reg		[577:0]						sr_wdata_change1;	// 
	reg		[577:0]						sr_wdata_change1_tmp;// 
	reg		[577:0]						sr_wdata_change2;	// 
	reg		[63:0]						sr_wstrb_change0;	// 
	reg		[63:0]						sr_wstrb_change1;	// 
	reg		[63:0]						sr_wstrb_change1_tmp;// 
	reg		[63:0]						sr_wstrb_change2;	// 
	reg		[511:0]						sr_wdata_change;	// 
	reg		[63:0]						sr_wstrb_change;	// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
	`define 	WR_ADR_INIT				4'b0000				// INITステート
	`define 	WR_ADR_RD				4'b0001				// アドレスリードステート
	`define 	WR_ADR_CAL				4'b0010				// アドレス演算ステート
	`define 	WR_ADR_ST				4'b0011				// アドレススタートステート
	`define 	WR_ADR_CHK				4'b0100				// アドレスチェックステート
	`define 	WR_ADR_WAIT				4'b0101				// アドレスウエイトステート
	`define 	WR_ADR_END				4'b0110				// 終了ステート

	`define 	WR_DAT_INIT				4'b1000				// INITステート
	`define 	WR_DAT_RD				4'b1001				// データリードステート
	`define 	WR_DAT_CHK				4'b1010				// データチェックステート
	`define 	WR_DAT_END				4'b1011				// 終了ステート


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

FIFO_21BXNW	#	(
					.FIFO_WORD				(FIFO_WORD)
				) inst_rd_addr_fifo (
					.RST_N					(M_RESET_N),
					.CLK					(M_CLK),
					.WREN					(s_wacc_fifo_wren),
					.WDATA					(s_wacc_fifo_wdata[20:0]),
					.FULL					(s_wacc_fifo_full),
					.RDEN					(s_wacc_fifo_rden),
					.RDATA					(s_wacc_fifo_rdata[20:0]),
					.EMPTY					(s_wacc_fifo_empty)
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------

	assign		M_AWID[M_ID_BITS-1:0]		=		sr_awid[M_ID_BITS-1:0];
	assign		M_AWADDR[M_ADR_BITS-1:0]	=		sr_awaddr[M_ADR_BITS-1:0];
	assign		M_AWLEN[M_LEN_BITS-1:0]		=		sr_awlen[M_LEN_BITS-1:0];
	assign		M_AWSIZE[2:0]				=		sr_awsize[2:0];
	assign		M_AWBURST[1:0]				=		sr_awburst[1:0];
	assign		M_AWLOCK[1:0]				=		sr_awlock[1:0];
	assign		M_AWCACHE[3:0]				=		sr_awcache[3:0];
	assign		M_AWPROT[2:0]				=		sr_awprot[2:0];
	assign		M_AWQOS[3:0]				=		sr_awqos[3:0];
	assign		M_AWUSER					=		sr_awuser;

	assign		M_AWVALID					=		sr_awvalid;
	assign		M_WDATA[M_DATA_BITS-1:0]	=		sr_wdata[M_DATA_BITS-1:0];
	assign		M_WSTRB[M_DATA_BITS/8-1:0]	=		sr_wstrb[M_DATA_BITS/8-1:0];
	assign		M_WLAST						=		sr_wlast;
	assign		M_WVALID					=		sr_wvalid;

	assign		M_BREADY					=		sr_bready;

	assign		WADR_FIFO_RDEN				=		s_wr_adr_fifo_rden;

	assign		WDAT_FIFO_RDEN				=		s_wr_dat_fifo_rden;

	assign		WACC_MASK					=		sr_wacc_mask;


//------------------------------------------------------------------------------
// ライトステート制御部
//------------------------------------------------------------------------------

	// ライトステート切替信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wr_adr_cycle		<=		1'b1;
			sr_wr_dat_cycle		<=		1'b0;
		end else if( MLT_OUT_EN == 1'b1 )begin
			sr_wr_adr_cycle		<=		1'b1;
			sr_wr_dat_cycle		<=		1'b1;
		end else begin
			if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
				&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1
				&& sr_wr_adr_cycle == 1'b1 )begin
				sr_wr_adr_cycle		<=		1'b0;
			end else if( sr_wr_dat_state[3:0] == `WR_DAT_END
						&& M_BVALID == 1'b1 && sr_bready == 1'b1 )begin
				sr_wr_adr_cycle		<=		1'b1;
			end
			if( sr_wr_dat_state[3:0] == `WR_DAT_END
				&& M_BVALID == 1'b1 && sr_bready == 1'b1 )begin
				sr_wr_dat_cycle		<=		1'b0;
			end else if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
						&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1
						&& sr_wr_adr_cycle == 1'b1 )begin
				sr_wr_dat_cycle		<=		1'b1;
			end
		end
	end

	// ライトアドレスステート //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wr_adr_state[3:0]		<=		`WR_ADR_INIT;
		end else begin
			case ( sr_wr_adr_state[3:0] )
				`WR_ADR_INIT		:	if( WADR_FIFO_EMPTY == 1'b0 && s_wacc_fifo_full == 1'b0 )begin
											sr_wr_adr_state[3:0]		<=		`WR_ADR_RD;
										end else begin
											sr_wr_adr_state[3:0]		<=		`WR_ADR_INIT;
										end

				`WR_ADR_RD		:	sr_wr_adr_state[3:0]		<=		`WR_ADR_CAL;
				`WR_ADR_CAL		:	sr_wr_adr_state[3:0]		<=		`WR_ADR_ST;
				`WR_ADR_ST		:	if( sr_wr_adr_cycle == 1'b1 )begin
										sr_wr_adr_state[3:0]		<=		`WR_ADR_CHK;
									end else begin
										sr_wr_adr_state[3:0]		<=		`WR_ADR_ST;
									end
				`WR_ADR_CHK		:	if( M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
										if( s_loop_cnt[15:0] != 16'h0000 )begin
											if(  s_wacc_fifo_full == 1'b0 )begin
												sr_wr_adr_state[3:0]		<=		`WR_ADR_ST;
											end else begin
												sr_wr_adr_state[3:0]		<=		`WR_ADR_WAIT;
											end
										end else begin
											sr_wr_adr_state[3:0]		<=		`WR_ADR_END;
										end
									end else begin
										sr_wr_adr_state[3:0]		<=		`WR_ADR_CHK;
									end
				`WR_ADR_WAIT	:	if( s_wacc_fifo_full == 1'b0 )begin
										sr_wr_adr_state[3:0]		<=		`WR_ADR_ST;
									end else begin
										sr_wr_adr_state[3:0]		<=		`WR_ADR_WAIT;
									end
				`WR_ADR_END		:	sr_wr_adr_state[3:0]		<=		`WR_ADR_INIT;
				default			:	sr_wr_adr_state[3:0]		<=		`WR_ADR_INIT;
			endcase
		end
	end

	// ライトデータステート //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wr_dat_state[3:0]		<=		`WR_DAT_INIT;
		end else begin
			case ( sr_wr_dat_state[3:0] )
				`WR_DAT_INIT		:	if( sr_wr_dat_cycle == 1'b1
											&& WDAT_FIFO_EMPTY == 1'b0 && s_wacc_fifo_empty == 1'b0 )begin
											sr_wr_dat_state[3:0]		<=		`WR_DAT_RD;
										end else begin
											sr_wr_dat_state[3:0]		<=		`WR_DAT_INIT;
										end
				`WR_DAT_RD			:	sr_wr_dat_state[3:0]		<=		`WR_DAT_CHK;
				`WR_DAT_CHK			:	if( M_WREADY == 1'b1 && sr_wvalid == 1'b1 )begin
											if( sr_frame_cnt[15:0] == 16'h0000 )begin
												sr_wr_dat_state[3:0]		<=		`WR_DAT_END;
											end else begin
												sr_wr_dat_state[3:0]		<=		`WR_DAT_CHK;
											end
										end else begin
											sr_wr_dat_state[3:0]		<=		`WR_DAT_CHK;
										end
				`WR_DAT_END			:	if( M_BVALID == 1'b1 && sr_bready == 1'b1 )begin
											sr_wr_dat_state[3:0]		<=		`WR_DAT_INIT;
										end else begin
											sr_wr_dat_state[3:0]		<=		`WR_DAT_END;
										end
				default				:	sr_wr_dat_state[3:0]		<=		`WR_DAT_INIT;
			endcase
		end
	end


//------------------------------------------------------------------------------
// アドレスフェーズ制御部
//------------------------------------------------------------------------------

	// WR_ADR_FIFOリードイネーブル信号 //
	assign		s_wr_adr_fifo_rden			=		( sr_wr_adr_state[3:0] == `WR_ADR_RD ) ? 1'b1 : 1'b0;

	// WR_ACC_FIFOライトイネーブル信号 //
	assign		s_wacc_fifo_wren			=		( sr_wr_adr_cycle == 1'b1 && sr_wr_adr_state[3:0] == `WR_ADR_ST ) ? 1'b1 : 1'b0;

	// WR_ACC_FIFOライトデータ信号 //
	assign		s_wacc_fifo_wdata[20:0]		=		( s_loop_cnt[15:0] != 16'h0000 ) ? { sr_len_add, sr_acc_status[3:0], {16-M_LEN_BITS{1'b0}}, {M_LEN_BITS{1'b1}} } :
																					   { sr_len_add, sr_acc_status[3:0], {16-M_LEN_BITS{1'b0}}, sr_data_trans_cnt[M_LEN_BITS-1:0] };
	// データLENカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wlen_max[15:0]		<=		16'h0000;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_RD )begin
			if( M_DATA_BITS == 512 )begin
				sr_wlen_max[15:0]		<=		s_wlen_max_512[15:0];
			end else if( M_DATA_BITS == 256 )begin
				sr_wlen_max[15:0]		<=		s_wlen_max_256[15:0];
			end else if( M_DATA_BITS == 128 )begin
				sr_wlen_max[15:0]		<=		s_wlen_max_128[15:0];
			end else if( M_DATA_BITS == 64 )begin
				sr_wlen_max[15:0]		<=		s_wlen_max_64[15:0];
			end else if( M_DATA_BITS == 32 )begin
				sr_wlen_max[15:0]		<=		s_wlen_max_32[15:0];
			end else begin
				sr_wlen_max[15:0]		<=		16'h0000;
			end
		end
	end

	assign		s_wlen_max_512[15:0]		=		( WADR_FIFO_RDATA[114:112] == 3'b110 ) ? WADR_FIFO_RDATA[95:80]              :
													( WADR_FIFO_RDATA[114:112] == 3'b101 ) ? { 1'b0,    WADR_FIFO_RDATA[95:81] } :
													( WADR_FIFO_RDATA[114:112] == 3'b100 ) ? { 2'b00,   WADR_FIFO_RDATA[95:82] } :
													( WADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 3'b000,  WADR_FIFO_RDATA[95:83] } :
													( WADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 4'b0000, WADR_FIFO_RDATA[95:84] } : 16'd0;

	assign		s_wlen_max_256[15:0]		=		( WADR_FIFO_RDATA[114:112] == 3'b110 ) ? { WADR_FIFO_RDATA[94:80], 1'b1 }   :
													( WADR_FIFO_RDATA[114:112] == 3'b101 ) ? WADR_FIFO_RDATA[95:80]             :
													( WADR_FIFO_RDATA[114:112] == 3'b100 ) ? { 1'b0,   WADR_FIFO_RDATA[95:81] } :
													( WADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 2'b00,  WADR_FIFO_RDATA[95:82] } :
													( WADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 3'b000, WADR_FIFO_RDATA[95:83] } : 16'd0;

	assign		s_wlen_max_128[15:0]		=		( WADR_FIFO_RDATA[114:112] == 3'b110 ) ? { WADR_FIFO_RDATA[93:80], 2'b11 } :
													( WADR_FIFO_RDATA[114:112] == 3'b101 ) ? { WADR_FIFO_RDATA[94:80], 1'b1 }  :
													( WADR_FIFO_RDATA[114:112] == 3'b100 ) ? WADR_FIFO_RDATA[95:80]            :
													( WADR_FIFO_RDATA[114:112] == 3'b011 ) ? { 1'b0,  WADR_FIFO_RDATA[95:81] } :
													( WADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 2'b00, WADR_FIFO_RDATA[95:82] } : 16'd0;

	assign		s_wlen_max_64[15:0]			=		( WADR_FIFO_RDATA[114:112] == 3'b110 ) ? { WADR_FIFO_RDATA[92:80], 3'b111 } :
													( WADR_FIFO_RDATA[114:112] == 3'b101 ) ? { WADR_FIFO_RDATA[93:80], 2'b11 }  :
													( WADR_FIFO_RDATA[114:112] == 3'b100 ) ? { WADR_FIFO_RDATA[94:80], 1'b1 }   :
													( WADR_FIFO_RDATA[114:112] == 3'b011 ) ? WADR_FIFO_RDATA[95:80]             :
													( WADR_FIFO_RDATA[114:112] == 3'b010 ) ? { 1'b0, WADR_FIFO_RDATA[95:81] }   : 16'd0;

	assign		s_wlen_max_32[15:0]			=		( WADR_FIFO_RDATA[114:112] == 3'b110 ) ? { WADR_FIFO_RDATA[91:80], 4'b1111 } :
													( WADR_FIFO_RDATA[114:112] == 3'b101 ) ? { WADR_FIFO_RDATA[92:80], 3'b111 }  :
													( WADR_FIFO_RDATA[114:112] == 3'b100 ) ? { WADR_FIFO_RDATA[93:80], 2'b11 }   :
													( WADR_FIFO_RDATA[114:112] == 3'b011 ) ? { WADR_FIFO_RDATA[94:80], 1'b1 }    :
													( WADR_FIFO_RDATA[114:112] == 3'b010 ) ? WADR_FIFO_RDATA[95:80]              : 16'd0;

	// アクセスマスク信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wacc_mask		<=		1'b0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1
					&& s_loop_cnt[15:0] == 16'h0000 )begin
			sr_wacc_mask		<=		1'b0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_RD )begin
			sr_wacc_mask		<=		1'b1;
		end
	end

	// アドレス有効信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_awvalid		<=		1'b0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
			sr_awvalid		<=		1'b0;
		end else if( sr_wr_adr_cycle == 1'b1
					&& sr_wr_adr_state[3:0] == `WR_ADR_ST )begin
			sr_awvalid		<=		1'b1;
		end
	end

	// データサイズ信号 //
	assign		s_awsize[2:0]				=		( M_DATA_BITS ==   8 ) ? 3'b000 :
													( M_DATA_BITS ==  16 ) ? 3'b001 :
													( M_DATA_BITS ==  32 ) ? 3'b010 :
													( M_DATA_BITS ==  64 ) ? 3'b011 :
													( M_DATA_BITS == 128 ) ? 3'b100 :
													( M_DATA_BITS == 256 ) ? 3'b101 :
													( M_DATA_BITS == 512 ) ? 3'b110 : 3'b111;

	// 各種別信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_awid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_awaddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_awsize_mot[2:0]				<=		3'b000;
			sr_awburst[1:0]					<=		2'b00;
			sr_awlock[1:0]					<=		2'b00;
			sr_awcache[3:0]					<=		4'b0000;
			sr_awprot[2:0]					<=		3'b000;
			sr_awqos[3:0]					<=		4'b0000;
			sr_awuser						<=		1'b0;
			sr_awsize[2:0]					<=		3'b000;
		end else if( MLT_OUT_EN == 1'b1
					&& sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
			sr_awid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_awaddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_awsize_mot[2:0]				<=		3'b000;
			sr_awburst[1:0]					<=		2'b00;
			sr_awlock[1:0]					<=		2'b00;
			sr_awcache[3:0]					<=		4'b0000;
			sr_awprot[2:0]					<=		3'b000;
			sr_awqos[3:0]					<=		4'b0000;
			sr_awuser						<=		1'b0;
			sr_awsize[2:0]					<=		3'b000;
		end else if( MLT_OUT_EN == 1'b0
					&& sr_wr_dat_state[3:0] == `WR_DAT_END
					&& M_BVALID == 1'b1 && sr_bready == 1'b1 )begin
			sr_awid[M_ID_BITS-1:0]			<=		{M_ID_BITS{1'b0}};
			sr_awaddr[M_ADR_BITS-1:0]		<=		{M_ADR_BITS{1'b0}};
			sr_awsize_mot[2:0]				<=		3'b000;
			sr_awburst[1:0]					<=		2'b00;
			sr_awlock[1:0]					<=		2'b00;
			sr_awcache[3:0]					<=		4'b0000;
			sr_awprot[2:0]					<=		3'b000;
			sr_awqos[3:0]					<=		4'b0000;
			sr_awuser						<=		1'b0;
			sr_awsize[2:0]					<=		3'b000;
		end else if( sr_wr_adr_cycle == 1'b1
					&& sr_wr_adr_state[3:0] == `WR_ADR_ST )begin
			sr_awid[M_ID_BITS-1:0]			<=		sr_acc_status[M_ID_BITS+96-1:96];
			sr_awaddr[M_ADR_BITS-1:0]		<=		sr_addr_cnt[M_ADR_BITS-1:0];
			sr_awsize_mot[2:0]				<=		sr_acc_status[114:112];
			sr_awburst[1:0]					<=		sr_acc_status[79:78];
			sr_awlock[1:0]					<=		sr_acc_status[77:76];
			sr_awcache[3:0]					<=		sr_acc_status[75:72];
			sr_awprot[2:0]					<=		sr_acc_status[71:69];
			sr_awqos[3:0]					<=		sr_acc_status[68:65];
			sr_awuser						<=		sr_acc_status[64];
			sr_awsize[2:0]					<=		s_awsize[2:0];
		end
	end

	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_awlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( MLT_OUT_EN == 1'b1
					&& sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
			sr_awlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( MLT_OUT_EN == 1'b0
					&& sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_frame_cnt[15:0] == 16'h0000 )begin
			sr_awlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b0}};
		end else if( sr_wr_adr_cycle == 1'b1
					&& sr_wr_adr_state[3:0] == `WR_ADR_ST )begin
			if( s_loop_cnt[15:0] != 16'h0000 )begin
				sr_awlen[M_LEN_BITS-1:0]		<=		{M_LEN_BITS{1'b1}};
			end else begin
				sr_awlen[M_LEN_BITS-1:0]		<=		sr_data_trans_cnt[M_LEN_BITS-1:0];
			end
		end
	end

	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_acc_status[127:0]		<=		128'd0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_END )begin
			sr_acc_status[127:0]		<=		128'd0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_RD )begin
			sr_acc_status[127:0]		<=		{ WADR_FIFO_RDATA[127:4], s_addr_chk[3:0] };
		end
	end

	// アドレスチェック信号 //
	assign		s_addr_chk[3:0]				=		( M_DATA_BITS == 512 ) ? WADR_FIFO_RDATA[5:2]           :
													( M_DATA_BITS == 256 ) ? { 1'b0, WADR_FIFO_RDATA[4:2] } :
													( M_DATA_BITS == 128 ) ? { 2'b0, WADR_FIFO_RDATA[3:2] } :
													( M_DATA_BITS ==  64 ) ? { 3'b0, WADR_FIFO_RDATA[2] }   : 4'b0000;

	// アドレスカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_addr_cnt[63:0]		<=		64'd0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_RD )begin
			sr_addr_cnt[63:0]		<=		{ {64-M_ADR_BITS{1'b0}}, WADR_FIFO_RDATA[M_ADR_BITS-1:0] };
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
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
	assign		s_loop_cnt[15:0]			=		{ {16-M_LEN_BITS{1'b0}}, sr_data_trans_cnt[15:M_LEN_BITS] };

	// LEN+1検出信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_len_add		<=		1'b0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_END )begin
			sr_len_add		<=		1'b0;
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_RD )begin
			if( M_DATA_BITS == 512 )begin
				casex( { WADR_FIFO_RDATA[114:112], WADR_FIFO_RDATA[5:2], WADR_FIFO_RDATA[83:80] } )
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
				casex( { WADR_FIFO_RDATA[114:112], WADR_FIFO_RDATA[5:2], WADR_FIFO_RDATA[83:80] } )
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
				casex( { WADR_FIFO_RDATA[114:112], WADR_FIFO_RDATA[5:2], WADR_FIFO_RDATA[83:80] } )
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
				casex( { WADR_FIFO_RDATA[114:112], WADR_FIFO_RDATA[5:2], WADR_FIFO_RDATA[83:80] } )
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
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_CAL )begin
			if( sr_len_add == 1'b1 )begin
				sr_data_trans_cnt[15:0]		<=		sr_wlen_max[15:0] + 16'h0001;
			end else begin
				sr_data_trans_cnt[15:0]		<=		sr_wlen_max[15:0];
			end
		end else if( sr_wr_adr_state[3:0] == `WR_ADR_CHK
					&& M_AWREADY == 1'b1 && sr_awvalid == 1'b1 )begin
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

	// WR_ACC_FIFOリードイネーブル信号 //
	assign		s_wacc_fifo_rden			=		( sr_wr_dat_cycle == 1'b1 && sr_wr_dat_state[3:0] == `WR_DAT_INIT && WDAT_FIFO_EMPTY == 1'b0 && s_wacc_fifo_empty == 1'b0 ) ? 1'b1 : 1'b0;

	// データステータス保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wacc[4:0]		<=		5'b0_0000;
		end else if( sr_wr_dat_cycle == 1'b1
					&& sr_wr_dat_state[3:0] == `WR_DAT_INIT
					&& WDAT_FIFO_EMPTY == 1'b0
					&& s_wacc_fifo_empty == 1'b0 )begin
			sr_wacc[4:0]		<=		s_wacc_fifo_rdata[20:16];
		end
	end

	// WR_DATA_FIFOリードイネーブル信号 //
	assign		s_wr_dat_fifo_rden		=		( sr_wr_dat_state[3:0] == `WR_DAT_RD )                            ? 1'b1 :
												( sr_wr_dat_state[3:0] == `WR_DAT_CHK && WDAT_FIFO_EMPTY == 1'b0
													&& M_WREADY == 1'b1 && sr_wvalid == 1'b1 && sr_wlast == 1'b0
													&& sr_wcnt[3:0] == s_wcnt_max[3:0] && sr_wacc[4] == 1'b0
													&& sr_frame_cnt[15:0] != 16'h0000 )                           ? 1'b1 :
												( sr_wr_dat_state[3:0] == `WR_DAT_CHK && WDAT_FIFO_EMPTY == 1'b0
													&& M_WREADY == 1'b1 && sr_wvalid == 1'b1 && sr_wlast == 1'b0
													&& sr_wcnt[3:0] == s_wcnt_max[3:0] && sr_wacc[4] == 1'b1
													&& sr_frame_cnt[15:0] != 16'h0001 )                           ? 1'b1 :
												( sr_wr_dat_state[3:0] == `WR_DAT_CHK && WDAT_FIFO_EMPTY == 1'b0
													&& sr_wvalid == 1'b0 && sr_wcnt[3:0] == 4'b0000 )             ? 1'b1 : 1'b0;

	// フレームデータカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_frame_cnt[15:0]		<=		16'h0000;
		end else if( sr_wr_dat_cycle == 1'b1
					&& sr_wr_dat_state[3:0] == `WR_DAT_INIT
					&& WDAT_FIFO_EMPTY == 1'b0
					&& s_wacc_fifo_empty == 1'b0 )begin
			sr_frame_cnt[15:0]		<=		s_wacc_fifo_rdata[15:0];
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1 )begin
			sr_frame_cnt[15:0]		<=		sr_frame_cnt[15:0] - 16'h0001;
		end
	end

	// データカウントMAX信号 //
	assign		s_wcnt_max[3:0]			=		( M_DATA_BITS == 512 ) ? 4'b0000 :
												( M_DATA_BITS == 256 ) ? 4'b0001 :
												( M_DATA_BITS == 128 ) ? 4'b0011 :
												( M_DATA_BITS ==  64 ) ? 4'b0111 : 4'b1111;

	// データカウント信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wcnt[3:0]		<=		4'b0000;
		end else if( sr_wr_dat_cycle == 1'b1
					&& sr_wr_dat_state[3:0] == `WR_DAT_INIT )begin
			sr_wcnt[3:0]		<=		4'b0000;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK )begin
			if( M_WREADY == 1'b1 && sr_wvalid == 1'b1 )begin
				if( sr_wcnt[3:0] == s_wcnt_max[3:0] )begin
					sr_wcnt[3:0]		<=		4'b0000;
				end else begin
					sr_wcnt[3:0]		<=		sr_wcnt[3:0] + 4'b0001;
 				end
			end
		end
	end

	// データ有効信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wvalid		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wlast == 1'b1 )begin
			sr_wvalid		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] == s_wcnt_max[3:0]
					&& WDAT_FIFO_EMPTY == 1'b1
					&& sr_wacc[4] == 1'b0
					&& sr_frame_cnt[15:0] != 16'h0000 )begin
			sr_wvalid		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] == s_wcnt_max[3:0]
					&& WDAT_FIFO_EMPTY == 1'b1
					&& sr_wacc[4] == 1'b1
					&& sr_frame_cnt[15:0] != 16'h0001 )begin
			sr_wvalid		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& sr_wvalid == 1'b0
					&& sr_wcnt[3:0] == 4'b0000
					&& WDAT_FIFO_EMPTY == 1'b0 )begin
			sr_wvalid		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_RD )begin
			sr_wvalid		<=		1'b1;
		end
	end

	// ラストデータ信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wlast		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wlast == 1'b1 )begin
			sr_wlast		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] != s_wcnt_max[3:0]
					&& sr_frame_cnt[15:0] == 16'h0001 )begin
			sr_wlast		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] == s_wcnt_max[3:0]
					&& WDAT_FIFO_EMPTY == 1'b0 && sr_wacc[4] == 1'b0
					&& sr_frame_cnt[15:0] == 16'h0001 )begin
			sr_wlast		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] == s_wcnt_max[3:0]
					&& sr_wacc[4] == 1'b1
					&& sr_frame_cnt[15:0] == 16'h0001 )begin
			sr_wlast		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wvalid == 1'b1
					&& sr_wcnt[3:0] == 4'b0000
					&& WDAT_FIFO_EMPTY == 1'b0 && sr_wacc[4] == 1'b0
					&& sr_frame_cnt[15:0] == 16'h0001 )begin
			sr_wlast		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& sr_wvalid == 1'b0
					&& sr_wcnt[3:0] == 4'b0000
					&& WDAT_FIFO_EMPTY == 1'b0
					&& sr_frame_cnt[15:0] == 16'h0000 )begin
			sr_wlast		<=		1'b1;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_RD 
					&& sr_frame_cnt[15:0] == 16'h0000 )begin
			sr_wlast		<=		1'b1;
		end
	end

	// データ信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_RD )begin
			sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change0[M_DATA_BITS-1:0];
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK && sr_wcnt[3:0] == 4'b0000
					&& WDAT_FIFO_EMPTY == 1'b0 && sr_wvalid == 1'b0 )begin
			sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1[M_DATA_BITS-1:0];
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK )begin
			if( M_WREADY == 1'b1 && sr_wvalid == 1'b1 )begin
				if( sr_frame_cnt[15:0] == 16'h0000 )begin
					sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && WDAT_FIFO_EMPTY == 1'b0
							 && sr_frame_cnt[15:0] != 16'h0001 )begin
					sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1[M_DATA_BITS-1:0];
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && WDAT_FIFO_EMPTY == 1'b0
							&& sr_wacc[4] == 1'b0 && sr_frame_cnt[15:0] == 16'h0001 )begin
					sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1[M_DATA_BITS-1:0];
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && sr_wacc[4] == 1'b1
							&& sr_frame_cnt[15:0] == 16'h0001 )begin
					sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change2[M_DATA_BITS-1:0];
				end else begin
					if( M_DATA_BITS == 512 )begin
						sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
					end else if( M_DATA_BITS == 256 )begin
						case( sr_wcnt[0] )
							1'b0	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*2-1:M_DATA_BITS*1];
							default	:	sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
						endcase
					end else if( M_DATA_BITS == 128 )begin
						case( sr_wcnt[1:0] )
							2'b00	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*2-1:M_DATA_BITS*1];
							2'b01	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*3-1:M_DATA_BITS*2];
							2'b10	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*4-1:M_DATA_BITS*3];
							default	:	sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
						endcase
					end else if( M_DATA_BITS == 64 )begin
						case( sr_wcnt[2:0] )
							3'b000	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*2-1:M_DATA_BITS*1];
							3'b001	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*3-1:M_DATA_BITS*2];
							3'b010	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*4-1:M_DATA_BITS*3];
							3'b011	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*5-1:M_DATA_BITS*4];
							3'b100	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*6-1:M_DATA_BITS*5];
							3'b101	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*7-1:M_DATA_BITS*6];
							3'b110	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*8-1:M_DATA_BITS*7];
							default	:	sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
						endcase
					end else if( M_DATA_BITS == 32 )begin
						case( sr_wcnt[3:0] )
							4'b0000	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*2-1 :M_DATA_BITS*1];
							4'b0001	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*3-1 :M_DATA_BITS*2];
							4'b0010	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*4-1 :M_DATA_BITS*3];
							4'b0011	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*5-1 :M_DATA_BITS*4];
							4'b0100	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*6-1 :M_DATA_BITS*5];
							4'b0101	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*7-1 :M_DATA_BITS*6];
							4'b0110	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*8-1 :M_DATA_BITS*7];
							4'b0111	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*9-1 :M_DATA_BITS*8];
							4'b1000	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*10-1:M_DATA_BITS*9];
							4'b1001	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*11-1:M_DATA_BITS*10];
							4'b1010	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*12-1:M_DATA_BITS*11];
							4'b1011	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*13-1:M_DATA_BITS*12];
							4'b1100	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*14-1:M_DATA_BITS*13];
							4'b1101	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*15-1:M_DATA_BITS*14];
							4'b1110	:	sr_wdata[M_DATA_BITS-1:0]		<=		sr_wdata_change1_tmp[M_DATA_BITS*16-1:M_DATA_BITS*15];
							default	:	sr_wdata[M_DATA_BITS-1:0]		<=		{M_DATA_BITS{1'b0}};
						endcase
					end
				end
			end
		end
	end

	// データバイトイネーブル信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wstrb[M_DATA_BITS/8-1:0]		<=		{M_DATA_BITS/8{1'b0}};
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_RD )begin
			sr_wstrb[M_DATA_BITS/8-1:0]		<=		sr_wstrb_change0[M_DATA_BITS/8-1:0];
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK && sr_wcnt[3:0] == 4'b0000
					&& WDAT_FIFO_EMPTY == 1'b0 && sr_wvalid == 1'b0 )begin
			sr_wstrb[M_DATA_BITS/8-1:0]		<=		sr_wstrb_change1[M_DATA_BITS/8-1:0];
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK )begin
			if( M_WREADY == 1'b1 && sr_wvalid == 1'b1 )begin
				if( sr_frame_cnt[15:0] == 16'h0000 )begin
					sr_wstrb[M_DATA_BITS/8-1:0]		<=		{M_DATA_BITS/8{1'b0}};
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && WDAT_FIFO_EMPTY == 1'b0
							 && sr_frame_cnt[15:0] != 16'h0001 )begin
					sr_wstrb[M_DATA_BITS/8-1:0]		<=		sr_wstrb_change1[M_DATA_BITS/8-1:0];
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && WDAT_FIFO_EMPTY == 1'b0
							&& sr_wacc[4] == 1'b0 && sr_frame_cnt[15:0] == 16'h0001 )begin
					sr_wstrb[M_DATA_BITS/8-1:0]		<=		sr_wstrb_change1[M_DATA_BITS/8-1:0];
				end else if( sr_wcnt[3:0] == s_wcnt_max[3:0] && sr_wacc[4] == 1'b1
							&& sr_frame_cnt[15:0] == 16'h0001 )begin
					sr_wstrb[M_DATA_BITS/8-1:0]		<=		sr_wstrb_change2[M_DATA_BITS/8-1:0];
				end else begin
					if( M_DATA_BITS == 512 )begin
						sr_wstrb[M_DATA_BITS/8-1:0]		<=		{M_DATA_BITS/8{1'b0}};
					end else if( M_DATA_BITS == 256 )begin
						case( sr_wcnt[0] )
							1'b0	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*2-1:M_DATA_BITS/8*1];
							default	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		{M_DATA_BITS/8{1'b0}};
						endcase
					end else if( M_DATA_BITS == 128 )begin
						case( sr_wcnt[1:0] )
							2'b00	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*2-1:M_DATA_BITS/8*1];
							2'b01	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*3-1:M_DATA_BITS/8*2];
							2'b10	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*4-1:M_DATA_BITS/8*3];
							default	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		{M_DATA_BITS/8{1'b0}};
						endcase
					end else if( M_DATA_BITS == 64 )begin
						case( sr_wcnt[2:0] )
							3'b000	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*2-1:M_DATA_BITS/8*1];
							3'b001	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*3-1:M_DATA_BITS/8*2];
							3'b010	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*4-1:M_DATA_BITS/8*3];
							3'b011	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*5-1:M_DATA_BITS/8*4];
							3'b100	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*6-1:M_DATA_BITS/8*5];
							3'b101	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*7-1:M_DATA_BITS/8*6];
							3'b110	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*8-1:M_DATA_BITS/8*7];
							default	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		{M_DATA_BITS/8{1'b0}};
						endcase
					end else if( M_DATA_BITS == 32 )begin
						case( sr_wcnt[3:0] )
							4'b0000	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*2-1 :M_DATA_BITS/8*1];
							4'b0001	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*3-1 :M_DATA_BITS/8*2];
							4'b0010	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*4-1 :M_DATA_BITS/8*3];
							4'b0011	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*5-1 :M_DATA_BITS/8*4];
							4'b0100	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*6-1 :M_DATA_BITS/8*5];
							4'b0101	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*7-1 :M_DATA_BITS/8*6];
							4'b0110	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*8-1 :M_DATA_BITS/8*7];
							4'b0111	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*9-1 :M_DATA_BITS/8*8];
							4'b1000	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*10-1:M_DATA_BITS/8*9];
							4'b1001	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*11-1:M_DATA_BITS/8*10];
							4'b1010	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*12-1:M_DATA_BITS/8*11];
							4'b1011	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*13-1:M_DATA_BITS/8*12];
							4'b1100	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*14-1:M_DATA_BITS/8*13];
							4'b1101	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*15-1:M_DATA_BITS/8*14];
							4'b1110	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		sr_wstrb_change1_tmp[M_DATA_BITS/8*16-1:M_DATA_BITS/8*15];
							default	:	sr_wstrb[M_DATA_BITS/8-1:0]	<=		{M_DATA_BITS/8{1'b0}};
						endcase
					end
				end
			end
		end
	end


//------------------------------------------------------------------------------
// ライトデータ/ストローブ変換制御部
//------------------------------------------------------------------------------

	// データ変換信号 //
	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[479:0], 32'd0 };
				4'b0010	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[447:0], 64'd0 };
				4'b0011	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[415:0], 96'd0 };
				4'b0100	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[383:0], 128'd0 };
				4'b0101	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[351:0], 160'd0 };
				4'b0110	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[319:0], 192'd0 };
				4'b0111	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[287:0], 224'd0 };
				4'b1000	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[255:0], 256'd0 };
				4'b1001	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[223:0], 288'd0 };
				4'b1010	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[191:0], 320'd0 };
				4'b1011	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[159:0], 352'd0 };
				4'b1100	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[127:0], 384'd0 };
				4'b1101	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[95:0],  416'd0 };
				4'b1110	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[63:0],  448'd0 };
				4'b1111	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[31:0],  480'd0 };
				default	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[479:0], 32'd0 };
				4'b0010	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[447:0], 64'd0 };
				4'b0011	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[415:0], 96'd0 };
				4'b0100	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[383:0], 128'd0 };
				4'b0101	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[351:0], 160'd0 };
				4'b0110	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[319:0], 192'd0 };
				4'b0111	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[287:0], 224'd0 };
				default	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[479:0], 32'd0 };
				4'b0010	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[447:0], 64'd0 };
				4'b0011	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[415:0], 96'd0 };
				default	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[479:0], 32'd0 };
				default	:	sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else begin
			sr_wdata_change0[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change0[63:0], WDAT_FIFO_RDATA[511:0] };
		end
	end

	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[479:0], sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[447:0], sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[415:0], sr_wdata_change[511:416] };
				4'b0100	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[383:0], sr_wdata_change[511:384] };
				4'b0101	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[351:0], sr_wdata_change[511:352] };
				4'b0110	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[319:0], sr_wdata_change[511:320] };
				4'b0111	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[287:0], sr_wdata_change[511:288] };
				4'b1000	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[255:0], sr_wdata_change[511:256] };
				4'b1001	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[223:0], sr_wdata_change[511:224] };
				4'b1010	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[191:0], sr_wdata_change[511:192] };
				4'b1011	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[159:0], sr_wdata_change[511:160] };
				4'b1100	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[127:0], sr_wdata_change[511:128] };
				4'b1101	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[95:0],  sr_wdata_change[511:96] };
				4'b1110	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[63:0],  sr_wdata_change[511:64] };
				4'b1111	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[31:0],  sr_wdata_change[511:32] };
				default	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[479:0], sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[447:0], sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[415:0], sr_wdata_change[511:416] };
				4'b0100	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[383:0], sr_wdata_change[511:384] };
				4'b0101	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[351:0], sr_wdata_change[511:352] };
				4'b0110	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[319:0], sr_wdata_change[511:320] };
				4'b0111	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[287:0], sr_wdata_change[511:288] };
				default	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[479:0], sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[447:0], sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[415:0], sr_wdata_change[511:416] };
				default	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[479:0], sr_wdata_change[511:480] };
				default	:	sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else begin
			sr_wdata_change1[577:0]	<=	{ WDAT_FIFO_RDATA[577:576], sr_wstrb_change1[63:0], WDAT_FIFO_RDATA[511:0] };
		end
	end

	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 480'd0, sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 448'd0, sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 416'd0, sr_wdata_change[511:416] };
				4'b0100	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 384'd0, sr_wdata_change[511:384] };
				4'b0101	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 352'd0, sr_wdata_change[511:352] };
				4'b0110	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 320'd0, sr_wdata_change[511:320] };
				4'b0111	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 288'd0, sr_wdata_change[511:288] };
				4'b1000	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 256'd0, sr_wdata_change[511:256] };
				4'b1001	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 224'd0, sr_wdata_change[511:224] };
				4'b1010	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 192'd0, sr_wdata_change[511:192] };
				4'b1011	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 160'd0, sr_wdata_change[511:160] };
				4'b1100	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 128'd0, sr_wdata_change[511:128] };
				4'b1101	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 96'd0,  sr_wdata_change[511:96] };
				4'b1110	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 64'd0,  sr_wdata_change[511:64] };
				4'b1111	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 32'd0,  sr_wdata_change[511:32] };
				default	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 480'd0, sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 448'd0, sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 416'd0, sr_wdata_change[511:416] };
				4'b0100	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 384'd0, sr_wdata_change[511:384] };
				4'b0101	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 352'd0, sr_wdata_change[511:352] };
				4'b0110	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 320'd0, sr_wdata_change[511:320] };
				4'b0111	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 288'd0, sr_wdata_change[511:288] };
				default	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 480'd0, sr_wdata_change[511:480] };
				4'b0010	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 448'd0, sr_wdata_change[511:448] };
				4'b0011	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 416'd0, sr_wdata_change[511:416] };
				default	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], 480'd0, sr_wdata_change[511:480] };
				default	:	sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], WDAT_FIFO_RDATA[511:0] };
			endcase
		end else begin
			sr_wdata_change2[577:0]	<=	{ 2'b01, sr_wstrb_change2[63:0], WDAT_FIFO_RDATA[511:0] };
		end
	end

	// データ変換保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wdata_change[511:0]			<=		512'd0;
			sr_wdata_change1_tmp[511:0]		<=		512'd0;
		end else if( s_wr_dat_fifo_rden == 1'b1 )begin
			sr_wdata_change[511:0]			<=		WDAT_FIFO_RDATA[511:0];
			sr_wdata_change1_tmp[511:0]		<=		sr_wdata_change1[511:0];
		end
	end

	// データイネーブル変換信号 //
	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[571:512],  4'd0 };
				4'b0010	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[567:512],  8'd0 };
				4'b0011	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], 12'd0 };
				4'b0100	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[559:512], 16'd0 };
				4'b0101	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[555:512], 20'd0 };
				4'b0110	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[551:512], 24'd0 };
				4'b0111	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[547:512], 28'd0 };
				4'b1000	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[543:512], 32'd0 };
				4'b1001	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[539:512], 36'd0 };
				4'b1010	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[535:512], 40'd0 };
				4'b1011	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[531:512], 44'd0 };
				4'b1100	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[527:512], 48'd0 };
				4'b1101	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[523:512], 52'd0 };
				4'b1110	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[519:512], 56'd0 };
				4'b1111	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[515:512], 60'd0 };
				default	:	sr_wstrb_change0[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[571:512],  4'd0 };
				4'b0010	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[567:512],  8'd0 };
				4'b0011	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], 12'd0 };
				4'b0100	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[559:512], 16'd0 };
				4'b0101	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[555:512], 20'd0 };
				4'b0110	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[551:512], 24'd0 };
				4'b0111	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[547:512], 28'd0 };
				default	:	sr_wstrb_change0[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[571:512],  4'd0 };
				4'b0010	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[567:512],  8'd0 };
				4'b0011	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], 12'd0 };
				default	:	sr_wstrb_change0[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change0[63:0]	<=	{ WDAT_FIFO_RDATA[571:512],  4'd0 };
				default	:	sr_wstrb_change0[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else begin
			sr_wstrb_change0[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
		end
	end

	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[571:512], sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[567:512], sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], sr_wstrb_change[63:52] };
				4'b0100	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[559:512], sr_wstrb_change[63:48] };
				4'b0101	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[555:512], sr_wstrb_change[63:44] };
				4'b0110	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[551:512], sr_wstrb_change[63:40] };
				4'b0111	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[547:512], sr_wstrb_change[63:36] };
				4'b1000	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[543:512], sr_wstrb_change[63:32] };
				4'b1001	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[539:512], sr_wstrb_change[63:28] };
				4'b1010	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[535:512], sr_wstrb_change[63:24] };
				4'b1011	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[531:512], sr_wstrb_change[63:20] };
				4'b1100	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[527:512], sr_wstrb_change[63:16] };
				4'b1101	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[523:512], sr_wstrb_change[63:12] };
				4'b1110	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[519:512], sr_wstrb_change[63:8] };
				4'b1111	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[515:512], sr_wstrb_change[63:4] };
				default	:	sr_wstrb_change1[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[571:512], sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[567:512], sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], sr_wstrb_change[63:52] };
				4'b0100	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[559:512], sr_wstrb_change[63:48] };
				4'b0101	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[555:512], sr_wstrb_change[63:44] };
				4'b0110	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[551:512], sr_wstrb_change[63:40] };
				4'b0111	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[547:512], sr_wstrb_change[63:36] };
				default	:	sr_wstrb_change1[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[571:512], sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[567:512], sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[563:512], sr_wstrb_change[63:52] };
				default	:	sr_wstrb_change1[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change1[63:0]	<=	{ WDAT_FIFO_RDATA[571:512], sr_wstrb_change[63:60] };
				default	:	sr_wstrb_change1[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else begin
			sr_wstrb_change1[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
		end
	end

	always@( * )begin
		if( M_DATA_BITS == 512 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change2[63:0]	<=	{ 60'd0, sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change2[63:0]	<=	{ 56'd0, sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change2[63:0]	<=	{ 52'd0, sr_wstrb_change[63:52] };
				4'b0100	:	sr_wstrb_change2[63:0]	<=	{ 48'd0, sr_wstrb_change[63:48] };
				4'b0101	:	sr_wstrb_change2[63:0]	<=	{ 44'd0, sr_wstrb_change[63:44] };
				4'b0110	:	sr_wstrb_change2[63:0]	<=	{ 40'd0, sr_wstrb_change[63:40] };
				4'b0111	:	sr_wstrb_change2[63:0]	<=	{ 36'd0, sr_wstrb_change[63:36] };
				4'b1000	:	sr_wstrb_change2[63:0]	<=	{ 32'd0, sr_wstrb_change[63:32] };
				4'b1001	:	sr_wstrb_change2[63:0]	<=	{ 28'd0, sr_wstrb_change[63:28] };
				4'b1010	:	sr_wstrb_change2[63:0]	<=	{ 24'd0, sr_wstrb_change[63:24] };
				4'b1011	:	sr_wstrb_change2[63:0]	<=	{ 20'd0, sr_wstrb_change[63:20] };
				4'b1100	:	sr_wstrb_change2[63:0]	<=	{ 16'd0, sr_wstrb_change[63:16] };
				4'b1101	:	sr_wstrb_change2[63:0]	<=	{ 12'd0, sr_wstrb_change[63:12] };
				4'b1110	:	sr_wstrb_change2[63:0]	<=	{ 8'd0,  sr_wstrb_change[63:8] };
				4'b1111	:	sr_wstrb_change2[63:0]	<=	{ 4'd0,  sr_wstrb_change[63:4] };
				default	:	sr_wstrb_change2[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 256 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change2[63:0]	<=	{ 60'd0, sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change2[63:0]	<=	{ 56'd0, sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change2[63:0]	<=	{ 52'd0, sr_wstrb_change[63:52] };
				4'b0100	:	sr_wstrb_change2[63:0]	<=	{ 48'd0, sr_wstrb_change[63:48] };
				4'b0101	:	sr_wstrb_change2[63:0]	<=	{ 44'd0, sr_wstrb_change[63:44] };
				4'b0110	:	sr_wstrb_change2[63:0]	<=	{ 40'd0, sr_wstrb_change[63:40] };
				4'b0111	:	sr_wstrb_change2[63:0]	<=	{ 36'd0, sr_wstrb_change[63:36] };
				default	:	sr_wstrb_change2[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 128 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change2[63:0]	<=	{ 60'd0, sr_wstrb_change[63:60] };
				4'b0010	:	sr_wstrb_change2[63:0]	<=	{ 56'd0, sr_wstrb_change[63:56] };
				4'b0011	:	sr_wstrb_change2[63:0]	<=	{ 52'd0, sr_wstrb_change[63:52] };
				default	:	sr_wstrb_change2[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else if( M_DATA_BITS == 64 )begin
			case( sr_wacc[3:0] )
				4'b0001	:	sr_wstrb_change2[63:0]	<=	{ 60'd0, sr_wstrb_change[63:60] };
				default	:	sr_wstrb_change2[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
			endcase
		end else begin
			sr_wstrb_change2[63:0]	<=	  WDAT_FIFO_RDATA[575:512];
		end
	end

	// データイネーブル変換保持信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_wstrb_change[63:0]			<=		64'd0;
			sr_wstrb_change1_tmp[63:0]		<=		64'd0;
		end else if( s_wr_dat_fifo_rden == 1'b1 )begin
			sr_wstrb_change[63:0]			<=		WDAT_FIFO_RDATA[575:512];
			sr_wstrb_change1_tmp[63:0]		<=		sr_wstrb_change1[63:0];
		end
	end


//------------------------------------------------------------------------------
// BIDフェーズ制御部
//------------------------------------------------------------------------------

	// BIDレディ信号 //
	always@( posedge M_CLK or negedge M_RESET_N )begin
		if( M_RESET_N == 1'b0 )begin
			sr_bready		<=		1'b0;
		end else if( M_BVALID == 1'b1 && sr_bready == 1'b1 )begin
			sr_bready		<=		1'b0;
		end else if( sr_wr_dat_state[3:0] == `WR_DAT_CHK
					&& M_WREADY == 1'b1 && sr_wlast == 1'b1
					&& sr_wvalid == 1'b1 )begin
			sr_bready		<=		1'b1;
		end
	end



endmodule

