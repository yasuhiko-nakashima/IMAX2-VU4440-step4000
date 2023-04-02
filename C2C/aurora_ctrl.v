//------------------------------------------------------------------------------
// AURORA CTRL MODEL
//------------------------------------------------------------------------------
// AURORA CTRL モジュール
// (1) AURORA制御処理
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : aurora_ctrl.v
// Module         : AURORA_CTRL
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module AURORA_CTRL # (
					parameter	A_LANE_BITS		=	4,		// 
					parameter	A_DATA_BITS		=	64,		// 
					parameter	LEN_WORD		=	8,		// 
					parameter	LEN_CNT_BIT		=	3,		// 
					parameter	BUFF_WORD		=	8,		// 
					parameter	BUFF_CNT_BIT	=	3		// 
				) (
					AURORA_CLK,								// 
					AURORA_RESET_N,							// 

					FRAME_ERR,								// 
					HARD_ERR,								// 
					SOFT_ERR,								// 
					CH_UP,									// 
					LANE_UP,								// 
					LINK_UP,								// 

					TX_TDATA,								// 
					TX_TLAST,								// 
					TX_TKEEP,								// 
					TX_TVALID,								// 
					TX_TREADY,								// 
					RX_TDATA,								// 
					RX_TLAST,								// 
					RX_TKEEP,								// 
					RX_TVALID,								// 

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
					M_RDAT_FIFO_RDATA,						// 

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
                    S_RDAT_FIFO_WDATA,						// 

					TX_PROBE0,								// 
					TX_PROBE1,								// 
					TX_PROBE2,								// 
					TX_PROBE3,								// 
					TX_PROBE4								// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input							AURORA_CLK;				// 
	input							AURORA_RESET_N;			// 

	input							FRAME_ERR;				// 
	input							HARD_ERR;				// 
	input							SOFT_ERR;				// 
	input							CH_UP;					// 
	input	[A_LANE_BITS-1:0]		LANE_UP;				// 
	output							LINK_UP;				// 

	output	[A_DATA_BITS-1:0]		TX_TDATA;				// 
	output							TX_TLAST;				// 
	output	[A_DATA_BITS/8-1:0]		TX_TKEEP;				// 
	output							TX_TVALID;				// 
	input							TX_TREADY;				// 
	input	[A_DATA_BITS-1:0]		RX_TDATA;				// 
	input							RX_TLAST;				// 
	input	[A_DATA_BITS/8-1:0]		RX_TKEEP;				// 
	input							RX_TVALID;				// 

	input							M_WADR_FIFO_FULL;		// 
	output							M_WADR_FIFO_WREN;		// 
	output	[127:0]					M_WADR_FIFO_WDATA;		// 
	input							M_WDAT_FIFO_FULL;		// 
	output							M_WDAT_FIFO_WREN;		// 
	output	[577:0]					M_WDAT_FIFO_WDATA;		// 

	input							M_RADR_FIFO_FULL;		// 
	output							M_RADR_FIFO_WREN;		// 
	output	[127:0]					M_RADR_FIFO_WDATA;		// 
	input							M_RDAT_FIFO_EMPTY;		// 
	output							M_RDAT_FIFO_RDEN;		// 
	input	[577:0]					M_RDAT_FIFO_RDATA;		// 

	input							S_WADR_FIFO_EMPTY;		// 
	output							S_WADR_FIFO_RDEN;		// 
	input	[127:0]					S_WADR_FIFO_RDATA;		// 
	input							S_WDAT_FIFO_EMPTY;		// 
	output							S_WDAT_FIFO_RDEN;		// 
	input	[577:0]					S_WDAT_FIFO_RDATA;		// 

	input							S_RADR_FIFO_EMPTY;		// 
	output							S_RADR_FIFO_RDEN;		// 
	input	[127:0]					S_RADR_FIFO_RDATA;		// 
	input							S_RDAT_FIFO_FULL;		// 
	output							S_RDAT_FIFO_WREN;		// 
	output	[577:0]					S_RDAT_FIFO_WDATA;		// 

	output	[6:0]					TX_PROBE0;				// 
	output	[63:0]					TX_PROBE1;				// 
	output	[511:0]					TX_PROBE2;				// 
	output	[63:0]					TX_PROBE3;				// 
	output	[511:0]					TX_PROBE4;				// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire							s_wr_len_wren;			// 
	wire	[15:0]					s_wr_len_wdata;			// 
	wire							s_wr_len_rden;			// 
	wire	[15:0]					s_wr_len_rdata;			// 
	wire	[LEN_CNT_BIT:0]			s_wr_len_cnt;			// 
	wire							s_rd_len_wren;			// 
	wire	[15:0]					s_rd_len_wdata;			// 
	wire							s_rd_len_rden;			// 
	wire	[15:0]					s_rd_len_rdata;			// 
	wire	[LEN_CNT_BIT:0]			s_rd_len_cnt;			// 
	wire							s_rx_buff_wren;			// 
	wire	[577:0]					s_rx_buff_wdata;		// 
	wire							s_rx_buff_rden;			// 
	wire	[577:0]					s_rx_buff_rdata;		// 
	wire	[BUFF_CNT_BIT:0]		s_rx_buff_cnt;			// 
	wire							s_fifo_empty;			// 
	wire	[577:0]					s_fifo_rdat;			// 
	wire							s_fifo_rden;			// 
	wire	[4:0]					s_tx_cnt_max;			// 
	wire							s_tx_tready;			// 
	wire	[511:0]					s_cmd_data;				// 
	wire	[511:0]					s_tx_data;				// 
	wire	[7:0]					s_s_req_in;				// 
	wire	[7:0]					s_s_req;				// 
	wire							s_axi_last;				// 
	wire	[4:0]					s_rx_cnt_max;			// 
	wire	[511:0]					s_rx_data;				// 
	wire	[8:0]					s_rx_buff_chk;			// 
	wire	[8:0]					s_rx_buff_cnt_hi;		// 
	wire	[8:0]					s_rx_buff_cnt_low;		// 
	wire							s_fifo_wren;			// 
	wire							s_fifo_wren_f;			// 
	wire	[577:0]					s_fifo_wdata;			// 
	wire	[2:0]					s_wr_sel;				// 
	wire							s_fifo_full;			// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	reg								sr_error;				// 
	reg								sr_aurora_ok;			// 
	reg		[4:0]					sr_tx_cnt;				// 
	reg								sr_tx_wait;				// 
	reg		[511:0]					sr_tx_data;				// 
	reg		[511:0]					sr_tx_data_tmp;			// 
	reg								sr_tx_data_last_flag;	// 
	reg								sr_tx_last_flag;		// 
	reg								sr_tx_last_flag_f;		// 
	reg		[3:0]					sr_tx_data_sel;			// 
	reg		[A_DATA_BITS-1:0]		sr_tx_tdata;			// 
	reg								sr_tx_tvalid;			// 
	reg								sr_tx_tlast;			// 
	reg		[A_DATA_BITS/8-1:0]		sr_tx_tkeep;			// 
	reg		[4:0]					sr_tx_state;			// 
	reg		[2:0]					sr_rd_sel;				// 
	reg		[A_DATA_BITS-1:0]		sr_rx_tdata;			// 
	reg		[A_DATA_BITS/8-1:0]		sr_rx_tkeep;			// 
	reg								sr_rx_tlast;			// 
	reg								sr_rx_tvalid;			// 
	reg		[511:0]					sr_rx_buff_wdata;		// 
	reg		[15:0]					sr_rx_data_cnt_max;		// 
	reg		[15:0]					sr_rx_data_cnt;			// 
	reg		[3:0]					sr_rx_data_sel;			// 
	reg								sr_rx_data_flag;		// 
	reg								sr_rx_data_frame;		// 
	reg								sr_rx_data_wait;		// 
	reg		[4:0]					sr_rx_cnt;				// 
	reg		[511:0]					sr_rx_data;				// 
	reg								sr_rx_req_st;			// 
	reg								sr_rx_req_st_f;			// 
	reg								sr_rx_req_end;			// 
	reg								sr_rx_wr_cycle;			// 
	reg								sr_rx_rd_cycle;			// 


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
	`define 	TX_INIT				5'b00000				// INITステート
	`define 	TX_CMD_RD			5'b00001				// コマンドリードステート
	`define 	TX_CMD_CHK			5'b00010				// コマンドチェックステート
	`define 	TX_DATA_RD			5'b00011				// データリードステート
	`define 	TX_DATA_CHK			5'b00100				// データチェックステート
	`define 	TX_DATA_WAIT		5'b00101				// データウエイトステート
	`define 	TX_REST				5'b00110				// データ再スタートステート
	`define 	TX_REST_CHK			5'b00111				// データ再スタートチェックステート
	`define 	TX_BUFF_ST			5'b01000				// 受信バッファ状態開始ステート
	`define 	TX_BUFF_END			5'b01001				// 受信バッファ状態終了ステート
	`define 	TX_BUFF_CHK			5'b01010				// 受信バッファ状態チェックステート
	`define 	TX_END				5'b01011				// 終了ステート


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------

BUFF_16BXNW # (
					.BUFF_WORD				(LEN_WORD),
					.CNT_BIT				(LEN_CNT_BIT)
				) inst_wr_len_buff (
					.RST_N					(AURORA_RESET_N),
					.CLK					(AURORA_CLK),
					.WREN					(s_wr_len_wren),
					.WDATA					(s_wr_len_wdata[15:0]),
					.RDEN					(s_wr_len_rden),
					.RDATA					(s_wr_len_rdata[15:0]),
					.CNT					(s_wr_len_cnt[LEN_CNT_BIT:0])
	);

BUFF_16BXNW # (
					.BUFF_WORD				(LEN_WORD),
					.CNT_BIT				(LEN_CNT_BIT)
				) inst_rd_len_buff (
					.RST_N					(AURORA_RESET_N),
					.CLK					(AURORA_CLK),
					.WREN					(s_rd_len_wren),
					.WDATA					(s_rd_len_wdata[15:0]),
					.RDEN					(s_rd_len_rden),
					.RDATA					(s_rd_len_rdata[15:0]),
					.CNT					(s_rd_len_cnt[LEN_CNT_BIT:0])
	);

BUFF_578BXNW # (
					.BUFF_WORD				(BUFF_WORD),
					.CNT_BIT				(BUFF_CNT_BIT)
				) inst_rx_buff (
					.RST_N					(AURORA_RESET_N),
					.CLK					(AURORA_CLK),
					.WREN					(s_rx_buff_wren),
					.WDATA					(s_rx_buff_wdata[577:0]),
					.RDEN					(s_rx_buff_rden),
					.RDATA					(s_rx_buff_rdata[577:0]),
					.CNT					(s_rx_buff_cnt[BUFF_CNT_BIT:0])
	);


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------

	assign		TX_TDATA[A_DATA_BITS-1:0]	=		sr_tx_tdata[A_DATA_BITS-1:0];
	assign		TX_TLAST					=		sr_tx_tlast;
	assign		TX_TKEEP[A_DATA_BITS/8-1:0]	=		sr_tx_tkeep[A_DATA_BITS/8-1:0];
	assign		TX_TVALID					=		sr_tx_tvalid;

	assign		M_WADR_FIFO_WREN			=		( s_wr_sel[2:0] == 3'b000  && s_fifo_wren == 1'b1 ) ? 1'b1 : 1'b0;
	assign		M_WADR_FIFO_WDATA[127:0]	=		s_fifo_wdata[127:0];
	assign		M_WDAT_FIFO_WREN			=		( s_wr_sel[2:0] == 3'b010  && s_fifo_wren == 1'b1 ) ? 1'b1 : 1'b0;
	assign		M_WDAT_FIFO_WDATA[577:0]	=		s_fifo_wdata[577:0];

	assign		M_RADR_FIFO_WREN			=		( s_wr_sel[2:0] == 3'b001  && s_fifo_wren == 1'b1 ) ? 1'b1 : 1'b0;
	assign		M_RADR_FIFO_WDATA[127:0]	=		s_fifo_wdata[127:0];
	assign		M_RDAT_FIFO_RDEN			=		( sr_rd_sel[2:0] == 3'b011 && s_fifo_rden == 1'b1 )  ? 1'b1 : 1'b0;

	assign		S_WADR_FIFO_RDEN			=		( sr_rd_sel[2:0] == 3'b000 && s_fifo_rden == 1'b1 )  ? 1'b1 : 1'b0;
	assign		S_WDAT_FIFO_RDEN			=		( sr_rd_sel[2:0] == 3'b010 && s_fifo_rden == 1'b1 )  ? 1'b1 : 1'b0;

	assign		S_RADR_FIFO_RDEN			=		( sr_rd_sel[2:0] == 3'b001 && s_fifo_rden == 1'b1 )  ? 1'b1 : 1'b0;
	assign		S_RDAT_FIFO_WREN			=		( s_wr_sel[2:0] == 3'b011  && s_fifo_wren == 1'b1 )  ? 1'b1 : 1'b0;
	assign		S_RDAT_FIFO_WDATA[577:0]	=		s_fifo_wdata[577:0];

	assign		LINK_UP						=		sr_aurora_ok;

	assign		TX_PROBE0[6:0]				=		{ sr_rx_tlast, sr_rx_tvalid, sr_tx_tlast, sr_tx_tvalid, TX_TREADY, s_rx_buff_cnt[BUFF_CNT_BIT], sr_tx_wait };
	assign		TX_PROBE1[63:0]				=		sr_tx_tkeep[A_DATA_BITS/8-1:0];
	assign		TX_PROBE2[511:0]			=		sr_tx_tdata[A_DATA_BITS-1:0];
	assign		TX_PROBE3[63:0]				=		sr_rx_tkeep[A_DATA_BITS/8-1:0];
	assign		TX_PROBE4[511:0]			=		sr_rx_tdata[A_DATA_BITS-1:0];


//------------------------------------------------------------------------------
// エラー制御部
//------------------------------------------------------------------------------

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_error		<=		1'b0;
		end else if( FRAME_ERR == 1'b1 || HARD_ERR == 1'b1 || SOFT_ERR == 1'b1 )begin
			sr_error		<=		1'b1;
		end else begin
			sr_error		<=		1'b0;
		end
	end


	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_aurora_ok		<=		1'b0;
		end else if( CH_UP == 1'b1 && LANE_UP[A_LANE_BITS-1:0] == {A_LANE_BITS{1'b1}} )begin
			sr_aurora_ok		<=		1'b1;
		end else begin
			sr_aurora_ok		<=		1'b0;
		end
	end


//------------------------------------------------------------------------------
// 送信制御部
//------------------------------------------------------------------------------

	// BUFFリード信号 //
	assign		s_wr_len_rden				=		( sr_tx_state[4:0] == `TX_CMD_RD && s_fifo_empty == 1'b0 && sr_rd_sel[2:0] == 3'b010 ) ? 1'b1 : 1'b0;

	assign		s_rd_len_rden				=		( sr_tx_state[4:0] == `TX_CMD_RD && s_fifo_empty == 1'b0 && sr_rd_sel[2:0] == 3'b011 ) ? 1'b1 : 1'b0;

	// BUFFライト信号 //
	assign		s_wr_len_wren				=		( sr_tx_state[4:0] == `TX_CMD_RD && s_fifo_empty == 1'b0 && sr_rd_sel[2:0] == 3'b000 ) ? 1'b1 : 1'b0;

	// BUFFライトデータ信号 //
	assign		s_wr_len_wdata[15:0]		=		( s_fifo_rdat[114:112] == 3'b110 ) ?         s_fifo_rdat[95:80]   :
													( s_fifo_rdat[114:112] == 3'b101 ) ? { 1'd0, s_fifo_rdat[95:81] } :
													( s_fifo_rdat[114:112] == 3'b100 ) ? { 2'd0, s_fifo_rdat[95:82] } :
													( s_fifo_rdat[114:112] == 3'b011 ) ? { 3'd0, s_fifo_rdat[95:83] } :
													( s_fifo_rdat[114:112] == 3'b010 ) ? { 4'd0, s_fifo_rdat[95:84] } : 16'h0000;

	// EMPTY信号選択 //
	assign		s_fifo_empty				=		( sr_rd_sel[2:0] == 3'b000 ) ? S_WADR_FIFO_EMPTY :
													( sr_rd_sel[2:0] == 3'b001 ) ? S_RADR_FIFO_EMPTY :
													( sr_rd_sel[2:0] == 3'b010 ) ? S_WDAT_FIFO_EMPTY :
													( sr_rd_sel[2:0] == 3'b011 ) ? M_RDAT_FIFO_EMPTY :
													( sr_rd_sel[2:0] == 3'b100 ) ? 1'b0              :
													( sr_rd_sel[2:0] == 3'b101 ) ? 1'b0              : 1'b1;

	// リードデータ信号選択 //
	assign		s_fifo_rdat[577:0]			=		( sr_rd_sel[2:0] == 3'b000 ) ? { 450'd0, S_WADR_FIFO_RDATA[127:0] } :
													( sr_rd_sel[2:0] == 3'b001 ) ? { 450'd0, S_RADR_FIFO_RDATA[127:0] } :
													( sr_rd_sel[2:0] == 3'b010 ) ? S_WDAT_FIFO_RDATA[577:0]             :
													( sr_rd_sel[2:0] == 3'b011 ) ? M_RDAT_FIFO_RDATA[577:0]             : 578'd0;

	// FIFOリード信号 //
	assign		s_fifo_rden					=		( sr_tx_state[4:0] == `TX_CMD_RD && s_fifo_empty == 1'b0
														&& ( sr_rd_sel[2:0] == 3'b000 || sr_rd_sel[2:0] == 3'b001 ))                      ? 1'b1 :
													( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )                           ? 1'b1 :
													( sr_tx_state[4:0] == `TX_DATA_CHK && sr_tx_tvalid == 1'b0
														&& sr_tx_cnt[4:0] == 5'b0_0000 && sr_tx_data_sel[3:0] != 4'b0111
														&& sr_tx_last_flag == 1'b0 && sr_tx_last_flag_f == 1'b0 && s_fifo_empty == 1'b0 ) ? 1'b1 :
													( sr_tx_state[4:0] == `TX_DATA_CHK && sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
														&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] && sr_tx_data_sel[3:0] != 4'b0111
														&& sr_tx_last_flag == 1'b0 && sr_tx_last_flag_f == 1'b0 && s_fifo_empty == 1'b0 ) ? 1'b1 : 1'b0;

	// 送信カウントMAX信号 //
	assign		s_tx_cnt_max[4:0]			=		( A_DATA_BITS == 512 ) ? 5'b0_0000 :
													( A_DATA_BITS == 256 ) ? 5'b0_0001 :
													( A_DATA_BITS == 192 ) ? 5'b0_0010 :
													( A_DATA_BITS == 128 ) ? 5'b0_0011 :
													( A_DATA_BITS ==  64 ) ? 5'b0_0111 :
													( A_DATA_BITS ==  48 ) ? 5'b0_1010 :
													( A_DATA_BITS ==  32 ) ? 5'b0_1111 : 5'b1_1111;

	// 送信カウント信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_cnt[4:0]		<=		5'b0_0000;
		end else if( sr_tx_state[4:0] == `TX_CMD_RD
					|| sr_tx_state[4:0] == `TX_DATA_RD
					|| sr_tx_state[4:0] == `TX_REST
					|| sr_tx_state[4:0] == `TX_BUFF_ST
					|| sr_tx_state[4:0] == `TX_BUFF_END )begin
			sr_tx_cnt[4:0]		<=		5'b0_0000;
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK
					|| sr_tx_state[4:0] == `TX_DATA_CHK
					|| sr_tx_state[4:0] == `TX_REST_CHK
					|| sr_tx_state[4:0] == `TX_BUFF_CHK )
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1 )begin
			if( sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
				sr_tx_cnt[4:0]		<=		5'b0_0000;
			end else begin
				sr_tx_cnt[4:0]		<=		sr_tx_cnt[4:0] + 5'b0_0001;
			end
		end
	end

	// 送信ウエイト信号 //
	assign		s_tx_tready					=		( TX_TREADY == 1'b1 ) ? 1'b1 : 1'b0;

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_wait		<=		1'b0;
		end else if(( sr_rx_data_frame == 1'b0
						|| (  sr_rx_data_frame == 1'b1 && sr_rx_data_wait == 1'b1 ))
					&& sr_rx_tvalid == 1'b1 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}} )begin
			if( s_rx_data[511:509] == 3'b101 )begin
				sr_tx_wait		<=		1'b0;
			end else if( s_rx_data[511:509] == 3'b100 )begin
				sr_tx_wait		<=		1'b1;
			end
		end
	end

	// 送信データ選択信号 //
	assign		s_cmd_data[511:0]			=		( sr_tx_state[4:0] == `TX_BUFF_ST )  ? { 3'b100, 509'd0 }                              :
													( sr_tx_state[4:0] == `TX_BUFF_END ) ? { 3'b101, 509'd0 }                              :
													( sr_tx_state[4:0] == `TX_REST )     ? { 3'b110, 509'd0 }                              :
													( sr_rd_sel[2:0] == 3'b000 )         ? { 3'b000, s_fifo_rdat[508:0] }                  :
													( sr_rd_sel[2:0] == 3'b001 )         ? { 3'b001, s_fifo_rdat[508:0] }                  :
													( sr_rd_sel[2:0] == 3'b010 )         ? { 3'b010, 413'd0, s_wr_len_rdata[15:0], 80'd0 } :
													( sr_rd_sel[2:0] == 3'b011 )         ? { 3'b011, 413'd0, s_rd_len_rdata[15:0], 80'd0 } :
													( sr_rd_sel[2:0] == 3'b100 )         ? { 3'b100, 509'd0 }                              :
													( sr_rd_sel[2:0] == 3'b101 )         ? { 3'b101, 509'd0 }                              : 512'd0;

	assign		s_tx_data[511:0]			=		( sr_tx_data_sel[3:0] == 5'b0000 ) ? { s_fifo_rdat[447:0], sr_tx_data_tmp[63:0] }  :
													( sr_tx_data_sel[3:0] == 5'b0001 ) ? { s_fifo_rdat[383:0], sr_tx_data_tmp[127:0] } :
													( sr_tx_data_sel[3:0] == 5'b0010 ) ? { s_fifo_rdat[319:0], sr_tx_data_tmp[191:0] } :
													( sr_tx_data_sel[3:0] == 5'b0011 ) ? { s_fifo_rdat[255:0], sr_tx_data_tmp[255:0] } :
													( sr_tx_data_sel[3:0] == 5'b0100 ) ? { s_fifo_rdat[191:0], sr_tx_data_tmp[319:0] } :
													( sr_tx_data_sel[3:0] == 5'b0101 ) ? { s_fifo_rdat[127:0], sr_tx_data_tmp[383:0] } :
													( sr_tx_data_sel[3:0] == 5'b0110 ) ? { s_fifo_rdat[63:0],  sr_tx_data_tmp[447:0] } :
													( sr_tx_data_sel[3:0] == 5'b0111 ) ? {                     sr_tx_data_tmp[511:0] } : s_fifo_rdat[511:0];


	// 送信データ保持信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_data[511:0]		<=		512'd0;
		end else if( sr_tx_state[4:0] == `TX_CMD_RD
					|| sr_tx_state[4:0] == `TX_REST
					|| sr_tx_state[4:0] == `TX_BUFF_ST
					|| sr_tx_state[4:0] == `TX_BUFF_END )begin
			sr_tx_data[511:0]		<=		s_cmd_data[511:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_data[511:0]		<=		s_fifo_rdat[511:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& ( s_fifo_empty == 1'b0 || sr_tx_last_flag == 1'b1 )
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_data[511:0]		<=		s_tx_data[511:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& s_fifo_empty == 1'b0
					&& sr_tx_tvalid == 1'b0
					&& sr_tx_cnt[4:0] == 5'b0_0000 )begin
			sr_tx_data[511:0]		<=		s_tx_data[511:0];
		end
	end

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_data_tmp[511:0]		<=		512'd0;
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_data_tmp[511:0]		<=		{ 448'd0, s_fifo_rdat[575:512] };
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& ( s_fifo_empty == 1'b0 || sr_tx_last_flag == 1'b1 )
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000 )begin
			case( sr_tx_data_sel[3:0] )
				4'b1000	:	sr_tx_data_tmp[511:0]		<=		{ 448'd0, s_fifo_rdat[575:512] };
				4'b0000	:	sr_tx_data_tmp[511:0]		<=		{ 384'd0, s_fifo_rdat[575:448] };
				4'b0001	:	sr_tx_data_tmp[511:0]		<=		{ 320'd0, s_fifo_rdat[575:384] };
				4'b0010	:	sr_tx_data_tmp[511:0]		<=		{ 256'd0, s_fifo_rdat[575:320] };
				4'b0011	:	sr_tx_data_tmp[511:0]		<=		{ 192'd0, s_fifo_rdat[575:256] };
				4'b0100	:	sr_tx_data_tmp[511:0]		<=		{ 128'd0, s_fifo_rdat[575:192] };
				4'b0101	:	sr_tx_data_tmp[511:0]		<=		{  64'd0, s_fifo_rdat[575:128] };
				4'b0110	:	sr_tx_data_tmp[511:0]		<=		{         s_fifo_rdat[575:64] };
				default	:	sr_tx_data_tmp[511:0]		<=		512'd0;
			endcase
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK && s_fifo_empty == 1'b0
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			case( sr_tx_data_sel[3:0] )
				4'b1000	:	sr_tx_data_tmp[511:0]		<=		{ 448'd0, s_fifo_rdat[575:512] };
				4'b0000	:	sr_tx_data_tmp[511:0]		<=		{ 384'd0, s_fifo_rdat[575:448] };
				4'b0001	:	sr_tx_data_tmp[511:0]		<=		{ 320'd0, s_fifo_rdat[575:384] };
				4'b0010	:	sr_tx_data_tmp[511:0]		<=		{ 256'd0, s_fifo_rdat[575:320] };
				4'b0011	:	sr_tx_data_tmp[511:0]		<=		{ 192'd0, s_fifo_rdat[575:256] };
				4'b0100	:	sr_tx_data_tmp[511:0]		<=		{ 128'd0, s_fifo_rdat[575:192] };
				4'b0101	:	sr_tx_data_tmp[511:0]		<=		{  64'd0, s_fifo_rdat[575:128] };
				4'b0110	:	sr_tx_data_tmp[511:0]		<=		{         s_fifo_rdat[575:64] };
				default	:	sr_tx_data_tmp[511:0]		<=		512'd0;
			endcase
		end
	end

	// 送信データ終了信号保持 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_data_last_flag			<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_INIT )begin
			sr_tx_data_last_flag			<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_data_last_flag			<=		s_fifo_rdat[576];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_rden == 1'b1 )begin
			sr_tx_data_last_flag			<=		s_fifo_rdat[576];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK && s_fifo_rden == 1'b1
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_data_last_flag			<=		s_fifo_rdat[576];
		end
	end
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_last_flag			<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_INIT )begin
			sr_tx_last_flag			<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_last_flag			<=		s_fifo_rdat[576];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_rden == 1'b1 )begin
			if( sr_tx_data_sel[3:0] == 4'b0110
				&& ( sr_rx_req_st == 1'b1 || sr_rx_req_end == 1'b1
						|| sr_tx_wait == 1'b1 ))begin
				sr_tx_last_flag			<=		1'b1;
			end else begin
				sr_tx_last_flag			<=		s_fifo_rdat[576];
			end
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK && s_fifo_rden == 1'b1
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			if( sr_tx_data_sel[3:0] == 4'b0110
				&& ( sr_rx_req_st == 1'b1 || sr_rx_req_end == 1'b1
						|| sr_tx_wait == 1'b1 ))begin
				sr_tx_last_flag			<=		1'b1;
			end else begin
				sr_tx_last_flag			<=		s_fifo_rdat[576];
			end
		end
	end
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_last_flag_f		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_INIT )begin
			sr_tx_last_flag_f		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_last_flag_f		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_last_flag_f		<=		sr_tx_last_flag;
		end
	end

	// 送信データ選択カウント信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_data_sel[3:0]		<=		4'b0000;
		end else if( sr_tx_state[4:0] == `TX_DATA_RD )begin
			sr_tx_data_sel[3:0]		<=		4'b0000;
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& ( s_fifo_empty == 1'b0 || sr_tx_last_flag == 1'b1 )
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			if( sr_tx_data_sel[3:0] == 4'b1000 )begin
				sr_tx_data_sel[3:0]		<=		4'b0000;
			end else begin
				sr_tx_data_sel[3:0]		<=		sr_tx_data_sel[3:0] + 4'b0001;
			end
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& s_fifo_empty == 1'b0
					&& sr_tx_tvalid == 1'b0
					&& sr_tx_cnt[4:0] == 5'b0_0000 )begin
			if( sr_tx_data_sel[3:0] == 4'b1000 )begin
				sr_tx_data_sel[3:0]		<=		4'b0000;
			end else begin
				sr_tx_data_sel[3:0]		<=		sr_tx_data_sel[3:0] + 4'b0001;
			end
		end
	end

	// 送信データ信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK || sr_tx_state[4:0] == `TX_DATA_CHK )
					&& sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1 && s_tx_tready == 1'b1 )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
		end else if( sr_tx_state[4:0] == `TX_CMD_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		s_cmd_data[A_DATA_BITS-1:0];
		end else if( sr_tx_state[4:0] == `TX_BUFF_ST || sr_tx_state[4:0] == `TX_BUFF_END
						|| sr_tx_state[4:0] == `TX_REST )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		s_cmd_data[A_DATA_BITS-1:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_RD && s_fifo_empty == 1'b0 )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		s_fifo_rdat[A_DATA_BITS-1:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& ( s_fifo_empty == 1'b0 || sr_tx_last_flag == 1'b1 )
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		s_tx_data[A_DATA_BITS-1:0];
		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tdata[A_DATA_BITS-1:0]		<=		s_tx_data[A_DATA_BITS-1:0];
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK || sr_tx_state[4:0] == `TX_DATA_CHK
						|| sr_tx_state[4:0] == `TX_BUFF_CHK || sr_tx_state[4:0] == `TX_REST_CHK )
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1 )begin
			if( A_DATA_BITS == 512 )begin
					sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
			end else if( A_DATA_BITS == 256 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1:A_DATA_BITS*1];
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else if( A_DATA_BITS == 192 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1:A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{ 64'd0, sr_tx_data[511   :384          ] };
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else if( A_DATA_BITS == 128 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1:A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*3-1:A_DATA_BITS*2];
					5'b0_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*4-1:A_DATA_BITS*3];
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else if( A_DATA_BITS == 64 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1:A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*3-1:A_DATA_BITS*2];
					5'b0_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*4-1:A_DATA_BITS*3];
					5'b0_0011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*5-1:A_DATA_BITS*4];
					5'b0_0100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*6-1:A_DATA_BITS*5];
					5'b0_0101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*7-1:A_DATA_BITS*6];
					5'b0_0110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*8-1:A_DATA_BITS*7];
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else if( A_DATA_BITS == 48 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1 :A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*3-1 :A_DATA_BITS*2];
					5'b0_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*4-1 :A_DATA_BITS*3];
					5'b0_0011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*5-1 :A_DATA_BITS*4];
					5'b0_0100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*6-1 :A_DATA_BITS*5];
					5'b0_0101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*7-1 :A_DATA_BITS*6];
					5'b0_0110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*8-1 :A_DATA_BITS*7];
					5'b0_0111	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*9-1 :A_DATA_BITS*8];
					5'b0_1000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*10-1:A_DATA_BITS*9];
					5'b0_1001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{ 16'd0, sr_tx_data[511    :480          ] };
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else if( A_DATA_BITS == 32 )begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1 :A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*3-1 :A_DATA_BITS*2];
					5'b0_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*4-1 :A_DATA_BITS*3];
					5'b0_0011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*5-1 :A_DATA_BITS*4];
					5'b0_0100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*6-1 :A_DATA_BITS*5];
					5'b0_0101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*7-1 :A_DATA_BITS*6];
					5'b0_0110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*8-1 :A_DATA_BITS*7];
					5'b0_0111	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*9-1 :A_DATA_BITS*8];
					5'b0_1000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*10-1:A_DATA_BITS*9];
					5'b0_1001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*11-1:A_DATA_BITS*10];
					5'b0_1010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*12-1:A_DATA_BITS*11];
					5'b0_1011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*13-1:A_DATA_BITS*12];
					5'b0_1100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*14-1:A_DATA_BITS*13];
					5'b0_1101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*15-1:A_DATA_BITS*14];
					5'b0_1110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*16-1:A_DATA_BITS*15];
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end else begin
				case( sr_tx_cnt[4:0] )
					5'b0_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*2-1 :A_DATA_BITS*1];
					5'b0_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*3-1 :A_DATA_BITS*2];
					5'b0_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*4-1 :A_DATA_BITS*3];
					5'b0_0011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*5-1 :A_DATA_BITS*4];
					5'b0_0100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*6-1 :A_DATA_BITS*5];
					5'b0_0101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*7-1 :A_DATA_BITS*6];
					5'b0_0110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*8-1 :A_DATA_BITS*7];
					5'b0_0111	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*9-1 :A_DATA_BITS*8];
					5'b0_1000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*10-1:A_DATA_BITS*9];
					5'b0_1001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*11-1:A_DATA_BITS*10];
					5'b0_1010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*12-1:A_DATA_BITS*11];
					5'b0_1011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*13-1:A_DATA_BITS*12];
					5'b0_1100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*14-1:A_DATA_BITS*13];
					5'b0_1101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*15-1:A_DATA_BITS*14];
					5'b0_1110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*16-1:A_DATA_BITS*15];
					5'b0_1111	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*17-1:A_DATA_BITS*16];
					5'b1_0000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*18-1:A_DATA_BITS*17];
					5'b1_0001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*19-1:A_DATA_BITS*18];
					5'b1_0010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*20-1:A_DATA_BITS*19];
					5'b1_0011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*21-1:A_DATA_BITS*20];
					5'b1_0100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*22-1:A_DATA_BITS*21];
					5'b1_0101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*23-1:A_DATA_BITS*22];
					5'b1_0110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*24-1:A_DATA_BITS*23];
					5'b1_0111	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*25-1:A_DATA_BITS*24];
					5'b1_1000	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*26-1:A_DATA_BITS*25];
					5'b1_1001	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*27-1:A_DATA_BITS*26];
					5'b1_1010	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*28-1:A_DATA_BITS*27];
					5'b1_1011	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*29-1:A_DATA_BITS*28];
					5'b1_1100	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*30-1:A_DATA_BITS*29];
					5'b1_1101	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*31-1:A_DATA_BITS*30];
					5'b1_1110	:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		sr_tx_data[A_DATA_BITS*32-1:A_DATA_BITS*31];
					default		:	sr_tx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
				endcase
			end
		end
	end

	// 送信データ有効信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_tvalid		<=		1'b0;
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK || sr_tx_state[4:0] == `TX_DATA_CHK
						|| sr_tx_state[4:0] == `TX_BUFF_CHK || sr_tx_state[4:0] == `TX_REST_CHK )
					&& sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1
					&& s_tx_tready == 1'b1 )begin
			sr_tx_tvalid		<=		1'b0;

		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& s_tx_tready == 1'b1 && sr_tx_tvalid == 1'b1
					&& s_fifo_empty == 1'b1 && sr_tx_last_flag == 1'b0
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_tvalid		<=		1'b0;

		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tvalid		<=		1'b1;

		end else if(( sr_tx_state[4:0] == `TX_CMD_RD || sr_tx_state[4:0] == `TX_DATA_RD )
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tvalid		<=		1'b1;

		end else if( sr_tx_state[4:0] == `TX_BUFF_ST
					|| sr_tx_state[4:0] == `TX_BUFF_END
					|| sr_tx_state[4:0] == `TX_REST )begin
			sr_tx_tvalid		<=		1'b1;

		end
	end

	// 送信データ終了信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_tlast		<=		1'b0;
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK || sr_tx_state[4:0] == `TX_DATA_CHK
						|| sr_tx_state[4:0] == `TX_BUFF_CHK || sr_tx_state[4:0] == `TX_REST_CHK )
					&& sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1
					&& s_tx_tready == 1'b1 )begin
			sr_tx_tlast		<=		1'b0;

		end else if( A_DATA_BITS == 512 && sr_tx_state[4:0] == `TX_CMD_RD
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tlast		<=		1'b1;
		end else if( A_DATA_BITS == 512 && sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_last_flag == 1'b1
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_tlast		<=		1'b1;
		end else if( A_DATA_BITS == 512 && sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_last_flag == 1'b1
					&& sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tlast		<=		1'b1;
		end else if( A_DATA_BITS == 512
					 && ( sr_tx_state[4:0] == `TX_BUFF_ST
							|| sr_tx_state[4:0] == `TX_BUFF_END
							|| sr_tx_state[4:0] == `TX_REST ))begin
			sr_tx_tlast		<=		1'b1;

		end else if( A_DATA_BITS != 512
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_cnt[4:0] == ( s_tx_cnt_max[4:0] - 5'b0_0001 )
					&& ( sr_tx_state[4:0] == `TX_CMD_CHK
							|| sr_tx_state[4:0] == `TX_BUFF_CHK
							|| sr_tx_state[4:0] == `TX_REST_CHK ))begin
			sr_tx_tlast		<=		1'b1;
		end else if( A_DATA_BITS != 512 && sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b1 && s_tx_tready == 1'b1
					&& sr_tx_last_flag_f == 1'b1
					&& sr_tx_cnt[4:0] == ( s_tx_cnt_max[4:0] - 5'b0_0001 ))begin
			sr_tx_tlast		<=		1'b1;
		end
	end

	// 送信データバイト有効信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b0}};
		end else if(( sr_tx_state[4:0] == `TX_CMD_CHK || sr_tx_state[4:0] == `TX_DATA_CHK
						|| sr_tx_state[4:0] == `TX_BUFF_CHK || sr_tx_state[4:0] == `TX_REST_CHK )
					&& sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1
					&& s_tx_tready == 1'b1 )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b0}};

		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& s_tx_tready == 1'b1 && sr_tx_tvalid == 1'b1
					&& s_fifo_empty == 1'b1 && sr_tx_last_flag == 1'b0
					&& sr_tx_cnt[4:0] == s_tx_cnt_max[4:0] )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b0}};

		end else if( sr_tx_state[4:0] == `TX_DATA_CHK
					&& sr_tx_tvalid == 1'b0 && sr_tx_cnt[4:0] == 5'b0_0000
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b1}};

		end else if(( sr_tx_state[4:0] == `TX_CMD_RD || sr_tx_state[4:0] == `TX_DATA_RD )
					&& s_fifo_empty == 1'b0 )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b1}};

		end else if( sr_tx_state[4:0] == `TX_BUFF_ST
					|| sr_tx_state[4:0] == `TX_BUFF_END
					|| sr_tx_state[4:0] == `TX_REST )begin
			sr_tx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b1}};
		end
	end

	// 送信ステート //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_tx_state[4:0]		<=		`TX_INIT;
		end else begin
			case ( sr_tx_state[4:0] )
				`TX_INIT			:	if( sr_aurora_ok == 1'b1 && sr_tx_wait == 1'b0
											&& s_s_req[7:0] != 8'h00 )begin
											sr_tx_state[4:0]		<=		`TX_CMD_RD;
										end else begin
											sr_tx_state[4:0]		<=		`TX_INIT;
										end

				`TX_CMD_RD			:	sr_tx_state[4:0]		<=		`TX_CMD_CHK;
				`TX_CMD_CHK			:	if( sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1 && s_tx_tready == 1'b1 )begin
											if( sr_rd_sel[2:0] == 3'b010 || sr_rd_sel[2:0] == 3'b011 )begin
												sr_tx_state[4:0]		<=		`TX_DATA_RD;
											end else if( s_s_req[7:0] != 8'h00 )begin
												sr_tx_state[4:0]		<=		`TX_INIT;
											end else begin
												sr_tx_state[4:0]		<=		`TX_END;
											end
										end else begin
											sr_tx_state[4:0]		<=		`TX_CMD_CHK;
										end

				`TX_DATA_RD			:	if( s_fifo_empty == 1'b0 )begin
											sr_tx_state[4:0]		<=		`TX_DATA_CHK;
										end else begin
											sr_tx_state[4:0]		<=		`TX_DATA_RD;
										end
				`TX_DATA_CHK		:	if( sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1 && s_tx_tready == 1'b1 )begin
											if( sr_rx_req_st == 1'b1 )begin
												sr_tx_state[4:0]		<=		`TX_BUFF_ST;
											end else if( sr_rx_req_end == 1'b1 )begin
												sr_tx_state[4:0]		<=		`TX_BUFF_END;
											end else if( sr_tx_wait == 1'b1 )begin
												sr_tx_state[4:0]		<=		`TX_DATA_WAIT;
											end else if( s_s_req[7:0] != 8'h00 )begin
												sr_tx_state[4:0]		<=		`TX_INIT;
											end else begin
												sr_tx_state[4:0]		<=		`TX_END;
											end
										end else begin
											sr_tx_state[4:0]		<=		`TX_DATA_CHK;
										end
				`TX_DATA_WAIT		:	if( sr_rx_req_st == 1'b1 )begin
											sr_tx_state[4:0]		<=		`TX_BUFF_ST;
										end else if( sr_rx_req_end == 1'b1 )begin
											sr_tx_state[4:0]		<=		`TX_BUFF_END;
										end else if( sr_tx_wait == 1'b0 )begin
											sr_tx_state[4:0]		<=		`TX_REST;
										end else begin
											sr_tx_state[4:0]		<=		`TX_DATA_WAIT;
										end

				`TX_REST			:	sr_tx_state[4:0]		<=		`TX_REST_CHK;
				`TX_REST_CHK		:	if( sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1 && s_tx_tready == 1'b1 )begin
											if( sr_tx_data_last_flag == 1'b1 )begin
												if( s_s_req[7:0] != 8'h00 )begin
													sr_tx_state[4:0]		<=		`TX_INIT;
												end else begin
													sr_tx_state[4:0]		<=		`TX_END;
												end
											end else begin
												sr_tx_state[4:0]		<=		`TX_DATA_RD;
											end
										end else begin
											sr_tx_state[4:0]		<=		`TX_REST_CHK;
										end

				`TX_BUFF_ST			:	sr_tx_state[4:0]		<=		`TX_BUFF_CHK;
				`TX_BUFF_END		:	sr_tx_state[4:0]		<=		`TX_BUFF_CHK;
				`TX_BUFF_CHK		:	if( sr_tx_tvalid == 1'b1 && sr_tx_tlast == 1'b1 && s_tx_tready == 1'b1 )begin
											sr_tx_state[4:0]		<=		`TX_DATA_WAIT;
										end else begin
											sr_tx_state[4:0]		<=		`TX_BUFF_CHK;
										end

				`TX_END				:	sr_tx_state[4:0]		<=		`TX_INIT;
				default				:	sr_tx_state[4:0]		<=		`TX_INIT;
			endcase
		end
	end


	// アクセス種別信号の生成 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rd_sel[2:0]		<=		3'b111;
		end else if( sr_tx_state[4:0] == `TX_INIT && sr_aurora_ok == 1'b1
					&& sr_tx_wait == 1'b0 )begin
			if( s_s_req[7] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b001;
			end else if( s_s_req[6] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b010;
			end else if( s_s_req[5] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b011;
			end else if( s_s_req[4] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b100;
			end else if( s_s_req[3] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b101;
			end else if( s_s_req[2] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b110;
			end else if( s_s_req[1] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0] + 3'b111;
			end else if( s_s_req[0] == 1'b1 )begin
				sr_rd_sel[2:0]		<=		sr_rd_sel[2:0];
			end
		end
	end

	// リクエスト信号の前処理 //
	assign		s_s_req_in[7:0]			=			{ ( S_WADR_FIFO_EMPTY == 1'b0 && s_wr_len_cnt[LEN_CNT_BIT:0] != {1'b1, {LEN_CNT_BIT{1'b0}}} ),
													   ~S_RADR_FIFO_EMPTY,
													  ( S_WDAT_FIFO_EMPTY == 1'b0 && s_wr_len_cnt[LEN_CNT_BIT:0] != {LEN_CNT_BIT+1{1'b0}} ),
													  ( M_RDAT_FIFO_EMPTY == 1'b0 && s_rd_len_cnt[LEN_CNT_BIT:0] != {LEN_CNT_BIT+1{1'b0}} ),
													  sr_rx_req_st, sr_rx_req_end, 2'b00 };

	assign		s_s_req[7:0]			=			( sr_rd_sel[2:0] == 3'b000 ) ? { s_s_req_in[6:0], s_s_req_in[7] }   :
													( sr_rd_sel[2:0] == 3'b001 ) ? { s_s_req_in[5:0], s_s_req_in[7:6] } :
													( sr_rd_sel[2:0] == 3'b010 ) ? { s_s_req_in[4:0], s_s_req_in[7:5] } :
													( sr_rd_sel[2:0] == 3'b011 ) ? { s_s_req_in[3:0], s_s_req_in[7:4] } :
													( sr_rd_sel[2:0] == 3'b100 ) ? { s_s_req_in[2:0], s_s_req_in[7:3] } :
													( sr_rd_sel[2:0] == 3'b101 ) ? { s_s_req_in[1:0], s_s_req_in[7:2] } :
													( sr_rd_sel[2:0] == 3'b110 ) ? { s_s_req_in[0],   s_s_req_in[7:1] } : s_s_req_in[7:0];


//------------------------------------------------------------------------------
// 受信制御部
//------------------------------------------------------------------------------

	// RX信号のラッチ //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_tdata[A_DATA_BITS-1:0]		<=		{A_DATA_BITS{1'b0}};
			sr_rx_tkeep[A_DATA_BITS/8-1:0]		<=		{A_DATA_BITS/8{1'b0}};
			sr_rx_tlast							<=		1'b0;
			sr_rx_tvalid						<=		1'b0;
		end else begin
			sr_rx_tdata[A_DATA_BITS-1:0]		<=		RX_TDATA[A_DATA_BITS-1:0];
			sr_rx_tkeep[A_DATA_BITS/8-1:0]		<=		RX_TKEEP[A_DATA_BITS/8-1:0];
			sr_rx_tlast							<=		RX_TLAST;
			sr_rx_tvalid						<=		RX_TVALID;
		end
	end

	// LEN-BUFFライト信号 //
	assign		s_rd_len_wren				=		( sr_rx_data_frame == 1'b0 && sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
														&& sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] && s_rx_buff_wdata[511:509] == 3'b001 ) ? 1'b1 : 1'b0;

	// LEN-BUFFライトデータ信号 //
	assign		s_rd_len_wdata[15:0]		=		( s_rx_buff_wdata[114:112] == 3'b110 ) ?         s_rx_buff_wdata[95:80]   :
													( s_rx_buff_wdata[114:112] == 3'b101 ) ? { 1'b0, s_rx_buff_wdata[95:81] } :
													( s_rx_buff_wdata[114:112] == 3'b100 ) ? { 2'b0, s_rx_buff_wdata[95:82] } :
													( s_rx_buff_wdata[114:112] == 3'b011 ) ? { 3'b0, s_rx_buff_wdata[95:83] } :
													( s_rx_buff_wdata[114:112] == 3'b010 ) ? { 4'b0, s_rx_buff_wdata[95:84] } : 16'h0000;

	// BUFFリード信号 //
	assign		s_rx_buff_rden				=		s_fifo_wren_f;

	// BUFFライト信号 //
	assign		s_rx_buff_wren				=		( sr_rx_data_frame == 1'b0 && sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
														&& sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] && s_rx_data[511] == 1'b0 )                                         ? 1'b1 :
													( sr_rx_data_frame == 1'b1 && sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
														&& sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] && sr_rx_data_sel[3:0] != 4'b0000  )                                ? 1'b1 : 1'b0;

	// BUFFライトデータ信号 //
	assign		s_rx_buff_wdata[577:0]		=		( sr_rx_data_sel[3:0] == 4'b0000 ) ? { 1'b1, 65'd0, s_rx_data[511:0] }                               :
													( sr_rx_data_sel[3:0] == 4'b0001 ) ? { 1'b0, s_axi_last, s_rx_data[63:0],  sr_rx_buff_wdata[511:0] } :
													( sr_rx_data_sel[3:0] == 4'b0010 ) ? { 1'b0, s_axi_last, s_rx_data[127:0], sr_rx_buff_wdata[447:0] } :
													( sr_rx_data_sel[3:0] == 4'b0011 ) ? { 1'b0, s_axi_last, s_rx_data[191:0], sr_rx_buff_wdata[383:0] } :
													( sr_rx_data_sel[3:0] == 4'b0100 ) ? { 1'b0, s_axi_last, s_rx_data[255:0], sr_rx_buff_wdata[319:0] } :
													( sr_rx_data_sel[3:0] == 4'b0101 ) ? { 1'b0, s_axi_last, s_rx_data[319:0], sr_rx_buff_wdata[255:0] } :
													( sr_rx_data_sel[3:0] == 4'b0110 ) ? { 1'b0, s_axi_last, s_rx_data[383:0], sr_rx_buff_wdata[191:0] } :
													( sr_rx_data_sel[3:0] == 4'b0111 ) ? { 1'b0, s_axi_last, s_rx_data[447:0], sr_rx_buff_wdata[127:0] } :
																						 { 1'b0, s_axi_last, s_rx_data[511:0], sr_rx_buff_wdata[63:0] };

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_buff_wdata[511:0]		<=		512'd0;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1 )begin
			sr_rx_buff_wdata[511:0]		<=		512'd0;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] )begin
			case( sr_rx_data_sel[3:0] )
				4'b0000	:	sr_rx_buff_wdata[511:0]		<=		s_rx_data[511:0];
				4'b0001	:	sr_rx_buff_wdata[511:0]		<=		{  64'd0, s_rx_data[511:64] };
				4'b0010	:	sr_rx_buff_wdata[511:0]		<=		{ 128'd0, s_rx_data[511:128] };
				4'b0011	:	sr_rx_buff_wdata[511:0]		<=		{ 192'd0, s_rx_data[511:192] };
				4'b0100	:	sr_rx_buff_wdata[511:0]		<=		{ 256'd0, s_rx_data[511:256] };
				4'b0101	:	sr_rx_buff_wdata[511:0]		<=		{ 320'd0, s_rx_data[511:320] };
				4'b0110	:	sr_rx_buff_wdata[511:0]		<=		{ 384'd0, s_rx_data[511:384] };
				4'b0111	:	sr_rx_buff_wdata[511:0]		<=		{ 448'd0, s_rx_data[511:448] };
				default	:	sr_rx_buff_wdata[511:0]		<=		512'd0;
			endcase
		end
	end

	// RXデータ数検出信号 //
	assign		s_axi_last					=		( sr_rx_data_cnt_max[15:0] == sr_rx_data_cnt[15:0] ) ? 1'b1 : 1'b0;

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_cnt_max[15:0]		<=		16'h0000;
		end else if( s_rx_buff_wren == 1'b1 && sr_rx_data_frame == 1'b0
					&& ( s_rx_data[511:509] == 3'b010 || s_rx_data[511:509] == 3'b011 ))begin
			sr_rx_data_cnt_max[15:0]		<=		s_rx_data[95:80];
		end
	end

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_cnt[15:0]		<=		16'h0000;
		end else if( s_rx_buff_wren == 1'b1 && sr_rx_data_frame == 1'b0 )begin
			sr_rx_data_cnt[15:0]		<=		16'h0000;
		end else if( s_rx_buff_wren == 1'b1 && sr_rx_data_frame == 1'b1
					&& sr_rx_data_wait == 1'b0 )begin
			sr_rx_data_cnt[15:0]		<=		sr_rx_data_cnt[15:0] + 16'h0001;
		end
	end

	// 受信データ選択カウント信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_sel[3:0]		<=		4'b0000;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1 )begin
			sr_rx_data_sel[3:0]		<=		4'b0000;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_data_wait == 1'b0 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] )begin
			if( sr_rx_data_sel[3:0] == 4'b1000 )begin
				sr_rx_data_sel[3:0]		<=		4'b0000;
			end else begin
				sr_rx_data_sel[3:0]		<=		sr_rx_data_sel[3:0] + 4'b0001;
			end
		end
	end

	// RXデータサイクル検出信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_flag			<=		1'b0;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1
					&& sr_rx_data_frame == 1'b1
					&& sr_rx_data_cnt_max[15:0] <= sr_rx_data_cnt[15:0] )begin
			sr_rx_data_flag						<=		1'b0;
		// Write Data
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_data_sel[3:0] == 4'b0000 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& s_rx_data[511:509] == 3'b010 && sr_rx_data_frame == 1'b0 )begin
			sr_rx_data_flag			<=		1'b1;
		// Read Data
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_data_sel[3:0] == 4'b0000 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& s_rx_data[511:509] == 3'b011 && sr_rx_data_frame == 1'b0 )begin
			sr_rx_data_flag			<=		1'b1;
		end
	end
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_frame		<=		1'b0;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1
					&& sr_rx_data_frame == 1'b1
					&& sr_rx_data_cnt_max[15:0] <= sr_rx_data_cnt[15:0] )begin
			sr_rx_data_frame		<=		1'b0;
		// Write Data
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1
					&& sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_data_sel[3:0] == 4'b0000 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& s_rx_data[511:509] == 3'b010 && sr_rx_data_flag == 1'b0 )begin
			sr_rx_data_frame		<=		1'b1;
		// Read Data
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1
					&& sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_data_sel[3:0] == 4'b0000 && sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& s_rx_data[511:509] == 3'b011 && sr_rx_data_flag == 1'b0 )begin
			sr_rx_data_frame		<=		1'b1;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1
					&& sr_rx_data_flag == 1'b1 )begin
			sr_rx_data_frame		<=		1'b1;
		end
	end
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data_wait		<=		1'b0;
		end else if( sr_rx_data_frame == 1'b1 && sr_rx_data_wait == 1'b1
					&& sr_rx_data_cnt_max[15:0] > sr_rx_data_cnt[15:0]
					&& sr_rx_cnt[4:0] == s_rx_cnt_max[4:0]
					&& sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}}
					&& sr_rx_tvalid == 1'b1 && s_rx_data[511:509] == 3'b110 )begin
			sr_rx_data_wait		<=		1'b0;
		end else if( sr_rx_data_frame == 1'b1 && sr_rx_data_wait == 1'b0
					&& sr_rx_data_cnt_max[15:0] > sr_rx_data_cnt[15:0]
					&& sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1 )begin
			sr_rx_data_wait		<=		1'b1;
		end
	end

	// 受信カウントMAX信号 //
	assign		s_rx_cnt_max[4:0]			=		( A_DATA_BITS == 512 ) ? 5'b0_0000 :
													( A_DATA_BITS == 256 ) ? 5'b0_0001 :
													( A_DATA_BITS == 192 ) ? 5'b0_0010 :
													( A_DATA_BITS == 128 ) ? 5'b0_0011 :
													( A_DATA_BITS ==  64 ) ? 5'b0_0111 :
													( A_DATA_BITS ==  48 ) ? 5'b0_1010 :
													( A_DATA_BITS ==  32 ) ? 5'b0_1111 : 5'b1_1111;

	// 受信カウント信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_cnt[4:0]		<=		5'b0_0000;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tlast == 1'b1 )begin
			sr_rx_cnt[4:0]		<=		5'b0_0000;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}} )begin
			if( sr_rx_cnt[4:0] == s_rx_cnt_max[4:0] )begin
				sr_rx_cnt[4:0]		<=		5'b0_0000;
			end else begin
				sr_rx_cnt[4:0]		<=		sr_rx_cnt[4:0] + 5'b0_0001;
			end
		end
	end

	// 受信データ信号 //
	assign		s_rx_data[511:0]			=		( A_DATA_BITS == 512 ) ?   sr_rx_tdata[A_DATA_BITS-1:0]                                   :
													( A_DATA_BITS == 256 ) ? { sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] }  :
													( A_DATA_BITS == 192 ) ? { sr_rx_tdata[127:0],           sr_rx_data[A_DATA_BITS*2-1:0] }  :
													( A_DATA_BITS == 128 ) ? { sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*3-1:0] }  :
													( A_DATA_BITS ==  64 ) ? { sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*7-1:0] }  :
													( A_DATA_BITS ==  48 ) ? { sr_rx_tdata[31:0],            sr_rx_data[A_DATA_BITS*10-1:0] } :
													( A_DATA_BITS ==  32 ) ? { sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*15-1:0] } :
													( A_DATA_BITS ==  16 ) ? { sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*31-1:0] } : 512'd0;

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_data[511:0]		<=		512'd0;
		end else if( sr_rx_tvalid == 1'b1 && sr_rx_tkeep[A_DATA_BITS/8-1:0] == {A_DATA_BITS/8{1'b1}} )begin
			if( A_DATA_BITS == 512 )begin
				sr_rx_data[511:0]		<=		sr_rx_tdata[A_DATA_BITS-1:0];
			end else if( A_DATA_BITS == 256 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS{1'b0}},    sr_rx_tdata[A_DATA_BITS-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else if( A_DATA_BITS == 192 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ 128'd0, {A_DATA_BITS*2{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ 128'd0,                         sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else if( A_DATA_BITS == 128 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*3{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*2{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					5'b0_0010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*1{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*2-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else if( A_DATA_BITS == 64 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*7{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*6{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					5'b0_0010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*5{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*2-1:0] };
					5'b0_0011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*4{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*3-1:0] };
					5'b0_0100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*3{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*4-1:0] };
					5'b0_0101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*2{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*5-1:0] };
					5'b0_0110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*1{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*6-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else if( A_DATA_BITS == 48 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*9{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*8{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					5'b0_0010	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*7{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*2-1:0] };
					5'b0_0011	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*6{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*3-1:0] };
					5'b0_0100	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*5{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*4-1:0] };
					5'b0_0101	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*4{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*5-1:0] };
					5'b0_0110	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*3{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*6-1:0] };
					5'b0_0111	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*2{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*7-1:0] };
					5'b0_1000	:	sr_rx_data[511:0]		<=		{ 32'd0, {A_DATA_BITS*1{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*8-1:0] };
					5'b0_1001	:	sr_rx_data[511:0]		<=		{ 32'd0,                        sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*9-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else if( A_DATA_BITS == 32 )begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*15{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*14{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					5'b0_0010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*13{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*2-1:0] };
					5'b0_0011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*12{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*3-1:0] };
					5'b0_0100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*11{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*4-1:0] };
					5'b0_0101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*10{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*5-1:0] };
					5'b0_0110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*9{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*6-1:0] };
					5'b0_0111	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*8{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*7-1:0] };
					5'b0_1000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*7{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*8-1:0] };
					5'b0_1001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*6{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*9-1:0] };
					5'b0_1010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*5{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*10-1:0] };
					5'b0_1011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*4{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*11-1:0] };
					5'b0_1100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*3{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*12-1:0] };
					5'b0_1101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*2{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*13-1:0] };
					5'b0_1110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*1{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*14-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end else begin
				case( sr_rx_cnt[4:0] )
					5'b0_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*31{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0] };
					5'b0_0001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*30{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*1-1:0] };
					5'b0_0010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*29{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*2-1:0] };
					5'b0_0011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*28{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*3-1:0] };
					5'b0_0100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*27{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*4-1:0] };
					5'b0_0101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*26{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*5-1:0] };
					5'b0_0110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*25{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*6-1:0] };
					5'b0_0111	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*24{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*7-1:0] };
					5'b0_1000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*23{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*8-1:0] };
					5'b0_1001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*22{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*9-1:0] };
					5'b0_1010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*21{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*10-1:0] };
					5'b0_1011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*20{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*11-1:0] };
					5'b0_1100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*19{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*12-1:0] };
					5'b0_1101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*18{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*13-1:0] };
					5'b0_1110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*17{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*14-1:0] };
					5'b0_1111	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*16{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*15-1:0] };
					5'b1_0000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*15{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*16-1:0] };
					5'b1_0001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*14{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*17-1:0] };
					5'b1_0010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*13{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*18-1:0] };
					5'b1_0011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*12{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*19-1:0] };
					5'b1_0100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*11{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*20-1:0] };
					5'b1_0101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*10{1'b0}}, sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*21-1:0] };
					5'b1_0110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*9{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*22-1:0] };
					5'b1_0111	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*8{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*23-1:0] };
					5'b1_1000	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*7{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*24-1:0] };
					5'b1_1001	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*6{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*25-1:0] };
					5'b1_1010	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*5{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*26-1:0] };
					5'b1_1011	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*4{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*27-1:0] };
					5'b1_1100	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*3{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*28-1:0] };
					5'b1_1101	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*2{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*29-1:0] };
					5'b1_1110	:	sr_rx_data[511:0]		<=		{ {A_DATA_BITS*1{1'b0}},  sr_rx_tdata[A_DATA_BITS-1:0], sr_rx_data[A_DATA_BITS*30-1:0] };
					default		:	sr_rx_data[511:0]		<=		512'd0;
				endcase
			end
		end
	end

	// 受信OK状態送信要求信号 //
	assign		s_rx_buff_chk[8:0]			=		{ {9-BUFF_CNT_BIT{1'b0}}, s_rx_buff_cnt[BUFF_CNT_BIT:0] };

	assign		s_rx_buff_cnt_hi[8:0]		=		( BUFF_WORD == 256 ) ? 9'b0_1000_0111 :
													( BUFF_WORD == 128 ) ? 9'b0_0000_0111 : 9'b1_1111_1111;

	assign		s_rx_buff_cnt_low[8:0]		=		( BUFF_WORD == 256 ) ? 9'b0_1000_0011 :
													( BUFF_WORD == 128 ) ? 9'b0_0000_0011 : 9'b0_0000_0001;

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_req_st	<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_CMD_RD
					&& sr_rd_sel[2:0] == 3'b100 )begin
			sr_rx_req_st		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_BUFF_ST )begin
			sr_rx_req_st		<=		1'b0;
		end else if( s_rx_buff_chk[8:0] >= s_rx_buff_cnt_hi[8:0]
					&& sr_rx_req_st_f == 1'b0 )begin
			sr_rx_req_st		<=		1'b1;
		end
	end
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_req_st_f	<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_CMD_RD
					&& sr_rd_sel[2:0] == 3'b101 )begin
			sr_rx_req_st_f		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_BUFF_END )begin
			sr_rx_req_st_f		<=		1'b0;
		end else if( s_rx_buff_chk[8:0] >= s_rx_buff_cnt_hi[8:0]
					&& sr_rx_req_st_f == 1'b0 )begin
			sr_rx_req_st_f		<=		1'b1;
		end
	end

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_req_end	<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_CMD_RD
					&& sr_rd_sel[2:0] == 3'b101 )begin
			sr_rx_req_end		<=		1'b0;
		end else if( sr_tx_state[4:0] == `TX_BUFF_END )begin
			sr_rx_req_end		<=		1'b0;
		end else if( s_rx_buff_chk[8:0] <= s_rx_buff_cnt_low[8:0]
					&& sr_rx_req_st_f == 1'b1 )begin
			sr_rx_req_end		<=		1'b1;
		end
	end


//------------------------------------------------------------------------------
// 受信FIFO制御部
//------------------------------------------------------------------------------

	// FIFOライト信号 //
	assign		s_fifo_wren					=		( s_fifo_full == 1'b0 && s_rx_buff_cnt[BUFF_CNT_BIT:0] != {BUFF_CNT_BIT+1{1'b0}}
														&& ( s_rx_buff_rdata[511:509] == 3'b000 || s_rx_buff_rdata[511:509] == 3'b001
															||  sr_rx_wr_cycle == 1'b1 || sr_rx_rd_cycle == 1'b1 )) ? 1'b1 : 1'b0;

	assign		s_fifo_wren_f				=		( s_fifo_full == 1'b0 && s_rx_buff_cnt[BUFF_CNT_BIT:0] != {BUFF_CNT_BIT+1{1'b0}} ) ? 1'b1 : 1'b0;

	// FIFOライトデータ信号 //
	assign		s_fifo_wdata[577:0]			=		( s_rx_buff_rdata[577] == 1'b1 ) ? { 66'd0, s_rx_buff_rdata[511:0] } : s_rx_buff_rdata[577:0];

	// FIFOライト選択信号 //
	assign		s_wr_sel[2:0]				=		( sr_rx_wr_cycle == 1'b1 ) ? 3'b010 :
													( sr_rx_rd_cycle == 1'b1 ) ? 3'b011 : s_rx_buff_rdata[511:509];

	// FULL信号選択 //
	assign		s_fifo_full					=		( sr_rx_wr_cycle == 1'b1 )             ? M_WDAT_FIFO_FULL :
													( sr_rx_rd_cycle == 1'b1 )             ? S_RDAT_FIFO_FULL :
													( s_rx_buff_rdata[511:509] == 3'b000 ) ? M_WADR_FIFO_FULL :
													( s_rx_buff_rdata[511:509] == 3'b001 ) ? M_RADR_FIFO_FULL :
													( s_rx_buff_rdata[511:509] == 3'b010 ) ? 1'b0             :
													( s_rx_buff_rdata[511:509] == 3'b011 ) ? 1'b0             :
													( s_rx_buff_rdata[511:509] == 3'b100 ) ? 1'b0             :
													( s_rx_buff_rdata[511:509] == 3'b101 ) ? 1'b0             : 1'b1;

	// RXサイクル検出信号 //
	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_wr_cycle		<=		1'b0;
		end else if( s_fifo_wren_f == 1'b1 && s_rx_buff_rdata[576] == 1'b1 )begin
			sr_rx_wr_cycle		<=		1'b0;
		end else if( s_fifo_wren_f == 1'b1  && s_rx_buff_rdata[577] == 1'b1
					&& s_rx_buff_rdata[511:509] == 3'b010 )begin
			sr_rx_wr_cycle		<=		1'b1;
		end
	end

	always@( posedge AURORA_CLK or negedge AURORA_RESET_N )begin
		if( AURORA_RESET_N == 1'b0 )begin
			sr_rx_rd_cycle		<=		1'b0;
		end else if( s_fifo_wren_f == 1'b1 && s_rx_buff_rdata[576] == 1'b1 )begin
			sr_rx_rd_cycle		<=		1'b0;
		end else if( s_fifo_wren_f == 1'b1  && s_rx_buff_rdata[577] == 1'b1
					&& s_rx_buff_rdata[511:509] == 3'b011 )begin
			sr_rx_rd_cycle		<=		1'b1;
		end
	end



endmodule

